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

struct OpenFolderRow: View {
    var folder: Folder
    var body: some View {
        HStack(){
            Image(systemName: "folder")
            Text(folder.title).fontWeight(.bold)
        }
    }
}

struct FolderRow: View {
    var folder: Folder
    var body: some View {
        HStack(){
            Image(systemName: "folder.fill")
            Text(folder.title).fontWeight(.bold)
        }
    }
}

struct BackFolderRow: View {
    var body: some View {
        HStack(){
            Image(systemName: "arrowshape.turn.up.left")
        }
    }
}

struct BookmarkRow: View {
    let book: Bookmark
    var body: some View {
        HStack(){
            VStack (alignment: .leading) {
                Text(book.title).fontWeight(.bold)
                if tagsAvailable(for: book) {
                    Text((book.tags.joined(separator:", "))).font(.footnote).lineLimit(1)
                }
                Text(book.url).font(.footnote).lineLimit(1).foregroundColor(Color.gray)
            }.onTapGesture {
                debugPrint("TODO EDIT BOOKMARK")
            }
            Spacer()
            Divider()
            Button(action: {
                guard let url = URL(string: self.book.url) else { return }
                UIApplication.shared.open(url)
            }) {
                Image(systemName: "safari")
            }
            .padding(.leading)
        }
    }
}

struct BookmarksView: View {
    @ObservedObject var vm: Model = Model()
    @State private var searchText : String = ""
    private let defaultFolder: Folder = .init(id: -20, title: "<Pull down to load your bookmarks>",  parent_folder_id: -10, books: [])

    var body: some View {
        NavigationView{
            VStack{
                SearchBar(text: $searchText, placeholder: "Filter bookmarks")
                
                OpenFolderRow(folder: vm.currentRoot)
                
                // Subfolders
                List {
                    if vm.currentRoot.id > -1 {
                        BackFolderRow().onTapGesture {
                            self.vm.currentRoot = self.vm.folders.first(where: {$0.id == self.vm.currentRoot.parent_folder_id})!
                            CallNextcloud(data: self.vm).get_all_bookmarks_for_folder(folder: self.vm.currentRoot)
                        }
                    }
                    
                    
                    ForEach(self.vm.folders.filter {
                        $0.parent_folder_id == vm.currentRoot.id && $0.id != vm.currentRoot.id
                    }) { folder in
                        FolderRow(folder: folder).onTapGesture {
                            self.vm.currentRoot = folder
                            CallNextcloud(data: self.vm).get_all_bookmarks_for_folder(folder: self.vm.currentRoot)
                        }}
                    ForEach(vm.currentRoot.books.filter {
                        self.searchText.isEmpty ? true : $0.title.lowercased().contains(self.searchText.lowercased()) || $0.url.lowercased().contains(self.searchText.lowercased())
                    }) { book in
                        BookmarkRow(book: book)
                    }
                    .onDelete(perform: { row in
                        self.delete(folder: self.vm.currentRoot, row: row)
                    })
                    
                }
            }
            .pullToRefresh(isShowing: $vm.isShowing) {
                self.startUpCheck()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    CallNextcloud(data: self.vm).get_all_bookmarks_for_folder(folder: self.vm.currentRoot)
                }
            }.navigationBarTitle("Bookmarks", displayMode: .inline)
                .navigationBarItems(
                    trailing: NavigationLink(destination: SettingsView()) {
                        Text("Settings")} )
            
        }.navigationViewStyle(StackNavigationViewStyle())
            .onAppear() {
                CallNextcloud(data: self.vm).requestFolderHierarchy()
                    CallNextcloud(data: self.vm).get_all_bookmarks_for_folder(folder: self.vm.currentRoot)
        }
    }
    
    func startUpCheck() {
        let validConnection = sharedUserDefaults?.bool(forKey: SharedUserDefaults.Keys.valid) ?? false
        if !validConnection {
            let banner = NotificationBanner(title: "Missing Credentials", subtitle: "Please enter valid Nextcloud credentials in 'Settings'", style: .warning)
            banner.show()
        }
    }
    
    func delete(folder: Folder, row: IndexSet) {
        for index in row {
            CallNextcloud(data: self.vm).delete(bookId: folder.books[index].id)
            vm.currentRoot.books.remove(at: index)
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
        BookmarksView()
    }
}

struct SearchBar: UIViewRepresentable {
    
    @Binding var text: String
    var placeholder: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            text = ""
            searchBar.text = ""
            searchBar.resignFirstResponder()
            searchBar.endEditing(true)
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            searchBar.endEditing(true)
        }
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        //searchBar.delegate = context.coordinator
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        searchBar.showsCancelButton = true
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
