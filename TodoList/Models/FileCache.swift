import Foundation
import CocoaLumberjackSwift

class FileCache {
    private(set) var toDoList: [TodoItem] = []
    
    func addItem(_ item: TodoItem) {
        if let itemIndex = toDoList.firstIndex(where: { $0.id == item.id }) {
            toDoList.remove(at: itemIndex)
        }
        toDoList.append(item)
    }
    
    func deleteItem(_ id: String) {
        if let find = toDoList.firstIndex(where: { $0.id == id }) {
            toDoList.remove(at: find)
        }
    }
    
    func saveAllJsonFile(fileName: String) {
        let jsonDict = toDoList.map { $0.json }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonDict)
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("\(fileName)").appendingPathExtension("json")
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                DDLogInfo("Файл существует")
                try jsonData.write(to: fileUrl)
                
            } else {
                DDLogError("Файл не существует")
                try jsonData.write(to: fileUrl)
            }
        } catch {
            DDLogError("Ошибка создания JSONdata")
            return
        }
    }
    
    func getAllFromJson(fileName: String) {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("\(fileName)").appendingPathExtension("json")
            
            var data: Data?
            
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                do {
                    data = try Data(contentsOf: URL(filePath: fileUrl.path()))
                } catch {
                    DDLogError("Ошибка получения Data: \(error.localizedDescription)")
                    return
                }
            }
            
            guard let dataExist = data else {
                DDLogError("Ошибка")
                return
            }
            
            guard let dict = try? JSONSerialization.jsonObject(with: dataExist, options: .allowFragments) as? [[String: Any]] else
            {
                DDLogError("Ошибка... [String: Any]")
                return
            }
            
            var toDoList: [TodoItem] = []
            for dictItem in dict {
                if let item = TodoItem.parse(json: dictItem) {
                    toDoList.append(item)
                }
            }
            
            self.toDoList = toDoList
        }
        catch {
            print()
        }
    }
    
    
    let delimiter = TodoItem.delimiter
    
    func saveAllCsvFile(fileName: String) {
        var csvString = "id;text;importance;deadline;isDone;createAt;dateEdit;\n"
        for i in toDoList {
            csvString.append("\(i.csv)\n")
        }
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("\(fileName)").appendingPathExtension("csv")
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                DDLogInfo("Файл существует")
                try csvString.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
                
            } else {
                DDLogError("Файл не существует")
                try csvString.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
            }
        } catch {
            DDLogError("Ошибка создания CSV файла")
            return
        }
    }
    
    func getAllFromCsv(fileName: String) {
        do {
            let documentDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let fileUrl = documentDirectory.appendingPathComponent("\(fileName)").appendingPathExtension("csv")
            var data = ""
            if FileManager.default.fileExists(atPath: fileUrl.path) {
                do {
                    data = try String(contentsOfFile: fileUrl.path())
                } catch {
                    DDLogError("Ошибка получения данных из CSV файла")
                    return
                }
            }
            
            var rows = data.components(separatedBy: "\n")
            rows.removeFirst()
            
            var toDoList: [TodoItem] = []
            for row in rows {
                if let item = TodoItem.parse(csv: row) {
                    toDoList.append(item)
                }
            }
            
            self.toDoList = toDoList
        } catch {
            DDLogError("Ошибка получения данных из CSV файла: \(error.localizedDescription)")
        }
    }
}
