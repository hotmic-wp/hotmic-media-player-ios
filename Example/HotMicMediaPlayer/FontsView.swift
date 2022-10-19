//
//  FontsView.swift
//  HotMicMediaPlayer_Example
//
//  Created by Jordan Hipwell on 9/22/22.
//  Copyright © 2022 HotMic. All rights reserved.
//

import SwiftUI
import HotMicMediaPlayer

struct FontsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    @State private var currentTextStyle: HMTextStyle?
    @State private var isShowingFontPicker = false
    
    var body: some View {
        Form {
            Group {
                fontView(style: .largeTitle)
                fontView(style: .title1)
                fontView(style: .title2)
                fontView(style: .title3)
                fontView(style: .headline)
            }
            Group {
                fontView(style: .body)
                fontView(style: .highlightedBody)
                fontView(style: .callout)
                fontView(style: .subheadline)
                fontView(style: .footnote)
                fontView(style: .caption1)
                fontView(style: .highlightedCaption1)
                fontView(style: .caption2)
            }
        }
        .navigationTitle("Fonts")
        .toolbar {
            ToolbarItem {
                Button("Reset", role: .destructive) {
                    viewModel.resetFonts()
                }
            }
        }
        .sheet(isPresented: $isShowingFontPicker) {
            FontPicker { descriptor in
                guard let currentTextStyle else { return }
                updateFontDescriptor(descriptor, for: currentTextStyle)
             }
        }
    }
    
    private func fontView(style: HMTextStyle) -> some View {
        let title: String
        let titleFont: Font
        let fontDescriptor: UIFontDescriptor?
        
        switch style {
        case .largeTitle:
            title = "Large Title"
            titleFont = .largeTitle
            fontDescriptor = viewModel.largeTitleFontDescriptor
        case .title1:
            title = "Title 1"
            titleFont = .title
            fontDescriptor = viewModel.title1FontDescriptor
        case .title2:
            title = "Title 2"
            titleFont = .title2
            fontDescriptor = viewModel.title2FontDescriptor
        case .title3:
            title = "Title 3"
            titleFont = .title3
            fontDescriptor = viewModel.title3FontDescriptor
        case .headline:
            title = "Headline"
            titleFont = .headline
            fontDescriptor = viewModel.headlineFontDescriptor
        case .body:
            title = "Body"
            titleFont = .body
            fontDescriptor = viewModel.bodyFontDescriptor
        case .highlightedBody:
            title = "Highlighted Body"
            titleFont = .body
            fontDescriptor = viewModel.highlightedBodyFontDescriptor
        case .callout:
            title = "Callout"
            titleFont = .callout
            fontDescriptor = viewModel.calloutFontDescriptor
        case .subheadline:
            title = "Subheadline"
            titleFont = .subheadline
            fontDescriptor = viewModel.subheadlineFontDescriptor
        case .footnote:
            title = "Footnote"
            titleFont = .footnote
            fontDescriptor = viewModel.footnoteFontDescriptor
        case .caption1:
            title = "Caption 1"
            titleFont = .caption
            fontDescriptor = viewModel.caption1FontDescriptor
        case .highlightedCaption1:
            title = "Highlighted Caption 1"
            titleFont = .caption
            fontDescriptor = viewModel.highlightedCaption1FontDescriptor
        case .caption2:
            title = "Caption 2"
            titleFont = .caption2
            fontDescriptor = viewModel.caption2FontDescriptor
        @unknown default:
            fatalError()
        }
        
        return HStack {
            Text(title)
                .font(titleFont)
            
            Spacer()
            
            Button(fontDescriptor?.postscriptName ?? "Default") {
                currentTextStyle = style
                isShowingFontPicker = true
            }
            .font(fontDescriptor != nil ? Font(UIFont(descriptor: fontDescriptor!, size: 17)) : nil)
        }
    }
    
    private func updateFontDescriptor(_ descriptor: UIFontDescriptor, for style: HMTextStyle) {
        switch style {
        case .largeTitle:
            viewModel.largeTitleFontDescriptor = descriptor
        case .title1:
            viewModel.title1FontDescriptor = descriptor
        case .title2:
            viewModel.title2FontDescriptor = descriptor
        case .title3:
            viewModel.title3FontDescriptor = descriptor
        case .headline:
            viewModel.headlineFontDescriptor = descriptor
        case .body:
            viewModel.bodyFontDescriptor = descriptor
        case .highlightedBody:
            viewModel.highlightedBodyFontDescriptor = descriptor
        case .callout:
            viewModel.calloutFontDescriptor = descriptor
        case .subheadline:
            viewModel.subheadlineFontDescriptor = descriptor
        case .footnote:
            viewModel.footnoteFontDescriptor = descriptor
        case .caption1:
            viewModel.caption1FontDescriptor = descriptor
        case .highlightedCaption1:
            viewModel.highlightedCaption1FontDescriptor = descriptor
        case .caption2:
            viewModel.caption2FontDescriptor = descriptor
        @unknown default:
            break
        }
    }
}

struct FontsView_Previews: PreviewProvider {
    static var previews: some View {
        FontsView(viewModel: SettingsViewModel())
    }
}
