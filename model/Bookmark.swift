//
//  Bookmarks.swift
//  nextBookmark
//
//  Created by Kai on 16.12.19.
//  Copyright © 2019 Kai. All rights reserved.
//

import Foundation

struct Bookmark: Identifiable {
    var id: Int
    let title, url: String
    let tags: [String]
}
