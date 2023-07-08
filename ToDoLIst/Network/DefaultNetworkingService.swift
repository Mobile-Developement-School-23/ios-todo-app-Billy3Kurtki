//
//  DefaultNetworkingService.swift
//  TodoList
//
//  Created by Кирилл Казаков on 06.07.2023.
//

import Foundation
import CocoaLumberjackSwift

//baseUrl https://beta.mrdekk.ru/todobackend
struct DefaultNetworkingService: NetworkingService {
    private let mutex = NSLock()
    private static let scheme = "https"
    private static let host = "beta.mrdekk.ru"
    private static let path = "/todobackend"
    
    private static let httpStatusCodeSuccess = 200..<300
    private static let token = "contemplative"
    static var lastRevision: Int32 = 0
    let queue = DispatchQueue.global()
    
//    var lastRevision: Int32 = 0
//    mutating func setLastRevision(_ value: Int32) {
//        mutex.withLock {
//            lastRevision = value
//        }
//    }
    
    static func makeUrl() throws -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        guard let url = components.url else {
            throw RequestProcessorError.wrongUrl(components)
        }
        
        return url
    }
    
    static func getList() async -> [TodoItem]? {
        guard let baseUrl = try? makeUrl().appending(path: "/list") else {
            DDLogError("Ошибка создания Url")
            return nil
        }
        
        do {
            var request = URLRequest(url: baseUrl)
            request.httpMethod = "GET"
            request.setValue("Bearer \(DefaultNetworkingService.token)", forHTTPHeaderField: "Authorization")
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            guard let response = response as? HTTPURLResponse else {
                throw RequestProcessorError.unexpectedResponse(response)
            }
            guard Self.httpStatusCodeSuccess.contains(response.statusCode) else {
                throw RequestProcessorError.failureResponse(response)
            }
            let decoder = JSONDecoder()
            guard let todo = try? decoder.decode(NetworkTodoItem.self, from: data) else {
                DDLogError("Ошибка декодирования json")
                return nil
            }
            return todo.list
        } catch {
            DDLogError("Ошибка получения списка задач")
            return nil
        }
        return nil
    }
    
    static func addItem(_ item: TodoItem) async {
        guard let baseUrl = try? makeUrl().appending(path: "/list") else {
            DDLogError("Ошибка создания Url")
            return
        }
        let itemJSON = item.json as? [String: Any]
        let json: [String: [String: Any]] = ["element": itemJSON ?? [:]]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        do {
            var request = URLRequest(url: baseUrl)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(DefaultNetworkingService.token)", forHTTPHeaderField: "Authorization")
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            guard let response = response as? HTTPURLResponse else {
                FileCache.isDirty = true
                throw RequestProcessorError.unexpectedResponse(response)
            }
            guard Self.httpStatusCodeSuccess.contains(response.statusCode) else {
                FileCache.isDirty = true
                throw RequestProcessorError.failureResponse(response)
            }
            let decoder = JSONDecoder()
            guard let todo = try? decoder.decode(NetworkTodoItem.self, from: data) else {
                DDLogError("Ошибка декодирования json")
                return
            }
//            setLastRevision(todo.revision)
            lastRevision = todo.revision
        } catch {
            DDLogError("Ошибка добавления задачи")
            return
        }
    }
    
    static func updateItem(_ item: TodoItem) async {
        guard let baseUrl = try? makeUrl().appending(path: "/list/\(item.id)") else {
            DDLogError("Ошибка создания Url")
            return
        }
        let itemJSON = item.json as? [String: Any]
        let json: [String: [String: Any]] = ["element": itemJSON ?? [:]]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        do {
            var request = URLRequest(url: baseUrl)
            request.httpMethod = "PUT"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(DefaultNetworkingService.token)", forHTTPHeaderField: "Authorization")
            request.setValue("\(lastRevision)", forHTTPHeaderField: "X-Last-Known-Revision")
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            guard let response = response as? HTTPURLResponse else {
                FileCache.isDirty = true
                throw RequestProcessorError.unexpectedResponse(response)
            }
            guard Self.httpStatusCodeSuccess.contains(response.statusCode) else {
                FileCache.isDirty = true
                throw RequestProcessorError.failureResponse(response)
            }
            let decoder = JSONDecoder()
            guard let todo = try? decoder.decode(NetworkTodoItem.self, from: data) else {
                DDLogError("Ошибка декодирования json")
                return
            }
            lastRevision = todo.revision
        } catch {
            DDLogError("Ошибка обновления задачи")
            return
        }
    }
    
    static func deleteItem(_ id: String) async {
        guard let baseUrl = try? makeUrl().appending(path: "/list/\(id)") else {
            DDLogError("Ошибка создания Url")
            return
        }
        do {
            var request = URLRequest(url: baseUrl)
            request.httpMethod = "DELETE"
            request.setValue("Bearer \(DefaultNetworkingService.token)", forHTTPHeaderField: "Authorization")
            request.setValue("\(lastRevision)", forHTTPHeaderField: "X-Last-Known-Revision")
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            guard let response = response as? HTTPURLResponse else {
                FileCache.isDirty = true
                throw RequestProcessorError.unexpectedResponse(response)
            }
            guard Self.httpStatusCodeSuccess.contains(response.statusCode) else {
                FileCache.isDirty = true
                throw RequestProcessorError.failureResponse(response)
            }
            let decoder = JSONDecoder()
            guard let todo = try? decoder.decode(NetworkTodoItem.self, from: data) else {
                DDLogError("Ошибка декодирования json")
                return
            }
            lastRevision = todo.revision
        } catch {
            DDLogError("Ошибка удаления задачи")
            return
        }
    }
    
    static func getItem(_ id: String) async -> TodoItem? {
        guard let baseUrl = try? makeUrl().appending(path: "/list/\(id)") else {
            DDLogError("Ошибка создания Url")
            return nil
        }
        do {
            var request = URLRequest(url: baseUrl)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(DefaultNetworkingService.token)", forHTTPHeaderField: "Authorization")
            request.setValue("\(lastRevision)", forHTTPHeaderField: "X-Last-Known-Revision")
            let (data, response) = try await URLSession.shared.dataTask(for: request)
            guard let response = response as? HTTPURLResponse else {
                throw RequestProcessorError.unexpectedResponse(response)
            }
            guard Self.httpStatusCodeSuccess.contains(response.statusCode) else {
                throw RequestProcessorError.failureResponse(response)
            }
            let decoder = JSONDecoder()
            guard let todo = try? decoder.decode([String: TodoItem].self, from: data) else {
                DDLogError("Ошибка декодирования json")
                return nil
            }
            let item = todo["element"]
            return item
        } catch {
            DDLogError("Ошибка получения задачи")
            return nil
        }
    }
    
}

enum RequestProcessorError: Error {
    case wrongUrl(URLComponents)
    case unexpectedResponse(URLResponse)
    case failureResponse(HTTPURLResponse)
}
