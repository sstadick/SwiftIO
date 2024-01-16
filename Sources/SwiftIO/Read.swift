/// Read
public protocol Read {
    mutating func read(buf: inout [UInt8]) throws -> Int
}