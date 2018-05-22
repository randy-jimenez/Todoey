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
    @objc dynamic var title: String = ""
    let items: List<Item> = List<Item>()
}
