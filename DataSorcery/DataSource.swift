//  The MIT License (MIT)
//
//  Copyright (c) 2016 Adam Cumiskey
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
//
//  DataSource.swift
//  DataSorcery
//
//  Created by Adam Cumiskey on 6/16/15.
//  Copyright (c) 2015 adamcumiskey. All rights reserved.

import UIKit

/// Enum to model the two ways we can index something in the DataSource, by section or by IndexPath
public enum Index {
    case indexPath(IndexPath)
    case section(Int)
}

/// Configures the UIView passed into the block
public typealias ConfigureBlock = (UIView) -> Void
/// Callback for an event at an IndexPath
public typealias IndexPathBlock = (_ indexPath: IndexPath) -> Void
/// Callback for when the DataSource wants to move an Item to a new position
public typealias ReorderBlock = (_ sourceIndex: IndexPath, _ destinationIndex: IndexPath) -> Void
/// Callback with IndexPath and completion block parameters used for Swipe actions
public typealias SwipeBlock = (_ indexPath: IndexPath, _ completion: (Bool) -> Void) -> Void
/// Block that can be called before or after a reusable is displayed.
public typealias Middleware<T: UIView> = (T, Index, DataSource) -> Void
/// Middleware for any UIView
public typealias AnyMiddleware = Middleware<UIView>

// MARK: - DataSource

/** Object that can act as the delegate and datasource for `UITableView`s and `UICollectionView`s.
 
  The block-based initialization provides an embedded DSL for creating `UITableViewController` and `UICollectionViewController`s.
*/
open class DataSource: NSObject {
    /// Array of `Section`s in the view
    public var sections: [Section]
    /// Block called when an `Item` is reordered. You must update the data backing the view inside this block.
    public var onReorder: ReorderBlock?
    /// Collection of callbacks used for handling `UIScrollViewDelegate` events
    public var scroll: Scroll?
    /// Middleware applied to all reusables before they appear on-screen. Called before the Reusable's middleware.
    public var willDisplayMiddleware: [AnyMiddleware]
    /// Middleware applied to all reusables after the go off-screen. Called before the Reusable's middleware.
    public var didEndDisplayingMiddleware: [AnyMiddleware]

    /// Initialize a `DataSource`
    ///
    /// - Parameters:
    ///     - sections: The array of sections in this `DataSource`
    ///     - onReorder: Optional callback for when items are moved. You should update the order your underlying data in this callback. If this property is `nil`, reordering will be disabled for this TableView
    ///     - onScroll: Optional callback for recieving scroll events from `UIScrollViewDelegate`
    ///     - middleware: The `Middleware` for this `DataSource` to apply
    public init(sections: [Section],
                onReorder: ReorderBlock? = nil,
                scroll: Scroll? = nil,
                willDisplayMiddleware: [AnyMiddleware] = [],
                didEndDisplayingMiddleware: [AnyMiddleware] = []) {
        self.sections = sections
        self.onReorder = onReorder
        self.scroll = scroll
        self.willDisplayMiddleware = willDisplayMiddleware
        self.didEndDisplayingMiddleware = didEndDisplayingMiddleware
    }

    /// Convenience initializer to construct a DataSource with a single section
    public convenience init(section: Section,
                            onReorder: ReorderBlock? = nil,
                            scroll: Scroll? = nil,
                            willDisplayMiddleware: [AnyMiddleware] = [],
                            didEndDisplayingMiddleware: [AnyMiddleware] = []) {
        self.init(
            sections: [section],
            onReorder: onReorder,
            scroll: scroll,
            willDisplayMiddleware: willDisplayMiddleware,
            didEndDisplayingMiddleware: didEndDisplayingMiddleware
        )
    }

    /// Convenience initializer to construct a DataSource with an array of items
    public convenience init(items: [Item],
                            onReorder: ReorderBlock? = nil,
                            scroll: Scroll? = nil,
                            willDisplayMiddleware: [AnyMiddleware] = [],
                            didEndDisplayingMiddleware: [AnyMiddleware] = []) {
        self.init(
            sections: [Section(items: items)],
            onReorder: onReorder,
            scroll: scroll,
            willDisplayMiddleware: willDisplayMiddleware,
            didEndDisplayingMiddleware: didEndDisplayingMiddleware
        )
    }

