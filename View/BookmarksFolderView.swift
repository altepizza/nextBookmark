//
//  BookmarkFolderView.swift
//  nextBookmark
//
//  Created by Kai Rieger on 31.05.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI

struct BookmarksFolderView: View {
    @EnvironmentObject var model: Model
    @State private var searchText: String = ""
    @State var current_root_folder: Folder
    @State private var show_new_bookmark_modal = false
    
    var body: some View {
        LoadingView(isShowing: $model.isShowing) {
            VStack{
                SearchBar(text: self.$searchText, placeholder: "Filter bookmarks")
                List {
                    ForEach(self.model.folders.filter {
                        $0.parent_folder_id == self.current_root_folder.id && $0.id != self.current_root_folder.id
                    }) { folder in
                        FolderRow(folder: folder)
                    }
                    
                    ForEach(self.model.sorted_filtered_bookmarks_of_folder(searchText: self.searchText, folder: self.current_root_folder), id: \.id)
                    { book in
                        BookmarkRow(book: book)
                    }
                    .onDelete(perform: self.delete)
                }
                .pullToRefresh(isShowing: self.$model.isShowing) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        CallNextcloud(data: self.model).get_all_bookmarks()
                        CallNextcloud(data: self.model).get_tags()
                    }
                }
            }
            .navigationBarTitle(Text(self.current_root_folder.title), displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    self.model.editing_bookmark = create_empty_bookmark(folder_id: self.model.currentRoot.id)
                    self.show_new_bookmark_modal = true
                }) {
                    Image(systemName: "plus").imageScale(.large).padding([.leading, .top, .bottom])
                }
            )
            .sheet(isPresented: self.$show_new_bookmark_modal, onDismiss: {}) {
                BookmarkDetailView(bookmark: create_empty_bookmark(), bookmark_folder: self.current_root_folder).environmentObject(self.model)
            }
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
        BookmarksFolderView(current_root_folder: Folder(id: -1, title: "String", parent_folder_id: -1, full_path: "String"))
    }
}
