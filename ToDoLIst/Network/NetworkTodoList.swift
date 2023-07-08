//
//  NetworkResponse.swift
//  TodoList
//
//  Created by Кирилл Казаков on 07.07.2023.
//

import Foundation

struct NetworkTodoList: Decodable {
    let status: String
    let revision: Int32
    let list: [TodoItem]?
}

struct NetworkTodoItem: Decodable {
    let status: String
    let revision: Int32
    let item: TodoItem?
}
