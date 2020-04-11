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
    @State var server = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.url) ?? "https://you-nextcloud.instance"
    @State var username = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.username) ?? "Username"
    @State var password = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.password) ?? "Password"
    
    struct Setting: View {
        let headline: String
        let binding: Binding<String>
        let key: String
        let isSecret: Bool
        let containsURL: Bool
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0.2) {
                Text(headline)
                    .font(.headline)
                if isSecret {
                    SecureField(key, text: binding)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                else {
                    if containsURL {
                        TextField(key, text: binding)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.URL)
                    }
                    else {
                        TextField(key, text: binding)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
            }.padding(.all)
        }
    }
    
    var body: some View {
        NavigationView{
            VStack() {
                Setting(headline: "Nextcloud URL", binding: $server, key: "server", isSecret: false, containsURL: true)
                Setting(headline: "Nextcloud Username", binding: $username, key: "username", isSecret: false, containsURL: false)
                Setting(headline: "Nextcloud Password", binding: $password, key: "password", isSecret: true, containsURL: false)
                Spacer()
                Button(action: {
                    self.saveSettings()
                }) {
                    Text("Save And Test Settings").padding()
                }
            }
            .padding()
            .padding(.bottom, keyboardHeight).animation(.easeInOut(duration:0.5))
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
        var banner = NotificationBanner(title: "Testing connection", subtitle: "", style: .warning)
        banner.autoDismiss = false
        banner.show()
        if NSURL(string: server) != nil {
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
                        debugPrint("AF worked")
                        banner.dismiss()
                        banner.autoDismiss = true
                        banner = NotificationBanner(title: "Success", subtitle: "Can connect to Nextcloud Bookmarks", style: .success)
                        sharedUserDefaults?.set(true, forKey: SharedUserDefaults.Keys.valid)
                        banner.show()
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
        SettingsView(server: "defaultURL", username: "defaultUser", password: "defaultPassword")
    }
}
