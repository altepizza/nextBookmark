//
//  Folder.swift
//  nextBookmark
//
//  Created by Kai on 29.02.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import Foundation

struct Folder: Identifiable {
    var id: Int
    let title: String
    let parent_folder_id: Int
    var books: [Bookmark]
    var isExpanded: Bool = true
    
//    init(id: Int, title: String, parent_folder_id: Int, books: [Bookmark]){
//        self.id = id
//        self.title = title
//        self.parent_folder_id = parent_folder_id
//        self.books = books
//        self.isExpanded = true
//    }
}
