//
//  Call_Nextcloud.swift
//  nextBookmark
//
//  Created by Kai on 16.12.19.
//  Copyright © 2019 Kai. All rights reserved.
//

import Foundation
import SwiftyJSON
import SwiftUI
import KeychainSwift

protocol Nextcloud {
    init(data: Model)
    func get_all_bookmarks()
    func delete(bookId: Int)
    func requestFolderHierarchy()
    func postURL(url: String, completionHandler: @escaping (Bool?) -> Void)
    func get_tags()
    func delete_tag(tag: String)
    func edit_or_create_bookmark(bookmark: Bookmark)
    func create_folder(folder: Folder)
}

struct DemoCallNextcloud: Nextcloud
{
    @ObservedObject var state: Model
    
    init(data: Model) {
        state = data
    }
    
    func get_all_bookmarks() {
        get_tags()
        var bookmarks: [Bookmark] = []
        self.state.weAreOnline = true
        bookmarks = [
            Bookmark(id: -1, url: "https://apple.com", title: "Apple",description: "Apple", lastmodified: -1, added: -1, tags: [], folders: [-1])
        ]
        self.state.isShowing = false
        self.state.bookmarks = bookmarks
    }
    
    func delete(bookId: Int) {
        self.state.bookmarks.removeAll{$0.id == bookId}
        self.state.isShowing = false
    }
    
    func requestFolderHierarchy() {
        let swiftyJsonVar = JSON([
                                    "id": 2,
                                    "title": "A Folder",
                                    "userId": "Apple",
                                    "parent_folder": -1,
                                    "children": []]
        )
        self.state.folders = self.makeFolders(json: swiftyJsonVar)
        self.state.folders.append(Folder(id: -1, title: "/", parent_folder_id: -1))
        self.state.currentRoot = Folder(id: -1, title: "/", parent_folder_id: -1)
        if let upload_folder = self.state.folders.first(where: {$0.id == self.state.default_upload_folder_id}) {
            self.state.default_upload_folder = upload_folder
        }
        self.state.isShowing = false
    }
    
    private func makeFolders(json: JSON, pfolder_id: Int = -1, fullpath: String = "/") -> [Folder] {
        var folders = [Folder]()
        for (_, folderJSON) in json {
            if (folderJSON["id"].exists()){
                let newFolder = Folder(id: Int(folderJSON["id"].intValue), title: folderJSON["title"].stringValue, parent_folder_id: pfolder_id, full_path: fullpath + folderJSON["title"].stringValue)
                folders.append(newFolder)
                if !(folderJSON["children"].isEmpty) {
                    for (_, child) in folderJSON["children"] {
                        let subfolder = makeFolders(json: [child], pfolder_id: Int(folderJSON["id"].intValue), fullpath: newFolder.full_path + "/")
                        if (subfolder.count > 0) {
                            folders = folders + subfolder}
                    }
                }
            }
        }
        return folders
    }
    
    func postURL(url: String, completionHandler: @escaping (Bool?) -> Void) {
        var upload_status = false
        upload_status = true
        completionHandler(upload_status)
        self.state.bookmarks.append(Bookmark(id: 666, url: url, title: url, description: url, lastmodified: 1, added: 1, tags: ["Demo"], folders: [-1]))
        self.state.isShowing = false
    }
    
    private func post_new_bookmark(bookmark: Bookmark) {
        self.state.bookmarks.append(bookmark)
        self.state.isShowing = false
    }
    
    private func create_bookmark(bookmark: Bookmark) {
        self.state.bookmarks.append(bookmark)
        self.state.isShowing = false
    }
    
    private func update_bookmark(bookmark: Bookmark) {
        self.state.isShowing = true
        self.state.bookmarks.append(bookmark)
        self.state.isShowing = false
    }
    
    func get_tags() {
        self.state.isShowing = true
        self.state.weAreOnline = true
        self.state.tags = ["Apple", "Demo"]
        self.state.isShowing = false
    }
    
    func delete_tag(tag: String) {
        self.state.tags.removeAll{$0 == tag}
        self.state.isShowing = false
    }
    
    func edit_or_create_bookmark(bookmark: Bookmark) {
        if (bookmark.id == -1) {
            create_bookmark(bookmark: bookmark)
        } else {
            update_bookmark(bookmark: bookmark)
        }
        self.state.isShowing = false
    }
    
    func create_folder(folder: Folder) {
        self.state.isShowing = true
        self.state.folders.append(folder)
        self.state.isShowing = false
    }
}
