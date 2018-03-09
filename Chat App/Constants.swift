//
//  Constants.swift
//  Chat App
//
//  Created by inan on 7.03.2018.
//  Copyright © 2018 inan. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

struct Constants {
    static let dbRef = Database.database().reference()
    static let dbChats = dbRef.child("messages")
    static let dbmedias = dbRef.child("images")
    
    static let storageRef = Storage.storage().reference(forURL : "gs://flash-chat-cf31a.appspot.com")
    static let imageStorageRef = storageRef.child("images")
    static let videosStorageRef = storageRef.child("videos")
}
