Pod::Spec.new do |s|
  s.name             = 'HotMicMediaPlayer'
  s.version          = '8.0.0'
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
  s.swift_version = '5.10'

  s.dependency 'PubNubSwift', '7.3.1'
  s.dependency 'FittedSheets', '2.6.1'
  s.dependency 'Kingfisher', '7.12.0'
  s.dependency 'BitmovinPlayer', '3.66.1'
  s.dependency 'Kronos', '4.3.0'
  s.dependency 'OTXCFramework', '2.28.0'
end
