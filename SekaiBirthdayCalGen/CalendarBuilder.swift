//===---*- Greatdori! -*---------------------------------------------------===//
//
// CalendarBuilder.swift
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

final class CalendarBuilder {
    init() {}
    
    private var _context: [String] = []
    
    func makeResult() -> String {
        return _context.map { line in
            var folded = ""
            var byteCount = 0
            for scalar in line.unicodeScalars {
                let text = String(scalar)
                if byteCount + text.utf8.count > 75 {
                    folded += "\r\n "
                    byteCount = 1
                }
                folded += text
                byteCount += text.utf8.count
            }
            return folded
        }.joined(separator: "\r\n") + "\r\n"
    }
    
    func emitCalendarStart(providerID: String, calendarName: String?) {
        _context.append("BEGIN:VCALENDAR")
        _context.append("VERSION:2.0")
        _context.append("PRODID:\(providerID)")
        _context.append("CALSCALE:GREGORIAN")
        if let calendarName {
            _context.append("X-WR-CALNAME:\(escaped(calendarName))")
        }
    }
    func emitCalendarEnd() {
        _context.append("END:VCALENDAR")
    }
    
    func emitEventStart() {
        _context.append("BEGIN:VEVENT")
    }
    func emitEventEnd() {
        _context.append("END:VEVENT")
    }
    
    // Date-Time Stamp specifies the date and time
    // that the information associated with the calendar component
    // was last revised in the calendar store.
    func emitDateTimeStamp(_ date: Date, timeZone: TimeZone) {
        let dateString = formalDateString(for: date, in: timeZone)
        _context.append("DTSTAMP:\(dateString)")
    }
    
    func emitUID(_ uid: String) {
        _context.append("UID:\(uid)")
    }
    
    func emitStartDate(_ date: Date, in timeZone: TimeZone, allDay: Bool) {
        if allDay {
            let dateString = formalDayString(for: date, in: timeZone)
            _context.append("DTSTART;VALUE=DATE:\(dateString)")
        } else {
            let dateString = formalDateString(for: date, in: timeZone)
            _context.append("DTSTART:\(dateString)")
        }
    }
    
    func emitEndDate(_ date: Date, in timeZone: TimeZone, allDay: Bool) {
        if allDay {
            let dateString = formalDayString(for: date, in: timeZone)
            _context.append("DTEND;VALUE=DATE:\(dateString)")
        } else {
            let dateString = formalDateString(for: date, in: timeZone)
            _context.append("DTEND:\(dateString)")
        }
    }
    
    func emitClassification(_ class: Classification) {
        _context.append("CLASS:\(`class`.rawValue)")
    }
    
    func emitSummary(_ summary: String, language: String?) {
        var result = "SUMMARY"
        if let language {
            result += ";LANGUAGE=\(language)"
        }
        result += ":\(escaped(summary))"
        _context.append(result)
    }
    
    func emitTransparency(_ transp: Transparency) {
        _context.append("TRANSP:\(transp.rawValue)")
    }
    
    func emitRecurrenceRule(frequency: RecurrenceFrequency, interval: UInt?, count: UInt?) {
        var result = "RRULE:FREQ=\(frequency.rawValue)"
        if let interval {
            result += ";INTERVAL=\(interval)"
        }
        if let count {
            result += ";COUNT=\(count)"
        }
        _context.append(result)
    }
    
    func emitCategories(_ categories: [String], language: String?) {
        var result = "CATEGORIES"
        if let language {
            result += ";LANGUAGE=\(language)"
        }
        result += ":\(categories.map(escaped).joined(separator: ","))"
        _context.append(result)
    }
    
    func emitAlarmStart(description: String) {
        _context.append("BEGIN:VALARM")
        _context.append("ACTION:DISPLAY")
        _context.append("DESCRIPTION:\(escaped(description))")
    }
    func emitAlarmEnd() {
        _context.append("END:VALARM")
    }
    
    func emitTrigger(before: Bool = false, days: UInt, hours: UInt, minutes: UInt, seconds: UInt) {
        var result = "TRIGGER:"
        if before {
            result += "-"
        }
        result += "P"
        if days > 0 {
            result += "\(days)D"
        }
        if hours > 0 || minutes > 0 || seconds > 0 || days == 0 {
            result += "T"
        }
        if hours > 0 {
            result += "\(hours)H"
        }
        if minutes > 0 || hours > 0 {
            result += "\(minutes)M"
        }
        if seconds > 0 || minutes > 0 || hours > 0 || days == 0 {
            result += "\(seconds)S"
        }
        _context.append(result)
    }
    
    func emitURL(_ url: String) {
        _context.append("URL;VALUE=URI:\(url)")
    }
    
    // Modified for standards-compliant text, line folding, and UTC timestamps.
    private func escaped(_ value: String) -> String {
        value.replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: ";", with: "\\;")
            .replacingOccurrences(of: ",", with: "\\,")
    }

    private func formalDateString(for date: Date, in timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return formatter.string(from: date)
    }
    private func formalDayString(for date: Date, in timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
    
    enum Classification: String {
        case `public` = "PUBLIC"
        case `private` = "PRIVATE"
        case confidential = "CONFIDENTIAL"
    }
    // Time Transparency is the characteristic of an event that determines
    // whether it appears to consume time on a calendar.
    // Events that consume actual time for the individual or resource
    // associated with the calendar SHOULD be recorded as OPAQUE,
    // allowing them to be detected by free/busy time searches.
    // Other events, which do not take up the individual's (or resource's) time
    // SHOULD be recorded as TRANSPARENT, making them invisible
    // to free/busy time searches.
    enum Transparency: String {
        case opaque = "OPAQUE"
        case transparent = "TRANSPARENT"
    }
    enum RecurrenceFrequency: String {
        case daily = "DAILY"
        case weekly = "WEEKLY"
        case monthly = "MONTHLY"
        case yearly = "YEARLY"
    }
}
