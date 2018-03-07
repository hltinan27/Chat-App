//
//  Constants.swift
//  Chat App
//
//  Created by inan on 7.03.2018.
//  Copyright © 2018 inan. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Constants {
    static let dbRef = Database.database().reference()
    static let dcChats = dbRef.child("messages")
}
