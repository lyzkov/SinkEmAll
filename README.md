# SinkEmAll

An error handling reactive extension for fine-grained control over Abort, Retry, Fail?

> Battleship (also Battleships or Sea Battle) is a guessing game for two players. It is played on ruled grids (paper or board) on which each player's fleet of ships (including battleships) are marked. The locations of the fleets are concealed from the other player. Players alternate turns calling "shots" at the other player's ships, and the objective of the game is to destroy the opposing player's fleet.

## Usage

SinkEmAll extends the way of handling errors in RxSwift. It brings (A)bort, (R)etry, (F)ail? pattern back to the game. Yes, that's the battleship game!

```swift
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
```

Therefore, you can implement `ErrorShooting` protocol in order to take a single shot on target.

```swift
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
```

Take note that shoot function is generic so another error type can be used.

```swift
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
```

After that you can use your instance as a shooter for reactive operator.

```swift
    observableThatErrorsOut
        .shootError(with: viewController)
        .shootError(with: ConsoleErrorLogger(level: .debug))
```

Another example with custom shooter function:

```swift
    observableThatErrorsOut
    	.shootError { error, _ in
            print("Sinking an error: \(error.localizedDescription)")
            return .just(.sink)
        }
```

Please look at `ViewController.swift` file in example project for more examples.

## Example

To run the example project, clone the repo and run `pod install` from the Example directory first.

## TO-DO

- [ ]  Replace completion handlers with dedicated shot observable
- [ ]  Add miss, hit and sink hooks to error traits
- [ ]  Wrap around the underlying error in some ship struct
- [ ]  What about Result type?

[How to enjoy error handling in RxSwift](https://www.notion.so/56aed37191ef4fb28f420a1348a6d2fc)

## Author

Piotr Boguslaw Łyczba, lyzkov@gmail.com

## License

SinkEmAll is available under the MIT license. See the LICENSE file for more info.
