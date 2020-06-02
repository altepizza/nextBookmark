//
//  BookmarkFolderView.swift
//  nextBookmark
//
//  Created by Kai Rieger on 31.05.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI

struct BookmarksFolderView: View {
    @ObservedObject var model: Model
    @State private var searchText: String = ""
    @State var current_root_folder: Folder
    @State var order_bookmarks = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.order_bookmarks) ?? "newest first"
    
    var body: some View {
        
        LoadingView(isShowing: $model.isShowing) {
            NavigationView{
                VStack{
                    SearchBar(text: self.$searchText, placeholder: "Filter bookmarks")
                    
                    List {
                        ForEach(self.model.sorted_filtered_bookmarks_of_folder(searchText: self.searchText, folder: self.current_root_folder), id: \.id)
                        { book in
                            BookmarkRow(main_model: self.model, book: book)
                        }
                        .onDelete(perform: self.delete)
                    }
                }
                .pullToRefresh(isShowing: self.$model.isShowing) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        CallNextcloud(data: self.model).get_all_bookmarks()
                        CallNextcloud(data: self.model).get_tags()
                    }
                }
                .navigationBarTitle(Text(self.current_root_folder.title), displayMode: .inline)
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    func delete(row: IndexSet) {
        for index in row {
            let real_index = model.bookmarks.firstIndex{$0.id == self.model.sorted_filtered_bookmarks_of_folder(searchText: self.searchText, folder: self.current_root_folder)[index].id}
            CallNextcloud(data: self.model).delete(bookId: model.bookmarks[real_index!].id)
            debugPrint(self.model.sorted_filtered_bookmarks(searchText: self.searchText)[index].title)
            debugPrint(model.bookmarks[real_index!].title)
            model.bookmarks.remove(at: real_index!)
        }
    }
}

struct BookmarkFolderView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksFolderView(model: Model(), current_root_folder: Folder(id: -1, title: "String", parent_folder_id: -1, isExpanded: false, full_path: "String"))
    }
}
