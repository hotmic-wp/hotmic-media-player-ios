//
//  ViewController.swift
//  HotMicMediaPlayer
//
//  Created by Jordan Hipwell on 02/07/2022.
//  Copyright (c) 2022 HotMic. All rights reserved.
//

import UIKit
import SwiftUI
import HotMicMediaPlayer

class ViewController: UIViewController {
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
    private lazy var dataSource = createDataSource()
    
    private var streams: [HMStream]?
    
    private var includeLiveStreams = true
    private var includeVODStreams = true
    private var includeScheduledStreams = true
    private var limitToFiveStreams = false
    private var skipFirstFiveStreams = false
    
    private enum Section: Int {
        case main
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", image: UIImage(systemName: "gear"), primaryAction: UIAction() { [weak self] _ in
            let viewController = UIHostingController(rootView: SettingsView(viewModel: (UIApplication.shared.delegate as! AppDelegate).settingsViewModel))
            self?.present(viewController, animated: true)
        })
        
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addAction(UIAction { [weak self] action in
            self?.loadStreams(isRefreshing: true)
        }, for: .valueChanged)
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        updateMoreMenu()
        loadStreams(isRefreshing: false)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "DidReinitializeHMMediaPlayer"), object: nil, queue: nil) { [weak self] _ in
            self?.loadStreams(isRefreshing: false)
        }
    }
    
    private func updateMoreMenu() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "More", image: UIImage(systemName: "ellipsis.circle"), menu: UIMenu(children: [
            UIMenu(options: .displayInline, children: [
                UIAction(title: "Live", state: includeLiveStreams ? .on : .off) { [weak self] _ in
                    self?.includeLiveStreams.toggle()
                    self?.updateMoreMenu()
                    self?.loadStreams(isRefreshing: false)
                },
                UIAction(title: "VOD", state: includeVODStreams ? .on : .off) { [weak self] _ in
                    self?.includeVODStreams.toggle()
                    self?.updateMoreMenu()
                    self?.loadStreams(isRefreshing: false)
                },
                UIAction(title: "Scheduled", state: includeScheduledStreams ? .on : .off) { [weak self] _ in
                    self?.includeScheduledStreams.toggle()
                    self?.updateMoreMenu()
                    self?.loadStreams(isRefreshing: false)
                }
            ]),
            UIMenu(options: .displayInline, children: [
                UIAction(title: "Limit to 5", state: limitToFiveStreams ? .on : .off) { [weak self] _ in
                    self?.limitToFiveStreams.toggle()
                    self?.updateMoreMenu()
                    self?.loadStreams(isRefreshing: false)
                },
                UIAction(title: "Skip First 5", state: skipFirstFiveStreams ? .on : .off) { [weak self] _ in
                    self?.skipFirstFiveStreams.toggle()
                    self?.updateMoreMenu()
                    self?.loadStreams(isRefreshing: false)
                }
            ])
        ]))
    }
    
    private func loadStreams(isRefreshing: Bool) {
        if !isRefreshing {
            collectionView.refreshControl?.beginRefreshing()
        }
        
        HMMediaPlayer.getStreams(
            live: includeLiveStreams,
            scheduled: includeScheduledStreams,
            vod: includeVODStreams,
            userID: nil,
            limit: limitToFiveStreams ? 5 : nil,
            skip: skipFirstFiveStreams ? 5 : nil)
        { [weak self] result in
            guard let self else { return }
            
            self.collectionView.refreshControl?.perform(#selector(UIRefreshControl.endRefreshing), with: nil, afterDelay: 0)
            
            switch result {
            case .success(let streams):
                self.streams = streams
                self.updateDataSourceSnapshot()
            case .failure(let error):
                let alert = UIAlertController(title: "Failed to Get Streams", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let cellSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        
        let item = NSCollectionLayoutItem(layoutSize: cellSize)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: cellSize, subitems: [item])
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: .fixed(4), trailing: nil, bottom: .fixed(4))
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func createDataSource() -> UICollectionViewDiffableDataSource<Section, String> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, HMStream> { [weak self] (cell, indexPath, stream) in
            cell.contentConfiguration = self?.createStreamContentConfiguration(cell: cell, stream: stream)
        }
        
        return UICollectionViewDiffableDataSource<Section, String>(collectionView: collectionView) { [weak self] (collectionView, indexPath, identifier) -> UICollectionViewCell? in
            guard let streams = self?.streams else { return nil }

            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: streams[indexPath.row])
        }
    }
    
    private func updateDataSourceSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        snapshot.appendSections([.main])
        snapshot.appendItems((streams ?? []).map { $0.id })
        
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func createStreamContentConfiguration(cell: UICollectionViewCell, stream: HMStream) -> UIContentConfiguration {
        var config = StreamContentConfiguration()
        
        config.id = stream.id
        
        config.title = stream.title
        
        config.date = {
            if let date = stream.state == .scheduled ? stream.scheduledDate : stream.liveDate {
                return date.formatted(date: .numeric, time: .shortened)
            }
            return nil
        }()
        
        config.state = {
            switch stream.state {
            case .scheduled: return "SCHEDULED"
            case .live: return "LIVE"
            case .vod: return "VOD"
            case .ended: return "ENDED"
            @unknown default: return nil
            }
        }()
        
        config.host = stream.user.displayName
        
        if let thumbnailURL = stream.thumbnail {
            let displaySize = CGSize(width: StreamContentView.thumbnailSize.width * traitCollection.displayScale, height: StreamContentView.thumbnailSize.width * traitCollection.displayScale)
            downloadThumbnailImage(of: displaySize, url: thumbnailURL) { [weak cell] image in
                guard let cell,
                      var updatedConfiguration = cell.contentConfiguration as? StreamContentConfiguration,
                      updatedConfiguration.id == stream.id
                else { return }
                
                updatedConfiguration.thumbnailImage = image
                cell.contentConfiguration = updatedConfiguration
            }
        }
        
        if let hostThumbnailURL = stream.user.profilePic {
            let displaySize = CGSize(width: StreamContentView.hostThumbnailSize.width * traitCollection.displayScale, height: StreamContentView.hostThumbnailSize.width * traitCollection.displayScale)
            downloadThumbnailImage(of: displaySize, url: hostThumbnailURL) { [weak cell] image in
                guard let cell,
                      var updatedConfiguration = cell.contentConfiguration as? StreamContentConfiguration,
                      updatedConfiguration.id == stream.id
                else { return }
                
                updatedConfiguration.hostThumbnailImage = image
                cell.contentConfiguration = updatedConfiguration
            }
        }
        
        return config
    }
    
    private func downloadThumbnailImage(of size: CGSize, url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data,
                  let image = UIImage(data: data)
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            image.prepareThumbnail(of: size) { image in
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }.resume()
    }

}

extension ViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if let identifier = dataSource.itemIdentifier(for: indexPath) {
            let playerViewController = HMMediaPlayer.initializePlayerViewController(streamID: identifier, delegate: self, supportsMinimizingToPiP: false)
            present(playerViewController, animated: true, completion: nil)
        }
    }
    
}

extension ViewController: HMPlayerViewControllerDelegate {
    
    func playerViewController(_ viewController: HMPlayerViewController, didFinishWith pipView: UIView?) {
        dismiss(animated: true, completion: nil)
        
        // If you set supportsMinimizingToPiP true, display the pipView in a Picture-in-Picture window if it's non-nil
    }
    
}
