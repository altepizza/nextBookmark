//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Kai on 30.08.19.
//  Copyright © 2019 Kai. All rights reserved.
//

import UIKit
import MobileCoreServices
import JGProgressHUD

extension NSItemProvider {
    var isText: Bool {
        hasItemConformingToTypeIdentifier(kUTTypePlainText as String)
    }
    
    var isURL: Bool {
        hasItemConformingToTypeIdentifier(kUTTypeURL as String)
    }
    
    func getUrl(completion: @escaping (String) -> Void) {
        loadItem(forTypeIdentifier: kUTTypeURL as String, options: nil) { (url, _) -> Void in
            completion((url as? NSURL)!.absoluteString!)
        }
    }
    
    // swiftlint:disable force_cast
    func getText(completion: @escaping (String) -> Void) {
        loadItem(forTypeIdentifier: kUTTypePlainText as String, options: nil) { (text, _) -> Void in
            completion(text as! String)
        }
    }
}

@objc(ShareViewController)
class ShareViewController: UIViewController {
    let loading = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(blurEffectView, at: 0)
        loading.textLabel.text = "Uploading"
        loading.show(in: self.view)
    }
        
    override func viewWillAppear(_: Bool) {
        self.getUrl { shareURL in
            guard let shareURL = shareURL else {
                return
            }
            CallNextcloud(data: Model()).postURL(url: shareURL, completionHandler: { upload_status in
                let status = JGProgressHUD(style: .dark)
                let generator = UINotificationFeedbackGenerator()
                self.loading.dismiss(animated: true)
                if upload_status! {
                    status.indicatorView = JGProgressHUDSuccessIndicatorView()
                    status.textLabel.text = "Success"
                } else {
                    status.indicatorView = JGProgressHUDErrorIndicatorView()
                    status.textLabel.text = "Error"
                }
                status.show(in: self.view, animated: true)
                if upload_status! {
                    generator.notificationOccurred(.success)
                } else {
                    generator.notificationOccurred(.error)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                }
            })
        }
    }
    
    private func getUrl(completion: @escaping (String?) -> Void) {
        guard let item = extensionContext?.inputItems.first as? NSExtensionItem else {
            completion(nil)
            return
        }
        
        item.attachments?.forEach { attachment in
            if attachment.isURL {
                attachment.getUrl { completion($0) }
            }
            if attachment.isText {
                attachment.getText { text in
                    if text.hasPrefix("http") {
                        completion(text)
                    }
                }
            }
        }
    }
}


