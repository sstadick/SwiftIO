
// https://github.com/rust-lang/rust/blob/master/library/std/src/io/buffered/bufreader/buffer.rs
public class Buffer {
    /// The buffer
    var buf: [UInt8]
    /// The current seek offset into `buf`, must always be <= `filled`.
    var pos: UInt
    /// Each call to `fill_buf` sets `filled` to indicate how many bytes at `buf` are
    /// initialized with bytes from a read.
    var filled: UInt

    public init(capacity: Int = 0) {
        self.buf = [UInt8](repeating: 0, count: capacity)
        self.pos = 0
        self.filled = 0
    }

    public func getBuf() -> ArraySlice<UInt8> {
        return self.buf[Int(self.pos)..<Int(self.filled)]
    }

    public func capacity() -> UInt {
        return UInt(self.buf.count)
    }

    public func getFilled() -> UInt { return self.filled }

    public func getPos() -> UInt { return self.pos }

    public func discardBuffer() {
        self.pos = 0
        self.filled = 0
    }

    public func consume(amt: UInt) {
        self.pos = min(self.pos + amt, self.filled)
    }

    public func consumeWith(amt: UInt, visitor: (ArraySlice<UInt8>) -> Void) -> Bool {
        let buffer = self.getBuf()
        if buffer.count < Int(amt) {
            return false
        } else {
            visitor(buffer[0..<Int(amt)])
            self.pos += amt;
            return true
        }
    }

    public func unconsume(amt: UInt) {
        let (value, overflow) = self.pos.subtractingReportingOverflow(amt)
        self.pos = if overflow {
            0
        } else {
            value
        }
    }

    public func fillBuf<R>(reader: inout R) throws -> ArraySlice<UInt8> where R: Read {
        // If we've reached the end ouf our internal buffer then we need to fetch
        // some more data from the underlying reader.
        // Branch using `>=` instead of the more correct `==` to tell
        // the compiler that pos..<cap slice is always valid.

        if self.pos >= self.filled {
            assert(self.pos == self.filled)

            let bytes_read = try reader.read(buf: &self.buf, amt: self.capacity())
            self.pos = 0
            self.filled = UInt(bytes_read)
        }
        return self.getBuf()
    }

}