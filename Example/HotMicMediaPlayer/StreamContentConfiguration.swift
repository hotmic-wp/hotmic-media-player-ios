//
//  StreamContentConfiguration.swift
//  HotMicMediaPlayer_Example
//
//  Created by Jordan Hipwell on 2/8/22.
//  Copyright © 2022 HotMic. All rights reserved.
//

import UIKit

struct StreamContentConfiguration: UIContentConfiguration {
    
    var backgroundColor: UIColor?
    
    var id: String?
    var title: String?
    var date: String?
    var state: String?
    var host: String?
    var thumbnailImage: UIImage?
    var hostThumbnailImage: UIImage?
    
    func makeContentView() -> UIView & UIContentView {
        return StreamContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> StreamContentConfiguration {
        // Perform updates based on current cell state
        
        // Make sure we are dealing with cell configuration
        guard let state = state as? UICellConfigurationState else {
            return self
        }
        
        // Update self based on the current state
        var updatedConfiguration = self
        updatedConfiguration.backgroundColor = state.isHighlighted || state.isSelected ? .systemGray4 : .secondarySystemGroupedBackground
        return updatedConfiguration
    }
    
}
