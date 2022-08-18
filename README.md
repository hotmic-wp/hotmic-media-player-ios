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
- Accessibility support including Dynamic Type, VoiceOver, etc

## Requirements

- iOS 12+ 
- Swift and UIKit-based app
- App uses view controller based status bar appearance
- App supports portrait and landscape orientations
- App disables Bitcode - because HotMicMediaPlayer uses ACRCloud which was built without full Bitcode support, HotMicMediaPlayer must disable Bitcode, and your app must as well.
    
## App Privacy
When integrating HotMicMediaPlayer into your app, you must disclose the data it and its dependencies collect on the App Store:
- Name - used for product personalization
- Audio data - used for app functionality
- Device ID - used for analytics
- Advertising data - used for developer’s advertising or marketing, analytics, linked to the user’s identity
- Other diagnostics data - used for app functionality, linked to the user’s identity

HotMicMediaPlayer has the following dependencies:
- ACRCloudSDK
- youtube-ios-player-helper
- BitmovinPlayer
- TrueTime
- OpenTok
- Shipbook
- PubNub
- FittedSheets
- Kingfisher


## Example

To run the example app, clone the repo and execute `pod install` from the Example directory. In the `AppDelegate`, add your `apiKey` provided by HotMic and generated `accessToken` in the call to initialize `HMMediaPlayer`. Run the app and a list of streams will be loaded. Select a stream to open the media player experience.

## Installation

