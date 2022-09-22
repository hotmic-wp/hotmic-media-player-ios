//
//  SettingsView.swift
//  HotMicMediaPlayer_Example
//
//  Created by Jordan Hipwell on 9/21/22.
//  Copyright © 2022 HotMic. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
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
                Section {
                    Button("Reset", action: viewModel.resetAll)
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
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel())
    }
}