    /// Reference section with `DataSource[sectionIndex]`
    public subscript(sectionIndex: Int) -> Section {
        return sections[sectionIndex]
    }

    public subscript(safe sectionIndex: Int) -> Section? {
        guard sectionIndex < sections.count else { return nil }
        return sections[sectionIndex]
    }

    /// Reference item with `DataSource[indexPath]`
    public subscript(indexPath: IndexPath) -> Item {
        return sections[indexPath.section].items[indexPath.item]
    }

    public subscript(safe indexPath: IndexPath) -> Item? {
        guard indexPath.section < sections.count, indexPath.item < sections[indexPath.section].items.count else { return nil }
        return sections[indexPath.section].items[indexPath.item]
    }
}

// MARK: - Scroll

/// Stores blocks that allow the user to configure the `UIScrollViewDelegate` methods
public struct Scroll {
    public typealias WillEndDraggingBlock = ((_ scrollView: UIScrollView, _ velocity: CGPoint, _ targetContentOffset: UnsafeMutablePointer<CGPoint>) -> Void)
    public typealias DidEndDraggingBlock = ((UIScrollView, Bool) -> Void)
    public typealias ScrollBlock = (_ scrollView: UIScrollView) -> Void

    /// Callback for when the scrollView is being dragged
    public let onScroll: ScrollBlock?
    /// Callback for when the scrollView is about to begin scrolling
    public let willBeginDragging: ScrollBlock?
    /// Callback for when the scrollView is about to stop dragging
    public let willEndDragging: WillEndDraggingBlock?
    /// Callback for when the scrollView dragging ends
    public let didEndDragging: DidEndDraggingBlock?
    /// Callback for when the scrollView stops scrolling
    public let didEndDecelerating: ScrollBlock?

    public init(onScroll: ScrollBlock? = nil,
                willBeginDragging: ScrollBlock? = nil,
                willEndDragging: WillEndDraggingBlock? = nil,
                didEndDragging: DidEndDraggingBlock? = nil,
                didEndDecelerating: ScrollBlock? = nil) {
        self.onScroll = onScroll
        self.willBeginDragging = willBeginDragging
        self.willEndDragging = willEndDragging
        self.didEndDragging = didEndDragging
        self.didEndDecelerating = didEndDecelerating
    }
}

// MARK: - Reusable

/// Represents the data for configuring a reusable view
/// You must specify the View class that a `Reusable` will represent in the `configure` closure.
/// View must be a subtype of `UITableViewCell`, `UITableViewHeaderFooterView`, `UICollectionViewCell`, `UICollectionReusableView`
public protocol Reusable {
    /// Store the generic view's type.
    var viewClass: UIView.Type { get }
    /// A block which takes a `UIView` and configures it
    var configure: ConfigureBlock { get }
    /// A block called before the Reusable appears on-screen
    var willDisplay: AnyMiddleware? { get }
    /// A block called after the Reusable goes off-screen
    var didEndDisplaying: AnyMiddleware? { get }
    /// The identifier used to diff this reusable
    var identifier: String { get }
    /// The reuse identifier to use when recycling the view element
    var reuseIdentifier: String { get }
}

// MARK: - Item

