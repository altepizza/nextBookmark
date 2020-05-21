//
//  FolderToSyncView.swift
//  nextBookmark
//
//  Created by Kai Rieger on 21.05.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI

struct FolderSyncRow: View {
    var model: Model
    let folder: Folder
    @State var sync = true

    var body: some View {
        HStack {
            Button(action: {
                if (self.model.folders_not_for_sync.contains(self.folder.id)) {
                    self.model.folders_not_for_sync.removeAll { $0 == self.folder.id }
                    self.sync = true
                } else {
                    self.model.folders_not_for_sync.append(self.folder.id)
                    self.sync = false
                }
            }) {
                HStack {
                    Text(folder.full_path)
                    Spacer()
                    if (sync) {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }.onAppear() {
            self.sync = !self.model.folders_not_for_sync.contains(self.folder.id)
        }
    }
}

struct FolderToSyncView: View {
    var model: Model
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach (self.model.folders) {
                        folder in
                        FolderSyncRow(model: self.model, folder: folder)
                    }
                }
            }
        }.navigationBarTitle("Synced folders", displayMode: .inline)
    }
}

struct FolderToSyncView_Previews: PreviewProvider {
    static var previews: some View {
        FolderToSyncView(model: Model())
    }
}
