//
//  AtomicTests.swift
//  
//
//  Created by Guillermo Muntaner Perelló on 18/06/2019.
//

import XCTest
@testable import AtomicWrite

final class AtomicWriteTests: XCTestCase {
    
    let iterations = 1000
    
    @AtomicWrite var count: Int = 0
    
    override func setUp() {
        $count = AtomicWrite(initialValue: 0)
    }
    
    func testGet() {
        XCTAssertEqual(count, 0)
        XCTAssertEqual($count.storage, 0)
    }
    
    func testSet() {
        count = 99
        
        XCTAssertEqual(count, 99)
        XCTAssertEqual($count.storage, 99)
    }
    
    /// Tests the issue with this property wrapper which is lack of native read & write exclusivity
    func testNonExclusiveReadWrite() {
        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            count += 1
        }
        XCTAssertNotEqual(count, iterations)
    }
    
    @AtomicWrite var atomicCount2: Int = 0
    
    func testMutateHelperForExclusiveReadWrite() {
        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            $count.mutate {
                $0 += 1
            }
        }
        XCTAssertEqual(count, iterations)
    }

    static var allTests = [
        ("testGet", testGet),
        ("testSet", testSet),
        ("testNonExclusiveReadWrite", testNonExclusiveReadWrite),
        ("testMutateHelperForExclusiveReadWrite", testMutateHelperForExclusiveReadWrite),
    ]
}
