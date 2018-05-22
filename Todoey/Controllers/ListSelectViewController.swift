//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Randy on 5/20/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import UIKit
import RealmSwift

class ListSelectViewController: UITableViewController {
    // MARK: - Properties
    let realm: Realm = try! Realm()
    
    var lists: [Category]?

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
        return lists?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        cell.textLabel?.text = lists?[indexPath.row].title ?? "No lists found."
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
                let destinationView = segue.destination as! ListItemsViewController
                destinationView.selectedCategory = lists?[indexPath.row]
            }
        }
    }

    // MARK: - CRUD methods
    func saveCategory(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
            tableView.reloadData()
        } catch {
            print("Unable to save Lists \(error)")
        }
        
    }

    func loadCategories() {
        lists = Array(realm.objects(Category.self))
        tableView.reloadData()
    }

    // MARK: - UI methods
    @IBAction func addListButtonPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField!

        let alert = UIAlertController(title: "Add New List", message: "What would you like to call your new list?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add List", style: .default) {
            (action) in
            if let newListTitle = textField.text {
                if !newListTitle.isEmpty {
                    let newList: Category = Category()
                    newList.title = newListTitle
                    self.lists?.append(newList)
                    self.saveCategory(category: newList)
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
