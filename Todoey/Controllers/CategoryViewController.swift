//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Randy on 5/20/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import UIKit
import CoreData


class CategoryViewController: UITableViewController, TodoListViewControllerDelegate {
    // MARK: - Properties
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categoryArray: [Category] = []
    var selectCategory: Category!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }

    // MARK: - TodoListViewControllerDelegate methods
    func getCategory() -> Category {
        return selectCategory
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destinationView = segue.destination as! TodoListViewController
            destinationView.delegate = self
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        let category: Category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.title
        return cell
    }

    // MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectCategory = categoryArray[indexPath.row]
        performSegue(withIdentifier: "goToItems", sender: self)
    }

    // MARK: - CRUD methods
    func saveCategories() {
        do {
            try viewContext.save()
            tableView.reloadData()
        } catch {
            print(error)
        }
        
    }

    func loadCategories(request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryArray = try viewContext.fetch(request)
            tableView.reloadData()
        } catch {
            print(error)
        }
    }

    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField!

        let alert = UIAlertController(title: "Add Category", message: "What category would you like to add?", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let newCategoryTitle = textField.text {
                if !newCategoryTitle.isEmpty {
                    let newCategory: Category = Category(context: self.viewContext)
                    newCategory.title = newCategoryTitle
                    self.categoryArray.append(newCategory)
                    self.saveCategories()
                }
            }
        }

        alert.addAction(action)

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Category name"
            textField = alertTextField
        }

        present(alert, animated: true, completion: nil)
    }
}
