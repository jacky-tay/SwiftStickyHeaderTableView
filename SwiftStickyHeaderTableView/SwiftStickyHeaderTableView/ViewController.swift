//
//  ViewController.swift
//  SwiftStickyHeaderTableView
//
//  Created by Jacky Tay on 25/05/18.
//  Copyright © 2018 JackyTay. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var viewDidAppear = false
    var sections = [Section]()
    var pointersForHeader = [IndexPath : IndexPath]() // key = starting point, value = ending point
    var stickyReference = [IndexPath]() // value = sections object index path
    var heightDict = [IndexPath : CGFloat]() // key = index path, value = cell's height
    var minVisibleIndexPath = IndexPath.zero
    var maxVisibleIndexPath = IndexPath.zero
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

    func updateAndResetStickyTableView() {
        updateVisibleCellIndexPaths()
        updateStickyContent()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if viewDidAppear && scrollView == tableView {
            updateVisibleCellIndexPaths()
            updateStickyContent()
            self.scrollView.contentSize.height = tableView.contentSize.height
            self.scrollView.contentOffset = CGPoint(x: 0, y: tableView.contentOffset.y)
            self.scrollView.subviews.last?.alpha = 1
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.15) { [weak self] in self?.scrollView.subviews.last?.alpha = 0 }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            UIView.animate(withDuration: 0.3) { [weak self] in self?.scrollView.subviews.last?.alpha = 0 }
        }
    }

    // MARK: -
    private func updateVisibleCellIndexPaths() {
        if let minIndexPath = tableView.indexPathsForVisibleRows?.min(), minIndexPath != minVisibleIndexPath {
            minVisibleIndexPath = minIndexPath
        }
        if let maxIndexPath = tableView.indexPathsForVisibleRows?.max(), maxIndexPath != maxVisibleIndexPath {
            maxVisibleIndexPath = maxIndexPath
        }
    }

    // MARK: - Prepare data
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
            // reset all reference pointers
            heightDict.removeAll()
            pointersForHeader.removeAll()
            for (index, section) in sections.enumerated() where (section.rows.reduce(false) { $0 || $1.hasChildren() }) {
                for i in 0 ..< section.numberOfFlattenRows() where (section.get(flattenRowAt: i).hasChildren()) {
                    let anchorPoint = IndexPath(row: i, section: index)
                    let to = i + section.get(flattenRowAt: i).numberOfFlattenRows() - 1
                    let toAnchorPoint = IndexPath(row: to, section: index)
                    pointersForHeader[anchorPoint] = toAnchorPoint
                } //for row
            } // for section
        } // if let
    }

    private func updateStickyContent() {
        stickyReference.removeAll()
        var indexPathsToStick = [IndexPath]() // the index path of header object

        // get all visible index path for sticky reference
        for range in pointersForHeader where isWithinVisibleRange(from: range.key, to: range.value) {
            indexPathsToStick.append(range.key)
        }
        indexPathsToStick.sort()
        var stickyTableViewHeight: CGFloat = 0.0

        // add sticky view if needed
        for indexPath in indexPathsToStick where isWithinVisibleView(for: indexPath, stickyTableViewHeight: stickyTableViewHeight) && check(indexPath: indexPath, isParentOf: stickyReference.last) {
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
            let offset = rect.maxY - tableView.contentOffset.y - stickyTableViewHeight
            if offset < 0, let cellHeight = heightDict[stickyReference[stickyReference.count - 1]], cellHeight + offset > 0 {
                stickyTableView.cellForRow(at: IndexPath(row: stickyReference.count - 1, section: 0))?.frame.origin.y = stickyTableViewHeight - cellHeight + offset
                stickyTableViewHeight += offset
            }
        }
    }

    /// Ensure that the index path range is visible within screen view
    ///
    /// - Parameters:
    ///   - from: The upper bound of index path range
    ///   - to: The lower bound of index path range
    /// - Returns: Index path range is visible on screen
    private func isWithinVisibleRange(from: IndexPath, to: IndexPath) -> Bool {
        return to >= minVisibleIndexPath && from < maxVisibleIndexPath
    }

    private func isWithinVisibleView(for indexPath: IndexPath, stickyTableViewHeight: CGFloat, shouldRetry: Bool = true) -> Bool {
        guard let endAnchor = pointersForHeader[indexPath] else {
            return false
        }
        guard let rect = findRect(for: indexPath) else {
            if let endRect = findRect(for: endAnchor) {
                return endRect.maxY - tableView.contentOffset.y - stickyTableViewHeight > 0
            }
            return indexPath <= minVisibleIndexPath && endAnchor >= minVisibleIndexPath
        }
        let shouldPresent = rect.origin.y < (tableView.contentOffset.y + stickyTableViewHeight)
        if shouldPresent, let endRect = findRect(for: endAnchor) {
            return endRect.maxY - tableView.contentOffset.y - stickyTableViewHeight > 0
        }
        return shouldPresent
    }

    private func check(indexPath child: IndexPath, isParentOf parent: IndexPath?) -> Bool {
        guard let parent = parent else {
            return true
        }
        guard parent.section == child.section else {
            return false
        }
        let parentRow = sections[parent.section].get(flattenRowAt: parent.row)
        let childRow = sections[child.section].get(flattenRowAt: child.row)
        return parentRow.has(child: childRow)
    }

    func findRect(for indexPath: IndexPath) -> CGRect? {
        return tableView.cellForRow(at: indexPath)?.frame
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView == self.tableView ? sections.count : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == self.tableView ? sections[section].numberOfFlattenRows() : stickyReference.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // use sticky reference convession to find the reference index path if tableView is sticky table view
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
        return tableView == self.tableView ? sections[section].header : nil
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableView == self.tableView ? sections[section].footer : nil
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView == stickyTableView && indexPath.row < stickyReference.count {
            heightDict[stickyReference[indexPath.row]] = cell.frame.height
        }
    }
}
