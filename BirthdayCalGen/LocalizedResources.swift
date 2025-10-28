//
//  LocalizedResources.swift
//  BirthdayCalGen
//
//  Created by Mark Chan on 10/28/25.
//

import DoriKit
import Foundation

let localizedCalendarName = LocalizedData(
    _jp: "ガルパ誕生日",
    en: "GBP Birthdays",
    tw: "GBP生日",
    cn: "GBP生日",
    kr: "GBP생일"
)

let localizedCategoryName = LocalizedData(
    _jp: "誕生日",
    en: "Birthday",
    tw: "生日",
    cn: "生日",
    kr: "생일"
)

let localizedTimeZone = LocalizedData(
    _jp: TimeZone(identifier: "Asia/Tokyo")!,
    en: TimeZone(secondsFromGMT: 0)!,
    tw: TimeZone(identifier: "Asia/Taipei")!,
    cn: TimeZone(identifier: "Asia/Shanghai")!,
    kr: TimeZone(identifier: "Asia/Seoul")!
)

let localizedBirthdayPrompt = LocalizedData(
    _jp: "%@の誕生日",
    en: "%@’s Birthday",
    tw: "%@的生日",
    cn: "%@的生日",
    kr: "%@의생일"
)

let localizedLangIdentifier = LocalizedData(
    _jp: "ja_JP",
    en: "en_US",
    tw: "zh_TW",
    cn: "zh_CN",
    kr: "ko_KR"
)
