//===---*- Greatdori! -*---------------------------------------------------===//
//
// CommandLineEntry.swift
//
// This source file is part of the Greatdori! open source project
//
// Copyright (c) 2025 the Greatdori! project authors
// Licensed under Apache License v2.0
//
// See https://greatdori.com/LICENSE.txt for license information
// See https://greatdori.com/CONTRIBUTORS.txt for the list of Greatdori! project authors
//
//===----------------------------------------------------------------------===//

import Foundation
import ArgumentParser
import SekaiKit

// Modified for Project Sekai: regional names and birthdays come from SekaiKit.

@main
struct CommandLineEntry: AsyncParsableCommand {
    static let configuration = CommandConfiguration(commandName: "SekaiBirthdayCalGen")

    @Option(help: "A directory for output files")
    var output: String
    
    @Option(help: "Optional directory containing character.aar and event.aar (for offline generation)")
    var dataDirectory: String?

    mutating func validate() throws {
        while output.count > 1 && output.hasSuffix("/") {
            output.removeLast()
        }
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: output, isDirectory: &isDirectory) {
            throw ValidationError.noSuchDirectory
        }
        if !isDirectory.boolValue {
            throw ValidationError.notADirectory
        }
    }
    
    mutating func run() async throws {
        print("Initializing...")
        if let dataDirectory {
            try await SekaiProtobuf.$baseURL.withValue(URL(filePath: dataDirectory)) {
                try await generate()
            }
        } else {
            try await generate()
        }
    }

    private func generate() async throws {
        guard let characters = await Character.all(), !characters.isEmpty else {
            throw ValidationError.characterDataUnavailable
        }
        guard let events = await Event.all(), !events.isEmpty else {
            throw ValidationError.eventDataUnavailable
        }
        let tokyoTimeZone = TimeZone(identifier: "Asia/Tokyo")!
        var tokyoCalendar = Calendar(identifier: .gregorian)
        tokyoCalendar.timeZone = tokyoTimeZone
        
        var calendarResult = LocalizedData<String>(_jp: nil, en: nil, tw: nil, cn: nil, kr: nil)
        
        for locale in SekaiLocale.allCases {
            print("Building calendar for \(locale.rawValue)...")
            
            let languageID = localizedLangIdentifier.forLocale(locale)!
            
            let builder = CalendarBuilder()
            builder.emitCalendarStart(
                providerID: "-//GreatSekai//SekaiBirthdayCalGen//EN",
                calendarName: localizedCalendarName.forLocale(locale)!
            )
            
            for character in characters {
                guard let charaName = character.fullName.localizedData?[locale],
                      let month = character.birthday?.month,
                      let day = character.birthday?.day else { continue }
                
                builder.emitEventStart()
                
                // Match the original tool: start with the first event featuring
                // the character, falling back to the game's Japanese launch day.
                let creationDate = events.filter { $0.characters.contains(character.id) }
                    .compactMap { $0.startDate.localizedData?.jp }.min()
                    ?? tokyoCalendar.date(from: DateComponents(year: 2020, month: 9, day: 30))!
                builder.emitDateTimeStamp(creationDate, timeZone: tokyoTimeZone)
                builder.emitUID(stableUUID(from: character.id, locale: locale.rawValue))
                let year = tokyoCalendar.component(.year, from: creationDate)
                var rewrittenBirthday: Date?
                // Validate components so leap-day birthdays never become March 1.
                for candidateYear in year...(year + 8) {
                    guard let date = tokyoCalendar.date(from: DateComponents(year: candidateYear, month: month, day: day)),
                          tokyoCalendar.component(.month, from: date) == month,
                          tokyoCalendar.component(.day, from: date) == day,
                          date >= tokyoCalendar.startOfDay(for: creationDate) else { continue }
                    rewrittenBirthday = date
                    break
                }
                guard let rewrittenBirthday else { throw ValidationError.invalidBirthday(character.id) }
                builder.emitStartDate(rewrittenBirthday, in: tokyoTimeZone, allDay: true)
                
                builder.emitClassification(.public)
                
                let fixedCharaName = locale != .en ? charaName.replacing(" ", with: "") : charaName
                let isAnniversary = SekaiKit.Unit.virtualSinger.members.contains(character.id)
                let prompt = isAnniversary ? localizedAnniversaryPrompt : localizedBirthdayPrompt
                let summaryName = prompt.forLocale(locale)!.replacing("%@", with: fixedCharaName)
                builder.emitSummary(summaryName, language: languageID)
                
                builder.emitTransparency(.transparent)
                
                builder.emitRecurrenceRule(frequency: .yearly, interval: 1, count: nil)
                
                let category = isAnniversary ? localizedAnniversaryCategoryName : localizedCategoryName
                builder.emitCategories([category.forLocale(locale)!], language: languageID)
                
                // === Alarms ===
                
                // First alarm
                builder.emitAlarmStart(description: summaryName)
                builder.emitTrigger(before: true, days: 1, hours: 0, minutes: 0, seconds: 0)
                builder.emitAlarmEnd()
                
                // Second alarm
                builder.emitAlarmStart(description: summaryName)
                builder.emitTrigger(days: 0, hours: 0, minutes: 0, seconds: 0)
                builder.emitAlarmEnd()
                
                // ==============
                
                builder.emitEventEnd()
            }
            
            builder.emitCalendarEnd()
            
            calendarResult[locale] = builder.makeResult()
        }
        
        for locale in SekaiLocale.allCases {
            try calendarResult.forLocale(locale)!
                .write(
                    toFile: "\(output)/BirthdayCalendar_\(locale.rawValue).ics",
                    atomically: true,
                    encoding: .utf8
                )
        }
        
        print("Results have been successfully written to: \(output)")
    }
}

enum ValidationError: Error {
    case notADirectory
    case noSuchDirectory
    case characterDataUnavailable
    case eventDataUnavailable
    case invalidBirthday(Int)
}

func reportError(file: StaticString = #fileID, line: _const Int = #line, column: _const Int = #column) -> Never {
    print("Fatal error: \(file):\(line),\(column)", to: &stderr)
    abort()
}
