//
//  StandardError.swift
//  BirthdayCalGen
//
//  Created by Mark Chan on 10/28/25.
//

import Foundation

var stderr = StandardError()

struct StandardError: TextOutputStream, Sendable {
    private static let handle = FileHandle.standardError
    
    public func write(_ string: String) {
        Self.handle.write(Data(string.utf8))
    }
}
