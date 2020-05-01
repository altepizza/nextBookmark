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
            VStack() {
                Form {
                    Section(header: Text("Nextcloud credentials")) {
                        TextField("https://your-nextcloud.instance", text: $main_model.credentials_url)
                        .keyboardType(.URL)
                        TextField("Your Username", text: $main_model.credentials_user)
                        SecureField("Your Password", text: $main_model.credentials_password)
                    }
                    Section(header: Text("Visuals")) {
                        Text("Altering these settings might take a couple of seconds to load").font(.subheadline)
                        Picker(selection: $main_model.order_bookmarks, label: Text("Order bookmarks by")){
                            ForEach(orders, id: \.self) { order in
                                Text(verbatim: order)
                            }
                        }
                    }
                }
                Spacer()
                Button(action: {
                    self.saveSettings()
                }) {
                    Text("Save And Test Settings").padding()
                }
            }
            .padding(.bottom, keyboardHeight).animation(.easeInOut(duration:0.5))
            .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
        }.navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(trailing: NavigationLink(destination: ThanksView()) {
                Text("About")})
            .navigationViewStyle(StackNavigationViewStyle())
    }
        
    func saveSettings() {
        hello_world()
    }
    
    func hello_world() {
        var banner = NotificationBanner(title: "Testing connection", subtitle: "", style: .warning)
        banner.autoDismiss = false
        banner.show()
        if NSURL(string: main_model.credentials_url) != nil {
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
                        debugPrint("AF worked")
                        banner.dismiss()
                        banner.autoDismiss = true
                        banner = NotificationBanner(title: "Connection successful", subtitle: "Credentials saved", style: .success)
                        sharedUserDefaults?.set(true, forKey: SharedUserDefaults.Keys.valid)
                        banner.show()
                        CallNextcloud(data: self.main_model).requestFolderHierarchy()
                        CallNextcloud(data: self.main_model).get_all_bookmarks()
                    case .failure( _):
                        debugPrint("AF fail")
                        banner.dismiss()
                        banner.autoDismiss = true
                        banner = NotificationBanner(title: "Error", subtitle: "Cannot login to Nextcloud Bookmarks", style: .danger)
                        sharedUserDefaults?.set(false, forKey: SharedUserDefaults.Keys.valid)
                        banner.show()
                    }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(main_model: Model())
    }
}
