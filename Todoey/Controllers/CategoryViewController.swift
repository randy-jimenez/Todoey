//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Randy on 5/20/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CategoryViewController: UITableViewController, SwipeTableViewCellDelegate {
    // MARK: - Properties
    let realm: Realm = try! Realm()
    
    var categories: Results<Category>?

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        loadCategories()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.delegate = self
        cell.textLabel?.text = categories?[indexPath.row].title ?? "No lists found."
        return cell
    }

    // MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }

    // MARK: - Swipe table view cell delegate methods
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var swipeActions: [SwipeAction] = []
        if orientation == .right {
            let deleteSwipeAction = SwipeAction(style: .destructive, title: "Delete List?") {
                (action, indexPath) in
                self.removeCategory(category: (self.categories?[indexPath.row])!)
            }
            deleteSwipeAction.image = UIImage(named: "delete")
            swipeActions.append(deleteSwipeAction)
        }
        return swipeActions
    }

    // MARK: - Segue methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            if let indexPath: IndexPath = tableView.indexPathForSelectedRow {
                let destinationView = segue.destination as! ItemsViewController
                destinationView.selectedCategory = categories?[indexPath.row]
            }
        }
    }

    // MARK: - CRUD methods
    func saveCategory(category: Category) {
        do {
            try realm.write {
                realm.add(category)
                tableView.reloadData()
            }
        } catch {
            print("Unable to save Lists \(error)")
        }
        
    }

    func loadCategories() {
        categories = realm.objects(Category.self).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }

    func removeCategory(category: Category) {
        do {
            try realm.write {
                realm.delete(category)
                tableView.reloadData()
            }
        } catch {
            print("Unable to remove List \(error)")
        }
    }

    // MARK: - UI methods
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField!

        let alert = UIAlertController(title: "Add New List", message: "What would you like to call your new list?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add List", style: .default) {
            (action) in
            if let newCategoryTitle = textField.text {
                if !newCategoryTitle.isEmpty {
                    let newCategory: Category = Category()
                    newCategory.title = newCategoryTitle
                    self.saveCategory(category: newCategory)
                }
            }
        })
        alert.addTextField {
            (alertTextField) in
            alertTextField.placeholder = "New List"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }
}
