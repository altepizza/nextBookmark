//
//  TagsView.swift
//  nextBookmark
//
//  Created by Kai Rieger on 30.05.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI

struct TagsView: View {
    @ObservedObject var model: Model

    var body: some View {
        NavigationView {
            List {
                ForEach(self.model.tags, id: \.self) { tag in
                    NavigationLink(destination: BookmarksTagView(model: self.model, current_tag: tag)) {
                        HStack {
                            Text(tag)
                            Spacer()
                            Text(String(self.model.tag_count[tag] ?? 0))
                        }
                    }
                }.onDelete(perform: { row in
                    self.delete(row: row)
                })
            }
            .navigationBarTitle("Tags", displayMode: .inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func delete(row: IndexSet) {
        for index in row {
            CallNextcloud(data: self.model).delete_tag(tag: self.model.tags[index])
        }
    }
}



struct TagsView_Previews: PreviewProvider {
    static var previews: some View {
        TagsView(model: Model())
    }
}