/// Object used to configure a UITableViewCell or UICollectionViewCell
public struct Item: Reusable {
    /// The identifier used to diff this reusable
    public let identifier: String
    /// The reuse identifier used to register the cell class to the table/collection view
    public let reuseIdentifier: String
    /// The type of the cell
    public let viewClass: UIView.Type
    /// The block used to configure the cell
    public let configure: ConfigureBlock
    /// Middleware called before the reusable appears on-screen
    public let willDisplay: AnyMiddleware?
    /// Middleware called after this resuable disappears from the screen
    public let didEndDisplaying: AnyMiddleware?
    /// The closure to execute when the item is tapped
    public let onSelect: IndexPathBlock?
    /// The closure to execute when the item is deleted
    public let onDelete: IndexPathBlock?
    /// The swipe actions on the leading edge of the cell. (iOS 11.0+)
    public let leadingActions: [SwipeAction]?
    /// The swipe actions on the trailing edge of the cell. (iOS 11.0+)
    public let trailingActions: [SwipeAction]?
    /// Determines if the first action will be called when a full swipe gesture occurs on the cell. (iOS 11.0+)
    public let performsFirstActionWithFullSwipe: Bool
    /// Allows this cell to be reordered when editing when true
    public let reorderable: Bool

    /// Initialize an item
    ///
    /// - Parameters:
    ///    - configure: The configuration block.
    ///    - onSelect: The closure to execute when the item is tapped
    ///    - onDelete: The closure to execute when the item is deleted
    ///    - willDisplay: Middleware called before the reusable appears on-screen
    ///    - didEndDisplaying: Middleware called after this resuable disappears from the screen
    ///    - leadingActions: The swipe actions on the leading edge of the cell. (iOS 11.0+)
    ///    - trailingActions: The swipe actions on the trailing edge of the cell. (iOS 11.0+)
    ///    - performsFirstActionWithFullSwipe: Determines if the first action will be called when a full swipe gesture occurs on the cell. (iOS 11.0+)
    ///    - identifier: The identifier used to diff this reusable
    ///    - reuseIdentifier: Custom reuseIdentifier to use for this Item
    ///    - reorderable: Allows this cell to be reordered when editing when true
    public init<View: UIView>(configure: @escaping (View) -> Void,
                              onSelect: IndexPathBlock? = nil,
                              onDelete: IndexPathBlock? = nil,
                              willDisplay: Middleware<View>? = nil,
                              didEndDisplaying: Middleware<View>? = nil,
                              leadingActions: [SwipeAction]? = nil,
                              trailingActions: [SwipeAction]? = nil,
                              performsFirstActionWithFullSwipe: Bool = true,
                              identifier: String = UUID().uuidString,
                              reuseIdentifier: String = String(describing: View.self),
                              reorderable: Bool = false) {
        self.onSelect = onSelect
        self.onDelete = onDelete
        self.leadingActions = leadingActions
        self.trailingActions = trailingActions
        self.performsFirstActionWithFullSwipe = performsFirstActionWithFullSwipe
        self.reorderable = reorderable
        self.identifier = identifier
        self.configure = { view in
            guard let unwrappedView = view as? View else {
                assertionFailure("Class mismatch in configure block. Expected \(String(describing: View.self)), Got \(type(of: view))")
                return
            }
            configure(unwrappedView)
        }
        self.willDisplay = { view, indexPath, dataSource in
            guard let unwrappedView = view as? View else {
                assertionFailure("Class mismatch in willDisplay block. Expected \(String(describing: View.self)), Got \(type(of: view))")
                return
            }
            willDisplay?(unwrappedView, indexPath, dataSource)
        }
        self.didEndDisplaying = { view, indexPath, dataSource in
            // Sometimes the view provided is stale compared to the item backing it in the data source, so we can not reliably assert here.
            if let view = view as? View {
                didEndDisplaying?(view, indexPath, dataSource)
            }
        }
        self.viewClass = View.self
        self.reuseIdentifier = reuseIdentifier
    }

    /// Convenience initializer for trailing closure initialization
    public init<View: UIView>(identifier: String = UUID().uuidString,
                              reuseIdentifier: String = String(describing: View.self),
                              reorderable: Bool = false,
                              configure: @escaping (View) -> Void) {
        self.init(configure: configure, reuseIdentifier: reuseIdentifier, reorderable: reorderable)
    }
}

extension Item: Hashable {
    public static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

// MARK: - SectionDecoration

public struct SectionDecoration: Reusable {
    public var viewClass: UIView.Type
    public var configure: ConfigureBlock
    public var willDisplay: AnyMiddleware?
    public var didEndDisplaying: AnyMiddleware?
    public var identifier: String
    public var reuseIdentifier: String

