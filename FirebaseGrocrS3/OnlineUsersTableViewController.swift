//
//  OnlineUsersTableViewController.swift
//  FirebaseGrocrS3
//
//  Created by Patrick Pahl on 10/23/16.
//  Copyright © 2016 Patrick Pahl. All rights reserved.
//

import UIKit

class OnlineUsersTableViewController: UITableViewController {
    
    // MARK: Constants
    let userCell = "userCell"
    let userReference = FIRDatabase.database().reference(withPath: "online")
    
    // MARK: Properties
    var currentUsers: [String] = []
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ///Users added to table as they go online
        userReference.observe(.childAdded, with: { snap in
            //Create an observer that listens for children added to the location managed by usersReference. This is different than a value listener because only the added child is passed to the closure.
            guard let email = snap.value as? String else { return }
            self.currentUsers.append(email)
            //append to local array
            let row = self.currentUsers.count - 1
            let indexPath = IndexPath(row: row, section: 0)
            //Create an instance NSIndexPath using the calculated row index.
            self.tableView.insertRows(at: [indexPath], with: .top)
            //Insert the row using an animation that causes the cell to be inserted from the top.
        })
        
        ///Users removed from table as they go offline
        userReference.observe(.childRemoved, with: { snap in
            //observer that looks for children being removed
            guard let emailToFind = snap.value as? String else { return }
            
            for (index, email) in self.currentUsers.enumerated() {
                //searches local array for email value to find corresponding child item
                //ENUMERTED: There several ways to loop through an array in Swift, but using the enumerated() method is one of my favorites because it iterates over each of the items while also telling you the items's position in the array.
                if email == emailToFind {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.currentUsers.remove(at: index)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        })
    }
    
    // MARK: UITableView Delegate methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentUsers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: userCell, for: indexPath)
        let onlineUserEmail = currentUsers[indexPath.row]
        cell.textLabel?.text = onlineUserEmail
        return cell
    }
    
    // MARK: Actions
    
    @IBAction func signoutButtonPressed(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
}
