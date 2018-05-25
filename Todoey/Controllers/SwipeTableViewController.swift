//
//  SwipeTableViewController.swift
//  Todoey
//
//  Created by Randy on 5/25/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeToTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    func removeObject(forRowAt indexPath: IndexPath) {
    }

    // MARK: - UITableViewDataSource methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        return cell
    }

    // MARK: - SwipeTableViewCellDelegate methods
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var swipeActions: [SwipeAction] = []
        if orientation == .right {
            let deleteAction = SwipeAction(style: .destructive, title: "Delete?") {
                (action, indexPath) in
                self.removeObject(forRowAt: indexPath)
            }
            deleteAction.image = UIImage(named: "delete")
            swipeActions.append(deleteAction)
        }
        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        if orientation == .right {
            options.expansionStyle = .destructive
        }
        return options
    }
}
