//
//  SharedUserDefaults.swift
//  nextBookmark
//
//  Created by Kai on 07.09.19.
//  Copyright © 2019 Kai. All rights reserved.
//

import Foundation

struct SharedUserDefaults {
    static let suiteName = "group.nextBookmark"
    
    struct Keys {
        static let default_upload_folder_id = "default_upload_folder_id"
        static let default_upload_folder_title = "default_upload_folder_name"
        static let demo = "demo"
        static let full_title = "full_title"
        static let order_bookmarks = "order_bookmarks"
        static let password = "password"
        static let url = "url"
        static let username = "username"
        static let valid = "valid"
    }
}
