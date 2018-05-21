//
//  ViewController.swift
//  Todoey
//
//  Created by Randy on 5/15/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import UIKit
import CoreData


// MARK: - Protocols
protocol ListItemsViewControllerDelegate {
    func getSelectedList() -> List
}


class ListItemsViewController: UITableViewController {
    // MARK: - Properties
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var items: [Item] = []
    var delegate: ListItemsViewControllerDelegate?

    @IBOutlet weak var navItem: UINavigationItem!

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        navItem.title = delegate?.getSelectedList().title
        loadItems()
    }

    // MARK: - TableView DataSource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        let itemAtPath = items[indexPath.row]
        cell.textLabel?.text = itemAtPath.title
        cell.accessoryType = itemAtPath.isDone ? .checkmark : .none
        return cell
    }

    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemAtPath = items[indexPath.row]
        itemAtPath.isDone = !itemAtPath.isDone
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - CRUD Operations
    func saveItems() {
        do {
            try viewContext.save()
            tableView.reloadData()
        } catch {
            print("Unable to save List Items \(error)")
        }
    }

    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
            let listPredicate = NSPredicate(format: "list = %@", (delegate?.getSelectedList())!)

            if let existingPredicate = request.predicate {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [existingPredicate, listPredicate])
            } else {
                request.predicate = listPredicate
            }

            items = try viewContext.fetch(request)
            tableView.reloadData()
        } catch {
            print("Unable to load List Items \(error)")
        }
    }

    func removeItem(at index: Int) {
        let itemToRemove: Item = items[index]
        viewContext.delete(itemToRemove)
        items.remove(at: index)
        saveItems()
    }

    // MARK: - UI methods
    @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
        let listTitle: String = (delegate?.getSelectedList().title!)!
        var textField: UITextField!
        
        let alert = UIAlertController(title: "Add New Item", message: "What would you like to add to your \(listTitle) list?", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let newItemTitle = textField.text {
                if !newItemTitle.isEmpty {
                    let newItem = Item(context: self.viewContext)
                    newItem.title = newItemTitle
                    newItem.list = self.delegate?.getSelectedList()
                    self.items.append(newItem)
                    self.saveItems()
                }
            }
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New Item"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
}


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
