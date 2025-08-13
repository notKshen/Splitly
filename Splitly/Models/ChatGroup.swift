//
//  Group.swift
//  Splitly
//
//  Created by Kobe Shen on 2025-08-13.
//

import Foundation

struct ChatGroup: Identifiable {
    let id: String
    let name: String
    let memberIDs: [String]
    let createdAt: Date
}
