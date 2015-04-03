#
# Be sure to run `pod lib lint DBAccess.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "DBAccess"
  s.version          = "0.1.1"
  s.summary          = "It's a ORM tool for iOS developer that use sqlite more easily."
  s.homepage         = "https://github.com/happiness9721/DBAccess"
  s.license          = 'MIT'
  s.author           = { "Joe" => "t9590345@gmail.com" }
  s.source           = { :git => "https://github.com/happiness9721/DBAccess.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'DBAccess' => ['Pod/Assets/*.png']
  }

  s.library          = "sqlite3.0"
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
