//
//  SafeTests.swift
//  SafeTests
//
//  Created by Honza Dvorsky on 1/19/16.
//  Copyright © 2016 Honza Dvorsky. All rights reserved.
//

import XCTest
@testable import Safe

func slp(_ ti: TimeInterval) {
    Thread.sleep(forTimeInterval: ti)
}

class SafeTests: XCTestCase {
    
    func testEREW() {
        
        var acc: [Int] = []
        let read1 = {
            acc.append(1)
            slp(0.1)
            acc.append(2)
        }
        
        let read2 = {
            acc.append(3)
            slp(0.1)
            acc.append(4)
        }
        
        let write1 = {
            slp(0.001)
            acc.append(5)
            slp(0.1)
            acc.append(6)
        }
        
        let read3 = {
            slp(0.002)
            acc.append(7)
            slp(0.1)
            acc.append(8)
        }
        
        let exp = self.expectation(description: "end")
        var safe: Safe! = EREW()
        let helperQ = DispatchQueue(label: "test", attributes: DispatchQueue.Attributes.concurrent)
        helperQ.async { safe.read(read1) }
        helperQ.async { safe.read(read2) }
        helperQ.async { safe.write(write1) }
        helperQ.async { safe.read(read3) }
        
        helperQ.async(flags: .barrier, execute: {
            
            safe.write {
                slp(0.1)
                safe = nil
                let expAcc = [1, 2, 3, 4, 5, 6, 7, 8]
                XCTAssertEqual(expAcc, acc)
                exp.fulfill()
            }
        }) 
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testCREW() {
        
        var acc: [Int] = []
        let read1 = {
            acc.append(1)
            slp(0.1)
            acc.append(2)
        }
        
        let read2 = {
            slp(0.001)
            acc.append(3)
            slp(0.1)
            acc.append(4)
        }
        
        let write1 = {
            slp(0.002)
            acc.append(5)
            slp(0.1)
            acc.append(6)
        }
        
        let read3 = {
            slp(0.003)
            acc.append(7)
            slp(0.1)
            acc.append(8)
        }
        
        let exp = self.expectation(description: "end")
        var safe: Safe! = CREW()
        let helperQ = DispatchQueue(label: "test", attributes: DispatchQueue.Attributes.concurrent)
        helperQ.async { safe.read(read1) }
        helperQ.async { safe.read(read2) }
        helperQ.async { safe.write(write1) }
        helperQ.async { safe.read(read3) }
        
        helperQ.async(flags: .barrier, execute: {
            
            safe.write {
                slp(0.1)
                safe = nil
                
                print(acc)
                
                //the first two reads should be intertwined
                let expReadFirsts: Set<Int> = [1, 3]
                let readFirsts = Set(acc.prefix(2))
                XCTAssertEqual(expReadFirsts, readFirsts)
                
                let expReadSeconds: Set<Int> = [2, 4]
                let readSeconds = Set(acc.prefix(4).suffix(2))
                XCTAssertEqual(expReadSeconds, readSeconds)
                
                let expAccTail = [5, 6, 7, 8]
                let accTail = Array(acc.dropFirst(4))
                XCTAssertEqual(expAccTail, accTail)
                
                exp.fulfill()
            }
        }) 
        self.waitForExpectations(timeout: 50, handler: nil)
    }

}
