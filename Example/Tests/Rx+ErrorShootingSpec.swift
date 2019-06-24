//
//  Rx+ErrorShootingSpec.swift
//  SinkEmAll_Tests
//
//  Created by BOGU$ on 21/06/2019.
//  Copyright © 2019 lyzkov. All rights reserved.
//

import Quick
import Nimble
import RxSwift
import RxNimble

import SinkEmAll

struct ErrorStub: Error {
}

struct AnotherErrorStub: Error, Equatable {
}

extension AnotherErrorStub: DescribableError {

    func message(for level: Level) -> String? {
        return "Error"
    }

}

class RxErrorShootingSpec: QuickSpec {

    override func spec() {
        describe("shooting the target") {
            context("when the source sequence emits the error") {
                context("and error doesn't conforms to the target type") {
                    it("leaves source sequence disaffected") {
                        let source = Observable<Int>.error(ErrorStub())
                        let result = source.shootError { (_: AnotherErrorStub, _) in
                            .just(.sink)
                        }
                        expect { try result.toBlocking().toArray() }.to(throwError())
                    }
                }
                context("and error conforms to the target type") {
                    it("passes the number of retry attempts to the shooter function") {
                        let source = Observable<Int>.error(ErrorStub())
                        let result = source.shootError { error, attempt in
                            expect(attempt).to(beLessThanOrEqualTo(1))
                            return attempt == 1 ? .just(.sink) : .just(.miss)
                        }
                        expect(result).array.to(beEmpty())
                    }
                    context("and shooter produces missing shot on target") {
                        it("restarts the source sequence") {
                            var isFirst = true
                            let source = Observable<Int>.error(ErrorStub())
                                .catchError { error in
                                    defer {
                                        isFirst = false
                                    }
                                    return isFirst ? .error(error) : .just(2)
                                }
                            let result = source.shootError { error, _ in
                                .just(.miss)
                            }
                            expect(result).array.to(equal([2]))
                        }
                    }
                    context("and shooter produces hitting shot on target") {
                        it("sends an error to the next observer") {
                            let error = ErrorStub()
                            let source = Observable<Int>.error(error)
                            let result = source.shootError { (error: ErrorStub, _) in
                                .just(.hit(error))
                            }
                            expect { try result.toBlocking().toArray() }.to(throwError(error))
                        }
                    }
                    context("and shooter produces sinking shot on target") {
                        it("recovers from an error completing the source sequence gracefully") {
                            let source = Observable<Int>.concat(.just(2), .error(ErrorStub()))
                            let result = source.shootError { error, _ in
                                .just(.sink)
                            }
                            expect(result).array.to(equal([2]))
                            expect { try result.toBlocking().toArray() }.toNot(throwError())
                        }
                    }
                }
            }
            context("when there is no errors in the source sequence") {
                it("leaves source sequence disaffected") {
                    let source = Observable.from([1, 2])
                    let result = source.shootError { error, _ in
                        .just(.hit(error))
                    }
                    expect(result).array.to(equal([1, 2]))
                }
            }
        }
    }

}
