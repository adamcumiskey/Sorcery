//
//  Middleware.swift
//  DataSorceryExample
//
//  Created by Adam on 6/25/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import DataSorcery

let noCellSelectionStyle: AnyMiddleware = { cell, _, _ in
    guard let cell = cell as? UITableViewCell else { return }
    cell.selectionStyle = .none
}

let cellGradient: AnyMiddleware = { cell, index, dataSource in
    guard let cell = cell as? UITableViewCell else { return }
    guard case let .indexPath(indexPath) = index else { return }
    let normalized = CGFloat(Double(indexPath.row) / Double(dataSource.sections[indexPath.section].items.count))
    let backgroundColor = UIColor(white: 1-normalized, alpha: 1.0)
    let textColor = UIColor(white: normalized, alpha: 1.0)
    cell.contentView.backgroundColor = backgroundColor
    cell.textLabel?.textColor = textColor
    cell.detailTextLabel?.textColor = textColor
}

let disclosureIndicators: AnyMiddleware = { cell, _, _ in
    guard let cell = cell as? UITableViewCell else { return }
    cell.accessoryType = .disclosureIndicator
}
