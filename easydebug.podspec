#
# Be sure to run `pod lib lint easydebug.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'easydebug'
  s.version          = '1.0.0.0'
  s.summary          = 'easydebug'
  s.description      = <<-DESC
    Debug tool for iOS🚀, Custom log, Network monitoring, CPU/FPS/MEM monitoring, log dashboard...
                       DESC
  s.homepage         = 'https://github.com/rggsix/easydebug'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.source           = { :git => 'git@github.com:rggsix/easydebug.git'}
  s.authors          = {'easydebug' => 'songhengdsg@icloud.com'}
  
  s.ios.deployment_target = '12.0'
    
  s.subspec 'Core' do |core|
    core.source_files = 'Source/Core/**/*'
    core.resource_bundles = {
        'easydebug' => ['Source/Resource/*']
    }
    core.dependency 'FMDB'
  end
  
  s.subspec 'CrashMonitor' do |crash|
    crash.source_files = 'Source/CrashMonitor/**/*'
    crash.dependency 'easydebug/Core'
  end
  
  s.subspec 'NetworkMonitor' do |network|
    network.source_files = 'Source/NetworkMonitor/**/*'
    network.dependency 'easydebug/Core'
  end
  
  s.subspec 'Performance' do |performance|
    performance.source_files = 'Source/Performance/**/*'
    performance.dependency 'easydebug/Core'
  end
end
