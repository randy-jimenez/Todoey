//
//  ViewController.swift
//  Todoey
//
//  Created by Randy on 5/15/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    // MARK: - Properties
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("TodoListItems.plist")

    var itemArray: [TodoListItem] = []
    
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

    // MARK: - Add New Items.
    @IBAction func addItemPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField!

        let alert = UIAlertController(title: "Add New Todoey Item", message: "What would you like to add to your todo list?", preferredStyle: .alert)

        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            if let newItemTitle = textField.text {
                if !newItemTitle.isEmpty {
                    let newItem = TodoListItem(title: newItemTitle)
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

    func loadTodoItemList() {
        do {
            if let data = try? Data(contentsOf: dataFilePath!) {
                let decoder = PropertyListDecoder()
                itemArray = try decoder.decode(type(of: itemArray), from: data)
            }
        } catch {
            print(error)
        }
    }

    func saveTodoItemList() {
        do {
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
            tableView.reloadData()
        } catch {
            print(error)
        }
    }
}
