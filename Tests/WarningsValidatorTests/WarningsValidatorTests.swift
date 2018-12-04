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
        let output: String = try run(with: ["-","/Baseline/warnings-baseline.json", "/Users/jsras/development/tdc/tv-film/result.json", "--verbose"])
        
        XCTAssert(output.contains("3 new warnings found"))
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

fileprivate extension WarningsValidatorTests {
    @discardableResult func run(with arguments: [String]) throws -> String {
        
        var output = ""
        
        let printFunction: PrintFunction = { message in
            output.append(message)
        }
        
        try WarningsValidator.run(with: arguments, printFunction: printFunction)
        
        return output
    }
}
