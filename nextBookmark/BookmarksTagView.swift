//
//  BookmarksTagView.swift
//  nextBookmark
//
//  Created by Kai Rieger on 31.05.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI

struct BookmarksTagView: View {
    @ObservedObject var model: Model
    @State private var searchText: String = ""
    @State var current_tag: String
    @State var order_bookmarks = sharedUserDefaults?.string(forKey: SharedUserDefaults.Keys.order_bookmarks) ?? "newest first"
    
    var body: some View {
        
        LoadingView(isShowing: $model.isShowing) {
            NavigationView{
                VStack{
                    SearchBar(text: self.$searchText, placeholder: "Filter bookmarks")
                    
                    List {
                        ForEach(self.model.sorted_filtered_bookmarks_of_tag(searchText: self.searchText, tag: self.current_tag), id: \.id)
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
                .navigationBarTitle(Text(self.current_tag), displayMode: .inline)
            }.navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    func delete(row: IndexSet) {
        for index in row {
            let real_index = model.bookmarks.firstIndex{$0.id == self.model.sorted_filtered_bookmarks_of_tag(searchText: self.searchText, tag: self.current_tag)[index].id}
            CallNextcloud(data: self.model).delete(bookId: model.bookmarks[real_index!].id)
            debugPrint(self.model.sorted_filtered_bookmarks_of_tag(searchText: self.searchText, tag: self.current_tag))
            debugPrint(model.bookmarks[real_index!].title)
            model.bookmarks.remove(at: real_index!)
        }
    }
}

struct BookmarksTagView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarksTagView(model: Model(), current_tag: "String")
    }
}
