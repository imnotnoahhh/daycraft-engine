//
//  DaycraftLogicTests.swift
//  DaycraftEngine
//
//  Created by qinfuyao on 1/14/26.
//

import XCTest
@testable import DaycraftLogic // 引用我们的逻辑库

final class DaycraftLogicTests: XCTestCase {
    func testExample() throws {
        let brain = DaycraftBrain()
        // 验证大脑是否在线
        XCTAssertEqual(brain.sayHello(), "🧠 Engine: Logic is online!")
    }
}
