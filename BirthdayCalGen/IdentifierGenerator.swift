//
//  IdentifierGenerator.swift
//  BirthdayCalGen
//
//  Created by Mark Chan on 10/28/25.
//

import Foundation

func stableUUID(from id: Int) -> String {
    var result = "greatdor-ipro-ject-tool-birdaycalgen"
    let idString = String(id)
    result.removeLast(idString.count)
    result += idString
    return result
}
