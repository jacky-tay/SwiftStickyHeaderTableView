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
    var pointersForHeader = [IndexPath : Int]()
    var rectDict = [IndexPath : CGRect]()
    var minVisibleIndexPath = IndexPath.zero
    var maxVisibleIndexPath = IndexPath.zero
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Review"
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(UINib(nibName: "VehicleTableViewCell", bundle: nil), forCellReuseIdentifier: "VehicleCell")
        tableView.register(UINib(nibName: "PersonTableViewCell", bundle: nil), forCellReuseIdentifier: "PersonCell")
        loadData(file: "data1")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // reset rect dictionary reference rect to zero when device orientation did changed
        rectDict.keys.forEach { [weak self] in self?.rectDict[$0] = CGRect.zero }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var visibleIndexPathDidChange = false
        if viewDidAppear, let minIndexPath = tableView.indexPathsForVisibleRows?.min(), minIndexPath != minVisibleIndexPath {
            minVisibleIndexPath = minIndexPath
            visibleIndexPathDidChange = true
        }

        if viewDidAppear, let maxIndexPath = tableView.indexPathsForVisibleRows?.max(), maxIndexPath != maxVisibleIndexPath {
            maxVisibleIndexPath = maxIndexPath
            visibleIndexPathDidChange = true
        }

        if visibleIndexPathDidChange {
            updateStickyContent()
        }
    }

    // MARK: - Prepare data
    private func loadData(file: String) {
        if let url = Bundle.main.url(forResource: file, withExtension: "json"),
            let data = (try? Data(contentsOf: url)),
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String : Any]] {
            sections = json.map { Section(json: $0) }
            // reset all reference pointers
            rectDict.removeAll()
            pointersForHeader.removeAll()
            for (index, section) in sections.enumerated() where (section.rows.reduce(false) { $0 || $1.hasChildren() }) {
                for i in 0 ..< section.numberOfFlattenRows() where (section.get(flattenRowAt: i).hasChildren()) {
                    let anchorPoint = IndexPath(row: i, section: index)
                    let to = i + section.get(flattenRowAt: i).numberOfFlattenRows() - 1
                    rectDict[anchorPoint] = CGRect.zero
                    pointersForHeader[anchorPoint] = to
                    let toAnchorPoint = IndexPath(row: to, section: index)
                    rectDict[toAnchorPoint] = CGRect.zero
                } //for row
            } // for section
        } // if let
    }

    private func updateStickyContent() {

    }

    // MARK: - UITableVewiDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfFlattenRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].get(flattenRowAt: indexPath.row)
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
        return sections[section].header
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if rectDict[indexPath] != nil {
            rectDict[indexPath] = cell.frame
        }
    }
}

