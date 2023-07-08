//
//  UrlExtension.swift
//  TodoList
//
//  Created by Кирилл Казаков on 05.07.2023.
//

import Foundation

extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: urlRequest) { (data, response, error) in
                if Task.isCancelled {
                    let error = NSError(domain: "com.example.app", code: 0, userInfo: nil)
                    continuation.resume(throwing: error)
                } else if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    let error = NSError(domain: "com.example.app", code: 0, userInfo: nil)
                    continuation.resume(throwing: error)
                }
            }
            
            Task {
                do {
                    try Task.checkCancellation()
                    task.cancel()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            task.resume()
        }
    }
}
