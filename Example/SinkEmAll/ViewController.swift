//
//  ViewController.swift
//  SinkEmAll
//
//  Created by lyzkov on 06/13/2019.
//  Copyright (c) 2019 lyzkov. All rights reserved.
//

import UIKit
import RxSwift
import SinkEmAll

class ViewController: UIViewController {

    let offTarget = PublishSubject<Int>()

    let onTarget = PublishSubject<Int>()

    let emptyValue = PublishSubject<Int>()

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        Observable.merge(offTarget, onTarget, emptyValue)
            .flatMap { choice -> Observable<Void> in
                let result: Observable<Void>
                switch choice {
                case 1: result = .error(SimpleError.unknown)
                case 2: result = .error(RichError.unknown)
                default: result = .just(())
                }
                return result
                    .observeOn(MainScheduler.asyncInstance)
                    .shootError(with: self)
                    .shootError(with: ConsoleErrorLogger(level: .debug))
                    .shootError { error, _ in
                        print("Sinking an error: \(error.localizedDescription)!")
                        return .just(.sink)
                    }
                    .retryThenSinkError(maxAttempts: 0)
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    @IBAction func offTargetTapped(_ sender: UIButton) {
        offTarget.onNext(1)
    }

    @IBAction func onTargetTapped(_ sender: UIButton) {
        onTarget.onNext(2)
    }

    @IBAction func emptyValueTapped(_ sender: UIButton) {
        onTarget.onNext(3)
    }

}

extension ViewController: ErrorShooting {

    func shoot(error: RetriableError, attempt: Int, complete: @escaping (Shot) -> Void) {
        let alert = UIAlertController(title: "", message: "Something wrong happened", preferredStyle: .alert)
        if error.canRetry && attempt < 3 {
            alert.addAction(
                UIAlertAction(title: "Retry", style: .cancel) { _ in
                    complete(.miss)
                }
            )
        }
        alert.addAction(
            UIAlertAction(title: "Rethrow", style: .destructive) { _ in
                complete(.hit(error))
            }
        )
        alert.addAction(
            UIAlertAction(title: "Close", style: .default) { _ in
                complete(.sink)
            }
        )

        present(alert, animated: true)
    }

}

class ConsoleErrorLogger: ErrorShooting {

    public let level: Level

    public init(level: Level) {
        self.level = level
    }

    public func shoot(error: DescribableError, attempt: Int, complete: ((Shot) -> Void)) {
        if let message = error.message(for: level) {
            print("Error Log: \(message)")
        }
        complete(.hit(error))
    }

}

enum SimpleError: Error {
    case unknown
}

enum RichError {
    case unknown
}

extension RichError: RetriableError {

    var canRetry: Bool {
        return true
    }

}

extension RichError: DescribableError {

    func message(for level: Level) -> String? {
        switch level {
        case .debug:
            return "Hello description rich bug!"
        default:
            return "Description rich bug occured!"
        }
    }

}
