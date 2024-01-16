// https://github.com/rust-lang/rust/blob/master/library/std/src/io/buffered/bufreader.rs

public protocol BufRead {
    /// Returns the contents of the internal buffer, filling it with more data from the inner reader if it is empty.
    mutating func fillBuf() throws -> ArraySlice<UInt8>
    /// Tells this buffer that `n` bytes have been consumed from the buffer, so they should no longer be returned in calls to `read`.
    mutating func consume(n: Int)
    /// Read all bytes into `buf` until the delimiter `delim` is reached, or until EOF. If successful, returns the total number of bytes read.
    mutating func readUntil(delim: UInt8, buf: inout [UInt8]) throws -> Int
    /// Read all bytes untuil a newline (the 0xA byte) is reached, and append them to the supplied buffer. If successful, returns the total number of bytes read.
    mutating func readLine(buf: inout String) throws -> Int

}

public class BufReader<R> where R: Read {
    var inner: R 
    var buffer: Buffer

    public init(reader: R, capacity: Int = DEFAULT_BUF_SIZE) {
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
        // https://github.com/rust-lang/rust/blob/bf2637f4e89aab364d7ab28deb09820363bef86d/library/std/src/io/mod.rs#L2067
        var read = 0
        var done = false
        var used = 0
        while true {
            let available = try self.fillBuf()
            // TODO: Use memchr to find a byte in our buffer
            if let index = available.firstIndex(of: UInt8(ascii: "\n")) {
                buf.append(contentsOf: available[0...index])
                (done, used) = (true, index+1)
            } else {
                buf.append(contentsOf: available)
                (done, used) = (false, available.count)
            }
            self.consume(n: used)
            read += used
            if done || used == 0 {
                return read
            }
        }
    }

    public func readLine(buf: inout String) throws -> Int {
        // https://doc.rust-lang.org/src/std/io/mod.rs.html#2284
        var raw_buf: [UInt8] = Array(buf.utf8)
        let bytes_read = try self.readUntil(delim: UInt8(ascii: "\n"), buf: &raw_buf)
        let str = String(decoding: raw_buf, as: UTF8.self)
        buf.append(str)
        return bytes_read
    }
}

extension BufReader: Read {
    public func read(buf: inout [UInt8], amt: UInt) throws -> Int {
        // If we don't have any buffered data and we're doing a massive read
        // (larger than the internal buffer), bypass our buffer completely.
        if self.buffer.getPos() == self.buffer.getFilled() && buf.count >= self.buffer.capacity() {
            self.discardBuffer();
            return try self.inner.read(buf: &buf, amt: amt)
        }

        let rem = try self.fillBuf()
        // TODO: stuck here: https://github.com/rust-lang/rust/blob/fa0dc208d0a34027c1d3cca7d47975d8238bcfde/library/std/src/io/buffered/bufreader.rs#L289
        // I don't understand how we fill the `buf` if `buf` is larger than our capacity.
        // Maybe the answer is that read isn't guaranteed to fill the entire buffer?
        

        // copy bytes from rem into buf
        // TODO: udpate Read api to take a slice instead of an array
        buf.removeAll(keepingCapacity: true)
        buf.append(contentsOf: rem[0..<buf.count])
        self.consume(n: rem.count)
        return rem.count
    }
}
