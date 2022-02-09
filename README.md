# HotMicMediaPlayer

[![CI Status](https://img.shields.io/travis/HotMic/HotMicMediaPlayer.svg?style=flat)](https://travis-ci.org/HotMic/HotMicMediaPlayer)
[![Version](https://img.shields.io/cocoapods/v/HotMicMediaPlayer.svg?style=flat)](https://cocoapods.org/pods/HotMicMediaPlayer)
[![License](https://img.shields.io/cocoapods/l/HotMicMediaPlayer.svg?style=flat)](https://cocoapods.org/pods/HotMicMediaPlayer)
[![Platform](https://img.shields.io/cocoapods/p/HotMicMediaPlayer.svg?style=flat)](https://cocoapods.org/pods/HotMicMediaPlayer)

HotMicMediaPlayer allows you to integrate the HotMic player experience into your app.

Use this framework to get streams, create a HMPlayerViewController for a specific stream, and present it full screen.

## Features

- Watch live broadcast commentator streams in your app
- Rewatch previous streams on demand
- Participate in chat
- Polls
- Tip the host
- Join the host with audio/video
- Light and dark mode support
- Accessibility support including Dynamic Type, VoiceOver, etc

## Requirements

- API Key and JWT Secret: Will be provided by HotMic.
- iOS 12+
    - Integration in iPadOS or macOS apps is not supported.
- Swift UIKit app
    - Integration in Objective-C or SwiftUI apps is not officially supported.
- App is live on the App Store
    - HotMicMediaPlayer uses the UIWebView framework for YouTube playback. Apple does not allow new apps to use UIWebView. This component can also be removed if YouTube playback is not required for the use-case.  
- App uses view controller based status bar appearance
- App supports portrait and landscape orientations
- App disables Bitcode
    - Because HotMicMediaPlayer uses ACRCloud which was built without full Bitcode support, HotMicMediaPlayer must disable Bitcode, and your app must as well.
    
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

To run the example project, clone the repo, and run `pod install` from the Example directory. In the AppDelegate, add your `apiKey` and `accessToken` in the call to initialize HMMediaPlayer. Run the app and a list of streams will be loaded. Select a stream to open the media player experience.

## Installation

HotMicMediaPlayer is available through [CocoaPods](https://cocoapods.org). To install
it, add the following to your Podfile, execute `pod repo update`, then `pod install`:

```ruby
platform :ios, '12.0'
use_frameworks!

source 'https://cdn.cocoapods.org/' # Default global repository
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
- NSCameraUsageDescription - this is required to join the room with video
- NSMicrophoneUsageDescription - this is required to join the room with audio and sync the stream with a TV

### Capabilities

Add the following capabilities to your app’s target:
- Background Modes - Audio, AirPlay, and Picture in Picture

### API Key and Access Token

You will need an API key, provided by HotMic, for your app to use the HotMic service. You will also need to create an access token in the appropriate format. 

### In-App Purchases

HotMic supports two types of in-app purchases in the player experience: tip the host and join the stream. You can support these in your app as well. You will need to configure these in App Store Connect, then be sure to submit them to Apple for review alongside your app update. 

## Usage

### Initialization

Initialize HMMediaPlayer with your API key and access token. This must be done before any other functions are called in HMMediaPlayer, so we recommend performing initialization in your AppDelegate’s `didFinishLaunchingWithOptions` function. If needed, it can be called again later, for example if the token changes.

```swift
import HotMicMediaPlayer

HMMediaPlayer.initialize(apiKey: "YOUR_KEY", accessToken: token)
```

#### API Key

A UUID provided by HotMic. 

#### Access Token

Use any JWT library to create a token. Format is as follows:

```js
accessToken = jwt.sign({identity: {
              user_id: [Consistent ID for user],
              display_name: user.display_name,
              profile_pic: user.profile_pic,
            }}, apiSecret, { expiresIn: '1d'}),
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

### Player View Controller

Initialize a HMPlayerViewController and present it:

```swift
let playerViewController =  HMMediaPlayer.initializePlayerViewController(streamID: streamID, delegate: self, supportsMinimizingToPiP: true)
present(playerViewController, animated: true, completion: nil)
```

Setting the modalPresentationStyle to a value other than fullScreen is not allowed.

The player view controller is presented in portrait mode, then after presentation it will support rotating to landscape. Note that the player may force rotate to portrait in the experience, for example, if a tall sheet needs to be presented.

### Player View Controller Delegate

Implement the HMPlayerViewControllerDelegate protocol to dismiss the player when needed, such as when the user taps a button to dismiss. A PiP view is provided which allows you to place it into a custom Picture-in-Picture like the HotMic app does -- we utilize the PIPKit library. If you’d like to support this, initialize a player view controller with supportsMinimizingToPiP true, then store this view controller in a strongly held property to prevent it from deallocating. When you wish to restore the player full-screen, provide the player view to move back into the player view controller and present the player view controller again. Be sure to set the view controller property to nil when the user wishes to close the player or PiP.

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

To support returning to the full-screen player experience from PiP, call HMPlayerViewController’s restorePiPView(:) function and then present the player view controller full screen:
 
 ```swift
func pipViewControllerDidTapFullScreen(_ viewController: PIPViewController) {
    guard let playerViewController = playerViewController else { return }
    
    playerViewController.restorePiPView(viewController.contentView)
    
    PIPKit.dismiss(animated: true)
    
    playerViewController.modalPresentationStyle = .fullScreen
    present(playerViewController, animated: true, completion: nil)
}
```

To be informed when the user taps an ad in the stream, implement the following HMPlayerViewControllerDelegate function:

```swift
func playerViewController(_ viewController: HMPlayerViewController, userDidTapAd id: String, streamID streamId: String) {
    // Maybe record it
}
```

### User Profile Delegate

To support following and unfollowing users from inside the HotMic experience, you can implement the HMMediaPlayerUserProfileDelegate protocol. If you do not implement this delegate, the follow/unfollow buttons will not be shown.

```swift
HMMediaPlayer.userProfileDelegate = self
```

When a user profile is shown, the following function is called to get the “is following” state for the currently logged in user. Provide a success result with true if the logged in user is following the provided user, false if they are not following, or nil if follow/unfollow is not available for the provided user. Provide a failure result with an Error if one occurred.

```swift
func getIsFollowingUser(userID: String, completion: @escaping (Result<Bool?, Error>) -> Void) {
    // Fetch the state and call completion
}
```
 
When the user taps the follow or unfollow button, the following function is called allowing you to record the new following state. Provide an Error to the completion handler if one occurs.

```swift
func followOrUnfollowUser(userID: String, follow: Bool, completion: @escaping (Error?) -> Void) {
    // Record the new state and call completion
}
```

### In App Purchase Delegate

To support tipping hosts and joining their streams for a price, you can implement the HMMediaPlayerInAppPurchaseDelegate protocol and integrate it with your StoreKit in-app purchase code. If you do not implement this delegate, users cannot tip hosts, but can still join the host for free.

```swift
HMMediaPlayer.inAppPurchaseDelegate = self
```

When the user opens the tip sheet, the following function will be called to get the SKProducts available to purchase for a host ID. Your app should fetch the products that are applicable to this host from the App Store.

```swift
func getTipProducts(hostID: String, completion: @escaping (Result<[SKProduct], Error>) -> Void) {
    // Fetch the products and call completion
}
```

When the user wishes to purchase a tip, the following function will be called. Your app should initiate the in-app purchase process. If the purchase is successful, your app should then submit the tip purchase information including the App Store receipt via HMMediaPlayer’s submitTipPurchase function. HotMic will verify this purchase is legitimate and record the tip if validated. Be sure to provide an error if one occurs in this process, such as if the device cannot make payments, a purchase is already in progress, the transaction was canceled, the transaction failed, failed to get transaction info, no purchase info was found, failed to verify, or failed to process. The completion handler allows you to specify if you want this error’s localizedDescription to be shown to the user and if a button should be provided to retry submitting their purchase information if that request fails. We strongly recommend persisting the purchase information on the device and avoid marking the SKPaymentTransaction finished until the purchase has been successfully submitted, as this allows you to retry submitting the information when StoreKit informs you there is a not-yet-finished purchased transaction.

```swift
func purchaseTip(product: SKProduct, userID: String, hostID: String, streamID: String, message: String?, anonymous: Bool, completion: @escaping ((error: Error?, showError: Bool, canRetry: Bool)) -> Void) {
    // Purchase the product then call HMMediaPlayer.submitTipPurchase to record it, or provide an error
}
```

When the user wishes to retry submitting their purchase information, the following function will be called. Your app should look up the purchase information with the provided product identifier and submit it via HMMediaPlayer’s submitTipPurchase function.

```swift
func retrySubmittingPurchaseInfo(productID: String, completion: @escaping ((error: Error?, showError: Bool, canRetry: Bool)) -> Void) {
    // Call HMMediaPlayer.submitTipPurchase to try recording it again
}
```

To support join stream in-app purchases, very similar functions as those for tips are available and should be used in the same way.

In the HotMic app, we found this to be difficult to implement ensuring edge cases are handled. If you reach out to us we would be happy to provide you with more information and example code from our in-app purchase manager that will allow you to implement this the same way we did.

### Analytics Event Observing

To be notified of analytics events as they occur throughout the experience, you can implement the HMMediaPlayerAnalyticsEventObserving protocol. Documentation for event names and info keys and values is not yet available..

```swift
HMMediaPlayer.analyticsObserver = self

func eventStarted(name: String) {
    // Start timing this event by name
}
 
func eventOccurred(name: String, info: [String: Any]) {
    // Stop timing event by name, maybe record the event
}
```
