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
                }
            }
            .navigationBarTitle("Tags", displayMode: .inline)
        }
    }
}

struct TagsView_Previews: PreviewProvider {
    static var previews: some View {
        TagsView(model: Model())
    }
}
