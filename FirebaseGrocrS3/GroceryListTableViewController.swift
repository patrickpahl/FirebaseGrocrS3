//  GroceryListTableViewController.swift
//  FirebaseGrocrS3
//  Created by Patrick Pahl on 10/23/16.
//  Copyright © 2016 Patrick Pahl. All rights reserved.

import UIKit

class GroceryListTableViewController: UITableViewController {
    
    // MARK: Constants
    let listToUsersSegue = "ListToUsersSegue"
    
    // MARK: Properties
    let reference = FIRDatabase.database().reference(withPath: "grocery-items")
    let userReference = FIRDatabase.database().reference(withPath: "online")
    
    var items: [GroceryItem] = []
    var user: User?
    var userCountBarButtonItem: UIBarButtonItem?
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = false
        
        userCountBarButtonItem = UIBarButtonItem(title: "1", style: .plain, target: self, action: #selector(userCountButtonDidTouch))
        userCountBarButtonItem?.tintColor = UIColor.white
        navigationItem.leftBarButtonItem = userCountBarButtonItem
        
        ///Using Firebase queries, you can sort the list by arbitrary properties
        reference.queryOrdered(byChild: "completed").observe(.value, with: {  snapshot in
            //Attach listener to receive updates whenever the grocery-items endpoint is modified.
            var newItems: [GroceryItem] = []
            //Store the latest version of the data in a local variable inside the listener’s closure.
            for item in snapshot.children {
            //The snapshot contains the entire list of grocery items, not just the updates. Using children, you loop through the grocery items
                guard let itemASFirDataSnapshot = item as? FIRDataSnapshot else { return }
                
                let groceryItem = GroceryItem(snapshot: itemASFirDataSnapshot)
                guard let unwrappedGroceryItem = groceryItem else { return }
                
                newItems.append(unwrappedGroceryItem)
                //The GroceryItem struct has an init that populates its properties using a FIRDataSnapshot. A snapshot’s value is of type AnyObject, and can be a dictionary, array, number, or string. After creating an instance of GroceryItem, it’s added it to the array that contains the latest version of the data.
            }
            
            self.items = newItems
            self.tableView.reloadData()
        })
        
        ///observer W/O query
        /*
        reference.observe(.value, with: { snapshot in
        //Attach listener to receive updates whenever the grocery-items endpoint is modified.
            var newItems: [GroceryItem] = []
            //Store the latest version of the data in a local variable inside the listener’s closure.
            for item in snapshot.children {
            //The snapshot contains the entire list of grocery items, not just the updates. Using children, you loop through the grocery items.
                guard let itemASFIRDataSnapshot = item as? FIRDataSnapshot else { return }
                
                let groceryItem = GroceryItem(snapshot: itemASFIRDataSnapshot)
                guard let unwrappedGroceryItem = groceryItem else { return }
                
                newItems.append(unwrappedGroceryItem)
                //The GroceryItem struct has an init that populates its properties using a FIRDataSnapshot. A snapshot’s value is of type AnyObject, and can be a dictionary, array, number, or string. After creating an instance of GroceryItem, it’s added it to the array that contains the latest version of the data.
            }
            self.items = newItems
            self.tableView.reloadData()
        })
        */
        
        ///Here you attach an authentication observer to the Firebase auth object, that in turn assigns the user property when a user successfully signs in. If a user is logged in, they bypass LoginViewController and segue to the GroceryListTableViewController. When users add items, their email will show in the detail of the cell.
        
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            guard let user = user else { return }
            self.user = User(authData: user)
        
            guard let unwrappedUser = self.user else { return }
    
            let currentUserRef = self.userReference.child(unwrappedUser.uid)
            //Create a child reference using a user’s uid, which is generated when Firebase
            currentUserRef.setValue(unwrappedUser.email)
            currentUserRef.onDisconnectRemoveValue()
            //Call onDisconnectRemoveValue() on currentUserRef. This removes the value at the reference’s location after the connection to Firebase closes, for instance when a user quits your app. This is perfect for monitoring users who have gone offline.
        }
        
        //Creates an observer that monitors online users. When users go on-and-offline, the title of userCountBarButtonItem updates with the current user count.
        userReference.observe(.value, with: { snapshot in
            if snapshot.exists() {
                self.userCountBarButtonItem?.title = snapshot.childrenCount.description
            } else {
                self.userCountBarButtonItem?.title = "0"
            }
        })
        
    ///end of VDL
    }
    
    // MARK: UITableView Delegate methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        let groceryItem = items[indexPath.row]
        
        cell.textLabel?.text = groceryItem.name
        cell.detailTextLabel?.text = groceryItem.addedByUser
        toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    ///Original: delete from array
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            items.remove(at: indexPath.row)
//            tableView.reloadData()
//        }
//    }
    
    ///Remove from Firebase
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let groceryItem = items[indexPath.row]
            groceryItem.reference?.removeValue()
            //Each GroceryItem has a Firebase reference property named reference, and calling removeValue() on that reference causes the listener you defined in viewDidLoad() to fire. The listener has a closure attached that reloads the table view using the latest data.
        }
    }

    ///Original: toggle checkbox
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let cell = tableView.cellForRow(at: indexPath) else { return }
//        var groceryItem = items[indexPath.row]
//        let toggledCompletion = !groceryItem.completed
//        
//        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
//        groceryItem.completed = toggledCompletion
//        tableView.reloadData()
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        //Find the cell the user tapped using cellForRow(at:)
        let groceryItem = items[indexPath.row]
        let toggledCompletion = !groceryItem.completed
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        //Call toggleCellCheckbox(_:isCompleted:) to update the visual properties of the cell.
        groceryItem.reference?.updateChildValues(["completed": toggledCompletion])
        //Use updateChildValues(_:), passing a dictionary, to update Firebase. This method is different than setValue(_:) because it only applies updates, whereas setValue(_:) is destructive and replaces the entire value at that reference.
    }
    
    //Toggle Value
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.gray
            cell.detailTextLabel?.textColor = UIColor.gray
        }
    }
    
    // MARK: Add Item
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Grocery Item", message: "Add an Item", preferredStyle: .alert)

        ///Original save action: Saves to local array
        /*
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
        let textField = alert.textFields?[0]
        guard let textFieldText = textField?.text else { return }
        guard let userEmail = self.user?.email else { return }
                                        
        let groceryItem = GroceryItem(name: textFieldText, addedByUser: userEmail, completed: false)
        self.items.append(groceryItem)
        self.tableView.reloadData()
        }
        */
        
        ///Save to Firebase
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            
            guard let textField = alert.textFields?.first, let text = textField.text else { return }
            guard let userEmail = self.user?.email else { return }
            
            let groceryItem = GroceryItem(name: text, addedByUser: userEmail, completed: false)
            let groceryItemReference = self.reference.child(text.lowercased())
            groceryItemReference.setValue(groceryItem.toAnyObject())
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func userCountButtonDidTouch() {
        performSegue(withIdentifier: listToUsersSegue, sender: nil)
    }
    
}
