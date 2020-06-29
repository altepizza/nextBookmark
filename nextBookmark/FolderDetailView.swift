//
//  FolderDetailView.swift
//  nextBookmark
//
//  Created by Kai Rieger on 31.05.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI

struct FolderDetailView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var model: Model
    @State var parent_folder = Folder(id: -1, title: "/", parent_folder_id: -1, full_path: "/")
    @State var new_folder = Folder(id: -1, title: "", parent_folder_id: -1, full_path: "")
    var parent_folder_full_path = "/"
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("folder name", text: $new_folder.title)
                }
                Section(header: Text("Parent Folder")) {
                    Picker(selection: $parent_folder, label: Text("Parent Folder")){
                        ForEach(model.folders, id: \.self) { folder in
                            Text(verbatim: folder.full_path)
                        }
                    }
                }
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                    self.new_folder.parent_folder_id = self.parent_folder.id
                    CallNextcloud(data: self.model).create_folder(folder: self.new_folder)
                    // TODO Put in completion handler
                    CallNextcloud(data: self.model).requestFolderHierarchy()
                }) {
                    Text("Create Folder")
                }
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}


struct FolderDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FolderDetailView(model: Model())
    }
}
