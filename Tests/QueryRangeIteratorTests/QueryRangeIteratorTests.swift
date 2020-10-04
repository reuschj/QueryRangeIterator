import XCTest
@testable import QueryRangeIterator

final class QueryRangeIteratorTests: XCTestCase {
    let query = "foo"
    let content = "foobarfoobaz"
    
    func testThatStringsCanBeCollected() {
        measure {
            var selects = QueryRangeIterator(query, in: content)
            var nonSelects = QueryRangeIterator(query, in: content, inverted: true)
            XCTAssertEqual(selects.collectStrings(), ["foo", "foo"])
            XCTAssertEqual(nonSelects.collectStrings(), ["bar", "baz"])
        }
    }
    
    func testThatItCanCollect() {
        measure {
            var selects = QueryRangeIterator(query, in: content)
            let collected = selects.collect()
            XCTAssertEqual(collected.count, 2)
            collected.forEach {
                XCTAssertEqual(String(content[$0]), query)
            }
        }
    }
    
    func testThatCanTransform() {
        measure {
            let transformed = QueryRangeIterator.transform(query, in: content) { $0.uppercased() }
            XCTAssertEqual(transformed, "FOObarFOObaz")
        }
    }
    
    func testThatCanReassembleWithTransforms() {
        measure {
            let transformed = QueryRangeIterator.reassemble(content, with: query, nonQueryTransform: { $0.uppercased() }, queryTransform: { $0.capitalized })
            XCTAssertEqual(transformed, "FooBARFooBAZ")
        }
    }
}
