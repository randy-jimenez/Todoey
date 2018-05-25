//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Randy on 5/20/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import ChameleonFramework
import RealmSwift
import UIKit

class CategoryViewController: SwipeToTableViewController {
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
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            cell.backgroundColor = UIColor(hexString: category.backgroundColor)
            cell.textLabel?.text = category.title
            cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cell.backgroundColor!, isFlat: true)
        } else {
            cell.textLabel?.text = "No lists found."
        }
        return cell
    }

    // MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
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
                category.backgroundColor = UIColor.randomFlat().hexValue()
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

    override func removeObject(forRowAt indexPath: IndexPath) {
        if let category = categories?[indexPath.row] {
            do {
                try realm.write {
                    for item in category.items {
                       realm.delete(item)
                    }
                    realm.delete(category)
                }
            } catch {
                print("Unable to remove List \(error)")
            }
        }
    }

    // MARK: - UI methods
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField!

        let alert = UIAlertController(title: "Add New List", message: "What would you like to call your new list?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
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
