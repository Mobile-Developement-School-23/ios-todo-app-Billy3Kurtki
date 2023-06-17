//
//  ToDoLIstTests.swift
//  ToDoLIstTests
//
//  Created by Кирилл Казаков on 10.06.2023.
//

import XCTest
@testable import ToDoLIst

final class ToDoLIstTests: XCTestCase {

    // System under test
    var sut: TodoItem!
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = TodoItem(id: "1", text: "test text", importance: .unimportant, deadline: (124412049140).date, isDone: false, createAt: (121412049140).date, dateEdit: (121412049140).date)
    }

    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testParseJSON1() throws {
        let json: [String: Any] = ["id": "1", "text": "test text", "importance": "неважная", "deadline": "124412049140", "isDone": "false", "createAt": "121412049140", "dateEdit": "121412049140"]
        XCTAssert(TodoItem.parse(json: json) == sut)
    }

    func testParseJSON2() throws {
        XCTAssert(TodoItem.parse(json: sut.json) == sut)
    }
    
    func testParseJSON3WithError() throws {
        let json: [String: Any] = ["id": "1", "text": "test text", "importance": "неважная", "deadline": "124412049140", "createAt": "121412049140", "dateEdit": "121412049140"] // removed isDone
        XCTAssertEqual(TodoItem.parse(json: json), nil)
    }
    
    func testParseCSV1() throws {
        let csv: String = "1;test text;неважная;124412049140;false;121412049140;121412049140;"
        XCTAssert(TodoItem.parse(csv: csv) == sut)
    }

    func testParseCSV2() throws {
        XCTAssert(TodoItem.parse(csv: sut.csv) == sut)
    }
    
    func testParseCSV3WithError() throws {
        let csv: String = "1;test text;неважная;124412049140;;121412049140;121412049140;" // removed isDone
        XCTAssertEqual(TodoItem.parse(csv: csv), nil)
    }
    
    

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
