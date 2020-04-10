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

struct CallNextcloud
{
    let sharedUserDefaults = UserDefaults(suiteName: SharedUserDefaults.suiteName)
    let usernameFromSettings: String
    let passwordFromSettings: String
    let urlFromSettings: String
    let headers: HTTPHeaders
    
    init() {
        usernameFromSettings = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.username) ?? "NO USER NAME"
        passwordFromSettings = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.password) ?? "NO PASSWORD"
        urlFromSettings = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.url) ?? "NO URLS"        
        headers = [
            .authorization(username: usernameFromSettings, password: passwordFromSettings),
            .accept("application/json")
        ]
    }
    
    func get_all_bookmarks(completion: @escaping ([Bookmark]?) -> Void) {
        var bookmarks: [Bookmark] = []
        let response = AF.request(urlFromSettings + "/index.php/apps/bookmarks/public/rest/v2/bookmark?page=-1", headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let swiftyJsonVar = JSON(value)
                bookmarks.removeAll()
                for (_, mark) in swiftyJsonVar["data"] {
                    var newBookmark = Bookmark(id: Int(mark["id"].string!)! , title: mark["title"].string ?? "TITLE" , url: mark["url"].string ?? "URL", tags: mark["tags"].arrayValue.map { $0.stringValue}, folder_ids: mark["folders"].arrayValue.map { $0.intValue})
                    bookmarks.append(newBookmark)
                }
            case .failure(let error):
                print(error)
            }
            completion(bookmarks)
        }
    }
    
    func get_all_bookmarks_for_folder(folder: Folder, completion: @escaping ([Bookmark]?) -> Void) {
        var bookmarks: [Bookmark] = []
        let response = AF.request(urlFromSettings + "/index.php/apps/bookmarks/public/rest/v2/bookmark?page=-1&folder="+String(folder.id), headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                let swiftyJsonVar = JSON(value)
                bookmarks.removeAll()
                for (_, mark) in swiftyJsonVar["data"] {
                    var newBookmark = Bookmark(id: Int(mark["id"].string!)! , title: mark["title"].string ?? "TITLE" , url: mark["url"].string ?? "URL", tags: mark["tags"].arrayValue.map { $0.stringValue}, folder_ids: mark["folders"].arrayValue.map { $0.intValue})
                    bookmarks.append(newBookmark)
                }
            case .failure(let error):
                print(error)
            }
            completion(bookmarks)
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
    
    
    func getAllFolders() -> [Folder] {
        var fff = [Folder(id: -1, title: "/", parent_folder_id: -1, books: [])]
        requestFolderHierarchy() { olders in
            guard let olders = olders else {
                return
            }
            fff =  self.makeFolders(json: olders)
        }
        return fff
    }
    
    func requestFolderHierarchy(completionHandler: @escaping (JSON?) -> Void) {
        var swiftyJsonVar = JSON("")
        let response = AF.request(urlFromSettings + "/index.php/apps/bookmarks/public/rest/v2/folder", headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                swiftyJsonVar = JSON(value)["data"]
                print(swiftyJsonVar["data"])
            case .failure(let error):
                print(error)
            }
            completionHandler(swiftyJsonVar)
        }
        debugPrint(response)
    }
    
    func makeFolders(json: JSON) -> [Folder] {
        var folders = [Folder]()
        for (_, folderJSON) in json {
            if (folderJSON["id"].exists()){
                let newFolder = Folder(id: Int(folderJSON["id"].intValue) , title: folderJSON["title"].stringValue , parent_folder_id: Int(folderJSON["parent_folder"].intValue), books: [])
                folders.append(newFolder)
                if !(folderJSON["children"].isEmpty) {
                    for (_, child) in folderJSON["children"] {
                        let subfolder = makeFolders(json: child)
                        if (subfolder.count > 0) {
                            folders = folders + makeFolders(json: child)}
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
}
