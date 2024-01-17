/// Read
public protocol Read {
    mutating func read(buf: inout [UInt8], amt: UInt) throws -> Int
}