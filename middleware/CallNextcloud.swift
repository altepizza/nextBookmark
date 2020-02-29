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
    
    func get_bookmarks(completion: @escaping ([Bookmark]?) -> Void) {
        var bookmarks: [Bookmark] = []
        debugPrint("DOING AF")
        let response = AF.request(urlFromSettings + "/index.php/apps/bookmarks/public/rest/v2/bookmark?page=-1", headers: headers).responseJSON { response in
            switch response.result {
             case .success(let value):
                debugPrint(response)
                 let swiftyJsonVar = JSON(value)
                 print(swiftyJsonVar["data"])
                bookmarks.removeAll()
                 for (_, mark) in swiftyJsonVar["data"] { //TODO tags
                    bookmarks.append(Bookmark(id: Int(mark["id"].string!)! , title: mark["title"].string ?? "TITLE" , url: mark["url"].string ?? "URL", tags: mark["tags"].arrayValue.map { $0.stringValue}) )
                    print(bookmarks.count)
                 }
             case .failure(let error):
                debugPrint("ERROR")
                print(error)
             }
           completion(bookmarks)
        }
        debugPrint(response)
    }
    
    func delete(bookId: Int) {
        AF.request(urlFromSettings + "/index.php/apps/bookmarks/public/rest/v2/bookmark/" + String(bookId), method: .delete, headers: headers).responseJSON { response in
            switch response.result {
             case .success(let value):
                debugPrint(response)
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
                debugPrint(response)
            case .failure( _):
                debugPrint("ERROR")
                debugPrint(response)
                let banner = NotificationBanner(title: "Error", subtitle: "Cannot login to Nextcloud Bookmars", style: .danger)
                self.sharedUserDefaults?.set(false, forKey: SharedUserDefaults.Keys.valid)
                banner.show()             }
        }
    }
}
