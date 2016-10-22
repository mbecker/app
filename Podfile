# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'app' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for app
  pod 'AsyncDisplayKit', :path => 'AsyncDisplayKit'
  pod 'Firebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Database'
  pod 'Firebase/Storage'
  pod 'Kingfisher', '~> 3.0'
  pod 'ARNTransitionAnimator'
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git', :branch => 'swift3'
  # pod 'ImagePicker', :git => 'https://github.com/hyperoslo/ImagePicker.git'
  # pod 'ALCameraViewController', :git => 'https://github.com/mbecker/ALCameraViewController.git'
  # pod 'TOCropViewController', :git => 'https://github.com/TimOliver/TOCropViewController.git'
  pod 'Eureka', '~> 2.0.0-beta.1'


  target 'appTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'appUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
