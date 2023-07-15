import Foundation
import CocoaLumberjackSwift
import SQLite

class FileCache {
    private(set) var toDoList: [TodoItem] = []
    static var isDirty: Bool = false
    
    var database: Connection!
    let table = Table(DatabaseConsts.tableName)
    
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
        var csvString = "id;text;importance;deadline;isDone;createAt;dateEdit;color;lastUpdatedBy\n"
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
    
    func getAllFromNetwork() async {
        try await DefaultNetworkingService.getList()
    }
    
    func saveAllNetwork() async {
        
    }
    
    func copyDatabaseIfNeeded(sourcePath: String) -> Bool {
        let documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let destinationPath = documents + "/\(DatabaseConsts.database).\(DatabaseConsts.databaseType)"
        let exists = FileManager.default.fileExists(atPath: destinationPath)
        guard !exists else { return false }
        do {
            try FileManager.default.copyItem(atPath: sourcePath, toPath: destinationPath)
            return true
        } catch {
            print("error during file copy: \(error)")
            return false
        }
    }
    
    func setConnection() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
            ).first!
            guard let path = Bundle.main.path(forResource: DatabaseConsts.database, ofType: DatabaseConsts.databaseType) else {
                print("Файл БД не найден")
                return
            }
            _ = copyDatabaseIfNeeded(sourcePath: path)
            let db = try Connection(path)
            self.database = db
            DDLogInfo("Соединение с БД установлено")
        }
        catch {
            DDLogError("Ошибка соединения с БД")
        }
    }
    
    func insertItemSQL(_ item: TodoItem) {
        let insertItem = self.table.insert(ExpressionsItemTable.id <- item.id,
                                                    ExpressionsItemTable.text <- item.text,
                                                    ExpressionsItemTable.importance <- item.importance.rawValue,
                                                    ExpressionsItemTable.deadline <- item.deadline?.unixTimestamp,
                                                    ExpressionsItemTable.isDone <- item.isDone ? 1 : 0,
                                                    ExpressionsItemTable.createAt <- item.createAt.unixTimestamp,
                                                    ExpressionsItemTable.dateEdit <- item.dateEdit?.unixTimestamp,
                                                    ExpressionsItemTable.color <- item.color,
                                                    ExpressionsItemTable.lastUpdatedBy <- item.lastUpdatedBy)
        do {
            try self.database.run(insertItem)
            DDLogInfo("Задача успешно добавлена в БД")
        } catch {
            DDLogError("Ошибка добавления задачи в БД")
            print(error)
        }
    }
    
    func updateItemSQL(_ item: TodoItem) {
        do {
            let _item = self.table.filter(ExpressionsItemTable.id == item.id)
            let updateItem = _item.update(ExpressionsItemTable.id <- item.id,
                                          ExpressionsItemTable.text <- item.text,
                                          ExpressionsItemTable.importance <- item.importance.rawValue,
                                          ExpressionsItemTable.deadline <- item.deadline?.unixTimestamp,
                                          ExpressionsItemTable.isDone <- item.isDone ? 1 : 0,
                                          ExpressionsItemTable.createAt <- item.createAt.unixTimestamp,
                                          ExpressionsItemTable.dateEdit <- item.dateEdit?.unixTimestamp,
                                          ExpressionsItemTable.color <- item.color,
                                          ExpressionsItemTable.lastUpdatedBy <- item.lastUpdatedBy)

            if try self.database.run(updateItem) > 0 {
                DDLogInfo("Задача успешно изменена в БД")
            }
            else {
                insertItemSQL(item)
            }
        } catch {
            DDLogError("Ошибка изменения задачи в БД")
            print(error)
        }
    }
    
    
    func deleteItemSQL(_ id: String) {
        do {
            let item = self.table.filter(ExpressionsItemTable.id == id)
            try self.database.run(item.delete())
            DDLogInfo("Задача успешно удалена из БД")
        } catch {
            DDLogError("Ошибка удаления задачи из БД")
            print(error)
        }
    }
    
    func loadListSQL() {
        do {
            let itemsSQL = try self.database.prepare(self.table)
            var items: [TodoItem] = []
            for item in itemsSQL {
                if let _item = TodoItem.parseSQL(item) {
                    items.append(_item)
                }
            }
            toDoList = items
            
        } catch {
            DDLogError("Ошибка получение списка задач из БД")
            print(error)
        }
    }
}

enum DatabaseConsts {
    static let database: String = "database"
    static let databaseType: String = "db"
    static let tableName: String = "Item"
    static let id:  String = "id"
    static let text:  String = "text"
    static let importance:  String = "importance"
    static let deadline:  String = "deadline"
    static let isDone:  String = "isDone"
    static let createAt:  String = "createAt"
    static let dateEdit:  String = "dateEdit"
    static let color:  String = "color"
    static let lastUpdatedBy:  String = "lastUpdatedBy"
}

enum ExpressionsItemTable {
    static let id = Expression<String>(DatabaseConsts.id)
    static let text = Expression<String>(DatabaseConsts.text)
    static let importance = Expression<String>(DatabaseConsts.importance)
    static let deadline = Expression<Int?>(DatabaseConsts.deadline)
    static let isDone = Expression<Int>(DatabaseConsts.isDone)
    static let createAt = Expression<Int>(DatabaseConsts.createAt)
    static let dateEdit = Expression<Int?>(DatabaseConsts.dateEdit)
    static let color = Expression<String?>(DatabaseConsts.color)
    static let lastUpdatedBy = Expression<String>(DatabaseConsts.lastUpdatedBy)
}
