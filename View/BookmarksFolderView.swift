//
//  BookmarkFolderView.swift
//  nextBookmark
//
//  Created by Kai Rieger on 31.05.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI

struct sortButtonView: View {
    @EnvironmentObject var model: Model
    var body: some View {
        Button {
            model.cycle_to_next_sort_option()
        } label: {
            HStack {
                if model.order_bookmarks == "NEWEST" {
                    Image(systemName: "arrow.up.arrow.down.square").imageScale(.large)
                    Image(systemName: "calendar")
                } else if model.order_bookmarks == "OLDEST" {
                    Image(systemName: "arrow.up.arrow.down.square.fill").imageScale(.large)
                    Image(systemName: "calendar")
                } else if model.order_bookmarks == "AZ" {
                    Image(systemName: "arrow.up.arrow.down.square").imageScale(.large)
                    Image(systemName: "textformat.abc")
                } else if model.order_bookmarks == "ZA" {
                    Image(systemName: "arrow.up.arrow.down.square.fill").imageScale(.large)
                    Image(systemName: "textformat.abc")
                }
            }
        }
    }
}

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
                    
                    ForEach(self.model.get_relevant_bookmarks(search_text: self.searchText, folder: self.current_root_folder), id: \.id)
                    { book in
                        BookmarkRow(book: book)
                    }
                    .onDelete(perform: self.delete)
                }
                .pullToRefresh(isShowing: self.$model.isShowing) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        model.middleware(data: self.model).get_all_bookmarks()
                        model.middleware(data: self.model).get_tags()
                    }
                }
            }
            .navigationBarTitle(Text(self.current_root_folder.title), displayMode: .inline)
            .navigationBarItems(
                leading: sortButtonView(),
                trailing: Button(action: {
                    self.model.editing_bookmark = create_empty_bookmark(folder_id: self.model.currentRoot.id)
                    self.show_new_bookmark_modal = true
                }) {
                    Image(systemName: "plus").imageScale(.large).padding([.leading, .top, .bottom])
                }.disabled(!model.weAreOnline)
            )
            .sheet(isPresented: self.$show_new_bookmark_modal, onDismiss: {}) {
                BookmarkDetailView(bookmark: create_empty_bookmark(), bookmark_folder: self.current_root_folder).environmentObject(self.model)
            }
        }
    }
    
    func delete(row: IndexSet) {
        for index in row {
            let real_index = model.bookmarks.firstIndex{$0.id == self.model.get_relevant_bookmarks(search_text: self.searchText, folder: self.current_root_folder)[index].id}
            model.middleware(data: self.model).delete(bookId: model.bookmarks[real_index!].id)
            model.bookmarks.remove(at: real_index!)
        }
    }
}

struct BookmarkFolderView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksFolderView(current_root_folder: Folder(id: -1, title: "String", parent_folder_id: -1, full_path: "String"))
    }
}
