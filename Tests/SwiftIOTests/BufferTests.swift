import XCTest
import Foundation

@testable import SwiftIO 

class BufferTests: XCTestCase {
    var buffer: Buffer!

    override func setUpWithError() throws {
        super.setUp()

        // Create the Buffer with a capacity of 10
        buffer = Buffer(capacity: 10)
    }

    override func tearDownWithError() throws {
        // Clear the buffer
        buffer = nil

        super.tearDown()
    }

    func testGetBuf() throws {
        // Initially, the buffer should be empty
        XCTAssertEqual(buffer.getBuf().count, 0)

        // Fill the buffer with some data
        var reader = StringReader(string: "Hello, world!")
        _ = try buffer.fillBuf(reader: &reader)

        // Now the buffer should contain the first 10 characters of the string
        let buf = buffer.getBuf()
        XCTAssertEqual(buf.count, 10)
        XCTAssertEqual(String(decoding: buf, as: UTF8.self), "Hello, wor")
    }

    func testConsume() throws {
        // Fill the buffer with some data
        var reader = StringReader(string: "Hello, world!")
        _ = try buffer.fillBuf(reader: &reader)

        // Consume 5 bytes
        buffer.consume(amt: 5)

        // Now the buffer should contain the next 5 characters of the string
        let buf = buffer.getBuf()
        XCTAssertEqual(buf.count, 5)
        XCTAssertEqual(String(decoding: buf, as: UTF8.self), ", wor")
    }

    // Add more test methods here to test the other methods of the Buffer class
}

// This is a simple implementation of the Read protocol for testing
struct StringReader: Read {
    var string: String
    var pos: String.Index

    init(string: String) {
        self.string = string
        self.pos = string.startIndex
    }

    mutating func read(buf: inout [UInt8], amt: UInt) throws -> Int {
        let remaining = string.distance(from: pos, to: string.endIndex)
        let count = min(Int(amt), remaining)
        let end = string.index(pos, offsetBy: count)
        buf = Array(string[pos..<end].utf8)
        pos = end
        return count
    }
}