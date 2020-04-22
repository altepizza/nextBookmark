//
//  File.swift
//  nextBookmark
//
//  Created by Kai Rieger on 22.04.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import Foundation

class Model: ObservableObject {
    @Published var currentRoot : Folder = Folder(id: -1, title: "/", parent_folder_id: -1, books: [])
    @Published var isShowing = false
    @Published var folders: [Folder] = [.init(id: -20, title: "<Pull down to load your bookmarks>",  parent_folder_id: -10, books: [])]
    @Published var bookmarks : [Bookmark] = [.init(id: -1, title: "DUMMY", url: "DUMMYURL", tags: ["DUMMY TAG"], folder_ids: [-1])]
}
