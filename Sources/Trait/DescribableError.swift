//
//  DescribableError.swift
//  SinkEmAll
//
//  Created by Piotr Bogusław Łyczba on 31/05/2019.
//  Copyright © 2019 lyzkov. All rights reserved.
//

/// A level of details.
///
/// - verbose: Verbose level.
/// - debug: Debug level.
/// - info: Info level.
/// - warn: Warn level.
/// - error: Error level.
public enum Level: Int {
    case verbose, debug, info, warn, error
}

/// An error described at various levels of details.
public protocol DescribableError: Error {
    /// Description of an error for a given level of details.
    ///
    /// - Parameter level: A level of details.
    /// - Returns: String description of an error.
    func message(for level: Level) -> String?
}
