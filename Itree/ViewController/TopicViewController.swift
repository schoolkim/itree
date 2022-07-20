//
//  TopicViewController.swift
//  Itree
//
//  Created by HAKKYU KIM on 2022/05/26.
//

import UIKit

protocol TopicViewControllerEvent: AnyObject {
    func topic(_ viewController: TopicViewController, didSelectedItem: String)
}

// MARK: TopicViewController

class TopicViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var collectionDataSource: UICollectionViewDiffableDataSource<String, String>!
    weak var eventDelegate: TopicViewControllerEvent?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.alwaysBounceVertical = false
        collectionView.delegate = self
        configureDataSource()
        configureCollectionViewLayout()
    }

    func configureDataSource() {
        let topicCellRegistration = UICollectionView.CellRegistration<TopicCell, String>(cellNib: TopicCell.nib) { cell, indexPath, itemIdentifier in
            cell.configureCell(itemIdentifier: itemIdentifier)
        }
        
        collectionDataSource = .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: topicCellRegistration, for: indexPath, item: itemIdentifier)
            return cell
        }
    }
    
    func configureCollectionViewLayout() {
        let itemLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let itemLayout = NSCollectionLayoutItem(layoutSize: itemLayoutSize)
        let groupLayoutSize = NSCollectionLayoutSize(widthDimension: .estimated(88), heightDimension: .absolute(44))
        let groupLayout = NSCollectionLayoutGroup.horizontal(layoutSize: groupLayoutSize, subitems: [itemLayout])
        let sectionLayout = NSCollectionLayoutSection(group: groupLayout)
        sectionLayout.orthogonalScrollingBehavior = .continuous
        sectionLayout.contentInsets.leading = 16
        sectionLayout.contentInsets.trailing = 16
        sectionLayout.interGroupSpacing = 16
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: sectionLayout)
    }
    
    func applyInitialData(items: [String]) {
        var snapshot = collectionDataSource.snapshot()
        snapshot.appendSections(["topic"])
        snapshot.appendItems(items, toSection: "topic")
        collectionDataSource.apply(snapshot) { [weak self] in
            self?.collectionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: [])
        }
    }
}

// MARK: UICollectionViewDelegate

extension TopicViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        if let itemIdentifier = collectionDataSource.itemIdentifier(for: indexPath) {
            eventDelegate?.topic(self, didSelectedItem: itemIdentifier)
        }
    }
}
