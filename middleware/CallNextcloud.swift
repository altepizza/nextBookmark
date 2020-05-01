//
//  Call_Nextcloud.swift
//  nextBookmark
//
//  Created by Kai on 16.12.19.
//  Copyright © 2019 Kai. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftUI

struct CallNextcloud
{
    let sharedUserDefaults = UserDefaults(suiteName: SharedUserDefaults.suiteName)
    let usernameFromSettings: String
    let passwordFromSettings: String
    let urlFromSettings: String
    let headers: HTTPHeaders
    @ObservedObject var vm: Model
    
    init(data: Model) {
        usernameFromSettings = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.username) ?? "NO USER NAME"
        passwordFromSettings = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.password) ?? "NO PASSWORD"
        urlFromSettings = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.url) ?? "NO URLS"        
        headers = [
            .authorization(username: usernameFromSettings, password: passwordFromSettings),
            .accept("application/json")
        ]
        vm = data
    }
        
    func get_all_bookmarks() {
        var bookmarks: [Bookmark] = []
        let response = AF.request(urlFromSettings + "/index.php/apps/bookmarks/public/rest/v2/bookmark?page=-1", headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let swiftyJsonVar = JSON(value)
                bookmarks.removeAll()
                for (_, mark) in swiftyJsonVar["data"] {
                    var newBookmark = Bookmark(id: mark["id"].intValue , added: mark["added"].intValue, title: mark["title"].stringValue , url: mark["url"].stringValue, tags: mark["tags"].arrayValue.map { $0.stringValue}, folder_ids: mark["folders"].arrayValue.map { $0.intValue}, description: mark["description"].stringValue)
                    bookmarks.append(newBookmark)
                }
            case .failure(let error):
                print(error)
            }
            self.vm.isShowing = false
            self.vm.bookmarks = bookmarks
        }
    }
    
    func delete(bookId: Int) {
        AF.request(urlFromSettings + "/index.php/apps/bookmarks/public/rest/v2/bookmark/" + String(bookId), method: .delete, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                print (value)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func requestFolderHierarchy() {
        var swiftyJsonVar = JSON("")
        let response = AF.request(urlFromSettings + "/index.php/apps/bookmarks/public/rest/v2/folder", headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                swiftyJsonVar = JSON(value)["data"]
                print(swiftyJsonVar["data"])
            case .failure(let error):
                print(error)
            }
            self.vm.folders =  self.makeFolders(json: swiftyJsonVar)
            self.vm.folders.append(Folder(id: -1, title: "/", parent_folder_id: -1, books: []))
            self.vm.currentRoot = Folder(id: -1, title: "/", parent_folder_id: -1, books: [])
        }
        debugPrint(response)
    }
    
    func makeFolders(json: JSON) -> [Folder] {
        debugPrint("iTERATE")
        debugPrint(json)
        var folders = [Folder]()
        for (_, folderJSON) in json {
            if (folderJSON["id"].exists()){
                let newFolder = Folder(id: Int(folderJSON["id"].intValue) , title: folderJSON["title"].stringValue , parent_folder_id: Int(folderJSON["parent_folder"].intValue), books: [])
                folders.append(newFolder)
                if !(folderJSON["children"].isEmpty) {
                    for (_, child) in folderJSON["children"] {
                        let subfolder = makeFolders(json: [child])
                        if (subfolder.count > 0) {
                            folders = folders + subfolder}
                    }
                }}
        }
        return folders
    }
    
    func postURL(url: String, completionHandler: @escaping (JSON?) -> Void) {
        let parameters: [String: String] = [
            "url": url
        ]
        var swiftyJsonVar = JSON("")
        let respons = AF.request(urlFromSettings + "/index.php/apps/bookmarks/public/rest/v2/bookmark", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                swiftyJsonVar = JSON(value)["data"]
                print(swiftyJsonVar["data"])
            case .failure(let error):
                print(error)
            }
            completionHandler(swiftyJsonVar)
        }
    }
    
    func update_bookmark(bookmark: Bookmark) {
        self.vm.isShowing = true
        let parameters: [String : Any] = [
            "url": bookmark.url,
            "title": bookmark.title,
            "description": bookmark.description,
            "tags": bookmark.tags,
            "folders": bookmark.folder_ids
            ]
        var swiftyJsonVar = JSON("")
        _ = AF.request(urlFromSettings + "/index.php/apps/bookmarks/public/rest/v2/bookmark/" + String(bookmark.id), method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                swiftyJsonVar = JSON(value)["data"]
                print(swiftyJsonVar["data"])
                //TODO: Alter bookmark in model
                self.get_all_bookmarks()
            case .failure(let error):
                print(error)
            }
        }
    }
}
