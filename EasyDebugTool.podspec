Pod::Spec.new do |s|
  s.name             = 'EasyDebugTool'
  s.version          = '0.1.3'
  s.summary          = 'debug tool for iOS develop.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/RggComing/easydebug'
  # s.screenshots     = ''
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'RggComing' => 'songhengdsg@outlook.com' }
  s.source           = { :git => 'https://github.com/RggComing/easydebug.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = ['easydebug/Classes/**/*.{h,m,a}', 'easydebug/Classes/*.{h,m,a}']
  s.resource = "easydebug/Classes/Assets/easydebug_asset.bundle"

  #s.public_header_files = 'easydebug/Classes/EasyDebugItems/Common/EZDDefine.h'
  s.dependency 'GCDWebServer/WebUploader'
end
