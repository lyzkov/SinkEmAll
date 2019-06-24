//
//  RetriableError.swift
//  SinkEmAll
//
//  Created by Piotr Bogusław Łyczba on 31/05/2019.
//  Copyright © 2019 lyzkov. All rights reserved.
//

/// An error with fine-grained control over retry behavior.
public protocol RetriableError: Error {
    /// Determines if retry from error instance is possible.
    var canRetry: Bool { get }
}
