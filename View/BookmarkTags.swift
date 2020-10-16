//
//  BookmarkTags.swift
//  nextBookmark
//
//  Created by Kai Rieger on 20.05.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI
import Combine

struct BookmarkTagsRow: View {
    @EnvironmentObject var model: Model
    let tag: String
    @State var checked_tag = false
    
    var body: some View {
        Button(action: {
            self.checked_tag.toggle()
            if (self.model.editing_bookmark.tags.contains(self.tag)) {
                self.model.editing_bookmark.tags.removeAll { $0 == self.tag }
            } else {
                self.model.editing_bookmark.tags.append(self.tag)
            }
        }) {
            HStack {
                Text(tag)
                Spacer()
                if (checked_tag) {
                    Image(systemName: "checkmark")
                }
            }.contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear() {
            self.checked_tag = self.model.editing_bookmark.tags.contains(self.tag)
        }
    }
}


struct BookmarkTags: View {
    @EnvironmentObject var model: Model    
    @State private var new_tag: String = ""
    
    var body: some View {
        Form {
            Section (header: Text("Tag(s)")) {
                List {
                    ForEach(self.model.tags, id: \.self) {
                        tag in
                        BookmarkTagsRow(tag: tag)
                    }
                }
            }
            Section (header: Text("New Tag")) {
                TextField("Enter your new tag", text: $new_tag)
                Button(action: {
                    self.model.tags.append(self.new_tag)
                }) {
                    Text("Add this tag")
                }
            }
        }
        .navigationBarTitle(Text("Tags"), displayMode: .inline)
    }
}

struct BookmarkTags_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkTags()
    }
}
