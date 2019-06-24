//
//  ErrorShooting.swift
//  SinkEmAll
//
//  Created by Piotr Bogusław Łyczba on 29/05/2019.
//  Copyright © 2019 lyzkov. All rights reserved.
//

/// Definition of a single attempt of handling error.
/// That's the battleship game: you can miss, hit, or sink on target.
///
/// - miss: Attempt the operation again. (R)etry
/// - hit: Throw an error to the next handler in the chain of responsibility. (A)bort or (I)gnore
/// - sink: Gracefully recover from an error. (F)ail
public enum Shot {
    case miss
    case hit(Error)
    case sink
}

/// Enables a class to handle a target error, completing an attempt with shot on target.
public protocol ErrorShooting: class {
    associatedtype Target

    /// Handles a target error completing an attempt with a shot on target.
    ///
    /// - Parameters:
    ///   - error: Target error instance.
    ///   - attempt: Number of attempt.
    ///   - complete: Completion handler getting a shot on target.
    func shoot(error: Target, attempt: Int, complete: @escaping (Shot) -> Void)
}
