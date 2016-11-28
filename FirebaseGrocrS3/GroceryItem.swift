//
//  GroceryItem.swift
//  FirebaseGrocrS3
//  Created by Patrick Pahl on 10/23/16.
//  Copyright © 2016 Patrick Pahl. All rights reserved.
//

import Foundation

struct GroceryItem {
    
    let key: String
    let name: String
    let addedByUser: String
    let reference: FIRDatabaseReference?
    var completed: Bool
    
    init(name: String, addedByUser: String, completed: Bool, key: String = "") {
        self.key = key
        self.name = name
        self.addedByUser = addedByUser
        self.completed = completed
        self.reference = nil
    }
    
    init?(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        guard let snapshotValue = snapshot.value as? [String: AnyObject],
            let name = snapshotValue["name"] as? String,
            let addedByUser = snapshotValue["addedByUser"] as? String,
            let completed = snapshotValue["completed"] as? Bool else {
                return nil
        }
        self.name = name
        self.addedByUser = addedByUser
        self.completed = completed
    
        reference = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return ["name": name, "addedByUser": addedByUser, "completed": completed]
    }
    
}
