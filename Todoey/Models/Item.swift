//
//  Item.swift
//  Todoey
//
//  Created by Randy on 5/21/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var isDone: Bool = false
    var category = LinkingObjects(fromType: Category.self, property: "items")
}
