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
        NavigationLink(destination: BookmarksFolderView(current_root_folder: folder)) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "folder.fill")
                    Text(folder.title).fontWeight(.bold)
                }
            }
        }
    }
}

struct BookmarkRow: View {
    @EnvironmentObject var model: Model
    @State private var showModal = false
    let book: Bookmark
    @State var editing_bookmark_folder = create_root_folder()
    @State var tapped_bookmark = create_empty_bookmark()
    var body: some View {
        HStack{
            VStack (alignment: .leading) {
                if (model.full_title) {
                    Text(book.title).fontWeight(.bold)
                }
                else {
                    Text(book.title).fontWeight(.bold).lineLimit(1)
                }
                if tagsAvailable(for: book) {
                    Text((book.tags.joined(separator:", "))).font(.footnote).lineLimit(1)
                }
                Text(book.url).font(.footnote).lineLimit(1).foregroundColor(Color.gray)
            }.onTapGesture {
                self.editing_bookmark_folder = self.model.folders.filter({ $0.id == self.book.folders.first }).first ?? create_root_folder()
                self.model.editing_bookmark = self.book
                self.tapped_bookmark = self.book
                self.showModal = true
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
        }.sheet(isPresented: $showModal, onDismiss: {
            print(self.showModal)
        }) {
            BookmarkDetailView(bookmark: self.tapped_bookmark, bookmark_folder: self.editing_bookmark_folder).environmentObject(self.model)
        }
    }
}

struct BookmarksView: View {
    @EnvironmentObject var model: Model
    @State private var searchText : String = ""
    @State var order_bookmarks = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.order_bookmarks) ?? "newest first"
    
    var body: some View {
        NavigationView{
            BookmarksFolderView(current_root_folder: self.model.currentRoot)
        }.navigationViewStyle(StackNavigationViewStyle())

    }
    
    func startUpCheck() {
        let validConnection = sharedUserDefaults?.bool(forKey: SharedUserDefaults.Keys.valid) ?? false
        if !validConnection {
            let banner = NotificationBanner(title: "Missing Credentials", subtitle: "Please enter valid Nextcloud credentials in 'Settings'", style: .warning)
            banner.show()
        }
    }
    
    func delete(row: IndexSet) {
        for index in row {
            let real_index = model.bookmarks.firstIndex{$0.id == self.model.sorted_filtered_bookmarks(searchText: self.searchText)[index].id}
            CallNextcloud(data: self.model).delete(bookId: model.bookmarks[real_index!].id)
            debugPrint(self.model.sorted_filtered_bookmarks(searchText: self.searchText)[index].title)
            debugPrint(model.bookmarks[real_index!].title)
            model.bookmarks.remove(at: real_index!)
        }
    }
}

private func tagsAvailable(for book: Bookmark) -> Bool {
    if (book.tags.isEmpty) {
        return false
    }
    return true
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


struct ActivityIndicator: UIViewRepresentable {
    
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct LoadingView<Content>: View where Content: View {
    
    @Binding var isShowing: Bool
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                
                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)
                
                VStack {
                    Text("Loading...")
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                    .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}

struct BookmarksView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksView()
    }
}
