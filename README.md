# HotMicMediaPlayer

HotMicMediaPlayer allows you to integrate the HotMic player experience into your app.

Use this framework to get streams, create a `HMPlayerViewController` for a specific stream, and present it full screen.

## Features

- Watch live broadcast commentator streams in your app
- Rewatch previous streams on demand
- Participate in watch parties
- Chat with others
- Answer polls
- Tip the host
- Join the host with audio/video
- Light and dark mode support
- Accessibility support including Dynamic Type, VoiceOver, Switch Control, etc
  - Default system colors provide high contrast variants
  - Dynamic Type support respects the device text size settings
  - Large content viewer is supported for small icon buttons
  - Views are marked as accessibility elements appropriately
  - Accessibility traits are set to identity headings, buttons, selection state, etc 
  - Accessibility labels are added to ensure controls are titled
  - Accessibility hints are added where additional instruction is helpful

## Requirements

- iOS 14+
- Swift app
- App supports portrait and landscape orientations
- App uses view controller based status bar appearance

## App Privacy
When integrating HotMicMediaPlayer into your app, you must disclose the data it and its dependencies collect on the App Store:
- Name - used for product personalization
- Audio data - used for app functionality
- Device ID - used for analytics
- Advertising data - used for developer’s advertising or marketing, analytics, linked to the user’s identity
- Other diagnostics data - used for app functionality, linked to the user’s identity

HotMicMediaPlayer has the following dependencies:
- ACRCloudSDK
- BitmovinPlayer
- FittedSheets
- Kingfisher
- OTXCFramework
- PubNubSwift
- TrueTime

## Example

