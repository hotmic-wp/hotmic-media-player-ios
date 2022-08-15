Pod::Spec.new do |s|
  s.name             = 'HotMicMediaPlayer'
  s.version          = '4.0.1'
  s.summary          = 'Integrate the HotMic player experience in your app.'
  s.description      = <<-DESC
'HotMicMediaPlayer allows you to integrate the HotMic player experience into your app.'
                       DESC
  s.homepage         = 'https://hotmic.io'
  s.license          = { :type => 'Copyright', :file => 'LICENSE' }
  s.author           = { 'HotMic' => 'info@hotmic.io' }

  s.ios.deployment_target = '12.0'

  s.source = { :git => 'https://github.com/hotmic-wp/hotmic-media-player-ios.git', :tag => s.version.to_s }
  s.vendored_frameworks = 'HotMicMediaPlayer.xcframework'
  s.swift_version = '5.6.1'

  s.dependency 'PubNubSwift', '6.0.0'
  s.dependency 'FittedSheets', '2.4.2'
  s.dependency 'Kingfisher', '7.3.1'
  s.dependency 'BitmovinPlayer', '3.22.0'
  s.dependency 'youtube-ios-player-helper', '1.0.4'
  s.dependency 'TrueTime', '5.0.3'
  s.dependency 'OpenTok', '2.23.0'
  s.dependency 'ShipBookSDK', '1.1.19'

  # Needed to pass lint validation
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
end
