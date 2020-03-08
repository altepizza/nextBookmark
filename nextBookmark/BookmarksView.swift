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
import NotificationBannerSwift

struct BookmarksView: View {
    @State private var isShowing = false
    
    @State var bookmarks: [Bookmark] = [
        .init(id: 0, title: "<Pull down to load your bookmarks>", url: "about:blank", tags: ["placeholder tag"], folder_ids: [-1]),
    ]
    
    @State var folders: [Folder] = [
        .init(id: -1, title: "/", parent_folder_id: -1),
    ]
    
    var body: some View {
        NavigationView{
            VStack{
                List {
                    ForEach(folders) { folder in
                        FolderRow(folder: folder)
                        ForEach(self.bookmarks) { book in
                            BookmarkRow(book: book)
                        }
                        .onDelete(perform: self.delete)
                    }
                }
            }
            .pullToRefresh(isShowing: $isShowing) {
                self.startUpCheck()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.folders = CallNextcloud().getAllFolders()
                    debugPrint("IN UI AFTER FOLDERS")
                    debugPrint(self.folders)
                    CallNextcloud().get_all_bookmarks() { bookmarks in
                        if let bookmarks = bookmarks {
                            self.bookmarks = bookmarks
                            self.isShowing = false
                        }
                    }
                    CallNextcloud().requestFolderHierarchy() { jason in
                        if let jason = jason {
                            self.folders =  CallNextcloud().makeFolders(json: jason)
                        }
                    }
                }
            }.navigationBarTitle("Bookmarks", displayMode: .inline)
                .navigationBarItems(trailing: NavigationLink(destination: SettingsView()) {
                    Text("Settings")})
        }.onAppear() {
            CallNextcloud().get_all_bookmarks() { bookmarks in
                if let bookmarks = bookmarks {
                    self.bookmarks = bookmarks
                }
            }
        }
    }
    
    func startUpCheck() {
        let validConnection = sharedUserDefaults?.bool(forKey: SharedUserDefaults.Keys.valid)
        debugPrint(validConnection)
        if !(validConnection ?? false) {
            let banner = NotificationBanner(title: "Missing Credentials", subtitle: "Please enter valid Nextcloud credentials in 'Settings'", style: .warning)
            banner.show()
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
            Text(book.title).fontWeight(.bold)
            if tagsAvailable(for: book) {
                Text((book.tags.joined(separator:", "))).font(.footnote).lineLimit(1)
            }
            Text(book.url).font(.footnote).lineLimit(1).foregroundColor(Color.gray)
        }
        .onTapGesture {
            debugPrint(self.book.url)
            guard let url = URL(string: self.book.url) else { return }
            UIApplication.shared.open(url)
        }
    }
}

struct FolderRow: View {
    let folder: Folder
    var body: some View {
        Text(folder.title).fontWeight(.bold)
    }
}

private func tagsAvailable(for book: Bookmark) -> Bool {
    if (book.tags.isEmpty) {
        return false
    }
    return true
}

struct BookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksView()
    }
}
