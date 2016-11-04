source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target 'daycation' do
  pod 'Alamofire', '~> 4.0'
  pod 'Crashlytics'
  pod 'DOFavoriteButton', :git => 'https://github.com/seemakamath/DOFavoriteButton', :branch => 'swift3'
  pod 'Dollar', '~> 6.1.0'
  pod 'Eureka', '2.0.0-beta.1'
  pod 'EZSwiftExtensions', '~> 1.7'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'HanekeSwift', :git => 'https://github.com/Haneke/HanekeSwift', :branch => 'feature/swift-3'
  pod 'iCarousel'
  pod 'ICSPullToRefresh', :git => 'https://github.com/icodesign/ICSPullToRefresh.Swift', :branch => 'swift-3.0'
  pod 'p2.OAuth2', '~> 3.0.0'
  pod 'PKHUD', '~> 4.0.0'
  pod 'SnapKit', '~> 3.0.2'
  pod 'youtube-ios-player-helper', '~> 0.1.4'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0.1'
    end
  end
end
