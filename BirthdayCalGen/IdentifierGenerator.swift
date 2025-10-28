//===---*- Greatdori! -*---------------------------------------------------===//
//
// IdentifierGenerator.swift
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

func stableUUID(from id: Int) -> String {
    var result = "greatdor-ipro-ject-tool-birdaycalgen"
    let idString = String(id)
    result.removeLast(idString.count)
    result += idString
    return result
}
