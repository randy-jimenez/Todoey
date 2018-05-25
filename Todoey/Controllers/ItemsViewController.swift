//
//  ViewController.swift
//  Todoey
//
//  Created by Randy on 5/15/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import ChameleonFramework
import RealmSwift
import UIKit

class ItemsViewController: SwipeToTableViewController {
    // MARK: - Properties
    let realm: Realm = try! Realm()

    var selectedCategory: Category? {
        didSet {
            loadItems()
            baseColor = UIColor(hexString: selectedCategory?.backgroundColor)!
        }
    }
    var baseColor: UIColor!
    var items: Results<Item>?

    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navBar = navigationController?.navigationBar {
            let contrastColor = ContrastColorOf(baseColor, returnFlat: true)
            navBar.barTintColor = baseColor
            navBar.tintColor = contrastColor
            navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: contrastColor]
            navItem.title = selectedCategory?.title
        }
    }

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let itemAtPath = items?[indexPath.row] {
            let percentage = CGFloat(indexPath.row) * 0.75 / CGFloat(items!.count)
            cell.backgroundColor = baseColor.darken(byPercentage: percentage)
            let contrastColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            cell.tintColor = contrastColor
            cell.textLabel?.textColor = contrastColor
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

    override func removeObject(forRowAt indexPath: IndexPath) { 
        if let item = items?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Unable to delete List Items \(error)")
            }
        }
    }

    // MARK: - UI methods
    @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
        let listTitle: String = selectedCategory?.title ?? "No list selected"
        var textField: UITextField!
        
        let alert = UIAlertController(title: "Add New Item", message: "What would you like to add to your \(listTitle) list?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
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
