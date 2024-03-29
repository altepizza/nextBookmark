//
//  FoldersView.swift
//  nextBookmark
//
//  Created by Kai Rieger on 30.05.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI

struct FoldersView: View {
    @EnvironmentObject var model: Model
    @State private var show_folder_detail_modal = false
    var body: some View {
        NavigationView {
            List {
                ForEach(self.model.folders) { folder in
                    NavigationLink(destination: BookmarksFolderView(current_root_folder: folder)) {
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "folder.fill")
                                Text(folder.title).fontWeight(.bold)
                            }
                            Text(folder.full_path).font(.footnote).lineLimit(1).foregroundColor(Color.gray)
                        }
                    }
                }
            }
            .pullToRefresh(isShowing: self.$model.isShowing) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    model.middleware(data: self.model).requestFolderHierarchy()
                    // TODO: Put in completion handler
                    self.model.isShowing = false
                }
            }
            .sheet(isPresented: self.$show_folder_detail_modal) {
                FolderDetailView().environmentObject(self.model)
            }
            .navigationBarTitle("Folders", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    self.show_folder_detail_modal = true
                }) {
                    Image(systemName: "plus").imageScale(.large).padding([.leading, .top, .bottom])
                }).disabled(!model.weAreOnline)
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct FoldersView_Previews: PreviewProvider {
    static var previews: some View {
        FoldersView()
    }
}
