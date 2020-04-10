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
    // 1.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // 2.
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        // 3.
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}


struct SettingsView: View {
    @State private var keyboardHeight: CGFloat = 0
    @State var server = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.url) ?? "https://you-nextcloud.instance"
    @State var username = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.username) ?? "Username"
    @State var password = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.password) ?? "Password"

    var body: some View {
        NavigationView{
            VStack() {
                VStack(alignment: .leading, spacing: 0.2 ) {
                    Text("Nextcloud URL")
                    TextField("server", text: $server)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }.padding(.all)
                
                VStack(alignment: .leading, spacing: 0.2 ) {
                Text("Nextcloud Username")
                TextField("username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }.padding(.all)
                
                VStack(alignment: .leading, spacing: 0.2 ) {
                Text("Nextcloud Password")
                SecureField("password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }.padding(.all)
                
                Spacer()
                Button(action: {
                    self.saveSettings()
                }) {
                    Text("Save Settings").padding()
                }
            }//.padding(.horizontal, 15)
            .padding()
            .padding(.bottom, keyboardHeight)
            .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
        }.navigationBarTitle("Settings", displayMode: .inline)
        .navigationBarItems(trailing: NavigationLink(destination: ThanksView()) {
                Text("About")})
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func saveSettings() {
        sharedUserDefaults?.set(server, forKey: SharedUserDefaults.Keys.url)
        sharedUserDefaults?.set(username, forKey: SharedUserDefaults.Keys.username)
        sharedUserDefaults?.set(password, forKey: SharedUserDefaults.Keys.password)
        hello_world()
    }
    
    func hello_world() {
        let banner = NotificationBanner(title: "Testing connection", subtitle: "", style: .warning)
        banner.autoDismiss = false
        banner.show()
        var headers: HTTPHeaders

        headers = [
            .authorization(username: username, password: password),
            .accept("application/json")
        ]
        AF.request(server + "/index.php/apps/bookmarks/public/rest/v2/bookmark?page=0", headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success( _):
                    banner.dismiss()
                    let banner = NotificationBanner(title: "Success", subtitle: "Can connect to Nextcloud Bookmarks", style: .success)
                    sharedUserDefaults?.set(true, forKey: SharedUserDefaults.Keys.valid)
                    banner.show()
                case .failure( _):
                    let banner = NotificationBanner(title: "Error", subtitle: "Cannot login to Nextcloud Bookmars", style: .danger)
                    sharedUserDefaults?.set(false, forKey: SharedUserDefaults.Keys.valid)
                    banner.show()
                }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(server: "defaultURL", username: "defaultUser", password: "defaultPassword")
    }
}
