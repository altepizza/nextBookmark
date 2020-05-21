//
//  BookmarkTags.swift
//  nextBookmark
//
//  Created by Kai Rieger on 20.05.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI

struct BookmarkTagsRow: View {
    var model: Model
    let tag: String
    @State var checked_tag = false

    var body: some View {
        HStack {
            Text(tag)
            Spacer()
            if (checked_tag) {
                Image(systemName: "checkmark")
            }
        }.onTapGesture {
            self.checked_tag.toggle()
            if (self.model.editing_bookmark.tags.contains(self.tag)) {
                self.model.editing_bookmark.tags.removeAll { $0 == self.tag }
            } else {
                self.model.editing_bookmark.tags.append(self.tag)
            }
        }.onAppear() {
            self.checked_tag = self.model.editing_bookmark.tags.contains(self.tag)
        }
    }
}

struct BookmarkTags: View {
    var model: Model
    var body: some View {
        VStack {
            List {
                ForEach(self.model.tags, id: \.self) {
                    tag in
                    BookmarkTagsRow(model: self.model, tag: tag)
                }
            }
        }
    }
}

struct BookmarkTags_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkTags(model: Model())
    }
}
