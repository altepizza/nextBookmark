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
    let added: Int
    var title: String
    var url: String
    var tags: [String]
    var folder_ids: [Int]
    var description: String
}
