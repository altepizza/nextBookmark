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
import KeychainSwift

struct CallNextcloud
{
    @ObservedObject var main_model: Model
    
    //TODO Delete this
    let keychain = KeychainSwift()
    
    init(data: Model) {
        main_model = data
    }
    
    private func create_headers() -> HTTPHeaders {
        return HTTPHeaders([
            .authorization(username: main_model.credentials_user, password: main_model.credentials_password),
            .accept("application/json")
        ])
    }
    
    func get_all_bookmarks() {
        //TODO Delete this
        keychain.set(main_model.credentials_user, forKey: "ncPW")
        
        get_tags()
        // TODO: Start below in completion handler from above
        var bookmarks: [Bookmark] = []
        let _ = AF.request(main_model.credentials_url + "/index.php/apps/bookmarks/public/rest/v2/bookmark?page=-1", headers: create_headers()).responseJSON { response in
            switch response.result {
            case .success(let value):
                let swiftyJsonVar = JSON(value)
                bookmarks.removeAll()
                for (_, mark) in swiftyJsonVar["data"] {
                    bookmarks.append(Bookmark(id: mark["id"].intValue , added: mark["added"].intValue, title: mark["title"].stringValue , url: mark["url"].stringValue, tags: mark["tags"].arrayValue.map { $0.stringValue}, folder_ids: mark["folders"].arrayValue.map { $0.intValue}, description: mark["description"].stringValue))
                }
                self.main_model.isShowing = false
            case .failure(let error):
                print(error)
            }
            self.main_model.isShowing = false
            self.main_model.bookmarks = bookmarks
        }
    }
    
    func delete(bookId: Int) {
        AF.request(main_model.credentials_url + "/index.php/apps/bookmarks/public/rest/v2/bookmark/" + String(bookId), method: .delete, headers: create_headers()).responseJSON { response in
            switch response.result {
            case .success(let value):
                debugPrint(value)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
    
    func requestFolderHierarchy() {
        var swiftyJsonVar = JSON("")
        let _ = AF.request(self.main_model.credentials_url + "/index.php/apps/bookmarks/public/rest/v2/folder", headers: create_headers()).responseJSON { response in
            switch response.result {
            case .success(let value):
                swiftyJsonVar = JSON(value)["data"]
                debugPrint(swiftyJsonVar["data"])
                self.main_model.folders = self.makeFolders(json: swiftyJsonVar)
                self.main_model.folders.append(Folder(id: -1, title: "/", parent_folder_id: -1))
                self.main_model.currentRoot = Folder(id: -1, title: "/", parent_folder_id: -1)
                if let upload_folder = self.main_model.folders.first(where: {$0.id == self.main_model.default_upload_folder_id}) {
                    self.main_model.default_upload_folder = upload_folder
                }
            case .failure(let error):
                debugPrint(error)
            }
        }
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
        var parameters: [String: Any]
        if main_model.default_upload_folder_id == 0 {
            parameters = [
                "url": url
            ]
        } else {
            parameters = [
                "url": url,
                "folders": [main_model.default_upload_folder_id]
            ]
        }
        var swiftyJsonVar = JSON("")
        let _ = AF.request(main_model.credentials_url + "/index.php/apps/bookmarks/public/rest/v2/bookmark", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: create_headers()).responseJSON { response in
            var upload_status = false
            switch response.result {
            case .success(let value):
                swiftyJsonVar = JSON(value)["data"]
                print(swiftyJsonVar["data"])
                upload_status = true
            case .failure(let error):
                print(error)
                upload_status = false
            }
            completionHandler(upload_status)
        }
    }
    
    private func post_new_bookmark(bookmark: Bookmark) {
        var parameters: [String: Any]
        if main_model.default_upload_folder_id == 0 {
            parameters = [
                "url": bookmark.url,
                "title": bookmark.title,
                "description": bookmark.description,
            ]
        } else {
            parameters = [
                "url": bookmark.url,
                "title": bookmark.title,
                "description": bookmark.description,
                "folders": [main_model.default_upload_folder_id]
            ]
        }
        var swiftyJsonVar = JSON("")
        let _ = AF.request(main_model.credentials_url + "/index.php/apps/bookmarks/public/rest/v2/bookmark", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: create_headers()).responseJSON { response in
            switch response.result {
            case .success(let value):
                swiftyJsonVar = JSON(value)["data"]
                print(swiftyJsonVar["data"])
                self.main_model.isShowing = false
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func create_bookmark(bookmark: Bookmark) {
        let parameters: [String: Any] = [
                "url": bookmark.url,
                "title": bookmark.title,
                "description": bookmark.description,
                "tags": bookmark.tags,
                "folders": bookmark.folder_ids
            ]
        
        var swiftyJsonVar = JSON("")
        let _ = AF.request(main_model.credentials_url + "/index.php/apps/bookmarks/public/rest/v2/bookmark", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: create_headers()).responseJSON { response in
            switch response.result {
            case .success(let value):
                swiftyJsonVar = JSON(value)["data"]
                print(swiftyJsonVar["data"])
                self.main_model.isShowing = false
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func update_bookmark(bookmark: Bookmark) {
        self.main_model.isShowing = true
        let parameters: [String : Any] = [
            "url": bookmark.url,
            "title": bookmark.title,
            "description": bookmark.description,
            "tags": bookmark.tags,
            "folders": bookmark.folder_ids
        ]
        var swiftyJsonVar = JSON("")
        _ = AF.request(main_model.credentials_url + "/index.php/apps/bookmarks/public/rest/v2/bookmark/" + String(bookmark.id), method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: create_headers()).responseJSON { response in
            switch response.result {
            case .success(let value):
                swiftyJsonVar = JSON(value)["data"]
                debugPrint(swiftyJsonVar["data"])
                //TODO: Alter bookmark in model
                self.get_all_bookmarks()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func get_tags() {
        self.main_model.isShowing = true
        let _ = AF.request(main_model.credentials_url + "/index.php/apps/bookmarks/public/rest/v2/tag", headers: create_headers()).responseJSON { response in
            switch response.result {
            case .success(let value):
                let swiftyJsonVar = JSON(value)
                debugPrint(swiftyJsonVar)
                self.main_model.tags = swiftyJsonVar.arrayValue.map {$0.stringValue}
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func delete_tag(tag: String) {
        self.main_model.isShowing = true
        let _ = AF.request(main_model.credentials_url + "/index.php/apps/bookmarks/public/rest/v2/tag/" + tag, method: .delete, headers: create_headers()).responseJSON { response in
            switch response.result {
            case .success(_):
                self.get_tags()
                self.main_model.isShowing = false
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func edit_or_create_bookmark(bookmark: Bookmark) {
        if (bookmark.id == -1) {
            create_bookmark(bookmark: bookmark)
        } else {
            update_bookmark(bookmark: bookmark)
        }
    }
    
    func create_folder(folder: Folder) {
        self.main_model.isShowing = true
        let parameters = [
            "title": folder.title,
            "parent_folder": folder.parent_folder_id,
            ] as [String : Any]
        var swiftyJsonVar = JSON("")
        let _ = AF.request(main_model.credentials_url + "/index.php/apps/bookmarks/public/rest/v2/folder", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: create_headers()).responseJSON { response in
            switch response.result {
            case .success(let value):
                swiftyJsonVar = JSON(value)["data"]
                print(swiftyJsonVar["data"])
                self.main_model.isShowing = false
            case .failure(let error):
                print(error)
            }
        }
    }
}
