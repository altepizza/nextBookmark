//
//  File.swift
//  nextBookmark
//
//  Created by Kai Rieger on 22.04.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import Foundation

class Model: ObservableObject {
    let sharedUserDefaults = UserDefaults(suiteName: SharedUserDefaults.suiteName)

    @Published var bookmarks : [Bookmark]
    @Published var currentRoot : Folder
    @Published var folders: [Folder]
    @Published var isShowing = false
    @Published var order_bookmarks: String {
        didSet {
            sharedUserDefaults?.set(order_bookmarks, forKey: SharedUserDefaults.Keys.order_bookmarks)
        }
    }
    
    init() {
        self.bookmarks = [.init(id: -1, added: 1, title: "Go to Settings...", url: "...setup your credentials", tags: ["...to..."], folder_ids: [-1], description: "")]
        self.currentRoot = Folder(id: -1, title: "/", parent_folder_id: -1, books: [])
        self.folders = [.init(id: -20, title: "<Pull down to load your bookmarks>",  parent_folder_id: -10, books: [])]
        self.order_bookmarks = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.order_bookmarks) ?? "newest first"
    }
}
