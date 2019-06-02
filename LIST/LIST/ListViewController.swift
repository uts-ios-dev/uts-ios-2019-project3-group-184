//
//  ViewController.swift
//  LIST
//
//  Created by 林铮 on 2019/5/28.
//  Copyright © 2019 林铮. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UITableViewController {
    var itemArray = [Item]()
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(dataFilePath!)
        loadItems()
    }
    
    func loadItems(request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do{
            itemArray = try context.fetch(request)
        }catch{
            print("load items fail \(error)")
        }
        
        tableView.reloadData()
    }
    //--Table View DataSource methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        
        let item = itemArray[indexPath.row]
        //display checkmark for each row
        cell.accessoryType = item.done == true ? .checkmark : .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //--Table View Delegate methods
    //When user click one row of the list
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        tableView.endUpdates()
        
        //animation of chosen a row
        tableView.deselectRow(at: indexPath, animated: true)
    }

    //--Add new Item
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        //create AlertController
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a new item", message: "", preferredStyle: .alert) //style: shows in the center of the scene
        
        //block runs after alter button clicked
        let action = UIAlertAction(title: "Add", style: .default){(action) in
            //create object of item (decleared by core data)
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            self.itemArray.append(newItem)
            
            self.saveItems()
            
            self.tableView.reloadData()
        }
        
        //text field to enter item
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New thing to add ..."
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert,animated: true,completion: nil)
    }
    
    func saveItems() {
        do{
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            try context.save()
        }catch{
            print(error)
        }
        tableView.reloadData()
    }
}

extension ListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[c] %@ ", searchBar.text!)
        request.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key:"title",ascending:true)
        request.sortDescriptors = [sortDescriptor]
        
        loadItems(request: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}
