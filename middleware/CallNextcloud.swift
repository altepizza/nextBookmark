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
import NotificationBannerSwift

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
    
    func hello_world() {
        let banner = NotificationBanner(title: "Testing connection", subtitle: "", style: .warning)
        banner.autoDismiss = false
        banner.show()
        AF.request(urlFromSettings + "/index.php/apps/bookmarks/public/rest/v2/bookmark?page=0", headers: headers)
        .validate(statusCode: 200..<300)
        .responseJSON { response in
            switch response.result {
            case .success( _):
                banner.dismiss()
                let banner = NotificationBanner(title: "Success", subtitle: "Can connect to Nextcloud Bookmarks", style: .success)
                self.sharedUserDefaults?.set(true, forKey: SharedUserDefaults.Keys.valid)
                banner.show()
            case .failure( _):
                debugPrint("ERROR")
                let banner = NotificationBanner(title: "Error", subtitle: "Cannot login to Nextcloud Bookmars", style: .danger)
                self.sharedUserDefaults?.set(false, forKey: SharedUserDefaults.Keys.valid)
                banner.show()
            }
        }
    }
    
    func getAllFolders() -> [Folder] {
        debugPrint("get all Folders")
        var fff = [Folder(id: -1, title: "/", parent_folder_id: -1)]
        requestFolderHierarchy() { olders in
            guard let olders = olders else {
                return
            }
            fff =  self.makeFolders(json: olders)
        }
        debugPrint("RETURNIN")
        debugPrint(fff)
        return fff
    }
    
    func requestFolderHierarchy(completionHandler: @escaping (JSON?) -> Void) {
        var swiftyJsonVar = JSON("")
        let response = AF.request(urlFromSettings + "/index.php/apps/bookmarks/public/rest/v2/folder", headers: headers).responseJSON { response in
            switch response.result {
             case .success(let value):
                debugPrint(response)
                 swiftyJsonVar = JSON(value)["data"]
                 print(swiftyJsonVar["data"])
             case .failure(let error):
                debugPrint("ERROR")
                print(error)
             }
           completionHandler(swiftyJsonVar)
        }
        debugPrint(response)
    }
    
    func makeFolders(json: JSON) -> [Folder] {
        debugPrint("makeFolders")
        debugPrint(json)
        var folders: [Folder]
        folders = [Folder(id: -1, title: "/", parent_folder_id: -1)]
        
        for (_, folderJSON) in json {
            let newFolder = Folder(id: Int(folderJSON["id"].intValue) , title: folderJSON["title"].stringValue , parent_folder_id: Int(folderJSON["parent_folder"].intValue))
           folders.append(newFolder)
            if !(folderJSON["children"].isEmpty) {
                for (_, child) in folderJSON["children"] {
                    folders = folders + makeFolders(json: child)
                }
            }
        }
        return folders
    }
}
