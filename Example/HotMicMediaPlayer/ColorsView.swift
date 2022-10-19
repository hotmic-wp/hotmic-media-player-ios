//
//  ColorsView.swift
//  HotMicMediaPlayer_Example
//
//  Created by Jordan Hipwell on 9/22/22.
//  Copyright © 2022 HotMic. All rights reserved.
//

import SwiftUI

extension Binding {
    func defaultValue<T>(_ value: T) -> Binding<T> where Value == Optional<T> {
        return Binding<T>(
            get: { wrappedValue ?? value },
            set: { wrappedValue = $0 }
        )
    }
}

struct ColorsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        Form {
            Section {
                ColorPicker("Primary", selection: $viewModel.primaryColor.defaultValue(.white))
                ColorPicker("Secondary", selection: $viewModel.secondaryColor.defaultValue(.white))
                ColorPicker("Tertiary", selection: $viewModel.tertiaryColor.defaultValue(.white))
            }
            Section {
                ColorPicker("Primary Tint", selection: $viewModel.primaryTintColor.defaultValue(.white))
                ColorPicker("Secondary Tint", selection: $viewModel.secondaryTintColor.defaultValue(.white))
                ColorPicker("Tertiary Tint", selection: $viewModel.tertiaryTintColor.defaultValue(.white))
            }
            Section {
                ColorPicker("Primary Tint Content", selection: $viewModel.primaryTintContentColor.defaultValue(.white))
                ColorPicker("Secondary Tint Content", selection: $viewModel.secondaryTintContentColor.defaultValue(.white))
                ColorPicker("Tertiary Tint Content", selection: $viewModel.tertiaryTintContentColor.defaultValue(.white))
            }
            Section {
                ColorPicker("Warning", selection: $viewModel.warningTintColor.defaultValue(.white))
                ColorPicker("Error", selection: $viewModel.errorTintColor.defaultValue(.white))
                ColorPicker("Success", selection: $viewModel.successTintColor.defaultValue(.white))
                ColorPicker("Live", selection: $viewModel.liveTintColor.defaultValue(.white))
            }
            Section {
                ColorPicker("Separator", selection: $viewModel.separatorColor.defaultValue(.white))
                ColorPicker("Highlighted Fill", selection: $viewModel.highlightedFillColor.defaultValue(.white))
                ColorPicker("Selected Fill", selection: $viewModel.selectedFillColor.defaultValue(.white))
                ColorPicker("Selected Poll Answer Fill", selection: $viewModel.selectedPollAnswerFillColor.defaultValue(.white))
            }
            Section {
                ColorPicker("Primary Background", selection: $viewModel.primaryBackgroundColor.defaultValue(.white))
                ColorPicker("Secondary Background", selection: $viewModel.secondaryBackgroundColor.defaultValue(.white))
                ColorPicker("Tertiary Background", selection: $viewModel.tertiaryBackgroundColor.defaultValue(.white))
            }
            Section {
                ColorPicker("Primary Background (Elevated)", selection: $viewModel.primaryBackgroundElevatedColor.defaultValue(.white))
                ColorPicker("Secondary Background (Elevated)", selection: $viewModel.secondaryBackgroundElevatedColor.defaultValue(.white))
                ColorPicker("Tertiary Background (Elevated)", selection: $viewModel.tertiaryBackgroundElevatedColor.defaultValue(.white))
            }
        }
        .navigationTitle("Colors")
        .toolbar {
            ToolbarItem {
                Button("Reset", role: .destructive) {
                    viewModel.resetColors()
                }
            }
        }
    }
}

struct ColorsView_Previews: PreviewProvider {
    static var previews: some View {
        ColorsView(viewModel: SettingsViewModel())
    }
}
