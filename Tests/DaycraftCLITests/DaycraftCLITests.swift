//
//  DaycraftCLITests.swift
//  DaycraftEngine
//
//  Created by qinfuyao on 1/14/26.
//

import XCTest
@testable import DaycraftCLI

final class DaycraftCLITests: XCTestCase {
    func testCLIConfigurationVersionIsSet() throws {
        XCTAssertFalse(Daycraft.configuration.version.isEmpty)
    }
}