To try out the example app, run the [CocoaPods](https://cocoapods.org) command `pod try HotMicMediaPlayer`. Alternatively, download or clone the repo and run `pod install` from the Example directory. The example app loads a list of streams and selecting one will open the media player experience.

## Installation

HotMicMediaPlayer is available through [CocoaPods](https://cocoapods.org). To install
it, add the following to your Podfile, run `pod repo update`, then `pod install`.

```ruby
platform :ios, '14.0'
use_frameworks!

source 'https://cdn.cocoapods.org/' # Default global repository
source 'https://github.com/hotmic-wp/hotmic-media-player-cocoapod-specs.git'
source 'https://github.com/bitmovin/cocoapod-specs.git'

target 'YourAppTarget' do
  pod 'HotMicMediaPlayer'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
```

## Setup

### Privacy

Add the following keys to your target’s Info tab:
- `NSCameraUsageDescription` - this is required to join the room with video
- `NSMicrophoneUsageDescription` - this is required to join the room with audio and sync the stream with a TV

### Capabilities

Add the following capabilities to your app’s target:
- Background Modes - Audio, AirPlay, and Picture in Picture

### API Key and Access Token

You will need an API key, a UUID provided by HotMic, for your app to use the HotMic service. You will also need to create an access token using a JWT library - the format is as follows: 

```js
accessToken = jwt.sign({identity: {
               user_id: [Consistent ID for user],
               display_name: user.display_name,
               profile_pic: user.profile_pic,
              }}, apiSecret, { expiresIn: '1d'}),
```

### In-App Purchases

HotMic supports two types of in-app purchases in the player experience: tip the host and join the stream. You can support these in your app as well. You will need to configure these in App Store Connect, then be sure to submit them to Apple for review alongside your app update. 

## Usage

### Initialization

Initialize `HMMediaPlayer` with your API key and access token. This must be done before any other functions are called in `HMMediaPlayer`, so we recommend performing initialization in your `AppDelegate`’s `application(_:didFinishLaunchingWithOptions:)` function. If needed, it can be called again later, for example if the token changes.

```swift
import HotMicMediaPlayer

HMMediaPlayer.initialize(apiKey: "YOUR_KEY", accessToken: token)
```

### Get Streams

You can fetch streams from HotMic that are live, scheduled, and/or video-on-demand replays. You can optionally choose to get streams created by a specific user. Pagination is supported via optional limit and skip parameters. 

```Swift
HMMediaPlayer.getStreams(live: true, scheduled: true, vod: true, userID: nil, limit: nil, skip: nil) { result in
    switch result {
    case .success(let streams):
        // Display the list of streams
    case .failure(let error):
        // Handle error
    }
}
```

You can also fetch a single stream by ID.

```Swift
HMMediaPlayer.getStream(id: id) { result in
    switch result {
    case .success(let stream):
        // Display the stream
    case .failure(let error):
        // Handle error
    }
}
```

`HMStream` contains available stream information, such as:
- `title`: a `String` for the stream's title
- `state`: an `Enum` of either scheduled, vod, live, or ended
- `tags`: an array of `String` set by the creator, for example: `["tag 1", "tag 2"]`
- `thumbnail`: a `URL` for the thumbnail image

### Player View Controller

Initialize a `HMPlayerViewController` and present it.

```swift
let playerViewController = HMMediaPlayer.initializePlayerViewController(streamID: streamID, delegate: self, supportsMinimizingToPiP: true)
present(playerViewController, animated: true, completion: nil)
```

Setting the `modalPresentationStyle` to a value other than `fullScreen` is not allowed.

### Player View Controller Delegate

Implement the `HMPlayerViewControllerDelegate` protocol to support functionality of the player screen.

When the user is finished with the player experience, for example when they tap a button to close the screen, the following function is called allowing you to dismiss it. A PiP view may be provided which allows you to place it into a custom Picture-in-Picture window, such as one provided by the `PIPKit` library. If you’d like to support PiP, initialize a player view controller with `supportsMinimizingToPiP: true`, then store this view controller in a strongly held property to prevent it from deinitializing. When you wish to restore the player full-screen, provide the player view to move back into the player view controller then present it again. Be sure to set the view controller property to `nil` when the user wishes to close the player or PiP.

```swift
func playerViewController(_ viewController: HMPlayerViewController, didFinishWith pipView: UIView?) {
    dismiss(animated: true, completion: nil)
    
    if let pipView {
        let pipViewController = PIPViewController()
        pipViewController.addContentView(pipView)
        PIPKit.show(with: pipViewController)
    } else {
        if PIPKit.isActive {
            PIPKit.dismiss(animated: true) {
                self.playerViewController = nil
            }
        } else {
            playerViewController = nil
        }
    }
}
```

Each time a player is needed, the following function is called allowing you to provide a custom player that implements the `HMPlayer` protocol. Return `nil` if you'd like to use the default player.

```swift
func playerViewController(_ viewController: HMPlayerViewController, playerForAssetAt url: URL) -> HMPlayer? {
    return nil
}
```

### Player View Controller Functions

To support returning to the full-screen player experience from Picture-in-Picture, call `HMPlayerViewController`’s `restorePiPView(_:)` function and then present the player view controller full screen.
 
 ```swift
func pipViewControllerDidTapFullScreen(_ viewController: PIPViewController) {
    guard let playerViewController else { return }
    
    playerViewController.restorePiPView(viewController.contentView)
    
    PIPKit.dismiss(animated: true)
    
    present(playerViewController, animated: true, completion: nil)
}
```

To show a banner ad in the player screen, call `HMPlayerViewController`’s `displayBannerAd(withView:duration:delay:)` function. Provide any `UIView` to display. The view fills the screen width and needs to have a known height such as an intrinsic content size or an Auto Layout constraint that defines a constant height or aspect ratio. If you do not specify a `duration` of time to display the ad, it will be displayed until you hide it. If you do not specify a `delay`, it will be displayed immediately. If you do not specify an `animationDuration`, a default value will be used. If you specify `animationDuration: 0`, it will not animate.

 ```swift
func displayAd() {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.isUserInteractionEnabled = true
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bannerAdTapped(_:))))
    imageView.image = UIImage(named: "ad")
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 3.0/8.0).isActive = true
    playerViewController.displayBannerAd(withView: imageView)
}
```

To remove the banner ad from the player screen, call `HMPlayerViewController`’s `hideBannerAd()` function. If you do not specify an `animationDuration`, a default value will be used. If you specify `animationDuration: 0`, it will not animate.

 ```swift
 func removeAd() {
    playerViewController.hideBannerAd()
}
```

### Player

The `HMPlayer` protocol defines variables and functions you must implement in order to provide a custom player. Your implementation must also store a reference to an `HMPlayerDelegate` and call its functions to inform the delegate when various events occur.

Provide a view to display on-screen.

```swift
var view: UIView { playerView }
```

Provide the playing status.

```swift
var isPlaying: Bool { player.isPlaying }
```

Provide the paused status.

```swift
var isPaused: Bool { player.isPaused }
```
   
Provide the seeking status.

```swift
var isSeeking: Bool { activelySeeking }
```

Provide the mute status.

```swift    
var isMuted: Bool { player.isMuted }
```

Provide the current audio level as a value between 0 and 100.

```swift
var volume: Int { player.volume }
```

Provide the total duration in seconds of the VoD stream or infinity if it’s a live stream.

```swift
var duration: TimeInterval { player.duration }
```

Provide the current playback position in seconds. For a VoD stream, the time ranges between 0 and the duration of the asset. For a live stream, the time is a Unix timestamp denoting the current playback position.

```swift
var time: TimeInterval { player.currentTime }
```
    
Provide the current playback rate as a value between 0 and 2.
```swift
var playbackSpeed: Float { player.playbackSpeed }
```
    
Store the delegate in a weak optional variable to call its functions in the future.

```swift
func setDelegate(_ delegate: HMPlayerDelegate) { self.delegate = delegate }
```

Invoke play.

```swift
func play() { player.play() }
```

Invoke pause.

```swift
func pause() { player.pause() }
```

Turn on volume muted.

```swift
func mute() { player.mute() }
```

Turn off volume muted.

```swift
func unmute() { player.unmute() }
```

Change the audio level.

```swift
func updateVolume(_ volume: Int) { player.volume = volume }
```

Seek to the given playback position for the VoD stream.

```swift
func seek(to time: TimeInterval) {
    guard !player.isLive else { return }
    
    player.seek(time: time)
}
```

Seek by the given time shift offset in seconds from the live edge for the live stream, or seek to the current time plus the given time shift offset for the VoD stream. Return an `HMPlayerLiveTimeShiftError` if the new time shift is too far behind or ahead of the live position. 

```swift
@discardableResult func seek(by timeShiftOffset: TimeInterval) -> HMPlayerLiveTimeShiftError? {
    guard player.isLive else {
        seek(to: time + timeShiftOffset)
        return nil
    }
    
    let newTimeShift = player.timeShift + timeShiftOffset
    
    guard newTimeShift >= player.maxTimeShift else {
        player.timeShift = 0
        return .tooFarBehind
    }
    guard newTimeShift <= 0 else {
        player.timeShift = 0
        return .tooFarAhead
    }
    
    player.timeShift = newTimeShift
    return nil
}
```

Seek the live stream to its 'now' playback time.

```swift
func seekToLive() { player.timeShift = 0 }
```
    
Change the playback rate. A value between 0 and 1 enables slow motion and a value between 1 and 2 enables fast forward.

```swift
func updatePlaybackSpeed(_ playbackSpeed: Float) { player.playbackSpeed = playbackSpeed }
```
    
Prepare for device rotation to begin.

```swift
func beginRotation() { playerView.willRotate() }
```
    
Handle device rotation ended.

```swift
func endRotation() { playerView.didRotate() }
```
    
Prepare to enter fullscreen mode.

```swift
func enterFullscreen() { playerView.enterFullscreen() }
```

Prepare to exit fullscreen mode.

```swift
func exitFullscreen() { playerView.exitFullscreen() }
```

### Player Delegate

The `HMPlayerDelegate` protocol defines functions your `HMPlayer` implementation calls to inform HotMic when various events occur.

Inform the delegate the player invoked play with intention to start/resume playback.

```swift
delegate?.playerDidInvokePlay(self)
```

Inform the delegate the player state changed to playing.

```swift
delegate?.playerPlaying(self)
```

Inform the delegate the player state changed to paused.

```swift
delegate?.playerPaused(self)
```

Inform the delegate the player state changed to buffering.

```swift
delegate?.playerBuffering(self)
```

Inform the delegate the player finished seeking in a live stream by adjusting the time shift.

```swift
delegate?.playerDidFinishSeekByTimeShift(self)
```

Inform the delegate the player recovered from a stall due to sufficient buffer.

```swift
delegate?.playerDidRecoverFromStall(self)
```

Inform the delegate the player's playback position changed.

```swift
delegate?.player(self, timeChanged time: player.currentTime)
```

Inform the delegate the player's duration changed.

```swift
delegate?.player(self, durationChanged duration: player.duration)
```

Inform the delegate the player encountered an error.

```swift
delegate?.player(self, errorOccurredWithCode code: error.code, message: error.localizedDescription)
```

### Appearance Delegate

To customize the appearance of the HotMic experience, you can implement the `HMMediaPlayerAppearanceDelegate` protocol.

```swift
HMMediaPlayer.appearanceDelegate = self
```

Each time a font will be used, the following function is called allowing you to return a custom font for the specified style. Return `nil` if you'd like to use the default font.

```swift
func customFont(for textStyle: HMTextStyle) -> UIFont? {
    switch textStyle {
    case .body:
        let font = UIFont(name: "CustomFont", size: 16)!
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: font) // Support dynamic type
    //...
    @unknown default: 
        return nil
    }
}
```

Each time a color will be used, the following function is called allowing you to return a custom color for the specified style. Return `nil` if you'd like to use the default color.

```swift
func customColor(for colorStyle: HMColorStyle) -> UIColor? {
    switch colorStyle {
    case .primaryTint:
        return UIColor(named: "AccentColor")
    case .primaryBackground:
        // Background colors support elevation variants
        return UIColor { traitCollection in
            if traitCollection.userInterfaceLevel == .elevated {
                return UIColor(named: "PrimaryBackgroundColorElevated")
            } else {
                return UIColor(named: "PrimaryBackgroundColor")
            }
        }
    //...
    @unknown default: 
        return nil
    }
}
```

Each time a customizable image will be used, the following function is called allowing you to return a custom image for the specified type. Return `nil` if you'd like to use the default image.

```swift
func customImage(for imageType: HMImageType) -> UIImage? {
    switch image {
    case .joinButton: 
        return UIImage(named: "join-button-image")
    case .syncButton: 
        return UIImage(named: "sync-button-image")
    @unknown default: 
        return nil
    }
}
```

### Share Delegate

To support share functionality if the stream does not already have share text, you can implement the `HMMediaPlayerShareDelegate` protocol. If you do not implement this delegate, no text will be shared when the stream does not have share text.

```swift
HMMediaPlayer.shareDelegate = self
```

When the stream is loaded, the following function is called to get the share text for the stream if it does not already have share text. Provide a success result with a `String` or `nil` if there’s no text available to share. Provide a failure result with an `Error` if one occurred.

```swift
func getStreamShareText(streamID: String, completion: @escaping (Result<String?, Error>) -> Void) {
    // Fetch the text and call completion
}
```

### User Profile Delegate

To support user profile functionality, you can implement the `HMMediaPlayerUserProfileDelegate` protocol. If you do not implement this delegate, profile info will be obtained by HotMic rather than your app, and buttons such as follow/unfollow will not be available.

```swift
HMMediaPlayer.userProfileDelegate = self
```

When a user's profile info is to be shown, the following function is called allowing you to provide that user's information. Provide a success result with an `HMUserProfile` containing information such as their name, profile pic, followers count, following count, if they're following the current user, and if they're followed by the current user. Provide `nil` for any values that are unavailable. For example, if `followingCount` is `nil` the number of people this user follows will not be shown, and if `followedByMe` is `nil` the follow/unfollow button will not be shown. Or provide a success result with `nil` if you would like the profile info to be provided by HotMic rather than your app. Provide a failure result with an `Error` if one occurred.

```swift
func getUserProfile(for id: String, restriction: String?, isHost: Bool, isCohost: Bool, completion: @escaping (Result<HMUserProfile?, Error>) -> Void) {
    // Fetch the profile info and call completion
}
```
 
When the user taps the follow/unfollow button, the following function is called allowing you to record the new following state. Provide an `Error` to the completion handler if one occurs.

```swift
func setFollowingUser(id: String, following: Bool, completion: @escaping (Error?) -> Void) {
    // Record the new state and call completion
}
```

When the user profile is shown, the following function is called allowing you to specify whether the See Full Profile button should be shown.

```swift
func shouldShowSeeFullProfileButton(for id: String) -> Bool {
    return true
}
```

When the user taps the See Full Profile button, the following function is called allowing you to handle this action, for example by presenting a view controller.

```swift
func seeFullProfileButtonTapped(for id: String, in viewController: UIViewController) {
    // Show the full profile
}
```

### In App Purchase Delegate

To support tipping hosts and joining their streams for a price, you can implement the `HMMediaPlayerInAppPurchaseDelegate` protocol and integrate it with your `StoreKit` in-app purchase code. If you do not implement this delegate, users cannot tip hosts, but can still join the host for free.

```swift
HMMediaPlayer.inAppPurchaseDelegate = self
```

When the user opens the tip sheet, the following function is called to get the `SKProduct`s available to purchase for a host ID. Your app should fetch the products that are applicable to this host from the App Store.

```swift
func getTipProducts(hostID: String, completion: @escaping (Result<[SKProduct], Error>) -> Void) {
    // Fetch the products and call completion
}
```

When the user wishes to purchase a tip, the following function is called. Your app should initiate the in-app purchase process. If the purchase is successful, your app should then submit the tip purchase information including the App Store receipt via `HMMediaPlayer`’s `submitTipPurchase()` function. HotMic will verify this purchase is legitimate and record the tip if validated. Be sure to provide an error if one occurs in this process, such as if the device cannot make payments, a purchase is already in progress, the transaction was canceled, the transaction failed, failed to get transaction info, no purchase info was found, failed to verify, or failed to process. The completion handler allows you to specify if you want this error’s `localizedDescription` to be shown to the user and if a button should be provided to retry submitting their purchase information if that request fails. We strongly recommend persisting the purchase information on the device and avoid marking the `SKPaymentTransaction` finished until the purchase has been successfully submitted, as this allows you to retry submitting the information when `StoreKit` informs you there is a not-yet-finished purchased transaction.

```swift
func purchaseTip(product: SKProduct, userID: String, hostID: String, streamID: String, message: String?, anonymous: Bool, completion: @escaping ((error: Error?, showError: Bool, canRetry: Bool)) -> Void) {
    // Purchase the product then call HMMediaPlayer.submitTipPurchase to record it
    // Call completion with an error or nil
}
```

When the user wishes to retry submitting their purchase information, the following function is called. Your app should look up the purchase information with the provided product identifier and submit it via `HMMediaPlayer`’s `submitTipPurchase()` function.

```swift
func retrySubmittingPurchaseInfo(productID: String, completion: @escaping ((error: Error?, showError: Bool, canRetry: Bool)) -> Void) {
    // Call HMMediaPlayer.submitTipPurchase to try recording it again
    // Call completion with an error or nil
}
```

To support join stream in-app purchases, very similar functions as those for tips are available and should be used in the same way.

In the HotMic app, we found this to be difficult to implement ensuring edge cases are handled. If you reach out to us we would be happy to provide you with more information and example code from our in-app purchase manager that will allow you to implement this the same way we did.

### Authentication Observing

To be notified of authentication events as they occur, you can implement the `HMMediaPlayerAuthenticationObserving` protocol. 

```swift
HMMediaPlayer.authenticationObserver = self
```

When a request fails due to improper authentication, the following function is called. It’s recommended to dismiss the player and request re-authentication.

```swift
func authenticationStatusChangedToUnauthenticated() {
    // Dismiss the player and re-authenticate
}
```

When the user attempts to perform a restricted action, the following function is called allowing you to handle this event, for example by presenting a view controller. Return `true` if you handle it or `false` if you'd like HotMic to handle it by informing the user this action is restricted.

```swift
func userDidAttemptRestrictedAction(_ action: HMRestrictedAction, in viewController: UIViewController) -> Bool {
    // Return true or false
}
```

### Analytics Event Observing

To be notified of analytics events as they occur, you can implement the `HMMediaPlayerAnalyticsEventObserving` protocol. [SDK Analytics Documentation](https://docs.hotmic.io/sdk-analytics)

```swift
HMMediaPlayer.analyticsObserver = self

func eventStarted(name: String) {
    // Start timing this event by name
}
 
func eventOccurred(name: String, info: [String: Any]) {
    // Stop timing event by name and/or record the event
}
```
