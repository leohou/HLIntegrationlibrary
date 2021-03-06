#
# Be sure to run `pod lib lint HLIntegrationlibrary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'HLIntegrationlibrary'
  s.version          = '0.1.4'
  s.summary          = 'A short description of HLIntegrationlibrary.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/leohou/HLIntegrationlibrary'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'leohou' => 'houli@wesai.com' }
  s.source           = { :git => 'https://github.com/leohou/HLIntegrationlibrary.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

#s.source_files = 'HLIntegrationlibrary/Classes/**/*'
s.source_files = 'Example/HLIntegrationlibrary/Classes/**/*'
#// 设置只依赖一个系统的library
# s.library = 'z'
s.libraries = 'z'
#s.xcconfig = {'HEADER_SEARCH_PATHS' =>'$(SDKROOT)/usr/'}
#s.xcconfig = { 'LIBRARY_SEARCH_PATHS' => '$(PODS_ROOT)/usr/include/**' }
  # s.resource_bundles = {
  #   'HLIntegrationlibrary' => ['HLIntegrationlibrary/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'SystemConfiguration', 'UIKit', 'Security', 'CoreGraphics','CoreTelephony','AdSupport'
  # s.dependency 'AFNetworking', '~> 2.3'
end
