//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Kai on 30.08.19.
//  Copyright © 2019 Kai. All rights reserved.
//

import UIKit
import Social
import MobileCoreServices

let sharedUserDefaults = UserDefaults(suiteName: SharedUserDefaults.suiteName)

extension NSItemProvider {
    var isText: Bool { return hasItemConformingToTypeIdentifier(String(kUTTypeText)) }
    var isUrl: Bool { return hasItemConformingToTypeIdentifier(String(kUTTypeURL)) }
    
    func processText(completion: CompletionHandler?) {
        loadItem(forTypeIdentifier: String(kUTTypeText), options: nil, completionHandler: completion)
    }
    
    func processUrl(completion: CompletionHandler?) {
        loadItem(forTypeIdentifier: String(kUTTypeURL), options: nil, completionHandler: completion)
    }
}

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
    }
    
    override func didSelectPost() {
        
        guard let sharedUsername = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.username) else { return }
        guard let sharedPassword = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.password) else { return }
        guard let sharedUrl = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.url) else { return }
        
        let inputItems = (extensionContext?.inputItems as? [NSExtensionItem])!
        for inputItem in inputItems {
            guard let attachments = inputItem.attachments else { continue }
            for attachment in attachments {
                if attachment.isUrl {
                    attachment.processUrl { obj, err in
                        guard err == nil else {
                            return
                        }
                        
                        guard let url = obj as? URL else {
                            return
                        }
                        
                        let title = inputItem.attributedContentText?.string
                        debugPrint(title)
                        debugPrint(url)
                        let params = ["username":sharedUsername, "password":sharedPassword] as Dictionary<String, String>
                        
                        let urlComponents = NSURLComponents(string: sharedUrl + "/index.php/apps/bookmarks/public/rest/v2/bookmark")!
                        
                        urlComponents.queryItems = [
                            NSURLQueryItem(name: "url", value: String(url.absoluteString))
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
                            do {
                                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                                print(json)
                            } catch {
                                print("error")
                            }
                        })
                        
                        task.resume()
                        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                    }
                    
                    return
                }
                
                if attachment.isText {
                    
                }
            }
        }
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