HotMicMediaPlayer is available through [CocoaPods](https://cocoapods.org). To install
it, add the following to your Podfile, execute `pod repo update`, then `pod install`:

```ruby
platform :ios, '12.0'
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

This will provide an array of `HMStream` containing available stream information, such as:
- `title`: `String`
- `state`: an `Enum` of either scheduled, vod, live, or ended
- `tags`: an array of `String` set by the creator on the stream, for example: `["tag 1", "tag 2"]`
- `thumbnail`: a `URL` for the image

### Player View Controller

Initialize a `HMPlayerViewController` and present it:

```swift
let playerViewController = HMMediaPlayer.initializePlayerViewController(streamID: streamID, delegate: self, supportsMinimizingToPiP: true)
present(playerViewController, animated: true, completion: nil)
```

Setting the `modalPresentationStyle` to a value other than `fullScreen` is not allowed.

The player view controller is presented in portrait mode, then after presentation it will support rotating to landscape. Note that the player may force rotate to portrait in the experience, for example, if a tall sheet needs to be presented.

### Player View Controller Delegate

Implement the `HMPlayerViewControllerDelegate` protocol to dismiss the player when needed, such as when the user taps a button to dismiss. A PiP view is provided which allows you to place it into a custom Picture-in-Picture like the HotMic app does -- we utilize the `PIPKit` library. If you’d like to support this, initialize a player view controller with `supportsMinimizingToPiP` true, then store this view controller in a strongly held property to prevent it from deallocating. When you wish to restore the player full-screen, provide the player view to move back into the player view controller and present the player view controller again. Be sure to set the view controller property to `nil` when the user wishes to close the player or PiP.

```swift
func playerViewController(_ viewController: HMPlayerViewController, didFinishWith pipView: UIView?) {
    dismiss(animated: true, completion: nil)
    
    if let pipView = pipView {
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

### Player View Controller Functions

To support returning to the full-screen player experience from PiP, call `HMPlayerViewController`’s `restorePiPView(_:)` function and then present the player view controller full screen:
 
 ```swift
func pipViewControllerDidTapFullScreen(_ viewController: PIPViewController) {
    guard let playerViewController = playerViewController else { return }
    
    playerViewController.restorePiPView(viewController.contentView)
    
    PIPKit.dismiss(animated: true)
    
    present(playerViewController, animated: true, completion: nil)
}
```

To show a banner ad in the player screen, call `HMPlayerViewController`’s `displayBannerAd(withView:duration:delay:)` function. Provide any `UIView` to display. The view fills the screen width and needs to have a known height such as an intrinsic content size or an Auto Layout constraint that defines a constant height or aspect ratio. If you do not specify a duration of time to display the ad, it will be displayed until you hide it. If you do not specify a delay, it will be displayed immediately.

 ```swift
func displayAd() {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.isUserInteractionEnabled = true
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bannerAdTapped(_:))))
    imageView.image = UIImage(named: "ad")
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 3.0/8.0).isActive = true
    playerViewController.displayBannerAd(withView: imageView, duration: nil, delay: nil)
}
```

To remove the banner ad from the player screen, call `HMPlayerViewController`’s `hideBannerAd()` function.

 ```swift
 func removeAd() {
    playerViewController.hideBannerAd()
}
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
func customColor(for colorStyle: HMColorStyle) -> UIFont? {
    switch colorStyle {
    case .primaryTint:
        return UIColor(named: "AccentColor")!
    case .primaryBackground:
        // Background colors support elevation variants
        return UIColor { traitCollection in
            if traitCollection.userInterfaceLevel == .elevated {
                return UIColor(named: "PrimaryBackgroundColorElevated")!
            } else {
                return UIColor(named: "PrimaryBackgroundColor")!
            }
        }
    //...
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

To support functionality in user profiles, you can implement the `HMMediaPlayerUserProfileDelegate` protocol. If you do not implement this delegate, functionality such as buttons to follow users will not be available.

```swift
HMMediaPlayer.userProfileDelegate = self
```

When a user's follow state is to be shown or the ability to follow a user is to be available, the following function is called to get the follow state of that user relative to the currently logged in user. Provide a success result with an `HMUserFollowState` consisting of their followers count, following count, if they're following the current user, and if they're followed by the current user. Provide `nil` for any values that are unavailable. For example, if `followingCount` is `nil` the number of people this user follows will not be shown, and if `followedByMe` is `nil` the follow/unfollow button will not be shown. Provide a failure result with an `Error` if one occurred.

```swift
func getUserFollowState(id: String, completion: @escaping (Result<HMUserFollowState, Error>) -> Void) {
    // Fetch the state and call completion
}
```
 
When the user taps the follow/unfollow button, the following function is called allowing you to record the new following state. Provide an `Error` to the completion handler if one occurs.

```swift
func setFollowingUser(id: String, following: Bool, completion: @escaping (Error?) -> Void) {
    // Record the new state and call completion
}
```

### In App Purchase Delegate

To support tipping hosts and joining their streams for a price, you can implement the `HMMediaPlayerInAppPurchaseDelegate` protocol and integrate it with your `StoreKit` in-app purchase code. If you do not implement this delegate, users cannot tip hosts, but can still join the host for free.

```swift
HMMediaPlayer.inAppPurchaseDelegate = self
```

When the user opens the tip sheet, the following function will be called to get the `SKProduct`s available to purchase for a host ID. Your app should fetch the products that are applicable to this host from the App Store.

```swift
func getTipProducts(hostID: String, completion: @escaping (Result<[SKProduct], Error>) -> Void) {
    // Fetch the products and call completion
}
```

When the user wishes to purchase a tip, the following function will be called. Your app should initiate the in-app purchase process. If the purchase is successful, your app should then submit the tip purchase information including the App Store receipt via `HMMediaPlayer`’s `submitTipPurchase()` function. HotMic will verify this purchase is legitimate and record the tip if validated. Be sure to provide an error if one occurs in this process, such as if the device cannot make payments, a purchase is already in progress, the transaction was canceled, the transaction failed, failed to get transaction info, no purchase info was found, failed to verify, or failed to process. The completion handler allows you to specify if you want this error’s `localizedDescription` to be shown to the user and if a button should be provided to retry submitting their purchase information if that request fails. We strongly recommend persisting the purchase information on the device and avoid marking the `SKPaymentTransaction` finished until the purchase has been successfully submitted, as this allows you to retry submitting the information when `StoreKit` informs you there is a not-yet-finished purchased transaction.

```swift
func purchaseTip(product: SKProduct, userID: String, hostID: String, streamID: String, message: String?, anonymous: Bool, completion: @escaping ((error: Error?, showError: Bool, canRetry: Bool)) -> Void) {
    // Purchase the product then call HMMediaPlayer.submitTipPurchase to record it
    // Call completion with an error or nil
}
```

When the user wishes to retry submitting their purchase information, the following function will be called. Your app should look up the purchase information with the provided product identifier and submit it via `HMMediaPlayer`’s `submitTipPurchase()` function.

```swift
func retrySubmittingPurchaseInfo(productID: String, completion: @escaping ((error: Error?, showError: Bool, canRetry: Bool)) -> Void) {
    // Call HMMediaPlayer.submitTipPurchase to try recording it again
    // Call completion with an error or nil
}
```

To support join stream in-app purchases, very similar functions as those for tips are available and should be used in the same way.

In the HotMic app, we found this to be difficult to implement ensuring edge cases are handled. If you reach out to us we would be happy to provide you with more information and example code from our in-app purchase manager that will allow you to implement this the same way we did.

### Authentication Observing

To be notified when a request failed due to improper authentication, you can implement the `HMMediaPlayerAuthenticationObserving` protocol. It’s recommended to dismiss the player and request re-authentication when this occurs.

```swift
HMMediaPlayer.authenticationObserver = self

func authenticationStatusChangedToUnauthenticated() {
    // Dismiss the player and re-authenticate
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
