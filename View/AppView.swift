//
//  AppView.swift
//  nextBookmark
//
//  Created by Kai Rieger on 30.05.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI

struct AppView: View {
    @EnvironmentObject var model: Model
    var body: some View {
        TabView {
            BookmarksView()
                .tabItem {
                    Image(systemName: "bookmark.fill")
                    Text("Bookmarks")
            }
            
            FoldersView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Folders")
            }
            
            TagsView()
                .tabItem {
                    Image(systemName: "tag.fill")
                    Text("Tags")
            }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
            }
        }.onAppear() {
            if sharedUserDefaults?.bool(forKey: SharedUserDefaults.Keys.valid) ?? false {
                self.model.isShowing = true
                CallNextcloud(data: self.model).requestFolderHierarchy()
                CallNextcloud(data: self.model).get_all_bookmarks()
                CallNextcloud(data: self.model).get_tags()
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView()
    }
}
