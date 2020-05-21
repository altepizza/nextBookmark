//
//  EditBookmarkView.swift
//  nextBookmark
//
//  Created by Kai Rieger on 27.04.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI
import Combine

struct New_Bookmark: View {
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

struct NewBookmarkView: View {
    @State private var showingSheet = false
    @State private var keyboardHeight: CGFloat = 0
    @ObservedObject var vm: Model
    @State var bookmark: Bookmark = Bookmark(id: -1, added: -1, title: "", url: "", tags: [], folder_ids: [-1], description: "")
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("New Bookmark").font(.title)
                Spacer()
            }

            Spacer()
            New_Bookmark(headline: "Title", containsURL: false, key: "title", binding: $bookmark.title)
            New_Bookmark(headline: "URL", containsURL: true, key: "url", binding: $bookmark.url)
            New_Bookmark(headline: "Description", containsURL: true, key: "description", binding: $bookmark.description)
            Spacer()
            Button(action: {
                self.showingSheet = true
                self.vm.isShowing = true
                self.presentationMode.wrappedValue.dismiss()
                CallNextcloud(data: self.vm).post_new_bookmark(bookmark: self.bookmark)
            }) {
                Text("Upload New Bookmark")
            }
            .sheet(isPresented: $showingSheet,
            content: {
                ActivityView(activityItems: [NSURL(string: self.bookmark.url)!] as [Any], applicationActivities: nil) })
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

struct NewBookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        NewBookmarkView(vm: Model(), bookmark: Bookmark(id: 1, added: 1, title: "EDITTITLE", url: "EDITURL", tags: ["EDITTAG"], folder_ids: [1], description: "EDITDES"))
    }
}
