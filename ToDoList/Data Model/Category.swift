//
//  Category.swift
//  ToDoList
//
//  Created by Margareta Mudrikova on 12/10/2020.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    let items = List<Item>()
    
}
