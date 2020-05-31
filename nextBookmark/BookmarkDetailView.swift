//
//  EditBookmarkView.swift
//  nextBookmark
//
//  Created by Kai Rieger on 27.04.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI
import Combine

struct ActivityView: UIViewControllerRepresentable {

    let activityItems: [Any]
    let applicationActivities: [UIActivity]?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems,
                                        applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController,
                                context: UIViewControllerRepresentableContext<ActivityView>) {

    }
}

struct BookmarkDetailView: View {
    @State private var showingSheet = false
    @State private var keyboardHeight: CGFloat = 0
    @ObservedObject var model: Model
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Title")) {
                        TextField("title", text: $model.editing_bookmark.title)
                    }
                    Section(header: Text("URL")) {
                        TextField("url", text: $model.editing_bookmark.url).keyboardType(.URL)
                    }
                    Section(header: Text("Description")) {
                        TextField("description", text: $model.editing_bookmark.description)
                    }
                    Section(header: Text("Tag(s)")) {
                        NavigationLink(destination: BookmarkTags(model: self.model)) {
                            Text(model.editing_bookmark.tags.joined(separator: ", ")).lineLimit(1)
                        }
                    }
                    Section(header: Text("Folder")) {
                        Picker(selection: $model.editing_bookmark_folder, label: Text("Folder")){
                            ForEach(model.folders, id: \.self) { folder in
                                Text(verbatim: folder.full_path)
                            }
                        }
                    }
                    Button(action: {
                        self.model.isShowing = true
                        self.presentationMode.wrappedValue.dismiss()
                        CallNextcloud(data: self.model).edit_or_create_bookmark(bookmark: self.model.editing_bookmark)
                    }) {
                        if (model.editing_bookmark.id == -1) {
                            Text("Create Bookmark")
                        } else {
                            Text("Update bookmark")
                        }
                    }
                }
                .sheet(isPresented: $showingSheet,
                       content: {
                        ActivityView(activityItems: [NSURL(string: self.model.editing_bookmark.url)!] as [Any], applicationActivities: nil) })
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                }
            }
            .padding(.bottom, keyboardHeight).animation(.easeInOut(duration:0.5))
            .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
            .navigationBarTitle("Bookmark", displayMode: .inline)
            .navigationBarItems(
                trailing:
                    Button(action: {self.showingSheet = true}) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: CGFloat(25), height: CGFloat(25))
                            .padding()
                    }
                    .sheet(isPresented: $showingSheet, content: {
                        ActivityView(activityItems: [NSURL(string: self.model.editing_bookmark.url)!] as [Any], applicationActivities: nil) })
            )
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct EditBookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkDetailView(model: Model())
    }
}
