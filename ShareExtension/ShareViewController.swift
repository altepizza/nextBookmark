//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Kai on 30.08.19.
//  Copyright © 2019 Kai. All rights reserved.
//

import UIKit
import Social

let sharedUserDefaults = UserDefaults(suiteName: SharedUserDefaults.suiteName)

class ShareViewController: SLComposeServiceViewController {

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    override func viewDidLoad() {
        guard let sharedUsername = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.username) else { return }
        guard let sharedPassword = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.password) else { return }
        guard let sharedUrl = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.url) else { return }
    }
    
    override func didSelectPost() {
        
        guard let sharedUsername = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.username) else { return }
        guard let sharedPassword = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.password) else { return }
        guard let sharedUrl = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.url) else { return }
        
        if let item = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = item.attachments?.first as? NSItemProvider,
            itemProvider.hasItemConformingToTypeIdentifier("public.url") {
            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil) { (url, error) in
                if let shareURL = url as? URL {
                    // do what you want to do with shareURL
                    print (shareURL)
                    
                    let params = ["username":sharedUsername, "password":sharedPassword] as Dictionary<String, String>
                    
                    let urlComponents = NSURLComponents(string: sharedUrl + "/index.php/apps/bookmarks/public/rest/v2/bookmark")!
                    
                    urlComponents.queryItems = [
                        NSURLQueryItem(name: "url", value: String(shareURL.absoluteString))
                        ] as [URLQueryItem]
                    
                    var request = URLRequest(url: urlComponents.url!)
                    request.httpMethod = "POST"
                    let username = sharedUsername
                    let password = sharedPassword
                    let loginData = String(format: "%@:%@", username, password).data(using: String.Encoding.utf8)!
                    let base64LoginData = loginData.base64EncodedString()
                    
                    
                    request.setValue("Basic \(base64LoginData)", forHTTPHeaderField: "Authorization")
                    
                    request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
                    let session = URLSession.shared
                    let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
                        print(response!)
                        do {
                            let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                            print(json)
                        } catch {
                            print("error")
                        }
                    })
                    
                    task.resume()
                }
                self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
            }
        }
    }
}
