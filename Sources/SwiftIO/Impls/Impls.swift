// https://github.com/rust-lang/rust/blob/bf2637f4e89aab364d7ab28deb09820363bef86d/library/std/src/fs.rs#L753
import Foundation

@available(macOS 10.15.4, *)
extension FileHandle: Read {
    public func read(buf: inout [UInt8], amt: UInt) throws -> Int {
        if let data = try self.read(upToCount: Int(min(amt, UInt(buf.count)))) {
            let _ = buf.withUnsafeMutableBufferPointer { buffer in
                data.copyBytes(to: buffer)
            }
            return data.count
        } else {
            return 0
        }
    }
}

extension [UInt8]: Read {
    public mutating func read(buf: inout [UInt8], amt: UInt) throws -> Int {
        // https://doc.rust-lang.org/src/std/io/impls.rs.html#233
        let amt = Swift.min(amt, UInt(self.count))
        // First check if the amount we want to copy is small:
        if amt == 1 {
            buf.append(self[0])
        } else {
            buf.append(contentsOf: self[0..<Int(amt)])
        }
        self.removeFirst(Int(amt))
        return Int(amt)
    }
}