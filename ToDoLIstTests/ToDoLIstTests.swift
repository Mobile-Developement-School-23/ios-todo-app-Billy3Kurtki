//
//  ToDoLIstTests.swift
//  ToDoLIstTests
//
//  Created by Кирилл Казаков on 10.06.2023.
//

import XCTest
@testable import ToDoLIst

final class ToDoLIstTests: XCTestCase {
    
    private let id = "1"
    private let text = "Помыть машину"
    private var importance = Importance.ordinary
    private var deadline: Date? = Date()
    private let isDone = false
    private let createAt = Date()
    private var dateEdit: Date? = Date()
    
    // System under test
    var sut: TodoItem!
    
    override func setUp() {
        super.setUp()
        sut = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createAt: createAt,
            dateEdit: dateEdit
        )
    }
    
    func testCreateTodoItemWithoutInvalidValues() {
        XCTAssertEqual(sut.id, id)
        XCTAssertEqual(sut.text, text)
        XCTAssertEqual(sut.importance, importance)
        XCTAssertEqual(sut.deadline, deadline)
        XCTAssertEqual(sut.isDone, isDone)
        XCTAssertEqual(sut.createAt, createAt)
        XCTAssertEqual(sut.dateEdit, dateEdit)
    }
    
    func testCreateTodoItemWithInvalidValues() {
        sut = TodoItem(
            id: id,
            text: "",
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createAt: createAt,
            dateEdit: dateEdit
        )
        XCTAssertEqual(sut.id, id)
        XCTAssertFalse(sut.text == text)
        XCTAssertEqual(sut.importance, importance)
        XCTAssertEqual(sut.deadline, deadline)
        XCTAssertEqual(sut.isDone, isDone)
        XCTAssertEqual(sut.createAt, createAt)
        XCTAssertEqual(sut.dateEdit, dateEdit)
    }
    
    func testTodoItemToJSON() {
        guard let json = sut.json as? [String: Any] else {
            XCTFail("Ошибка конвертации в JSON")
            return
        }
        
        XCTAssertEqual(json["deadline"] as? Int, sut.deadline?.unixTimestamp)
        XCTAssertEqual(json["createAt"] as? Int, sut.createAt.unixTimestamp)
        XCTAssertEqual(json["dateEdit"] as? Int, sut.dateEdit?.unixTimestamp)
    }
    
    func testTodoItemToJSONWithNilValues() {
        deadline = nil
        dateEdit = nil
        
        sut = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createAt: createAt,
            dateEdit: dateEdit
        )
        guard let json = sut.json as? [String: Any] else {
            XCTFail("Ошибка конвертации в JSON")
            return
        }
        
        XCTAssertEqual(json["deadline"] as? Int, nil)
        XCTAssertEqual(json["dateEdit"] as? Int, nil)
    }
    
    func testTodoItemToJSONWithOrdinaryImportance() {
        importance = Importance.ordinary
        
        sut = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createAt: createAt,
            dateEdit: dateEdit
        )
        guard let json = sut.json as? [String: Any] else {
            XCTFail("Ошибка конвертации в JSON")
            return
        }
        
        XCTAssertNil(json["importance"])
    }
    
    func testTodoItemToJSONWithoutOrdinaryImportance() {
        importance = Importance.unimportant
        
        sut = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createAt: createAt,
            dateEdit: dateEdit
        )
        guard let json = sut.json as? [String: Any] else {
            XCTFail("Ошибка конвертации в JSON")
            return
        }
        
        XCTAssertNotNil(json["importance"])
        XCTAssertEqual(json["importance"] as? String, importance.rawValue)
    }
    
    func testParseJSONWithoutFields() {
        let json: [String: Any] = [:]
        
        let sut = TodoItem.parse(json: json)
        XCTAssertNil(sut)
    }
    
    func testTodoItemToCSV() {
        let csv = sut.csv
        let item = csv.components(separatedBy: TodoItem.delimiter)
        XCTAssertEqual(item[0], sut.id)
        XCTAssertEqual(item[1], sut.text)
        XCTAssertEqual(item[2], "")
        XCTAssertEqual(item[3], String(sut.deadline?.unixTimestamp ?? 0))
        XCTAssertEqual(item[4], String(sut.isDone))
        XCTAssertEqual(item[5], String(sut.createAt.unixTimestamp))
        XCTAssertEqual(item[6], String(sut.dateEdit?.unixTimestamp ?? 0))
    }
    
    func testTodoItemToCSVWithNilValues() {
        deadline = nil
        dateEdit = nil
        
        sut = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createAt: createAt,
            dateEdit: dateEdit
        )
        let csv = sut.csv
        let item = csv.components(separatedBy: TodoItem.delimiter)
        XCTAssertEqual(item[3], "")
        XCTAssertEqual(item[6], "")
    }
    
    func testTodoItemToCSVWithOrdinaryImportance() {
        importance = Importance.ordinary
        
        sut = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createAt: createAt,
            dateEdit: dateEdit
        )
        let csv = sut.csv
        let item = csv.components(separatedBy: TodoItem.delimiter)
        XCTAssertEqual(item[2], "")
    }
    
    func testTodoItemToCSVWithoutOrdinaryImportance() {
        importance = Importance.unimportant
        
        sut = TodoItem(
            id: id,
            text: text,
            importance: importance,
            deadline: deadline,
            isDone: isDone,
            createAt: createAt,
            dateEdit: dateEdit
        )
        let csv = sut.csv
        let item = csv.components(separatedBy: TodoItem.delimiter)
        XCTAssertEqual(item[2], sut.importance.rawValue)
    }
    
    func testParseCSVWithoutFields() {
        let csv: String = ""
        
        let sut = TodoItem.parse(csv: csv)
        XCTAssertNil(sut)
    }
    
}
