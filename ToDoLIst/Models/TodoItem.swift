import Foundation

enum Importance: String {
    case unimportant = "неважная"
    case ordinary = "обычная"
    case important = "важная"
}

struct TodoItem: Equatable {
    let id: String
    let text: String
    let importance: Importance
    let deadline: Date?
    let isDone: Bool
    let createAt: Date
    let dateEdit: Date?
    
    init(id: String = UUID().uuidString, text: String, importance: Importance, deadline: Date? = nil, isDone: Bool = false, createAt: Date = Date(), dateEdit: Date? = nil) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
        self.createAt = createAt
        self.dateEdit = dateEdit
    }
}

extension TodoItem {
    static func parse(json: Any) -> TodoItem? {
        guard let json = json as? [String: Any],
              let id = json["id"] as? String,
              let text = json["text"] as? String,
              let isDone = json["isDone"] as? Bool,
              let createAt = json["createAt"] as? Int else { return nil }
        
        let importance = Importance(rawValue: (json["importance"] as? Importance.RawValue ?? Importance.ordinary.rawValue)) ?? .ordinary
        let deadline = (json["deadline"] as? Int)?.date
        let dateEdit = (json["dateEdit"] as? Int)?.date
        
        
        let item: TodoItem = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createAt: createAt.date,
            dateEdit: dateEdit
        )
        return item
    }
    
    var json: Any {
        var toDoItem: [String: Any] = [:]
        toDoItem["id"] = id
        toDoItem["text"] = text
        if importance != Importance.ordinary {
            toDoItem["importance"] = importance.rawValue
        }
        if let deadline = deadline {
            toDoItem["deadline"] = deadline.unixTimestamp
        }
        toDoItem["isDone"] = isDone
        toDoItem["createAt"] = createAt.unixTimestamp
        if let dateEdit = dateEdit {
            toDoItem["dateEdit"] = dateEdit.unixTimestamp
        }
        
        return toDoItem
    }
    
    static let delimiter = ";"
    
    static let csvString = "id;text;importance;deadline;isDone;createAt;dateEdit;\n"
    
    static let countCsvString = csvString.components(separatedBy: delimiter).count
    
    static func parse(csv: String) -> TodoItem? {
        let row = csv.components(separatedBy: delimiter)
        if row.count == countCsvString {
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
                id: row[0],
                text: row[1],
                importance: importanceTemp,
                deadline: Int(row[3])?.date ?? nil,
                isDone: isDone,
                createAt: createAt.date,
                dateEdit: Int(row[7])?.date ?? nil
            )
            
            return item
        }
        else {
            return nil
        }
    }
    
    var csv: String {
        var toDoItem: String = ""
        toDoItem.append("\(id)")
        toDoItem.append(TodoItem.delimiter)
        toDoItem.append("\(text);")
        if importance != Importance.ordinary  {
            toDoItem.append("\(importance)")
        }
        toDoItem.append(TodoItem.delimiter)
        if let deadline = deadline {
            toDoItem.append("\(deadline)")
        }
        toDoItem.append(TodoItem.delimiter)
        toDoItem.append("\(isDone);")
        toDoItem.append("\(createAt);")
        if let dateEdit = dateEdit {
            toDoItem.append("\(dateEdit)")
        }
        toDoItem.append(TodoItem.delimiter)
        
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
