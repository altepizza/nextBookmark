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

struct EditBookmarkView: View {
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
                }
                Spacer()
                Button(action: {
                    self.showingSheet = true
                    self.model.isShowing = true
                    self.presentationMode.wrappedValue.dismiss()
                    CallNextcloud(data: self.model).update_bookmark(bookmark: self.model.editing_bookmark)
                }) {
                    Text("Update bookmark")
                }
//                .foregroundColor(.white)
//                .background(Color.blue)
//                .cornerRadius(40)
                .sheet(isPresented: $showingSheet,
                       content: {
                        ActivityView(activityItems: [NSURL(string: self.model.editing_bookmark.url)!] as [Any], applicationActivities: nil) })
                .padding()
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                }
//                .foregroundColor(.white)
//                .background(Color.red)
//                .cornerRadius(40)
            }
            .padding(.bottom, keyboardHeight).animation(.easeInOut(duration:0.5))
            .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
            .navigationBarTitle("Edit Bookmark", displayMode: .inline)
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
        }
    }
}

struct EditBookmarkView_Previews: PreviewProvider {
    static var previews: some View {
        EditBookmarkView(model: Model())
    }
}
