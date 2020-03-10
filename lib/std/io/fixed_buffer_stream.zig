pub const FixedBufferInStream = struct {
    data: []const u8,
    pos: usize,

    pub const SeekError = error{EndOfStream};
    pub const GetSeekPosError = error{};

    pub const InStream = InStream(*FixedBufferInStream, error{}, read);

    pub fn inStream(self: *FixedBufferInStream) InStream {
        return .{ .context = self };
    }

    pub const SeekableStream = SeekableStream(*FixedBufferInStream, SeekError, GetSeekPosError,
        seekTo, seekBy, getEndPos, getPos,);

    pub fn seekableStream(self: *FixedBufferInStream) SeekableStream {
        return .{ .context = self };
    }

    pub fn read(self: *FixedBufferInStream, dest: []u8) error{}!usize {
        const size = std.math.min(dest.len, self.slice.len - self.pos);
        const end = self.pos + size;

        std.mem.copy(u8, dest[0..size], self.slice[self.pos..end]);
        self.pos = end;

        return size;
    }

    pub fn seekToFn(self: *FixedBufferInStream, pos: u64) SeekError!void {
        const usize_pos = std.math.cast(usize, pos) catch return error.EndOfStream;
        if (usize_pos > self.slice.len) return error.EndOfStream;
        self.pos = usize_pos;
    }

    pub fn seekByFn(self: *FixedBufferInStream, amt: i64) SeekError!void {
        if (amt < 0) {
            const abs_amt = std.math.cast(usize, -amt) catch return error.EndOfStream;
            if (abs_amt > self.pos) return error.EndOfStream;
            self.pos -= abs_amt;
        } else {
            const usize_amt = std.math.cast(usize, amt) catch return error.EndOfStream;
            if (self.pos + usize_amt > self.slice.len) return error.EndOfStream;
            self.pos += usize_amt;
        }
    }

    pub fn getEndPosFn(self: *FixedBufferInStream) GetSeekPosError!u64 {
        return self.slice.len;
    }

    pub fn getPos(self: *FixedBufferInStream) GetSeekPosError!u64 {
        return self.pos;
    }
};
