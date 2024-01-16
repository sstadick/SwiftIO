import XCTest
import Foundation

@testable import SwiftIO

class BufReaderTests: XCTestCase {
    var tempFile: URL!
    var fileHandle: FileHandle!

    override func setUpWithError() throws {
        super.setUp()

        // Create a temporary file
        let tempDir = FileManager.default.temporaryDirectory
        tempFile = tempDir.appendingPathComponent(UUID().uuidString)

        // Write some test data to the file
        let testData = "Hello, world!\nThis is a test.\n"
        try testData.write(to: tempFile, atomically: true, encoding: .utf8)

        // Open the file
        fileHandle = try FileHandle(forReadingFrom: tempFile)
    }

    override func tearDownWithError() throws {
        // Close the file and delete it
        fileHandle.closeFile()
        try FileManager.default.removeItem(at: tempFile)

        super.tearDown()
    }

    func testBufReader() throws {
        let reader = BufReader(reader: self.fileHandle)
        var buffer: [UInt8] = []
        let read = try reader.readUntil(delim: UInt8(ascii: "\n"), buf: &buffer);
        XCTAssertEqual(read, 14)
        XCTAssertEqual(buffer, [UInt8]("Hello, world!\n".utf8))
    }

    func testSmallBufReader() throws {
        let reader = BufReader(reader: self.fileHandle, capacity: 4)
        var buffer: [UInt8] = []
        let read = try reader.readUntil(delim: UInt8(ascii: "\n"), buf: &buffer);
        XCTAssertEqual(read, 14)
        XCTAssertEqual(buffer, [UInt8]("Hello, world!\n".utf8))
    }

    func testReadLine() throws {
        let reader = BufReader(reader: self.fileHandle)
        // Read the first line
        var line = ""
        let bytes_read = try reader.readLine(buf: &line)
        XCTAssertEqual(line, "Hello, world!\n")
        XCTAssertEqual(bytes_read, line.utf8.count)

        // Read the second line
        line = ""
        let bytes_read2 = try reader.readLine(buf: &line)
        XCTAssertEqual(line, "This is a test.\n")
        XCTAssertEqual(bytes_read2, line.utf8.count)
    }

    func testReadUntil() throws {
        let reader = BufReader(reader: self.fileHandle)

        var count = 0
        var buffer: [UInt8] = []
        while try reader.readUntil(delim: UInt8(ascii: "\n"), buf: &buffer) > 0 {
            count += 1
        }
        XCTAssertEqual(count, 2)
    }
}
