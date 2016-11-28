//
//  User.swift
//  FirebaseGrocrS3
//
//  Created by Patrick Pahl on 10/23/16.
//  Copyright © 2016 Patrick Pahl. All rights reserved.
//

import Foundation

struct User {
    
    let uid: String
    let email: String
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}
