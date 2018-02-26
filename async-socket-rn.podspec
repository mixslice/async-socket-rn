#
# Be sure to run `pod lib lint async-socket-rn.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name             = 'async-socket-rn'
  s.version          = package['version']
  s.summary          = 'TCP socket pod for react native'


  s.description      = <<-DESC
This pod simply exports a js bridge for react native to use asyncSocket
                       DESC

  s.homepage         = 'https://github.com/bensonz/async-socket-rn'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bensonz' => 'mr.bz@hotmail.com' }
  s.source           = { :git => 'https://github.com/bensonz/async-socket-rn.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.platform     = :ios, "8.0"

  s.source_files = "RNAsyncSocket/ios/*.{h,m,swift}"

  s.dependency 'React'
  s.dependency 'CocoaAsyncSocket'
  s.frameworks = 'UIKit'

end
