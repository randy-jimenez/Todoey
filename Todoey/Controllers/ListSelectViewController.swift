//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Randy on 5/20/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import UIKit
import CoreData


class ListSelectViewController: UITableViewController, ListItemsViewControllerDelegate {
    // MARK: - Properties
    let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var lists: [List] = []
    var selectedList: List!

    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLists()
    }

    // MARK: - TodoListViewControllerDelegate methods
    func getSelectedList() -> List {
        return selectedList
    }

    // MARK: - Segue methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let destinationView = segue.destination as! ListItemsViewController
            destinationView.delegate = self
        }
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        let list: List = lists[indexPath.row]
        cell.textLabel?.text = list.title
        return cell
    }

    // MARK: - Table view delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedList = lists[indexPath.row]
        performSegue(withIdentifier: "goToItems", sender: self)
    }

    // MARK: - CRUD methods
    func saveLists() {
        do {
            try viewContext.save()
            tableView.reloadData()
        } catch {
            print("Unable to save Lists \(error)")
        }
        
    }

    func loadLists(request: NSFetchRequest<List> = List.fetchRequest()) {
        do {
            lists = try viewContext.fetch(request)
            tableView.reloadData()
        } catch {
            print("Unable to load Lists \(error)")
        }
    }

    // MARK: - UI methods
    @IBAction func addListButtonPressed(_ sender: UIBarButtonItem) {
        var textField: UITextField!

        let alert = UIAlertController(title: "Add New List", message: "What would you like to call your new list?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add List", style: .default) {
            (action) in
            if let newListTitle = textField.text {
                if !newListTitle.isEmpty {
                    let newList: List = List(context: self.viewContext)
                    newList.title = newListTitle
                    self.lists.append(newList)
                    self.saveLists()
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
