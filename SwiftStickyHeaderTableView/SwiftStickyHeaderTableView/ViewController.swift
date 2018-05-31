//
//  ViewController.swift
//  SwiftStickyHeaderTableView
//
//  Created by Jacky Tay on 25/05/18.
//  Copyright © 2018 JackyTay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    fileprivate var viewDidAppear = false
    fileprivate var sections = [Section]()
    fileprivate var pointersForHeader = [IndexPath : IndexPath]() // key = starting point, value = ending point
    fileprivate var stickyReference = [IndexPath]() // value = sections object index path
    fileprivate var heightDict = [IndexPath : CGFloat]() // key = index path, value = cell's height
    fileprivate var minVisibleIndexPath = IndexPath.zero
    fileprivate var maxVisibleIndexPath = IndexPath.zero

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var stickyTableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Review"
        stickyTableView.backgroundColor = UIColor.clear
        stickyTableView.tableFooterView = UIView()
        register(nibCells: [(UINib(nibName: "StandardTableViewCell", bundle: nil), "StandardCell"),
                            (UINib(nibName: "VehicleTableViewCell", bundle: nil), "VehicleCell"),
                            (UINib(nibName: "PersonTableViewCell", bundle: nil), "PersonCell")])
        loadData(file: "data1")

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "change", style: .plain, target: self, action: #selector(changeData))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // reset hight reference when device orientation has changed
        if previousTraitCollection != nil {
            heightDict.removeAll()
            // pause 500 ms after screen orientation, this returns more accurate index path range
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
                self?.updateAndResetStickyTableView()
            } // asyncAfter
        }
    }

    @objc func changeData() {
        let data = title == "data1" ? "data2" : "data1"
        loadData(file: data)
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) { [weak self] in self?.updateStickyContent() }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if viewDidAppear && scrollView == tableView {
            updateVisibleCellIndexPaths()
            updateStickyContent()
            self.scrollView.contentSize.height = tableView.contentSize.height
            self.scrollView.contentOffset = CGPoint(x: 0, y: tableView.contentOffset.y) // move scroll view scroll bar because it's not interactable by user
            self.scrollView.subviews.last?.alpha = 1 // show scroll view scroll bar while scrolling
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // hide scroll view scroll bar 150 ms after user has finished scrolling
        UIView.animate(withDuration: 0.15) { [weak self] in self?.scrollView.subviews.last?.alpha = 0 }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // hide scroll view scroll bar 300 ms after user has finished scrolling
        if !decelerate { // decelerate is false when user lift the finger off the screen wihout swiping
            UIView.animate(withDuration: 0.3) { [weak self] in self?.scrollView.subviews.last?.alpha = 0 }
        }
    }

    // MARK: - Prepare data
    /// Register all nib cells that should be use for the table view.
    ///
    /// DO NOT add the dequeue reusable cell directly on the table view in interface builder because the table view cell is used in both main table view and sticky table view
    /// - Parameter nibCells: The list of table view nibs with identifiers for table view
    func register(nibCells: [(nib: UINib, identifier: String)]) {
        for cell in nibCells {
            tableView.register(cell.nib, forCellReuseIdentifier: cell.identifier)
            stickyTableView.register(cell.nib, forCellReuseIdentifier: cell.identifier)
        }
    }

    private func loadData(file: String) {
        title = file
        if let url = Bundle.main.url(forResource: file, withExtension: "json"),
            let data = (try? Data(contentsOf: url)),
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String : Any]] {
            sections = json.map { Section(json: $0) }
            resetAndUpdateReferencePointers()
        } // if let
    }

    // MARK: - Reference pointer change
    private func updateAndResetStickyTableView() {
        updateVisibleCellIndexPaths()
        updateStickyContent()
    }

    /// Update visible cell index path (for min and max) when it's changed
    private func updateVisibleCellIndexPaths() {
        if let minIndexPath = tableView.indexPathsForVisibleRows?.min(), minIndexPath != minVisibleIndexPath {
            minVisibleIndexPath = minIndexPath
        }
        if let maxIndexPath = tableView.indexPathsForVisibleRows?.max(), maxIndexPath != maxVisibleIndexPath {
            maxVisibleIndexPath = maxIndexPath
        }
    }

    /// Reset reference pointers when the data source has updated. Then build the pointers reference for all headers where the key is the anchor starting point and the value is the anchor ending point.
    private func resetAndUpdateReferencePointers() {
        // reset all reference pointers
        heightDict.removeAll()
        pointersForHeader.removeAll()
        for (index, section) in sections.enumerated() where (section.rows.reduce(false) { $0 || $1.hasChildren() }) {
            for i in 0 ..< section.numberOfFlattenRows() where (section.get(flattenRowAt: i).hasChildren()) {
                let anchorPoint = IndexPath(row: i, section: index)
                let to = i + section.get(flattenRowAt: i).numberOfFlattenRows() - 1 // subtract 1 because method `numberOfFlattenRows()` includes the count of the cell item itself
                let toAnchorPoint = IndexPath(row: to, section: index)
                pointersForHeader[anchorPoint] = toAnchorPoint
            } //for row
        } // for section
    }


    /// Update sticky table view content
    private func updateStickyContent() {
        stickyReference.removeAll()
        var indexPathsToStick = [IndexPath]() // the index path of header object

        // get all estimated visible index path for sticky reference
        for range in pointersForHeader where isWithinVisibleRange(from: range.key, to: range.value) {
            indexPathsToStick.append(range.key)
        }
        indexPathsToStick.sort()
        var stickyTableViewHeight: CGFloat = 0.0

        // add sticky reference when the index path (starting anchor) is within the visible view (isWithinVisibleView(for:StickyTableViewHeight:)), and it must be the child for previous sticky cell
        for indexPath in indexPathsToStick where isWithinVisibleView(for: indexPath, stickyTableViewHeight: stickyTableViewHeight) && check(indexPath: indexPath, isChildOf: stickyReference.last) {
            if let height = heightDict[indexPath] {
                stickyTableViewHeight += height
            }
            else if let rect = findRect(for: indexPath) {
                stickyTableViewHeight += rect.height
            }
            stickyReference.append(indexPath)
        }
        stickyTableView.reloadData()

        // shift last sticky cell upward if needed
        if stickyReference.count > 0,
            let endAnchor = pointersForHeader[stickyReference[stickyReference.count - 1]],
            let rect = findRect(for: endAnchor) {
            // the last stick cell should shift upward if the ending anchor is leaving the visible space
            let offset = rect.maxY - tableView.contentOffset.y - stickyTableViewHeight
            if offset < 0, let cellHeight = heightDict[stickyReference[stickyReference.count - 1]], cellHeight + offset > 0 {
                stickyTableView.cellForRow(at: IndexPath(row: stickyReference.count - 1, section: 0))?.frame.origin.y = stickyTableViewHeight - cellHeight + offset
                stickyTableViewHeight += offset

            }
        } // if there is more than 1 sticky table view cell
    }

    /// Ensure that the index path range is visible within screen view, where the starting anchor is before (smaller than) maximum visible index path and the ending anchor is after (greater or equal to) minimum index path
    ///
    /// - Parameters:
    ///   - from: The upper bound of index path range
    ///   - to: The lower bound of index path range
    /// - Returns: Index path range is visible on screen
    private func isWithinVisibleRange(from: IndexPath, to: IndexPath) -> Bool {
        return to >= minVisibleIndexPath && from < maxVisibleIndexPath
    }

    /// Check if the given sub-section, with index path range, intercepts with visible index path range with sticky table view offset.
    ///
    /// A sub-section is considered in the visible view range if:
    /// 1) it has a valid ending anchor index path
    /// 2) it's starting anchor index path has a frame rectangle, and its y-origin is smaller than the table view y-offset with stick table view height offset
    ///     + such index path could not be visible if its ending anchor frame ends after
    ///
    /// If the frame rect for index path (starting anchor point) is not found, this happens when the table view cell (starting anchor) is no longer present, ie: when user has scroll pass it, then such sub-section is consider as present if:
    /// 1) the ending anchor frame present and its different with table view content offset is smaller than sticku table view height
    /// - Parameters:
    ///   - indexPath: The index path for starting anchor
    ///   - stickyTableViewHeight: The height of sticky table view at the instance time
    /// - Returns: `True` if the index path range should be present for visible screen, otherwise returns `False`
    private func isWithinVisibleView(for indexPath: IndexPath, stickyTableViewHeight: CGFloat) -> Bool {
        guard let endAnchor = pointersForHeader[indexPath] else {
            return false // all sub-sections must have starting anchor and ending anchor
        }
        guard let rect = findRect(for: indexPath) else {
            if let endRect = findRect(for: endAnchor) {
                return endRect.maxY - tableView.contentOffset.y > stickyTableViewHeight // ending anchor frame still present
            }
            return indexPath <= minVisibleIndexPath && endAnchor >= minVisibleIndexPath
        }
        let shouldPresent = rect.origin.y < (tableView.contentOffset.y + stickyTableViewHeight)
        if shouldPresent, let endRect = findRect(for: endAnchor) {
            return endRect.maxY - tableView.contentOffset.y > stickyTableViewHeight
        }
        return shouldPresent
    }

    /// Check that the child item at index path is a child of the parent index path, return true if parent is nil
    ///
    /// - Parameters:
    ///   - child: The index path of the child item
    ///   - parent: The index path of the parent item
    /// - Returns: Item at index path is the child of parent item
    private func check(indexPath child: IndexPath, isChildOf parent: IndexPath?) -> Bool {
        guard let parent = parent else {
            return true
        }
        guard parent.section == child.section else {
            return false // parent and child must be at the same section index
        }
        let parentRow = sections[parent.section].get(flattenRowAt: parent.row)
        let childRow = sections[child.section].get(flattenRowAt: child.row)
        return parentRow.has(child: childRow)
    }


    /// Find the frame rectangle value of the table view cell at index path if present
    ///
    /// - Parameter indexPath: The index path
    /// - Returns: The frame of table view cell at index path
    func findRect(for indexPath: IndexPath) -> CGRect? {
        return tableView.cellForRow(at: indexPath)?.frame
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView == self.tableView ? sections.count : 1 // sticky table view always has single section
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == self.tableView ? sections[section].numberOfFlattenRows() : stickyReference.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // use sticky reference conversion to find the reference index path when displaying sticky table view
        let useIndexPath = tableView == self.tableView ? indexPath : (stickyReference[indexPath.row])

        let item = sections[useIndexPath.section].get(flattenRowAt: useIndexPath.row)

        let cell = tableView.dequeueReusableCell(withIdentifier: item.cellIdentifier, for: indexPath)
        if let vehicleCell = cell as? VehicleTableViewCell, let data = item as? VehicleRow {
            vehicleCell.bind(data: data)
        }
        else if let personCell = cell as? PersonTableViewCell, let data = item as? PersonRow {
            personCell.bind(data: data)
        }
        else if let standardCell = cell as? StandardTableViewCell, let data = item as? StandardRow {
            standardCell.bind(data: data)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableView == self.tableView ? sections[section].header : nil // stick table view doesn't have header
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableView == self.tableView ? sections[section].footer : nil // stick table view doesn't have footer
    }
}

// MARK: - UITableViewDelegate
extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // try to cache table view cell's height from the sticky table as it can be use for reference height when the frame is not present on main table view
        if tableView == stickyTableView && indexPath.row < stickyReference.count {
            heightDict[stickyReference[indexPath.row]] = cell.frame.height
        }
    }
}
