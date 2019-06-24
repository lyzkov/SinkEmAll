Pod::Spec.new do |s|
  s.name             = 'SinkEmAll'
  s.version          = '0.1.0'
  s.summary          = 'An error handling reactive extension for fine-grained control over Abort, Retry, Fail?'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

#  s.description      = <<-DESC
#TODO: Add long description of the pod here.
#                       DESC

  s.homepage         = 'https://github.com/lyzkov/SinkEmAll'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lyzkov' => 'lyzkov@gmail.com' }
  s.source           = { :git => 'https://github.com/lyzkov/SinkEmAll.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'Sources/**/*'
  s.dependency 'RxSwift', '~> 5'

  s.swift_version = '5.0'
end
