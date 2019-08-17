Pod::Spec.new do |s|
  s.name             = 'SinkEmAll'
  s.version          = '0.1.0'
  s.summary          = 'An error handling reactive extension for fine-grained control over Abort, Retry, Fail?'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
An error handling reactive extension for fine-grained control over [Abort, Retry, Fail?](https://en.wikipedia.org/wiki/Abort,_Retry,_Fail%3F)

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
                       DESC

  s.homepage         = 'https://github.com/lyzkov/SinkEmAll'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lyzkov' => 'lyzkov@gmail.com' }
  s.source           = { :git => 'https://github.com/lyzkov/SinkEmAll.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'Sources/**/*'
  s.dependency 'RxSwift', '~> 5'

  s.swift_version = '5.0'
end
