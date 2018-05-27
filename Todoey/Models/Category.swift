//
//  List.swift
//  Todoey
//
//  Created by Randy on 5/21/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var backgroundColor: String = "#FFFFFF"
    let items: List<Item> = List<Item>()

    override static func primaryKey() -> String? {
        return "id"
    }
}
