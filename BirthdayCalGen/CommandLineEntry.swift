//
//  CommandLineEntry.swift
//  BirthdayCalGen
//
//  Created by Mark Chan on 10/27/25.
//

import Foundation
import ArgumentParser
@_private(sourceFile: "DoriAPI.swift") import DoriKit

@main
struct CommandLineEntry: AsyncParsableCommand {
    @Option(help: "A directory for output files")
    var output: String
    
    mutating func validate() throws {
        while output.hasSuffix("/") {
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
        guard let characters = await BirthdayCharacter.all() else { reportError() }
        guard let events = await PreviewEvent.all() else { reportError() }
        let tokyoTimeZone = TimeZone(identifier: "Asia/Tokyo")!
        var tokyoCalendar = Calendar(identifier: .gregorian)
        tokyoCalendar.timeZone = tokyoTimeZone
        
        var calendarResult = LocalizedData<String>(_jp: nil, en: nil, tw: nil, cn: nil, kr: nil)
        
        for locale in DoriLocale.allCases {
            print("Building calendar for \(locale.rawValue)...")
            
            let languageID = localizedLangIdentifier.forLocale(locale)!
            
            let builder = CalendarBuilder()
            builder.emitCalendarStart(
                providerID: "com.memz233.Greatdori.BirthdayCalGen",
                calendarName: localizedCalendarName.forLocale(locale)!
            )
            
            for character in characters {
                guard let charaName = character.nickname.forLocale(locale)
                        ?? character.characterName.forLocale(locale) else { continue }
                
                builder.emitEventStart()
                
                var creationDate = Date(timeIntervalSince1970: 0)
                if let event = events.first(where: {
                    $0.characters.contains(where: {
                        $0.characterID == character.id
                    })
                }) {
                    // We find the first event that the character appears,
                    // use its start date as the creation date of calendar event
                    creationDate = event.startAt.jp!
                }
                builder.emitDateTimeStamp(creationDate, timeZone: tokyoTimeZone)
                
                builder.emitUID(stableUUID(from: character.id | locale.rawIntValue << 8))
                
                let birthdayDate = character.birthday
                var rewrittenBirthday = birthdayDate.componentsRewritten(
                    calendar: tokyoCalendar,
                    year: creationDate.components.year!
                )
                if rewrittenBirthday < creationDate {
                    rewrittenBirthday = birthdayDate.componentsRewritten(
                        calendar: tokyoCalendar,
                        year: creationDate.components.year! + 1
                    )
                }
                builder.emitStartDate(rewrittenBirthday, in: tokyoTimeZone, allDay: true)
                
                builder.emitClassification(.public)
                
                let fixedCharaName = locale != .en ? charaName.replacing(" ", with: "") : charaName
                let summaryName = localizedBirthdayPrompt.forLocale(locale)!.replacing("%@", with: fixedCharaName)
                builder.emitSummary(summaryName, language: languageID)
                
                builder.emitTransparency(.transparent)
                
                builder.emitRecurrenceRule(frequency: .yearly, interval: 1, count: nil)
                
                let birthdayCategory = localizedCategoryName.forLocale(locale)!
                builder.emitCategories([birthdayCategory], language: languageID)
                
                // === Alarms ===
                
                // First alarm
                builder.emitAlarmStart()
                builder.emitTrigger(before: true, days: 1, hours: 0, minutes: 0, seconds: 0)
                builder.emitAlarmEnd()
                
                // Second alarm
                builder.emitAlarmStart()
                builder.emitTrigger(days: 0, hours: 0, minutes: 0, seconds: 0)
                builder.emitAlarmEnd()
                
                // ==============
                
                builder.emitEventEnd()
            }
            
            builder.emitCalendarEnd()
            
            calendarResult._set(builder.makeResult(), forLocale: locale)
        }
        
        for locale in DoriLocale.allCases {
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
}

func reportError(file: StaticString = #fileID, line: _const Int = #line, column: _const Int = #column) -> Never {
    print("Fatal error: \(file):\(line),\(column)", to: &stderr)
    abort()
}