    public init<View: UIView>(configure: @escaping (View) -> Void,
                              willDisplay: AnyMiddleware? = nil,
                              didEndDisplaying: AnyMiddleware? = nil,
                              identifier: String = UUID().uuidString,
                              reuseIdentifier: String = String(describing: View.self)) {
        self.viewClass = View.self
        self.identifier = identifier
        self.reuseIdentifier = reuseIdentifier
        self.configure = { view in
            guard let unwrappedView = view as? View else {
                assertionFailure("Class mismatch in configure block. Expected \(String(describing: View.self)), Got \(type(of: view))")
                return
            }
            configure(unwrappedView)
        }
        self.willDisplay = { view, indexPath, dataSource in
            guard let unwrappedView = view as? View else {
                assertionFailure("Class mismatch in willDisplay block. Expected \(String(describing: View.self)), Got \(type(of: view))")
                return
            }
            willDisplay?(unwrappedView, indexPath, dataSource)
        }
        self.didEndDisplaying = { view, indexPath, dataSource in
            // Sometimes the view provided is stale compared to the item backing it in the data source, so we can not reliably assert here.
            if let view = view as? View {
                didEndDisplaying?(view, indexPath, dataSource)
            }
        }
    }

    public init<View: UIView>(identifier: String = UUID().uuidString,
                              reuseIdentifier: String = String(describing: View.self),
                              configure: @escaping (View) -> Void) {
        self.init(configure: configure, identifier: identifier, reuseIdentifier: reuseIdentifier)
    }
}

// MARK: - SwipeAction

/// Represents a leading or trailing swipe action for a UITableViewCell.
///
/// When defining the `handler`, ensure to call the `completion` handler with the result of whether the action was performed.
public class SwipeAction {
    public enum Style {
        case normal, destructive

        @available(iOS 11.0, *)
        func asUIContextualActionStyle() -> UIContextualAction.Style {
            switch self {
            case .normal: return .normal
            case .destructive: return .destructive
            }
        }
    }

    public let title: String?
    public let image: UIImage?
    public let style: Style
    public let backgroundColor: UIColor
    let handler: SwipeBlock

    public init(title: String? = nil,
                image: UIImage? = nil,
                style: Style = .normal,
                backgroundColor: UIColor = .blue,
                handler: @escaping SwipeBlock) {
        self.title = title
        self.image = image
        self.style = style
        self.backgroundColor = backgroundColor
        self.handler = handler
    }

    @available(iOS 11.0, *)
    func asContextualAction(for indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: style.asUIContextualActionStyle(), title: title) { [weak self] _, _, completionHandler in
            self?.handler(indexPath) { actionComplete in
                completionHandler(actionComplete)
            }
        }
        action.image = image
        action.backgroundColor = backgroundColor
        return action
    }
}

// MARK: - Section

/// Data structure that wraps an array of items to represent a tableView/collectionView section.
public struct Section {
    /// The identifier for this section
    public let identifier: String

    /// A SectionDecoration for this section's header
    public var header: SectionDecoration?
    /// The item data for this section
    public var items: [Item]
    /// A SectionDecoration for this section's footer
    public var footer: SectionDecoration?

    /// Header text for UITableView section
    public var headerText: String?
    /// Footer text for UITableView section
    public var footerText: String?

    /**
     */
    public init(identifier: String? = nil,
                header: SectionDecoration? = nil,
                headerText: String? = nil,
                items: [Item],
                footer: SectionDecoration? = nil,
                footerText: String? = nil) {
        self.identifier = identifier ?? UUID().uuidString
        self.header = header
        self.headerText = headerText
        self.items = items
        self.footer = footer
        self.footerText = footerText
    }

    // Reference items with `section[index]`
    public subscript(index: Int) -> Item {
        return items[index]
    }
}

