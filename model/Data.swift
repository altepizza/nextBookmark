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
    @Published var credentials_password : String {
        didSet {
            sharedUserDefaults?.set(credentials_password, forKey: SharedUserDefaults.Keys.password)
        }
    }
    @Published var credentials_url : String {
        didSet {
            sharedUserDefaults?.set(credentials_url, forKey: SharedUserDefaults.Keys.url)
        }
    }
    @Published var credentials_user : String {
        didSet {
            sharedUserDefaults?.set(credentials_user, forKey: SharedUserDefaults.Keys.username)
        }
    }
    @Published var folders: [Folder]
    @Published var isShowing = false
    @Published var order_bookmarks: String {
        didSet {
            sharedUserDefaults?.set(order_bookmarks, forKey: SharedUserDefaults.Keys.order_bookmarks)
        }
    }
    
    init() {
        self.bookmarks = [.init(id: -1, added: 1, title: "Go to Settings...", url: "...setup your credentials", tags: ["...to..."], folder_ids: [-1], description: "")]
        self.credentials_password = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.password) ?? "Your Password"
        self.credentials_url = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.url) ?? "https://your-nextcloud.instance"
        self.credentials_user = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.username) ?? "Your Username"
        self.currentRoot = Folder(id: -1, title: "/", parent_folder_id: -1, books: [])
        self.folders = [.init(id: -20, title: "<Pull down to load your bookmarks>",  parent_folder_id: -10, books: [])]
        self.order_bookmarks = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.order_bookmarks) ?? "newest first"
    }
    
    func sorted_filtered_bookmarks(searchText: String) -> [Bookmark] {
        if(order_bookmarks == "newest first") {
            return bookmarks.filter {
                searchText.isEmpty ? $0.folder_ids.contains(currentRoot.id) : ($0.title.lowercased().contains(searchText.lowercased()) || $0.url.lowercased().contains(searchText.lowercased())) && $0.folder_ids.contains(currentRoot.id)}
            .sorted(by: {($0.added > $1.added)})
        }
        if(order_bookmarks == "oldest first") {
            return bookmarks.filter {
            searchText.isEmpty ? $0.folder_ids.contains(currentRoot.id) : ($0.title.lowercased().contains(searchText.lowercased()) || $0.url.lowercased().contains(searchText.lowercased())) && $0.folder_ids.contains(currentRoot.id)}
            .sorted(by: {($0.added < $1.added)})
        }
        return bookmarks
    }
}
