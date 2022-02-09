//
//  StreamContentView.swift
//  HotMicMediaPlayer_Example
//
//  Created by Jordan Hipwell on 2/8/22.
//  Copyright © 2022 HotMic. All rights reserved.
//

import UIKit
import HotMicMediaPlayer

class StreamContentView: UIView, UIContentView {
    
    static let thumbnailSize = CGSize(width: 50, height: 50)
    static let hostThumbnailSize = CGSize(width: 32, height: 32)

    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let dateLabel = UILabel()
    private let stateLabel = UILabel()
    private let hostThumbnailImageView = UIImageView()
    private let hostLabel = UILabel()
    
    var configuration: UIContentConfiguration {
        didSet {
            apply(configuration: configuration)
        }
    }
    
    init(configuration: UIContentConfiguration) {
        self.configuration = configuration
        
        super.init(frame:.zero)
        
        layer.cornerRadius = 4
        
        let horizontalStackView = UIStackView()
        horizontalStackView.axis = .horizontal
        horizontalStackView.alignment = .top
        horizontalStackView.spacing = 16
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(horizontalStackView)
        
        thumbnailImageView.backgroundColor = .secondarySystemBackground
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 4
        horizontalStackView.addArrangedSubview(thumbnailImageView)
        
        let infoStackView = UIStackView()
        infoStackView.axis = .vertical
        infoStackView.spacing = 8
        horizontalStackView.addArrangedSubview(infoStackView)
        
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .label
        infoStackView.addArrangedSubview(titleLabel)
        
        dateLabel.font = .preferredFont(forTextStyle: .body)
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.numberOfLines = 0
        dateLabel.textColor = .label
        infoStackView.addArrangedSubview(dateLabel)
        
        stateLabel.font = {
            var descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .footnote)
            descriptor = descriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: UIFont.Weight.bold]])
            return UIFont(descriptor: descriptor, size: 0)
        }()
        stateLabel.adjustsFontForContentSizeCategory = true
        stateLabel.numberOfLines = 0
        stateLabel.textColor = .secondaryLabel
        infoStackView.addArrangedSubview(stateLabel)
        
        let hostStackView = UIStackView()
        hostStackView.axis = .horizontal
        hostStackView.alignment = .center
        hostStackView.spacing = 8
        infoStackView.addArrangedSubview(hostStackView)
        
        hostThumbnailImageView.backgroundColor = .secondarySystemBackground
        hostThumbnailImageView.contentMode = .scaleAspectFill
        hostThumbnailImageView.clipsToBounds = true
        hostThumbnailImageView.layer.cornerRadius = Self.hostThumbnailSize.height / 2
        hostStackView.addArrangedSubview(hostThumbnailImageView)
        
        hostLabel.font = .preferredFont(forTextStyle: .callout)
        hostLabel.adjustsFontForContentSizeCategory = true
        hostLabel.numberOfLines = 0
        hostLabel.textColor = .label
        hostStackView.addArrangedSubview(hostLabel)
        
        NSLayoutConstraint.activate([
            horizontalStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            horizontalStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            horizontalStackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            horizontalStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: Self.thumbnailSize.height),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: Self.thumbnailSize.height),
            hostThumbnailImageView.widthAnchor.constraint(equalToConstant: Self.hostThumbnailSize.width),
            hostThumbnailImageView.heightAnchor.constraint(equalToConstant: Self.hostThumbnailSize.height)
        ])
        
        apply(configuration: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func apply(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? StreamContentConfiguration else { return }
        
        backgroundColor = configuration.backgroundColor
        
        titleLabel.text = configuration.title
        dateLabel.text = configuration.date
        stateLabel.text = configuration.state
        hostLabel.text = configuration.host
        thumbnailImageView.image = configuration.thumbnailImage
        hostThumbnailImageView.image = configuration.hostThumbnailImage
    }

}
