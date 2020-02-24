//
//  SettingsView.swift
//  nextBookmark
//
//  Created by Kai on 20.10.19.
//  Copyright © 2019 Kai. All rights reserved.
//

import SwiftUI
import NotificationBannerSwift

struct SettingsView: View {
    @State var server: String
    @State var username: String
    @State var password: String
    let sharedUserDefaults = UserDefaults(suiteName: SharedUserDefaults.suiteName)
    
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
                    Text("Save Settings")
                }
            }.padding(.horizontal, 15)
        }.navigationBarTitle("Settings", displayMode: .inline)
        .navigationBarItems(trailing: NavigationLink(destination: ThanksView()) {
                Text("About")})
    }
    
    func saveSettings() {
        sharedUserDefaults?.set(server, forKey: SharedUserDefaults.Keys.url)
        sharedUserDefaults?.set(username, forKey: SharedUserDefaults.Keys.username)
        sharedUserDefaults?.set(password, forKey: SharedUserDefaults.Keys.password)
        CallNextcloud().hello_world()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(server: "defaultURL", username: "defaultUser", password: "defaultPassword")
    }
}
