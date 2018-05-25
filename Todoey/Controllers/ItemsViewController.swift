//
//  ViewController.swift
//  Todoey
//
//  Created by Randy on 5/15/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class ItemsViewController: UITableViewController {
    // MARK: - Properties
    let realm: Realm = try! Realm()

    var selectedCategory: Category? {
        didSet {
            loadItems()
            navItem.title = selectedCategory?.title
        }
    }
    var items: Results<Item>?

    @IBOutlet weak var navItem: UINavigationItem!

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none
    }

    // MARK: - TableView DataSource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self

        if let itemAtPath = items?[indexPath.row] {
            cell.textLabel?.text = itemAtPath.title
            cell.accessoryType = itemAtPath.isDone ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items found"
        }

        return cell
    }

    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let itemAtPath = items?[indexPath.row] {
            do {
                try realm.write {
                    itemAtPath.isDone = !itemAtPath.isDone
                    tableView.reloadData()
                }
            } catch {
                print("Unable to save List Items \(error)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - CRUD Operations
    func loadItems(filterBy predicate: NSPredicate? = nil, sortedBy sort: String = "dateCreated") {
        items = selectedCategory?.items.sorted(byKeyPath: sort, ascending: true)
        if let filter = predicate {
            items = items?.filter(filter)
        }
        tableView.reloadData()
    }

    func removeItem(item: Item) {
        do {
            try realm.write {
                realm.delete(item)
            }
        } catch {
            print("Unable to delete List Items \(error)")
        }
    }

    // MARK: - UI methods
    @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
        let listTitle: String = selectedCategory?.title ?? "No list selected"
        var textField: UITextField!
        
        let alert = UIAlertController(title: "Add New Item", message: "What would you like to add to your \(listTitle) list?", preferredStyle: .alert)        
        alert.addAction(UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            if let category = self.selectedCategory {
                if let newItemTitle = textField.text {
                    if !newItemTitle.isEmpty {
                        do {
                            try self.realm.write {
                                let newItem = Item()
                                newItem.title = newItemTitle
                                category.items.append(newItem)
                                self.tableView.reloadData()
                            }
                        } catch {
                            print("Unable to save List Items \(error)")
                        }
                    }
                }
            }
        })
        alert.addTextField {
            (alertTextField) in
            alertTextField.placeholder = "New Item"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - SwipeTableViewCellDelegate
extension ItemsViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var swipeActions: [SwipeAction] = []
        if orientation == .right {
            let deleteAction = SwipeAction(style: .destructive, title: "Delete Item?") {
                (action, indexPath) in
                if let item = self.items?[indexPath.row] {
                    self.removeItem(item: item)
                }
            }
            deleteAction.image = UIImage(named: "delete")
            swipeActions.append(deleteAction)
        }
        return swipeActions
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        if orientation == .right {
            options.expansionStyle = .fill
        }
        return options
    }
}

// MARK: - UISearchBarDelegate
extension ItemsViewController: UISearchBarDelegate {
    // Delegate is set in Interface Builder.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            loadItems(filterBy: NSPredicate(format: "title contains[cd] %@", searchText), sortedBy: "title")
        }
    }
}
