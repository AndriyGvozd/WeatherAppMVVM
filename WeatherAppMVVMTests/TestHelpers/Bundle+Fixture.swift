import Foundation
import XCTest

extension Bundle {
    
    static func loadJSONFixture(named fileName: String,
                                file: StaticString = #file,
                                line: UInt = #line) throws -> Data {
        
        let bundle = Bundle(for: DummyTestClass.self)
        
        guard let url = bundle.url(forResource: fileName, withExtension: "json") else {
            XCTFail("Missing fixture: \(fileName).json", file: file, line: line)
            throw NSError(domain: "FixtureError", code: 1)
        }
        
        return try Data(contentsOf: url)
    }
}

private final class DummyTestClass {}
