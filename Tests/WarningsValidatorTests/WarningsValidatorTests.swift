import Foundation
import XCTest
import WarningsValidatorCore

class WarningsValidatorTests: XCTestCase {
    
    // MARK: - XCTestCase
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testThatToWarningsWithDifferentLineNumbersInTheSameFileAreTreatedAsEqual() throws {
        try WarningsValidator.run(with: ["/Users/jsras/development/tools/WarningsValidator/Tests/WarningsValidatorTests/MockData/similar-warnings-baseline.json", "/Users/jsras/development/tools/WarningsValidator/Tests/WarningsValidatorTests/MockData/similar-warnings-rew-result.json"])
    }
    
    func testThatToWarningsWithDifferentTypesInTheSameFileAreTreatedAsNotEqual() {
//        let warn1 = [
//            Warning(file_name: "file_name", description: "reason", line:"1", type: .compile),
//            Warning(file_name: "file_name", description: "second reason", line:"4", type: .compile)
//        ]
//        let warn2 = [
//            Warning(file_name: "file_name", description: "reason", line:"3", type: .linker),
//            Warning(file_name: "file_name", description: "second reason", line:"4", type: .compile)
//        ]
//
//        let result = Validator.validate(known: warn1, new: warn2)
//
//        XCTAssertTrue(result.warningsAdded?.count == 1)
    }
}

