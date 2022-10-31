//
//  SettingsViewModel.swift
//  HotMicMediaPlayer_Example
//
//  Created by Jordan Hipwell on 9/22/22.
//  Copyright © 2022 HotMic. All rights reserved.
//

import SwiftUI

@MainActor final class SettingsViewModel: ObservableObject {
    
    @Published var apiKey = "90598599-fe2a-435f-b074-e494f2f5c60b"
    @Published var accessToken = "eyJhbGciOiJIUzI1NiJ9.eyJpZGVudGl0eSI6eyJ1c2VyX2lkIjoiM2Q1NTY3YzItNjAzYy00YjA4LWI5MTctN2U5ZjA1YzhlYmI1IiwiZGlzcGxheV9uYW1lIjoidGVzdGVyMSIsInByb2ZpbGVfcGljIjoiaHR0cHM6Ly91aS1hdmF0YXJzLmNvbS9hcGkvP25hbWU9dGVzdCZiYWNrZ3JvdW5kPTBEQ0FENiZjb2xvcj1mZmYiLCJiYWRnZSI6Imh0dHBzOi8vaG90bWljLWNvbnRlbnQuczMudXMtd2VzdC0xLmFtYXpvbmF3cy5jb20vYmFkZ2VzLzEwX2JhZGdlLnBuZz9jMjUxZmVjZS1jMDhmLTQ4YTAtOTMxZS03MGNmZThlYTdlZDQifSwiaWF0IjoxNjU3NjU4NTU1LCJleHAiOjE4MjE3MjQwMTR9.dXzoaMkWN8rp6bZ9Z-Zhit5c4rqoWTWRHIVHm2fKluk"
    
    @Published var largeTitleFontDescriptor: UIFontDescriptor?
    @Published var title1FontDescriptor: UIFontDescriptor?
    @Published var title2FontDescriptor: UIFontDescriptor?
    @Published var title3FontDescriptor: UIFontDescriptor?
    @Published var headlineFontDescriptor: UIFontDescriptor?
    @Published var bodyFontDescriptor: UIFontDescriptor?
    @Published var highlightedBodyFontDescriptor: UIFontDescriptor?
    @Published var calloutFontDescriptor: UIFontDescriptor?
    @Published var subheadlineFontDescriptor: UIFontDescriptor?
    @Published var footnoteFontDescriptor: UIFontDescriptor?
    @Published var caption1FontDescriptor: UIFontDescriptor?
    @Published var highlightedCaption1FontDescriptor: UIFontDescriptor?
    @Published var caption2FontDescriptor: UIFontDescriptor?
    
    @Published var primaryColor: Color?
    @Published var secondaryColor: Color?
    @Published var tertiaryColor: Color?
    @Published var primaryTintColor: Color?
    @Published var secondaryTintColor: Color?
    @Published var tertiaryTintColor: Color?
    @Published var primaryTintContentColor: Color?
    @Published var secondaryTintContentColor: Color?
    @Published var tertiaryTintContentColor: Color?
    @Published var warningTintColor: Color?
    @Published var errorTintColor: Color?
    @Published var successTintColor: Color?
    @Published var liveTintColor: Color?
    @Published var separatorColor: Color?
    @Published var highlightedFillColor: Color?
    @Published var selectedFillColor: Color?
    @Published var selectedPollAnswerFillColor: Color?
    @Published var primaryBackgroundColor: Color?
    @Published var secondaryBackgroundColor: Color?
    @Published var tertiaryBackgroundColor: Color?
    @Published var primaryBackgroundElevatedColor: Color?
    @Published var secondaryBackgroundElevatedColor: Color?
    @Published var tertiaryBackgroundElevatedColor: Color?
    
    @Published var streamShareText = ""
    
    @Published var isAnalyticsOverlayEnabled = false
    
    func resetAll() {
        apiKey = ""
        accessToken = ""
        
        resetFonts()
        resetColors()
        
        streamShareText = ""
        
        isAnalyticsOverlayEnabled = false
    }
    
    func resetFonts() {
        largeTitleFontDescriptor = nil
        title1FontDescriptor = nil
        title2FontDescriptor = nil
        title3FontDescriptor = nil
        headlineFontDescriptor = nil
        bodyFontDescriptor = nil
        highlightedBodyFontDescriptor = nil
        calloutFontDescriptor = nil
        subheadlineFontDescriptor = nil
        footnoteFontDescriptor = nil
        caption1FontDescriptor = nil
        highlightedCaption1FontDescriptor = nil
        caption2FontDescriptor = nil
    }
    
    func resetColors() {
        primaryColor = nil
        secondaryColor = nil
        tertiaryColor = nil
        primaryTintColor = nil
        secondaryTintColor = nil
        tertiaryTintColor = nil
        primaryTintContentColor = nil
        secondaryTintContentColor = nil
        tertiaryTintContentColor = nil
        warningTintColor = nil
        errorTintColor = nil
        successTintColor = nil
        liveTintColor = nil
        separatorColor = nil
        highlightedFillColor = nil
        selectedFillColor = nil
        selectedPollAnswerFillColor = nil
        primaryBackgroundColor = nil
        secondaryBackgroundColor = nil
        tertiaryBackgroundColor = nil
        primaryBackgroundElevatedColor = nil
        secondaryBackgroundElevatedColor = nil
        tertiaryBackgroundElevatedColor = nil
    }
    
}
