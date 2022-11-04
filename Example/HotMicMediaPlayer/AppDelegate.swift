//
//  AppDelegate.swift
//  HotMicMediaPlayer
//
//  Created by Jordan Hipwell on 02/07/2022.
//  Copyright (c) 2022 HotMic. All rights reserved.
//

import UIKit
import SwiftUI
import AVFoundation
import StoreKit
import HotMicMediaPlayer
import LocalConsole

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let settingsViewModel = SettingsViewModel()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        HMMediaPlayer.initialize(apiKey: settingsViewModel.apiKey, accessToken: settingsViewModel.accessToken)
        HMMediaPlayer.appearanceDelegate = self
        HMMediaPlayer.shareDelegate = self
        HMMediaPlayer.userProfileDelegate = self
        HMMediaPlayer.inAppPurchaseDelegate = self
        HMMediaPlayer.authenticationObserver = self
        HMMediaPlayer.analyticsObserver = self
        
        LCManager.shared.print("Listening for analytics events…")
        
        // Set the desired category and mode of the app's audio session to ensure audio is audible while in Silent Mode (Ring/Silent switch is set to Silent). This also ensures the app can play background audio with the Audio, AirPlay, and Picture in Picture capability enabled.
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback)
        } catch {
            print("Setting AVAudioSession category failed with error: \(error)")
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: HMMediaPlayerAppearanceDelegate {
    
    func customFont(for textStyle: HMTextStyle) -> UIFont? {
        // Return a custom font for this style or nil to use the default
        
        func scaledFont(descriptor: UIFontDescriptor?, textStyle: UIFont.TextStyle, defaultSize: CGFloat) -> UIFont? {
            guard let descriptor else { return nil }
            
            let font = UIFont(descriptor: descriptor, size: defaultSize)
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font) // Support dynamic type
        }
        
        switch textStyle {
        case .largeTitle:
            return scaledFont(descriptor: settingsViewModel.largeTitleFontDescriptor, textStyle: .largeTitle, defaultSize: 34)
        case .title1:
            return scaledFont(descriptor: settingsViewModel.title1FontDescriptor, textStyle: .title1, defaultSize: 28)
        case .title2:
            return scaledFont(descriptor: settingsViewModel.title2FontDescriptor, textStyle: .title2, defaultSize: 22)
        case .title3:
            return scaledFont(descriptor: settingsViewModel.title3FontDescriptor, textStyle: .title3, defaultSize: 20)
        case .headline:
            return scaledFont(descriptor: settingsViewModel.headlineFontDescriptor, textStyle: .headline, defaultSize: 17)
        case .body:
            return scaledFont(descriptor: settingsViewModel.bodyFontDescriptor, textStyle: .body, defaultSize: 17)
        case .highlightedBody:
            return scaledFont(descriptor: settingsViewModel.highlightedBodyFontDescriptor, textStyle: .body, defaultSize: 17)
        case .callout:
            return scaledFont(descriptor: settingsViewModel.calloutFontDescriptor, textStyle: .callout, defaultSize: 16)
        case .subheadline:
            return scaledFont(descriptor: settingsViewModel.subheadlineFontDescriptor, textStyle: .subheadline, defaultSize: 15)
        case .footnote:
            return scaledFont(descriptor: settingsViewModel.footnoteFontDescriptor, textStyle: .footnote, defaultSize: 13)
        case .caption1:
            return scaledFont(descriptor: settingsViewModel.caption1FontDescriptor, textStyle: .caption1, defaultSize: 12)
        case .highlightedCaption1:
            return scaledFont(descriptor: settingsViewModel.highlightedCaption1FontDescriptor, textStyle: .caption1, defaultSize: 12)
        case .caption2:
            return scaledFont(descriptor: settingsViewModel.caption2FontDescriptor, textStyle: .caption2, defaultSize: 11)
        @unknown default:
            return nil
        }
    }
    
    func customColor(for colorStyle: HMColorStyle) -> UIColor? {
        // Return a custom color for this style or nil to use the default
        
        func uiColor(for color: Color?) -> UIColor? {
            if let color {
                return UIColor(color)
            }
            return nil
        }
        
        func traitCollectionOptimizedUIColor(for color: Color?, elevatedColor: Color?) -> UIColor? {
            if let color, let elevatedColor {
                return UIColor { traitCollection in
                    return traitCollection.userInterfaceLevel == .elevated ? UIColor(elevatedColor) : UIColor(color)
                }
            } else if let color {
                return UIColor(color)
            }
            return nil
        }
        
        switch colorStyle {
        case .primary:
            return uiColor(for: settingsViewModel.primaryColor)
        case .secondary:
            return uiColor(for: settingsViewModel.secondaryColor)
        case .tertiary:
            return uiColor(for: settingsViewModel.tertiaryColor)
        case .primaryTint:
            return uiColor(for: settingsViewModel.primaryTintColor)
        case .secondaryTint:
            return uiColor(for: settingsViewModel.secondaryTintColor)
        case .tertiaryTint:
            return uiColor(for: settingsViewModel.tertiaryTintColor)
        case .primaryTintContent:
            return uiColor(for: settingsViewModel.primaryTintContentColor)
        case .secondaryTintContent:
            return uiColor(for: settingsViewModel.secondaryTintContentColor)
        case .tertiaryTintContent:
            return uiColor(for: settingsViewModel.tertiaryTintContentColor)
        case .warningTint:
            return uiColor(for: settingsViewModel.warningTintColor)
        case .errorTint:
            return uiColor(for: settingsViewModel.errorTintColor)
        case .successTint:
            return uiColor(for: settingsViewModel.successTintColor)
        case .liveTint:
            return uiColor(for: settingsViewModel.liveTintColor)
        case .separator:
            return uiColor(for: settingsViewModel.separatorColor)
        case .highlightedFill:
            return uiColor(for: settingsViewModel.highlightedFillColor)
        case .selectedFill:
            return uiColor(for: settingsViewModel.selectedFillColor)
        case .selectedPollAnswerFill:
            return uiColor(for: settingsViewModel.selectedPollAnswerFillColor)
        case .primaryBackground:
            return traitCollectionOptimizedUIColor(for: settingsViewModel.primaryBackgroundColor, elevatedColor: settingsViewModel.primaryBackgroundElevatedColor)
        case .secondaryBackground:
            return traitCollectionOptimizedUIColor(for: settingsViewModel.secondaryBackgroundColor, elevatedColor: settingsViewModel.secondaryBackgroundElevatedColor)
        case .tertiaryBackground:
            return traitCollectionOptimizedUIColor(for: settingsViewModel.tertiaryBackgroundColor, elevatedColor: settingsViewModel.tertiaryBackgroundElevatedColor)
        @unknown default:
            return nil
        }
    }
    
}

