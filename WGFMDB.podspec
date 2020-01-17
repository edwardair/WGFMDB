#
#  Be sure to run `pod spec lint WGFMDB.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "WGFMDB"
  s.version      = "0.8.3"
  s.summary      = "WGFMDB"

  s.description  = <<-DESC
                   简易数据库封装，通过JSONModel互相映射
                   DESC

  s.homepage     = "https://github.com/edwardair/WGFMDB.git"
  s.license      = "LICENSE"
  s.author             = { "Eduoduo" => "550621009@qq.com" }
   s.platform     = :ios, "8.0"
  s.source  = { :git => "https://github.com/edwardair/WGFMDB.git"}
  s.source_files  = "WGFMDB"
  s.dependency 'FMDB', '~> 2.5'
  s.dependency 'WGKit', '~> 0.5.2'
end
