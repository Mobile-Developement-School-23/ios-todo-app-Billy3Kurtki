import Foundation

class FileCache {
    private(set) var toDoList: [TodoItem] = []
    
    func addItem(_ item: TodoItem) {
        if let itemIndex = toDoList.firstIndex(where: { $0.id == item.id }) {
            toDoList.remove(at: itemIndex)
        }
        toDoList.append(item)
    }
    
    func deleteItem(_ item: TodoItem) {
        if let find = toDoList.firstIndex(where: { $0.id == item.id }) {
            toDoList.remove(at: find)
        }
    }
    
    func saveAllJsonFile(fileName: String) {
        let jsonDict = toDoList.map { $0.json }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonDict)
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("\(fileName)").appendingPathExtension("json")
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                print("Файл существует")
                try jsonString?.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
                
            } else {
                print("Файл не существует")
                try jsonString?.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
            }
        } catch {
            print("Ошибка создания JSONdata")
            return
        }
    }
    
    func getAllFromJson(fileName: String) {
        let path = Bundle.main.path(forResource: "\(fileName)", ofType: "json")
        var d: Data?
        
        if let json = path {
            do {
                d = try Data(contentsOf: URL(filePath: json))
            } catch {
                print("Ошибка получения Data: \(error.localizedDescription)")
                return
            }
        }
        
        guard let data = d else {
            print("Ошибка")
            return
        }
        
        var dictionary: [[String: Any]] = [[:]]
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String: Any]] else
        {
            print("Ошибка... [String: Any]")
            return
        }
        dictionary = dict
        
        var toDoList: [TodoItem] = []
        for dictItem in dictionary {
            if let item = TodoItem.parse(json: dictItem) {
                toDoList.append(item)
            }
        }
        
        self.toDoList = toDoList
    }
    
    
    static let delimiter = TodoItem.delimiter
    
    func saveAllCsvFile(fileName: String) {
        var csvString = ""
        for i in toDoList {
            csvString.append("\(i.csv)\n")
        }
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("\(fileName)").appendingPathExtension("csv")
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                print("Файл существует")
                try csvString.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
                
            } else {
                print("Файл не существует")
                try csvString.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
            }
        } catch {
            print("Ошибка создания CSV файла")
            return
        }
    }
    
    func getAllFromCsv(fileName: String) {
        let path = Bundle.main.path(forResource: "\(fileName)", ofType: "csv")
        var data = ""
        
        if let csv = path {
            do {
                data = try String(contentsOfFile: csv)
            } catch {
                print("Ошибка получения данных из CSV файла: \(error.localizedDescription)")
                return
            }
        }
        
        var rows = data.components(separatedBy: "\n")
        
        let columnCount = rows.first?.components(separatedBy: "delimiter").count
        rows.removeFirst()
        
        var toDoList: [TodoItem] = []
        for row in rows {
            if row.components(separatedBy: FileCache.delimiter).count == columnCount {
                if let item = TodoItem.parse(csv: row) {
                    toDoList.append(item)
                }
            }
        }
        
        self.toDoList = toDoList
    }
}
