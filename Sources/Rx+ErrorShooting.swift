//
//  Rx.swift
//  SinkEmAll
//
//  Created by Piotr Bogusław Łyczba on 13/06/2019.
//  Copyright © 2019 lyzkov. All rights reserved.
//

import RxSwift

public extension ObservableConvertibleType {

    typealias Attempt = Int

    /// Handles a target error in observable sequence with a shooter producing shot on target. That's the battleship game: you can miss, hit or sink on target.
    ///
    /// - Parameter shooter: A function getting a target error and the number of retry attempts as an arguments producing single sequence with missing shot, hitting shot or sinking shot.
    /// - Returns: An observable sequence containing the source sequence's elements, restarted in case of miss, followed by error in case of hit or completed successfully in case of sink.
    func shootError<Target>(shooter: @escaping (Target, Attempt) -> Single<Shot>)
        -> Observable<Element> {
            return _shootError(shooter: shooter)
    }

    /// Handles a swift standard error in observable sequence with a shooter producing shot on target. That's the battleship game: you can miss, hit or sink on target.
    ///
    /// - Parameter shooter: A function getting a target error and the number of retry attempts as an arguments producing single sequence with missing shot, hitting shot or sinking shot.
    /// - Returns: An observable sequence containing the source sequence's elements, restarted in case of miss, followed by error in case of hit or completed successfully in case of sink.
    func shootError(shooter: @escaping (Error, Attempt) -> Single<Shot>)
        -> Observable<Element> {
            return _shootError(shooter: shooter)
    }

    /// Handles a target error with a gun. That's the battleship game: you can miss, hit or sink on target.
    ///
    /// - Parameter shooter: An object that is capable of shooting on target.
    /// - Returns: An observable sequence containing the source sequence's elements, restarted in case of miss, followed by error in case of hit or completed successfully in case of sink.
    func shootError<Shooter, Target>(with shooter: Shooter)
        -> Observable<Element> where Shooter: ErrorShooting, Target == Shooter.Target {
            return _shootError(shooter: shooter.shoot)
    }

    private func _shootError<Target>(shooter: @escaping (Target, Attempt) -> Single<Shot>)
        -> Observable<Element> {
            return asObservable()
                .retryWhen { errors in
                    errors
                        .enumerated()
                        .flatMap { attempt, error -> Single<Shot> in
                            guard let target = error as? Target else {
                                throw error
                            }

                            return shooter(target, attempt)
                        }
                        .takeWhile { shot in
                            switch shot {
                            case .miss:
                                return true
                            case .hit(let target):
                                throw target
                            case .sink:
                                return false
                            }
                        }
                }
    }

}

public extension ObservableConvertibleType {

    /// Immediately retries from retriable error with maximum attempt count. If failed to retry then gracefully completes sequence.
    ///
    /// - Parameters:
    ///   - targetType: Error target type that is sinked.
    ///   - maxAttempts: Maximum number of retry attempts for retriable error.
    /// - Returns: An observable sequence containing the source sequence's elements, completed gracefully in case of retry failure.
    func retryThenSinkError<Target: Error>(targetType: Target.Type, maxAttempts: Int = Int.max) -> Observable<Element> {
        return shootError { (error: RetriableError, attempt) in
                error.canRetry && attempt < maxAttempts - 1 ? .just(.miss) : .just(.sink)
            }
            .shootError { (error: Target, attempt) -> Single<Shot> in
                .just(.sink)
            }
    }

    /// Immediately retries from retriable error with maximum attempt count. If failed to retry then successfully completes sequence.
    ///
    /// - Parameter maxAttempts: Maximum number of retry attempts for retriable error.
    /// - Returns: An observable sequence containing the source sequence's elements, completed gracefully in case of retry failure.
    func retryThenSinkError(maxAttempts: Int = Int.max) -> Observable<Element> {
        return retryThenSinkError(targetType: Error.self, maxAttempts: maxAttempts)
    }

}

fileprivate extension ErrorShooting {

    func shoot(error: Target, attempt: Int) -> Single<Shot> {
        return .create { [weak self] observer in
            self?.shoot(error: error, attempt: attempt) { shot in
                observer(.success(shot))
            }

            return Disposables.create()
        }
    }

}
