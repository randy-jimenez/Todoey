//
//  TodoListItem.swift
//  Todoey
//
//  Created by Randy on 5/16/18.
//  Copyright © 2018 Randy Jimenez. All rights reserved.
//

import Foundation


//class TodoListItem: Encodable, Decodable {
class TodoListItem: Codable {
    var title: String!
    var isDone: Bool = false

    init(title: String) {
        self.title = title
    }
}
