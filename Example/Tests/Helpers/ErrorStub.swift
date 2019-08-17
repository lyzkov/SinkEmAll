//
//  ErrorStub.swift
//  SinkEmAll_Tests
//
//  Created by lyzkov on 17/08/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

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
