import Foundation
import XCTest
import WarningsValidatorCore

class WarningsValidatorTests: XCTestCase {
    func testThatToWarningsWithDifferentLineNumbersInTheSameFileAreTreatedAsEqual() {
        let warn1 = [
            Warning(file_name: "file_name", description: "reason", line:"1", type: .compile),
            Warning(file_name: "file_name", description: "second reason", line:"2", type: .compile)
        ]
        
        let warn2 = [
            Warning(file_name: "file_name", description: "reason", line:"3", type: .compile),
            Warning(file_name: "file_name", description: "second reason", line:"5", type: .compile)
        ]
        
        let result = Validator.validate(known: warn1, new: warn2)
        
        XCTAssertTrue(result.warningsAdded?.count == 0)
    }
    
    func testThatToWarningsWithDifferentTypesInTheSameFileAreTreatedAsNotEqual() {
        let warn1 = [
            Warning(file_name: "file_name", description: "reason", line:"1", type: .compile),
            Warning(file_name: "file_name", description: "second reason", line:"4", type: .compile)
        ]
        let warn2 = [
            Warning(file_name: "file_name", description: "reason", line:"3", type: .linker),
            Warning(file_name: "file_name", description: "second reason", line:"4", type: .compile)
        ]
        
        let result = Validator.validate(known: warn1, new: warn2)
        
        XCTAssertTrue(result.warningsAdded?.count == 1)
    }
}
