//
//  Diffable.swift
//  DataSorcery
//
//  Created by Adam Cumiskey on 8/25/19.
//

import UIKit

@available(iOS 13, *)
public extension NSDiffableDataSourceSnapshot where SectionIdentifierType == Section, ItemIdentifierType == Item {
    /// Create a new NSDiffableDataSourceSnapshot from a DataSorcery,DataSource
    static func dataSourceSnapshot(_ dataSource: DataSource) -> NSDiffableDataSourceSnapshot<Section, Item> {
        let snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(dataSource.sections)
        dataSource.sections.forEach { snapshot.appendItems($0.items, toSection: $0) }
        return snapshot
    }
}

@available(iOS 13, *)
public extension UITableViewDiffableDataSource where SectionIdentifierType == Section, ItemIdentifierType == Item {
    /// Create a UITableViewDiffableDataSource configured for use with a DataSorcery,DataSource
    convenience init(tableView: UITableView) {
        self.init(
            tableView: tableView,
            cellProvider: { tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: item.reuseIdentifier,
                    for: indexPath
                )
                item.configure(cell)
                return cell
            }
        )
    }
}

@available(iOS 13, *)
public extension UICollectionViewDiffableDataSource where SectionIdentifierType == Section, ItemIdentifierType == Item {
    /// Create a UICollectionViewDiffableDataSource configured for use with a DataSorcery,DataSource
    convenience init(collectionView: UICollectionView) {
        self.init(
            collectionView: collectionView,
            cellProvider: { tableView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: item.reuseIdentifier,
                    for: indexPath
                )
                item.configure(cell)
                return cell
            }
        )
    }
}
