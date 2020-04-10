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
    
    @State var folders: [Folder] = [
        .init(id: -20, title: "<Pull down to load your bookmarks>",  parent_folder_id: -10, books: [])
    ]
    
    var body: some View {
        NavigationView{
            VStack{
                List {
                    ForEach(folders) { folder in
                        FolderRow(folder: folder)
                        ForEach(folder.books) { book in
                            BookmarkRow(book: book)
                        }
                        .onDelete(perform: { row in
                            self.delete(folder: folder, row: row)
                        })
                    }
                }
            }
            .pullToRefresh(isShowing: $isShowing) {
                self.startUpCheck()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    CallNextcloud().requestFolderHierarchy() { jason in
                        if let jason = jason {
                            self.folders =  CallNextcloud().makeFolders(json: jason)
                            self.folders.append(Folder(id: -1, title: "/", parent_folder_id: -1, books: []))
                            for i in self.folders.indices {
                                let fff = self.folders[i] as Folder
                                CallNextcloud().get_all_bookmarks_for_folder(folder: fff) { bookmarks in
                                    if let bookmarks = bookmarks {
                                        self.folders[i].books = bookmarks
                                        self.isShowing = false
                                    }
                                }
                            }
                        }
                    }
                }
            }.navigationBarTitle("Bookmarks", displayMode: .inline)
                .navigationBarItems(trailing: NavigationLink(destination: SettingsView()) {
                    Text("Settings")})
        }.navigationViewStyle(StackNavigationViewStyle())
        .onAppear() {
            CallNextcloud().requestFolderHierarchy() { jason in
                if let jason = jason {
                    self.folders =  CallNextcloud().makeFolders(json: jason)
                    self.folders.append(Folder(id: -1, title: "/", parent_folder_id: -1, books: []))
                    for i in self.folders.indices {
                        let fff = self.folders[i] as Folder
                        CallNextcloud().get_all_bookmarks_for_folder(folder: fff) { bookmarks in
                            if let bookmarks = bookmarks {
                                self.folders[i].books = bookmarks
                                self.isShowing = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    func startUpCheck() {
        let validConnection = sharedUserDefaults?.bool(forKey: SharedUserDefaults.Keys.valid)
        if !(validConnection ?? false) {
            let banner = NotificationBanner(title: "Missing Credentials", subtitle: "Please enter valid Nextcloud credentials in 'Settings'", style: .warning)
            banner.show()
        }
    }
    
    
    func delete(folder: Folder, row: IndexSet) {
        for index in row {
            for i in self.folders.indices {
                if folders[i].id == folder.id {
                    CallNextcloud().delete(bookId: folders[i].books[index].id)
                    folders[i].books.remove(at: index)
                }
            }
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
        HStack(){
            Image(systemName: "folder")
            Text(folder.title).fontWeight(.bold)
        }
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
        BookmarksView(folders : [
            Folder.init(id: -20, title: "<Pull down to load your bookmarks>",  parent_folder_id: -10, books: [Bookmark.init(id: 1, title: "Title", url: "http://localhost", tags: ["tag", "tag"], folder_ids: [-20])])
        ])
    }
}
