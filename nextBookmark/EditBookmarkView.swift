//
//  EditBookmarkView.swift
//  nextBookmark
//
//  Created by Kai Rieger on 27.04.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI
import Combine

struct Editable_Bookmark: View {
    let headline: String
    let containsURL: Bool
    let key: String
    let binding: Binding<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0.2) {
            Text(headline)
                .font(.headline)
                if containsURL {
                    TextField(key, text: binding)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.URL)
                }
                else {
                    TextField(key, text: binding)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
        }.padding(.all)
    }
}

struct EditBookmarkView: View {
    @State private var keyboardHeight: CGFloat = 0
    @ObservedObject var vm: Model
    @State var bookmark: Bookmark
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        VStack {
            Text("Edit Bookmark").font(.title)
            Spacer()
            Editable_Bookmark(headline: "Title", containsURL: false, key: "title", binding: $bookmark.title)
            Editable_Bookmark(headline: "URL", containsURL: true, key: "url", binding: $bookmark.url)
            Editable_Bookmark(headline: "Description", containsURL: true, key: "description", binding: $bookmark.description)
            Spacer()
            Button(action: {
                self.vm.isShowing = true
                self.presentationMode.wrappedValue.dismiss()
                CallNextcloud(data: self.vm).update_bookmark(bookmark: self.bookmark)
            }) {
                Text("Update bookmark")
            }
            Spacer()
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }
        }
        .padding()
        .padding(.bottom, keyboardHeight).animation(.easeInOut(duration:0.5))
        .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
    }
}

struct EditBookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        EditBookmarkView(vm: Model(), bookmark: Bookmark(id: 1, added: 1, title: "EDITTITLE", url: "EDITURL", tags: ["EDITTAG"], folder_ids: [1], description: "EDITDES"))
    }
}
