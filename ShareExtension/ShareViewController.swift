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
                        CallNextcloud().postURL(url: url.absoluteString)
                        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                    }
                }
                
                if attachment.isText {
                    }
                }
            }
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
