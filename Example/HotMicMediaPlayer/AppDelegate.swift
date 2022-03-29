//
//  AppDelegate.swift
//  HotMicMediaPlayer
//
//  Created by Jordan Hipwell on 02/07/2022.
//  Copyright (c) 2022 HotMic. All rights reserved.
//

import UIKit
import StoreKit
import HotMicMediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        #warning("Add your API key and access token below")
        
        HMMediaPlayer.initialize(
            apiKey: "YOUR_API_KEY",
            accessToken: "YOUR_ACCESS_TOKEN"
        )
        HMMediaPlayer.appearanceDelegate = self
        HMMediaPlayer.shareDelegate = self
        HMMediaPlayer.userProfileDelegate = self
        HMMediaPlayer.inAppPurchaseDelegate = self
        HMMediaPlayer.authenticationObserver = self
        HMMediaPlayer.analyticsObserver = self
        
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
        switch textStyle {
        case .body:
            let font = UIFont.systemFont(ofSize: 17)
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: font) // Support dynamic type
        default:
            return nil
        }
    }
    
    func customColor(for colorStyle: HMColorStyle) -> UIColor? {
        // Return a custom color for this style or nil to use the default
        switch colorStyle {
        case .primaryBackground:
            return UIColor { traitCollection in
                if traitCollection.userInterfaceLevel == .elevated {
                    return UIColor.systemBackground // Return your elevated color
                } else {
                    return UIColor.systemBackground // Return your non-elevated color
                }
            }
        default:
            return nil
        }
    }
    
}

extension AppDelegate: HMMediaPlayerShareDelegate {
    
    func getStreamShareText(streamID: String, completion: @escaping (Result<String?, Error>) -> Void) {
        // Call completion with a String or nil if there is no share text
        // Call completion with failure and an Error if an error occurs
        completion(.success(nil))
    }
    
}

extension AppDelegate: HMMediaPlayerUserProfileDelegate {
    
    func getIsFollowingUser(userID: String, completion: @escaping (Result<Bool?, Error>) -> Void) {
        // Determine if the logged in user is following this user
        // Call completion with success true or false or nil if following this user is not supported
        // Call completion with failure and an Error if an error occurs
        completion(.success(nil))
    }
    
    func followOrUnfollowUser(userID: String, follow: Bool, completion: @escaping (Error?) -> Void) {
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
        print("HotMic event \(name) started")
    }
    
    func eventOccurred(name: String, info: [String : Any]) {
        print("HotMic event \(name) occurred: \(info)")
    }
    
}
