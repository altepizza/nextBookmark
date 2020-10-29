//
//  File.swift
//  nextBookmark
//
//  Created by Kai Rieger on 22.04.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import Foundation
import KeychainSwift

class Model: ObservableObject {
    let keychain = KeychainSwift()
    
    let sharedUserDefaults = UserDefaults(suiteName: SharedUserDefaults.suiteName)
    @Published var tag_count : [String:Int] = [:]
    @Published var bookmarks : [Bookmark] {
        didSet {
            tag_count = [:]
            for tag in tags {
                tag_count[tag] = sorted_filtered_bookmarks_of_tag(searchText: "", tag: tag).count
            }
        }
    }
    @Published var currentRoot : Folder
    @Published var tmp_credentials_password: String {
        didSet {
            if tmp_credentials_password != "xxx" {
                keychain.set(tmp_credentials_password, forKey: "ncPW")
                credentials_password = tmp_credentials_password
            }
        }
    }
    @Published var credentials_password : String {
        didSet {
            keychain.set(credentials_password, forKey: "ncPW")
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
    @Published var full_title: Bool {
        didSet {
            sharedUserDefaults?.set(full_title, forKey: SharedUserDefaults.Keys.full_title)
        }
    }
    @Published var folders: [Folder]
    @Published var isShowing = false
    @Published var order_bookmarks: String {
        didSet {
            sharedUserDefaults?.set(order_bookmarks, forKey: SharedUserDefaults.Keys.order_bookmarks)
        }
    }
    
    @Published var default_upload_folder_id: Int {
        didSet {
            sharedUserDefaults?.set(default_upload_folder_id, forKey: SharedUserDefaults.Keys.default_upload_folder_id)
        }
    }
    @Published var default_upload_folder_title: String {
        didSet {
            sharedUserDefaults?.set(default_upload_folder_title, forKey: SharedUserDefaults.Keys.default_upload_folder_title)
        }
    }
    @Published var default_upload_folder: Folder {
        didSet {
            sharedUserDefaults?.set(default_upload_folder.id, forKey: SharedUserDefaults.Keys.default_upload_folder_id)
            sharedUserDefaults?.set(default_upload_folder.title, forKey: SharedUserDefaults.Keys.default_upload_folder_title)
        }
    }
    @Published var tags: [String] = []
    @Published var editing_bookmark = Bookmark(id: -1, url: "URL", title: "Title", description: "Description", lastmodified: -1, added: -1, tags: [], folders: [-1]) {
        didSet {
            editing_bookmark_folder = folders.filter({ $0.id == editing_bookmark.folders.first }).first ?? create_root_folder()
        }
    }
    @Published var editing_bookmark_folder = Folder(id: -1, title: "/", parent_folder_id: -1)
   
    init() {
        self.bookmarks = [.init(id: -1, url: "...setup your credentials", title: "Go to Settings...", description: "", lastmodified: -1, added: 1, tags: ["...to..."], folders: [-1])]
        
        self.tmp_credentials_password = "xxx"
        self.credentials_password = keychain.get("ncPW") ?? "xx"
        
        self.credentials_url = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.url) ?? "https://your-nextcloud.instance"
        self.credentials_user = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.username) ?? "Your Username"
        self.currentRoot = Folder(id: -1, title: "/", parent_folder_id: -1)
        self.folders = [.init(id: -20, title: "<Pull down to load your bookmarks>",  parent_folder_id: -10)]
        self.full_title = sharedUserDefaults?.bool(forKey: SharedUserDefaults.Keys.username) ?? false
        self.order_bookmarks = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.order_bookmarks) ?? "newest first"
        self.default_upload_folder_id = sharedUserDefaults?.integer(forKey: SharedUserDefaults.Keys.default_upload_folder_id) ?? -1
        self.default_upload_folder_title = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.default_upload_folder_title) ?? "/"
        self.default_upload_folder = Folder(id: -1, title: "/", parent_folder_id: -1)
    }
    
    func sorted_filtered_bookmarks(searchText: String) -> [Bookmark] {
        if(order_bookmarks == "newest first") {
            return bookmarks.filter {
                searchText.isEmpty ? $0.folders.contains(currentRoot.id) : ($0.title.lowercased().contains(searchText.lowercased()) || $0.url.lowercased().contains(searchText.lowercased())) && $0.folders.contains(currentRoot.id)}
            .sorted(by: {($0.added > $1.added)})
        }
        if(order_bookmarks == "oldest first") {
            return bookmarks.filter {
            searchText.isEmpty ? $0.folders.contains(currentRoot.id) : ($0.title.lowercased().contains(searchText.lowercased()) || $0.url.lowercased().contains(searchText.lowercased())) && $0.folders.contains(currentRoot.id)}
            .sorted(by: {($0.added < $1.added)})
        }
        return bookmarks
    }
    
    func sorted_filtered_bookmarks_of_folder(searchText: String, folder: Folder) -> [Bookmark] {
        if(order_bookmarks == "newest first") {
            return bookmarks.filter {
                searchText.isEmpty ? $0.folders.contains(folder.id) : ($0.title.lowercased().contains(searchText.lowercased()) || $0.url.lowercased().contains(searchText.lowercased())) && $0.folders.contains(folder.id)}
            .sorted(by: {($0.added > $1.added)})
        }
        if(order_bookmarks == "oldest first") {
            return bookmarks.filter {
            searchText.isEmpty ? $0.folders.contains(folder.id) : ($0.title.lowercased().contains(searchText.lowercased()) || $0.url.lowercased().contains(searchText.lowercased())) && $0.folders.contains(folder.id)}
            .sorted(by: {($0.added < $1.added)})
        }
        return bookmarks
    }
    
    func sorted_filtered_bookmarks_of_tag(searchText: String, tag: String) -> [Bookmark] {
        if(order_bookmarks == "newest first") {
            return bookmarks.filter {
                searchText.isEmpty ? $0.tags.contains(tag) : ($0.title.lowercased().contains(searchText.lowercased()) || $0.url.lowercased().contains(searchText.lowercased())) && $0.tags.contains(tag)}
            .sorted(by: {($0.added > $1.added)})
        }
        if(order_bookmarks == "oldest first") {
            return bookmarks.filter {
            searchText.isEmpty ? $0.tags.contains(tag) : ($0.title.lowercased().contains(searchText.lowercased()) || $0.url.lowercased().contains(searchText.lowercased())) && $0.tags.contains(tag)}
            .sorted(by: {($0.added < $1.added)})
        }
        return bookmarks
    }
}
