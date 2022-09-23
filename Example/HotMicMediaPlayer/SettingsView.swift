//
//  SettingsView.swift
//  HotMicMediaPlayer_Example
//
//  Created by Jordan Hipwell on 9/21/22.
//  Copyright © 2022 HotMic. All rights reserved.
//

import SwiftUI
import HotMicMediaPlayer

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Authentication") {
                    HStack {
                        TextField("API Key", text: $viewModel.apiKey, prompt: Text("API Key"))
                        
                        PasteButton(payloadType: String.self) { strings in
                            Task {
                                viewModel.apiKey = strings.first ?? ""
                            }
                        }
                        .labelStyle(.iconOnly)
                        .buttonBorderShape(.capsule)
                    }
                    
                    HStack {
                        TextField("Access Token", text: $viewModel.accessToken, prompt: Text("Access Token"))
                        
                        PasteButton(payloadType: String.self) { strings in
                            Task {
                                viewModel.accessToken = strings.first ?? ""
                            }
                        }
                        .labelStyle(.iconOnly)
                        .buttonBorderShape(.capsule)
                    }
                }
                Section("Appearance") {
                    NavigationLink {
                        FontsView(viewModel: viewModel)
                    } label: {
                        Label("Fonts", systemImage: "textformat")
                    }

                    NavigationLink {
                        ColorsView(viewModel: viewModel)
                    } label: {
                        Label("Colors", systemImage: "paintpalette")
                    }
                }
                Section("Share") {
                    TextField("Stream Share Text", text: $viewModel.streamShareText, prompt: Text("Stream Share Text"))
                }
                Section {
                    Button("Reset") {
                        viewModel.resetAll()
                    }
                    .tint(Color(.systemRed))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(Text("Settings"))
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                    .bold()
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onChange(of: viewModel.apiKey) { _ in
            reinitializeHMMediaPlayer()
        }
        .onChange(of: viewModel.accessToken) { _ in
            reinitializeHMMediaPlayer()
        }
    }
    
    private func reinitializeHMMediaPlayer() {
        HMMediaPlayer.initialize(
            apiKey: viewModel.apiKey,
            accessToken: viewModel.accessToken
        )
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "DidReinitializeHMMediaPlayer"), object: nil)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel())
    }
}
