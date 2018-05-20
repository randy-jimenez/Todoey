//
//  ViewController.swift
//  Todoey
//
//  Created by Randy on 5/15/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import UIKit
import CoreData


class TodoListViewController: UITableViewController {
    // MARK: - Properties
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var itemArray: [TodoListItem] = []

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTodoItemList()
    }

    // MARK: - TableView DataSource Methods
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        let todoListItemAtPath = itemArray[indexPath.row]
        cell.textLabel?.text = todoListItemAtPath.title
        cell.accessoryType = todoListItemAtPath.isDone ? .checkmark : .none
        return cell
    }

    // MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todoListItemAtPath = itemArray[indexPath.row]
        todoListItemAtPath.isDone = !todoListItemAtPath.isDone
        saveTodoItemList()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Add New Items
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField!

        let alert = UIAlertController(title: "Add New Todoey Item", message: "What would you like to add to your todo list?", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            if let newItemTitle = textField.text {
                if !newItemTitle.isEmpty {
                    let newItem = TodoListItem(context: self.viewContext)
                    newItem.title = newItemTitle
                    self.itemArray.append(newItem)
                    self.saveTodoItemList()
                }
            }
        }
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }

    // MARK: - CRUD Operations
    func saveTodoItemList() {
        do {
            try viewContext.save()
            tableView.reloadData()
        } catch {
            print("Unable to save Todo List Items \(error)")
        }
    }

    func loadTodoItemList(with request: NSFetchRequest<TodoListItem> = TodoListItem.fetchRequest()) {
        do {
            itemArray = try viewContext.fetch(request)
            tableView.reloadData()
        } catch {
            print("Unable to load Todo List Items \(error)")
        }
    }

    func removeItem(at index: Int) {
        let itemToRemove: TodoListItem = itemArray[index]
        viewContext.delete(itemToRemove)
        itemArray.remove(at: index)
        saveTodoItemList()
    }
}


// MARK: - UISearchBarDelegate
extension TodoListViewController: UISearchBarDelegate {
    // Delegate is set in Interface Builder.
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let request: NSFetchRequest<TodoListItem> = TodoListItem.fetchRequest()
        if !searchText.isEmpty {
            request.predicate = NSPredicate(format: "title contains[cd] %@", searchText)
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        }
        loadTodoItemList(with: request)
    }
}
