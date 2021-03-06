//
//  EditingViewController.swift
//  DataSorceryExample
//
//  Created by Adam on 6/25/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import DataSorcery
import UIKit

class EditingViewController: BlockTableViewController {
    var items = (0..<100).map { $0 }

    init() {
        super.init(style: .plain)

        self.title = "Editing"
        self.navigationItem.rightBarButtonItem = editButtonItem

        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = UITableViewAutomaticDimension

        self.dataSource = DataSource(
            sections: [
                Section(
                    header: SectionDecoration { (view: InformationHeaderFooterView) in
                        view.titleLabel.text = "Tap \"Edit\" to enabled deletion and reordering. Tap \"Done\" to end editing."
                    },
                    items: items.map { item in
                        return Item(
                            configure: { (cell: UITableViewCell) in
                                cell.textLabel?.text = "\(item)"
                            },
                            onDelete: { [unowned self] indexPath in
                                self.items.remove(at: indexPath.row)
                            },
                            willDisplay: { (cell: UITableViewCell, _, _) in
                                print("Displaying item: ", item)
                            },
                            trailingActions: [
                                SwipeAction(
                                    title: "Remove",
                                    style: .destructive,
                                    backgroundColor: .red,
                                    handler: { [weak self] indexPath, completion in
                                        print("Removing item at indexPath: \(indexPath)")
                                        self?.items.remove(at: item)
                                        completion(true)
                                    }
                                )
                            ],
                            reorderable: true
                        )
                    }
                )
            ],
            onReorder: { [unowned self] origin, destination in
                self.items.moveObjectAtIndex(origin.row, toIndex: destination.row)
            },
            willDisplayMiddleware: [
                noCellSelectionStyle
            ]
        )
    }
}
