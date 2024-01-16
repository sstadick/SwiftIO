# SwiftIO

Buffered Reader and Writer IO modeled after Rust's BufReader and BufWriter.

## Progress

- [x] First pass BufReader
- [ ] First pass BufWriter
- [ ] Replace `FileHandle` with something crossplatform?
- [ ] Performance improvements

## Usage

```swift
import ArgumentParser
import Foundation
import SwiftIO  

@main
struct LineCount: ParsableCommand {
    @Argument(help: "The file to count lines in.")
    var filePath: String

    mutating func run() throws {
        let fh = if let fh = FileHandle(forReadingAtPath: filePath) { fh } else {
            throw ValidationError("File not found: \(filePath)")
        }
        defer { fh.closeFile() }
        print("Counting lines in \(filePath)")
        let reader = BufReader(reader: fh)

        var buffer: [UInt8] = []
        var count = 0
        while try reader.readUntil(delim: UInt8(ascii: "\n"), buf: &buffer) > 0 {
            count += 1
        }
        print(count)
    }
}
```