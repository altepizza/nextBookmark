//
//  SettingsView.swift
//  nextBookmark
//
//  Created by Kai on 20.10.19.
//  Copyright © 2019 Kai. All rights reserved.
//

import SwiftUI
import NotificationBannerSwift
import Alamofire
import Combine

let sharedUserDefaults = UserDefaults(suiteName: SharedUserDefaults.suiteName)

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

struct SettingsView: View {
    @State private var keyboardHeight: CGFloat = 0
    let orders = ["newest first", "oldest first"]
    
    @ObservedObject var main_model: Model
    
    var body: some View {
        NavigationView{
            VStack {
                Form {
                    Section(header: Text("Nextcloud credentials")) {
                        TextField("https://your-nextcloud.instance", text: $main_model.credentials_url)
                            .keyboardType(.URL)
                        TextField("Your Username", text: $main_model.credentials_user)
                        SecureField("Your Password", text: $main_model.credentials_password)
                        Text("Please create and use an 'app password' if you are using Two-Factor Authentication").font(.subheadline)
                    }
                    Section(header: Text("Upload")) {
                        Text("Where to upload new bookmarks").font(.subheadline)
                        Picker(selection: $main_model.default_upload_folder, label: Text("Target Folder")){
                            ForEach(main_model.folders, id: \.self) { folder in
                                Text(verbatim: folder.full_path)
                            }
                        }
                    }
                    Section(header: Text("Visuals")) {
                        Text("Altering these settings might take a couple of seconds to load").font(.subheadline)
                        Picker(selection: $main_model.order_bookmarks, label: Text("Order bookmarks by")){
                            ForEach(orders, id: \.self) { order in
                                Text(verbatim: order)
                            }
                        }
                        Toggle(isOn: $main_model.full_title) {
                            Text("Show full bookmark title")
                        }
                    }
                }
                
                Spacer()
                
                Button(action: {
                    self.saveSettings()
                }) {
                    Text("Save And Test Settings").padding()
                }
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(40)
            }
            .padding(.bottom, keyboardHeight).animation(.easeInOut(duration:0.5))
            .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
        }.navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink(destination: ThanksView()) {
                Text("About")})
            .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func show_error_banner(banner: NotificationBanner, subtitle: String) {
        banner.dismiss()
        banner.autoDismiss = true
        let new_banner = NotificationBanner(title: "Error", subtitle: subtitle, style: .danger)
        new_banner.show()
    }
    
    func saveSettings() {
        var banner = NotificationBanner(title: "Testing connection", subtitle: "", style: .warning)
        banner.autoDismiss = false
        banner.show()
        main_model.credentials_url = main_model.credentials_url.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if NSURL(string: main_model.credentials_url) != nil {
            if (main_model.credentials_url.starts(with: "https://")) {
                var headers: HTTPHeaders
                headers = [
                    .authorization(username: main_model.credentials_user, password: main_model.credentials_password),
                    .accept("application/json")
                ]
                AF.request(main_model.credentials_url + "/index.php/apps/bookmarks/public/rest/v2/bookmark?page=0", headers: headers)
                    .validate(statusCode: 200..<300)
                    .responseJSON { response in
                        switch response.result {
                        case .success( _):
                            banner.dismiss()
                            banner.autoDismiss = true
                            banner = NotificationBanner(title: "Connection successful", style: .success)
                            sharedUserDefaults?.set(true, forKey: SharedUserDefaults.Keys.valid)
                            banner.show()
                            CallNextcloud(data: self.main_model).requestFolderHierarchy()
                            CallNextcloud(data: self.main_model).get_all_bookmarks()
                        case .failure( _):
                            self.show_error_banner(banner: banner, subtitle: "Cannot login to Nextcloud Bookmarks. Please check you credentials")
                        }
                }
            }
            else {
                show_error_banner(banner: banner, subtitle: "Your URL dosn't start with 'https://'. Only SSL encrypted connections are supported")
            }
            
        }
        else {
            show_error_banner(banner: banner, subtitle: "Invalid URL")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(main_model: Model())
    }
}