extension Section: Hashable {
    public static func == (lhs: Section, rhs: Section) -> Bool {
        return lhs.identifier == rhs.identifier
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

// MARK: - UITableViewDataSource

extension DataSource: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self[section].items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self[indexPath]
        let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier, for: indexPath)
        item.configure(cell)
        return cell
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self[section].headerText
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self[section].footerText
    }

    @nonobjc public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = self[indexPath]
        return item.onDelete != nil || item.reorderable == true
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let onDelete = self[indexPath].onDelete {
                sections[indexPath.section].items.remove(at: indexPath.item)
                // TODO: make configurable
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                onDelete(indexPath)
            }
        }
    }

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return self[indexPath].reorderable
    }

    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let reorder = onReorder {
            if sourceIndexPath.section == destinationIndexPath.section {
                sections[sourceIndexPath.section].items.moveObjectAtIndex(sourceIndexPath.item, toIndex: destinationIndexPath.item)
            } else {
                let item = sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.item)
                sections[destinationIndexPath.section].items.insert(item, at: destinationIndexPath.item)
            }
            reorder(sourceIndexPath, destinationIndexPath)
        }
    }
}

// MARK: - UITableViewDelegate

extension DataSource: UITableViewDelegate {
    // MARK: Cell

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        willDisplayMiddleware.forEach { $0(cell, .indexPath(indexPath), self) }
        self[indexPath].willDisplay?(cell, .indexPath(indexPath), self)
    }

    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        didEndDisplayingMiddleware.forEach { $0(cell, .indexPath(indexPath), self) }
        self[safe: indexPath]?.didEndDisplaying?(cell, .indexPath(indexPath), self)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let onSelect = self[indexPath].onSelect {
            onSelect(indexPath)
        }
    }

    // MARK: Header/Footer

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.tableView(tableView, viewForHeaderInSection: section) != nil || self[section].headerText != nil {
            return UITableViewAutomaticDimension
        } else {
            return 0
        }
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if self.tableView(tableView, viewForFooterInSection: section) != nil || self[section].footerText != nil {
            return UITableViewAutomaticDimension
        } else {
            return 0
        }
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = self[section].header else { return nil }
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: header.reuseIdentifier) else { return nil }
        header.configure(view)
        return view
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = self[section].footer else { return nil }
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: footer.reuseIdentifier) else { return nil }
        footer.configure(view)
        return view
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        willDisplayMiddleware.forEach { $0(view, .section(section), self) }
        self[section].header?.willDisplay?(view, .section(section), self)
    }

    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        willDisplayMiddleware.forEach { $0(view, .section(section), self) }
        self[section].footer?.willDisplay?(view, .section(section), self)
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        didEndDisplayingMiddleware.forEach { $0(view, .section(section), self) }
        self[safe: section]?.header?.didEndDisplaying?(view, .section(section), self)
    }

    public func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        didEndDisplayingMiddleware.forEach { $0(view, .section(section), self) }
        self[safe: section]?.header?.didEndDisplaying?(view, .section(section), self)
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        guard let _ = self[indexPath].onDelete else { return .none }
        return .delete
    }

    public func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return self[proposedDestinationIndexPath].reorderable ? proposedDestinationIndexPath : sourceIndexPath
    }

    // MARK: Swipe Actions

    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let actions = self[indexPath].leadingActions else { return nil }
        let configuration = UISwipeActionsConfiguration(actions: actions.map { $0.asContextualAction(for: indexPath) })
        configuration.performsFirstActionWithFullSwipe = self[indexPath].performsFirstActionWithFullSwipe
        return configuration
    }

    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let actions = self[indexPath].trailingActions else { return nil }
        let configuration = UISwipeActionsConfiguration(actions: actions.map { $0.asContextualAction(for: indexPath) })
        configuration.performsFirstActionWithFullSwipe = self[indexPath].performsFirstActionWithFullSwipe
        return configuration
    }
}

// MARK: - UICollectionViewDataSource

