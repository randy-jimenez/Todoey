//
//  ViewController.swift
//  Todoey
//
//  Created by Randy on 5/15/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import UIKit
import RealmSwift

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)

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
                    realm.add(itemAtPath, update: true)
                }
                tableView.reloadData()
            } catch {
                print("Unable to save List Items \(error)")
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - CRUD Operations
    func loadItems() {
        items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }

    func removeItem(at index: Int) {
    }

    // MARK: - UI methods
    @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
        let listTitle: String = selectedCategory?.title ?? "No list selected"
        var textField: UITextField!
        
        let alert = UIAlertController(title: "Add New Item", message: "What would you like to add to your \(listTitle) list?", preferredStyle: .alert)        
        alert.addAction(UIAlertAction(title: "Add Item", style: .default) {
            (action) in
            if let newItemTitle = textField.text {
                if !newItemTitle.isEmpty {
                    let newItem = Item()
                    newItem.title = newItemTitle
                    do {
                        if let category = self.selectedCategory {
                            try self.realm.write {
                                self.realm.add(newItem)
                                category.items.append(newItem)
                            }
                            self.tableView.reloadData()
                        }
                    } catch {
                        print("Unable to save List Items \(error)")
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

/*
// MARK: - UISearchBarDelegate
extension ListItemsViewController: UISearchBarDelegate {
    // Delegate is set in Interface Builder.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        if searchText.isEmpty {
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            request.predicate = NSPredicate(format: "title contains[cd] %@", searchText)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }
        loadItems(with: request)
    }
}
*/
