source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'

use_modular_headers!

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
         end
    end
  end
end

target 'EasyDebug' do
  pod 'Masonry'
  pod 'AFNetworking'
  pod 'FMDB'
  pod 'EasyDebug', :path => './'
end