extension DataSource: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection sectionIndex: Int) -> Int {
        return self[sectionIndex].items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sections[indexPath.section].items[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.reuseIdentifier, for: indexPath)
        item.configure(cell)
        return cell
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard onReorder != nil else { return false }
        return self[indexPath].reorderable
    }

    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let reorder = onReorder {
            // Reorder the items
            if sourceIndexPath.section == destinationIndexPath.section {
                sections[sourceIndexPath.section].items.moveObjectAtIndex(sourceIndexPath.item, toIndex: destinationIndexPath.item)
            } else {
                let item = sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.item)
                sections[destinationIndexPath.section].items.insert(item, at: destinationIndexPath.item)
            }
            // Update data model in this callback
            reorder(sourceIndexPath, destinationIndexPath)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section = self[indexPath.section]
        if kind == UICollectionElementKindSectionHeader {
            guard let header = section.header else { return UICollectionReusableView() }
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: header.reuseIdentifier, for: indexPath)
            header.configure(view)
            return view
        } else if kind == UICollectionElementKindSectionFooter {
            guard let footer = section.footer else { return UICollectionReusableView() }
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footer.reuseIdentifier, for: indexPath)
            footer.configure(view)
            return view
        }
        return UICollectionReusableView()
    }
}

// MARK: - UICollectionViewDelegate

extension DataSource: UICollectionViewDelegate {
    // MARK: Cell

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        willDisplayMiddleware.forEach { $0(cell, .indexPath(indexPath), self) }
        self[indexPath].willDisplay?(cell, .indexPath(indexPath), self)
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        didEndDisplayingMiddleware.forEach { $0(cell, .indexPath(indexPath), self) }
        self[safe: indexPath]?.didEndDisplaying?(cell, .indexPath(indexPath), self)
    }

    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return self[indexPath].onSelect != nil
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let onSelect = self[indexPath].onSelect {
            onSelect(indexPath)
        }
    }

    // MARK: Supplementary View

    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
      if elementKind == UICollectionElementKindSectionHeader {
        self[indexPath.section].header?.willDisplay?(view, .section(indexPath.section), self)
      } else if elementKind == UICollectionElementKindSectionFooter {
        self[indexPath.section].footer?.willDisplay?(view, .section(indexPath.section), self)
      }
    }

    public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
      if elementKind == UICollectionElementKindSectionHeader {
        self[safe: indexPath.section]?.header?.didEndDisplaying?(view, .section(indexPath.section), self)
      } else if elementKind == UICollectionElementKindSectionFooter {
        self[safe: indexPath.section]?.footer?.didEndDisplaying?(view, .section(indexPath.section), self)
      }
    }
}

// MARK: - UIScrollViewDelegate

extension DataSource: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let onScroll = scroll?.onScroll {
            onScroll(scrollView)
        }
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let willBeginDragging = scroll?.willBeginDragging {
            willBeginDragging(scrollView)
        }
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if let willEndDragging = scroll?.willEndDragging {
            willEndDragging(scrollView, velocity, targetContentOffset)
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let didEndDragging = scroll?.didEndDragging {
            didEndDragging(scrollView, decelerate)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let didEndDecelerating = scroll?.didEndDecelerating {
            didEndDecelerating(scrollView)
        }
    }
}

// MARK: - Cell Registration

public extension UITableView {
    /// Register the reuse identifiers to the table view
    func registerReuseIdentifiers(forDataSource dataSource: DataSource) {
        for section in dataSource.sections {
            if let header = section.header {
                register(sectionDecoration: header)
            }
            for item in section.items {
                if let _ = Bundle.main.path(forResource: item.reuseIdentifier, ofType: "nib") {
                    let nib = UINib(nibName: item.reuseIdentifier, bundle: Bundle.main)
                    register(nib, forCellReuseIdentifier: item.reuseIdentifier)
                } else {
                    register(item.viewClass, forCellReuseIdentifier: item.reuseIdentifier)
                }
            }
            if let footer = section.footer {
                register(sectionDecoration: footer)
            }
        }
    }

