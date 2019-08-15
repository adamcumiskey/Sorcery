# DataSorcery

[![Version](https://img.shields.io/cocoapods/v/Sorcery.svg?style=flat)](http://cocoapods.org/pods/DataSorcery)
[![License](https://img.shields.io/cocoapods/l/Sorcery.svg?style=flat)](http://cocoapods.org/pods/DataSorcery)
[![Platform](https://img.shields.io/cocoapods/p/Sorcery.svg?style=flat)](http://cocoapods.org/pods/DataSorcery)

Conjure tables and collections out of thin air

## Introduction

A `DataSource` is an embedded DSL for construcing UIs with UITableViews and UICollectionViews. 
You define the structure of your list and DataSource  will automatically conform to `UITableViewControllerDataSource`, ` UITableViewControllerDelegate`, `UICollectionViewControllerDataSource`, and `UICollectionViewControllerDelegate`. 

For example, this is how you can create a simple UITableViewController:

```swift
let vc = BlockTableViewController(
    style: .grouped,
    dataSource: DataSource(
        sections: [
            Section(
                items: [
                    Item { (cell: BedazzledTableViewCell) in
                        cell.titleLabel.text = "Custom cells"
                    },
                    Item { (cell: SubtitleTableViewCell) in
                        cell.textLabel?.text = "Load any cell with ease"
                        cell.detailTextLabel?.text = "Sorcery automatically registers and loads the correct cell by using the class specified in the configure block."
                        cell.detailTextLabel?.numberOfLines = 0
                    }
                ]
            )
        ],
        middleware: [
            Middleware.noCellSelectionStyle,
            Middleware.separatorInset(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        ]
    )
)
```

## Installation

DataSorcery is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "DataSorcery"
```

## Author

Adam Cumiskey, adam.cumiskey@gmail.com

## License

Sorcery is available under the MIT license. See the LICENSE file for more info.
