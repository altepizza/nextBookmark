//
//  FoldersView.swift
//  nextBookmark
//
//  Created by Kai Rieger on 30.05.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import SwiftUI

struct FoldersView: View {
    @ObservedObject var model: Model
    
    var body: some View {
        NavigationView {
            List {
                ForEach(self.model.folders) { folder in
                    FolderRow(folder: folder, main_model: self.model)
                }
            }
            .navigationBarTitle("Folders", displayMode: .inline)
        }
    }
}

struct FoldersView_Previews: PreviewProvider {
    static var previews: some View {
        FoldersView(model: Model())
    }
}
