//
//  TagsView.swift
//  nextBookmark
//
//  Created by Kai Rieger on 30.05.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI

struct TagsView: View {
    @EnvironmentObject var model: Model

    var body: some View {
        NavigationView {
            List {
                ForEach(self.model.tags, id: \.self) { tag in
                    NavigationLink(destination: BookmarksTagView(current_tag: tag)) {
                        HStack {
                            Text(tag)
                            Spacer()
                            Text(String(self.model.tag_count[tag] ?? 0))
                        }
                    }
                }
            }
            .navigationBarTitle("Tags", displayMode: .inline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct TagsView_Previews: PreviewProvider {
    static var previews: some View {
        TagsView()
    }
}
