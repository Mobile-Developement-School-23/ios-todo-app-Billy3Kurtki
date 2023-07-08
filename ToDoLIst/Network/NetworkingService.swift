//
//  NetworkService.swift
//  TodoList
//
//  Created by Кирилл Казаков on 06.07.2023.
//

import Foundation

protocol NetworkingService {
    static func makeUrl() throws -> URL
    static func getList() async -> [TodoItem]?
    static func addItem(_ item: TodoItem) async
    static func updateItem(_ item: TodoItem) async
    static func deleteItem(_ id: String) async
    static func getItem(_ id: String) async -> TodoItem?
}
