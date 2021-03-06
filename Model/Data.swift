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

    @Published var demo_mode: Bool {
        didSet {
            sharedUserDefaults?.set(demo_mode, forKey: SharedUserDefaults.Keys.demo)
        }
    }
    @Published var weAreOnline = false
    @Published var tag_count : [String:Int] = [:]
    @Published var bookmarks : [Bookmark] {
        didSet {
            tag_count = [:]
            for tag in tags {
                tag_count[tag] = get_relevant_bookmarks(search_text: "", tag: tag).count
            }
        }
    }
    @Published var currentRoot : Folder
    @Published var tmp_credentials_password: String {
        didSet {
            if tmp_credentials_password != "xxx" {
                sharedUserDefaults?.set(tmp_credentials_password, forKey: SharedUserDefaults.Keys.password)
                keychain.set(tmp_credentials_password, forKey: "ncPW")
                credentials_password = tmp_credentials_password
            }
        }
    }
    @Published var credentials_password : String {
        didSet {
            //TODO Switch to Keychain
            sharedUserDefaults?.set(credentials_password, forKey: SharedUserDefaults.Keys.password)
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
        
        //TODO Switch to keychain
        self.tmp_credentials_password = "xxx"
        self.credentials_password = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.password) ?? "Your Password"
        //self.credentials_password = keychain.get("ncPW") ?? "xxx"
        
        
        self.credentials_url = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.url) ?? "https://your-nextcloud.instance"
        self.credentials_user = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.username) ?? "Your Username"
        self.currentRoot = Folder(id: -1, title: "/", parent_folder_id: -1)
        self.demo_mode = sharedUserDefaults?.bool(forKey: SharedUserDefaults.Keys.demo) ?? false
        self.folders = [.init(id: -20, title: "<Pull down to load your bookmarks>",  parent_folder_id: -10)]
        self.full_title = sharedUserDefaults?.bool(forKey: SharedUserDefaults.Keys.username) ?? false
        self.order_bookmarks = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.order_bookmarks) ?? "newest first"
        self.default_upload_folder_id = sharedUserDefaults?.integer(forKey: SharedUserDefaults.Keys.default_upload_folder_id) ?? -1
        self.default_upload_folder_title = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.default_upload_folder_title) ?? "/"
        self.default_upload_folder = Folder(id: -1, title: "/", parent_folder_id: -1)
    }
    
    func get_relevant_bookmarks(search_text: String = "", tag: String = "", folder: Folder? = nil) -> [Bookmark] {
        var tmp_bookmarks = bookmarks
        if !search_text.isEmpty {
            tmp_bookmarks = tmp_bookmarks.filter {
                ($0.title.lowercased().contains(search_text.lowercased()) || $0.url.lowercased().contains(search_text.lowercased()))
            }
        }
        if !tag.isEmpty {
            tmp_bookmarks = tmp_bookmarks.filter {
                $0.tags.contains(tag)
            }
        }
        if let folder = folder {
            tmp_bookmarks = tmp_bookmarks.filter {
                $0.folders.contains(folder.id)
            }
        }
        
        if (order_bookmarks == "NEWEST") {
            return tmp_bookmarks.sorted(by: {($0.added > $1.added)})
        } else if (order_bookmarks == "OLDEST") {
            return tmp_bookmarks.sorted(by: {($0.added < $1.added)})
        } else if (order_bookmarks == "AZ") {
            return tmp_bookmarks.sorted(by: {($0.title < $1.title)})
        } else if (order_bookmarks == "ZA") {
            return tmp_bookmarks.sorted(by: {($0.title > $1.title)})
        }
        return tmp_bookmarks
    }
    
    func middleware(data: Model) -> Nextcloud {
        if demo_mode {
            return DemoCallNextcloud(data: data)
        }
        return CallNextcloud(data: data)
    }
    
    func cycle_to_next_sort_option() {
        if (order_bookmarks == "NEWEST") {
            order_bookmarks = "OLDEST"
        } else if (order_bookmarks == "OLDEST") {
            order_bookmarks = "AZ"
        } else if (order_bookmarks == "AZ") {
            order_bookmarks = "ZA"
        } else if (order_bookmarks == "ZA") {
            order_bookmarks = "NEWEST"
        }
    }
}