extension AppDelegate: HMMediaPlayerShareDelegate {
    
    func getStreamShareText(streamID: String, completion: @escaping (Result<String?, Error>) -> Void) {
        // Call completion with a String or nil if there is no share text
        // Call completion with failure and an Error if an error occurs
        if !settingsViewModel.streamShareText.isEmpty {
            completion(.success(settingsViewModel.streamShareText))
        } else {
            completion(.success(nil))
        }
    }
    
}

extension AppDelegate: HMMediaPlayerUserProfileDelegate {
    
    func getUserFollowState(id: String, completion: @escaping (Result<HMUserFollowState, Error>) -> Void) {
        // Get the user's follow state: followers count, following count, if they're following the current user, and if they're followed by the current user
        // Call completion with an HMUserFollowState specifying nil for any unsupported values
        // Call completion with failure and an Error if an error occurs
        let followState = HMUserFollowState(followersCount: 100, followingCount: 100, followingMe: false, followedByMe: false)
        completion(.success(followState))
    }
    
    func setFollowingUser(id: String, following: Bool, completion: @escaping (Error?) -> Void) {
        // Follow or unfollow this user
        // Call completion with nil or an Error
        completion(nil)
    }
    
}

extension AppDelegate: HMMediaPlayerInAppPurchaseDelegate {
    
    func getTipProducts(hostID: String, completion: @escaping (Result<[SKProduct], Error>) -> Void) {
        // Fetch the products and call completion
        completion(.success([]))
    }
    
    func getJoinStreamProduct(hostID: String, userID: String, completion: @escaping (Result<SKProduct?, Error>) -> Void) {
        // Fetch the product and call completion
        completion(.success(nil))
    }
    
    func purchaseTip(product: SKProduct, userID: String, hostID: String, streamID: String, message: String?, anonymous: Bool, completion: @escaping ((error: Error?, showError: Bool, canRetry: Bool)) -> Void) {
        // Purchase the product then call HMMediaPlayer.submitTipPurchase to record it
        // Call completion with an error or nil
        completion((error: nil, showError: false, canRetry: false))
    }
    
    func purchaseJoinStream(product: SKProduct, userID: String, streamID: String, streamType: String, completion: @escaping ((error: Error?, showError: Bool, canRetry: Bool)) -> Void) {
        // Purchase the product then call HMMediaPlayer.submitJoinStreamPurchase to record it
        // Call completion with an error or nil
        completion((error: nil, showError: false, canRetry: false))
    }
    
    func retrySubmittingPurchaseInfo(productID: String, completion: @escaping ((error: Error?, showError: Bool, canRetry: Bool)) -> Void) {
        // Call HMMediaPlayer.submitTipPurchase to try recording it again
        // Call completion with an error or nil
        completion((error: nil, showError: false, canRetry: false))
    }
    
}

extension AppDelegate: HMMediaPlayerAuthenticationObserving {
    
    func authenticationStatusChangedToUnauthenticated() {
        print("Unauthenticated")
    }
    
}

extension AppDelegate: HMMediaPlayerAnalyticsEventObserving {
    
    func eventStarted(name: String) {
        print("Analytics event \(name) started")
        LCManager.shared.print("\(name) started")
    }
    
    func eventOccurred(name: String, info: [String : Any]) {
        print("Analytics event \(name) occurred: \(info)")
        LCManager.shared.print("\(name) occurred: \(info)")
    }
    
}
