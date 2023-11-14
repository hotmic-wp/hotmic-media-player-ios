Pod::Spec.new do |s|
  s.name             = 'HotMicMediaPlayer'
  s.version          = '5.0.7'
  s.summary          = 'Integrate the HotMic player experience in your app.'
  s.description      = <<-DESC
'HotMicMediaPlayer allows you to integrate the HotMic player experience into your app.'
                       DESC
  s.homepage         = 'https://hotmic.io'
  s.license          = { :type => 'Copyright', :file => 'LICENSE' }
  s.author           = { 'HotMic' => 'info@hotmic.io' }

  s.ios.deployment_target = '14.0'

  s.source = { :git => 'https://github.com/hotmic-wp/hotmic-media-player-ios.git', :tag => s.version.to_s }
  s.vendored_frameworks = 'HotMicMediaPlayer.xcframework'
  s.swift_version = '5.8.1'

  s.dependency 'PubNubSwift', '6.1.0'
  s.dependency 'FittedSheets', '2.5.3'
  s.dependency 'Kingfisher', '7.9.1'
  s.dependency 'BitmovinPlayer', '3.44.2'
  s.dependency 'Kronos', '4.2.2'
  s.dependency 'OTXCFramework', '2.26.0'
end
