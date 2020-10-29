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
        static let username = "username"
        static let url = "url"
        static let valid = "valid"
        static let order_bookmarks = "order_bookmarks"
        static let full_title = "full_title"
        static let default_upload_folder_id = "default_upload_folder_id"
        static let default_upload_folder_title = "default_upload_folder_name"
    }
}
