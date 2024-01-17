// The Swift Programming Language
// https://docs.swift.org/swift-book

public let DEFAULT_BUF_SIZE = 8 * 1024


func copyBuffer(from src: borrowing ArraySlice<UInt8>, to dst: inout [UInt8]) {
    // Grow the dst if it is not large enough to fully copy the src
    if src.count > dst.count {
        for _ in 0..<(src.count - dst.count) {
            dst.append(0)
        }
    }
    dst.withUnsafeMutableBytes { dstBytes in
        src.withUnsafeBytes { srcBytes in 
            dstBytes.copyBytes(from: srcBytes)
        }
    }
}
