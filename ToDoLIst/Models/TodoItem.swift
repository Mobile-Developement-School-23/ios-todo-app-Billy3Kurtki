import Foundation

enum Importance: String {
    case unimportant = "неважная"
    case ordinary = "обычная"
    case important = "важная"
}

struct TodoItem {
    let id: String?
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let createAt: Date
    let dateEdit: Date?
}

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        if let json = json as? [String: Any] {
            if let id = json["id"] {
                guard let id = id as? String else { return nil }
            }
            
            guard let text = json["text"] else { return nil }
            guard let text = text as? String else { return nil }
            
            if let deadline = json["deadline"] {
                guard let deadline = deadline as? Int else { return nil }
            }
            
            guard let isDone = json["isDone"] else { return nil }
            guard let isDone = isDone as? Bool else { return nil }

            guard let createAt = json["createAt"] else { return nil }
            guard let createAt = createAt as? Int else { return nil }
            
            if let dateEdit = json["dateEdit"] {
                guard let dateEdit = dateEdit as? Int else { return nil }
            }
            
            let item: TodoItem = TodoItem(
                id: json["id"] as? String ?? UUID().uuidString,
                text: json["text"] as? String ?? "",
                importance: Importance(rawValue: (json["importance"] as? Importance.RawValue ?? Importance.ordinary.rawValue)) ?? .ordinary,
                deadline: (json["deadline"] as? Int)?.date ?? nil,
                isDone: json["isDone"] as? Bool ?? false,
                createAt: (json["createAt"] as? Int)?.date ?? Date(),
                dateEdit: (json["dateEdit"] as? Int)?.date ?? nil
            )
            return item
        }
        
        return nil
    }
    
    var json: Any {
        var toDoItem: [String: Any] = [:]
        if let id = id {
            toDoItem["id"] = id
        }
        else {
            toDoItem["id"] = UUID().uuidString
        }
        toDoItem["text"] = text
        if importance != Importance.ordinary {
            toDoItem["importance"] = importance.rawValue
        }
        if let deadline = deadline {
            toDoItem["deadline"] = "\(deadline.unixTimestamp)"
        }
        toDoItem["isDone"] = "\(isDone)"
        toDoItem["createAt"] = "\(createAt.unixTimestamp)"
        if let dateEdit = dateEdit {
            toDoItem["dateEdit"] = "\(dateEdit.unixTimestamp)"
        }
        
        return toDoItem
    }
    
    static let delimiter = ";"
    
    static func parse(csv: String) -> TodoItem? {
        let row = csv.components(separatedBy: delimiter)
        var importanceTemp = Importance.ordinary
        if row[1].isEmpty {
            return nil
        }
        if !row[2].isEmpty {
            guard let importance = Importance(rawValue: row[2]) else { return nil }
            importanceTemp = importance
        }
        
        if row[4].isEmpty {
            return nil
        }
        guard let isDone = Bool(row[4]) else { return nil }
        
        if row[5].isEmpty {
            return nil
        }
        guard let createAt = Int(row[5]) else { return nil }
        
        let item: TodoItem = TodoItem(
            id: !row[0].isEmpty ? row[0] : UUID().uuidString,
            text: row[1],
            importance: importanceTemp,
            deadline: Int(row[3])?.date ?? nil,
            isDone: isDone,
            createAt: Int(row[5])?.date ?? Date(),
            dateEdit: createAt.date
        )
        
        return item
    }
    
    var csv: String {
        var toDoItem: String = ""
        if let id = id {
            toDoItem.append("\(id)")
        }
        toDoItem.append(";")
        toDoItem.append("\(text);")
        if importance != Importance.ordinary  {
            toDoItem.append("\(importance)")
        }
        toDoItem.append(";")
        if let deadline = deadline {
            toDoItem.append("\(deadline)")
        }
        toDoItem.append(";")
        toDoItem.append("\(isDone);")
        toDoItem.append("\(createAt);")
        if let dateEdit = dateEdit {
            toDoItem.append("\(dateEdit)")
        }
        toDoItem.append(";")
        
        return toDoItem
    }
    
}

typealias UnixTimestamp = Int

extension Date {
    var unixTimestamp: UnixTimestamp {
        return UnixTimestamp(self.timeIntervalSince1970 * 1_000)
    }
    
    init(_ dateString: String) {
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateStringFormatter.locale = Locale(identifier: "ru_RU")
        let date = dateStringFormatter.date(from: dateString)!
        self.init(timeInterval: 0, since: date)
    }
}

extension UnixTimestamp {
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval((self + 10800000) / 1_000))
    }
}
