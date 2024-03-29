//
//  Folder.swift
//  nextBookmark
//
//  Created by Kai on 29.02.20.
//  Copyright © 2020 Kai Rieger. All rights reserved.
//

import Foundation

struct Folder: Identifiable, Hashable, Codable {
    var id: Int
    var title: String
    var parent_folder_id: Int
    var full_path: String = "/"
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

func create_root_folder() -> Folder {
    return Folder(id: -1, title: "/", parent_folder_id: -1, full_path: "/")
}
