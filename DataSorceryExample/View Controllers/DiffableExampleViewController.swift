//
//  DiffableExampleViewController.swift
//  DataSorceryExample
//
//  Created by Adam Cumiskey on 8/25/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import DataSorcery

class DiffableExampleViewController: UITableViewController {
    private var on = true
    private var differ: UITableViewDiffableDataSource<Section, Item>?

    override func viewDidLoad() {
        super.viewDidLoad()
        differ = .init(tableView: tableView)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))

        let data = createData()
        let dataSource = createDataSource(data: data)
        tableView.registerReuseIdentifiers(forDataSource: dataSource)
        differ?.apply(.dataSourceSnapshot(dataSource), animatingDifferences: false)
    }

    @objc func refresh() {
        on.toggle()
        let data = createData()
        let dataSource = createDataSource(data: data)
        let newSnapshot = NSDiffableDataSourceSnapshot.dataSourceSnapshot(dataSource)
        differ?.apply(newSnapshot, animatingDifferences: true)
    }

    func createData() -> [[Int]] {
        return on ? [[1, 2, 3, 4], [5, 6, 7, 8]] : [[2, 3, 4, 5, 6], [7, 8, 10, 11, 13]]
    }

    func createDataSource(data: [[Int]]) -> DataSource {
        return DataSource(
            sections: data.enumerated().map { offset, section in
                return Section(
                    identifier: "\(offset)",
                    headerText: "\(offset)",
                    items: section.map { item in
                        return Item(
                            configure: { (cell: UITableViewCell) in
                                cell.textLabel?.text = "\(item)"
                            },
                            identifier: "\(item)"
                        )
                    }
                )
            }
        )
    }
}
