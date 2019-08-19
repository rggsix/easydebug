#
# Be sure to run `pod lib lint easydebug.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'easydebug'
  s.version          = '0.1.0'
  s.summary          = 'A short description of easydebug.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/RggComing/easydebug'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'RggComing' => 'songhengdsg@sohu.com' }
  s.source           = { :git => 'https://github.com/RggComing/easydebug.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'easydebug/Classes/**/*'
  
  s.resource_bundles = {
      'ImageSource' => ['easydebug/easydebug/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'PLCrashReporter'
#  s.dependency 'PLCrashReporter-DynamicFramework', 'https://github.com/microsoft/PLCrashReporter.git'
  s.dependency 'GCDWebServer/WebUploader'
end