    /// Register a cell for the tableView view
    private func register(item: Item) {
        if let _ = Bundle.main.path(forResource: item.reuseIdentifier, ofType: "nib") {
            let nib = UINib(nibName: item.reuseIdentifier, bundle: Bundle.main)
            if nib.instantiate(withOwner: nil, options: nil).first as? UITableViewCell == nil {
                assertionFailure("Item viewClass must be a subclass of UITableViewCell")
            }
            register(nib, forCellReuseIdentifier: item.reuseIdentifier)
        } else {
            if !item.viewClass.isSubclass(of: UITableViewCell.self) {
                assertionFailure("Item viewClass must be a subclass of UITableViewCell")
            }
            register(item.viewClass, forCellReuseIdentifier: item.reuseIdentifier)
        }
    }

    /// Register a HeaderFooterView for the tableView
    private func register(sectionDecoration: Reusable) {
        if let _ = Bundle.main.path(forResource: sectionDecoration.reuseIdentifier, ofType: "nib") {
            let nib = UINib(nibName: sectionDecoration.reuseIdentifier, bundle: nil)
            if nib.instantiate(withOwner: nil, options: nil).first as? UITableViewHeaderFooterView == nil {
                assertionFailure("Reusable viewClass must be a subclass of UITableViewHeaderFooterView")
            }
            register(nib, forHeaderFooterViewReuseIdentifier: sectionDecoration.reuseIdentifier)
        } else {
            if !sectionDecoration.viewClass.isSubclass(of: UITableViewHeaderFooterView.self) {
                assertionFailure("Reusable viewClass must be a subclass of UITableViewHeaderFooterView")
            }
            register(sectionDecoration.viewClass, forHeaderFooterViewReuseIdentifier: sectionDecoration.reuseIdentifier)
        }
    }
}

public extension UICollectionView {
    /// Register reuse identifiers to the collection view
    func registerReuseIdentifiers(forDataSource dataSource: DataSource) {
        for section in dataSource.sections {
            if let header = section.header {
                register(sectionDecoration: header, kind: UICollectionElementKindSectionHeader)
            }
            for item in section.items {
                register(item: item)
            }
            if let footer = section.footer {
                register(sectionDecoration: footer, kind: UICollectionElementKindSectionFooter)
            }
        }
    }

    /// Register a cell for the collection view
    private func register(item: Item) {
        if let _ = Bundle.main.path(forResource: item.reuseIdentifier, ofType: "nib") {
            let nib = UINib(nibName: item.reuseIdentifier, bundle: Bundle.main)
            if nib.instantiate(withOwner: nil, options: nil).first as? UICollectionViewCell == nil {
                assertionFailure("Item viewClass must be a subclass of UICollectioonViewCell")
            }
            register(nib, forCellWithReuseIdentifier: item.reuseIdentifier)
        } else {
            if !item.viewClass.isSubclass(of: UICollectionViewCell.self) {
                assertionFailure("Item viewClass must be a subclass of UICollectioonViewCell")
            }
            register(item.viewClass, forCellWithReuseIdentifier: item.reuseIdentifier)
        }
    }

    /// Register a supplimentary view for the collectionView
    private func register(sectionDecoration: Reusable, kind: String) {
        if let _ = Bundle.main.path(forResource: sectionDecoration.reuseIdentifier, ofType: "nib") {
            let nib = UINib(nibName: sectionDecoration.reuseIdentifier, bundle: nil)
            if nib.instantiate(withOwner: nil, options: nil).first as? UICollectionReusableView == nil {
                assertionFailure("Reusable viewClass must be a subclass of UICollectionReusableView")
            }
            register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: sectionDecoration.reuseIdentifier)
        } else {
            if !sectionDecoration.viewClass.isSubclass(of: UICollectionReusableView.self) {
                assertionFailure("Reusable viewClass must be a subclass of UICollectionReusableView")
            }
            register(sectionDecoration.viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: sectionDecoration.reuseIdentifier)
        }
    }
}

// MARK: - Helpers

extension Array {
    mutating func moveObjectAtIndex(_ index: Int, toIndex: Int) {
        let element = self[index]
        remove(at: index)
        insert(element, at: toIndex)
    }
}
