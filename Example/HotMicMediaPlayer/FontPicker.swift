//
//  FontPicker.swift
//  HotMicMediaPlayer_Example
//
//  Created by Jordan Hipwell on 9/22/22.
//  Copyright © 2022 HotMic. All rights reserved.
//

import SwiftUI

struct FontPicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, UIFontPickerViewControllerDelegate {
        var parent: FontPicker
        
        private let onFontPicked: (UIFontDescriptor) -> Void
        
        init(_ parent: FontPicker, onFontPicked: @escaping (UIFontDescriptor) -> Void) {
            self.parent = parent
            self.onFontPicked = onFontPicked
        }
        
        func fontPickerViewControllerDidPickFont(_ viewController: UIFontPickerViewController) {
            guard let descriptor = viewController.selectedFontDescriptor else { return }
            
            onFontPicked(descriptor)
            parent.dismiss()
        }
    }
    
    private let onFontPicked: (UIFontDescriptor) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    init(onFontPicked: @escaping (UIFontDescriptor) -> Void) {
        self.onFontPicked = onFontPicked
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let configuration = UIFontPickerViewController.Configuration()
        configuration.includeFaces = true
        
        let viewController = UIFontPickerViewController(configuration: configuration)
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self, onFontPicked: self.onFontPicked)
    }
}

struct FontPicker_Previews: PreviewProvider {
    static var previews: some View {
        FontPicker(onFontPicked: { descriptor in
            print("Picked a font: \(descriptor)")
        })
    }
}
