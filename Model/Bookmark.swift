//
//  Bookmarks.swift
//  nextBookmark
//
//  Created by Kai on 16.12.19.
//  Copyright © 2019 Kai. All rights reserved.
//

import Foundation

struct Bookmark: Identifiable, Codable {
    let id: Int
    var url: String
    var title: String
    var description: String
    var lastmodified: Int
    var added: Int
//    var clickcount: Int
//    var available: Bool
//    var userId: String
    var tags: [String]
    var folders: [Int]
}

func create_empty_bookmark(folder_id: Int = -1) -> Bookmark {
    return Bookmark(id: -1, url: "", title: "",description: "", lastmodified: -1, added: -1, tags: [], folders: [folder_id])
}
