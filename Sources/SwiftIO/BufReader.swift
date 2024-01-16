// https://github.com/rust-lang/rust/blob/master/library/std/src/io/buffered/bufreader.rs

public protocol BufRead {
    /// Returns the contents of the internal buffer, filling it with more data from the inner reader if it is empty.
    mutating func fillBuf() throws -> ArraySlice<UInt8>
    /// Tells this buffer that `n` bytes have been consumed from the buffer, so they should no longer be returned in calls to `read`.
    mutating func consume(n: Int)
    /// Read all bytes into `buf` until the delimiter `delim` is reached, or until EOF. If successful, returns the total number of bytes read.
    mutating func readUntil(delim: UInt8, buf: inout [UInt8]) throws -> Int
    /// Read all bytes untuil a newline (the 0xA byte) is reached, and append them to the supplied buffer. If successful, returns the total number of bytes read.
    mutating func readLine(buf: inout [UInt8]) throws -> Int

}

public class BufReader {
    var inner: Read
    var buffer: Buffer

    init(reader: Read, capacity: Int = 4096) {
        self.inner = reader
        self.buffer = Buffer(capacity: capacity)
    }

    /// Returns a slice of the buffered data.
    /// 
    /// Unlike `fillBuf`, this will not attempt to fill the buffer if it is empty.
    public func getBuf() -> ArraySlice<UInt8> {
        return self.buffer.getBuf()
    }

    /// Returns the number of bytes the internal buffer can hold at once.
    public func capacity() -> UInt {
        return self.buffer.capacity()
    }

    /// Invalidate all data in the internal buffer.
    public func discardBuffer() {
        self.buffer.discardBuffer()
    }
}

extension BufReader: BufRead {
    public func fillBuf() throws -> ArraySlice<UInt8>{
        try self.buffer.fillBuf(reader: &self.inner)
    }

    public func consume(n: Int) {
        self.buffer.consume(amt: UInt(n))
    }

    public func readUntil(delim: UInt8, buf: inout [UInt8]) throws -> Int {
        0
    }

    public func readLine(buf: inout [UInt8]) throws -> Int {
       0 
    }


}

extension BufReader: Read {
    public func read(buf: inout [UInt8]) throws -> Int {
        // If we don't have any buffered data and we're doing a massive read
        // (larger than the internal buffer), bypass our buffer completely.
        if self.buffer.getPos() == self.buffer.getFilled() && buf.count >= self.buffer.capacity() {
            self.discardBuffer();
            return try self.inner.read(buf: &buf)
        }

        var rem = try self.fillBuf()
        // TODO: stuck here: https://github.com/rust-lang/rust/blob/fa0dc208d0a34027c1d3cca7d47975d8238bcfde/library/std/src/io/buffered/bufreader.rs#L289
        // I don't understand how we fill the `buf` if `buf` is larger than our capacity.
        // Maybe the answer is that read isn't guaranteed to fill the entire buffer?
        

        // copy bytes from rem into buf
        // TODO: udpate Read api to take a slice instead of an array
        buf.removeAll(keepingCapacity: true)
        buf.append(contentsOf: rem[0..<buf.count])
        self.consume(n: Int)

    }
}