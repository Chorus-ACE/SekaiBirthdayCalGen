//===---*- Greatdori! -*---------------------------------------------------===//
//
// LocalizedResources.swift
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

import SekaiKit
import Foundation

let localizedCalendarName = LocalizedData(
    _jp: "プロセカ誕生日",
    en: "Project Sekai Birthdays",
    tw: "世界計畫生日",
    cn: "世界计划生日",
    kr: "프로젝트 세카이 생일"
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

let localizedAnniversaryPrompt = LocalizedData(
    _jp: "%@の記念日",
    en: "%@’s Anniversary",
    tw: "%@的紀念日",
    cn: "%@的纪念日",
    kr: "%@의 기념일"
)

let localizedAnniversaryCategoryName = LocalizedData(
    _jp: "記念日",
    en: "Anniversary",
    tw: "紀念日",
    cn: "纪念日",
    kr: "기념일"
)

let localizedLangIdentifier = LocalizedData(
    _jp: "ja-JP",
    en: "en-US",
    tw: "zh-TW",
    cn: "zh-CN",
    kr: "ko-KR"
)
