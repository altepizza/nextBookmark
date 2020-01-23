//
//  BookmarksView.swift
//  nextBookmark
//
//  Created by Kai on 30.10.19.
//  Copyright © 2019 Kai. All rights reserved.
//

import SwiftUI
import SwiftyJSON
import SwiftUIRefresh

let sharedUserDefaults = UserDefaults(suiteName: SharedUserDefaults.suiteName)

struct BookmarksView: View {
    @State private var isShowing = false
    
    @State var bookmarks: [Bookmark] = [
        .init(id: 0, title: "<Placeholder>", url: "about:blank"),
    ]
    let usernameFromSettings = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.username) ?? "Username"
    let passwordFromSettings = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.password) ?? "Password"
    let urlFromSettings = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.url) ?? "https://you-nextcloud.instance"
    
    var body: some View {
        NavigationView{
            List {
                ForEach(bookmarks) { book in
                    BookmarkRow(book: book)
                }
                .onDelete(perform: delete)
                
            }.navigationBarTitle("Bookmarks", displayMode: .inline)
                .navigationBarItems(trailing: NavigationLink(destination: SettingsView(server: urlFromSettings, username: usernameFromSettings, password: passwordFromSettings)) {
                    Text("Settings")})
                .pullToRefresh(isShowing: $isShowing) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        CallNextcloud().get_bookmarks() { bookmarks in
                            if let bookmarks = bookmarks {
                                self.bookmarks = bookmarks
                                self.isShowing = false
                            }
                        }
                    }
            }
        }
    }
    
    func delete(at offsets: IndexSet) {
        for index in offsets {
            let book = bookmarks[index]
            CallNextcloud().delete(bookId: book.id)
            bookmarks.remove(at: index)
        }
    }
}

struct BookmarkRow: View {
    let book: Bookmark
    var body: some View {
        VStack (alignment: .leading) {
            Text(book.title).font(.headline)
            Text(book.url).font(.subheadline).lineLimit(nil)
        }
        .onTapGesture {
            debugPrint("TAPTEST")
            debugPrint(self.book.url)
            guard let url = URL(string: self.book.url) else { return }
            UIApplication.shared.open(url)
        }
        
    }
}

struct BookmarksView_Previews: PreviewProvider {
    @State var bookmarks: [Bookmark] = [
        .init(id: 0, title: "Google", url: "https://google.com"),
    ]
    static var previews: some View {
        BookmarksView()
    }
}
