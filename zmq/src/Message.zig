const zmq = @import("libzmq");
const std = @import("std");
const c = @import("std").c;

const errno = @import("errno.zig").errno;

const Self = @This();

message: zmq.struct_zmq_msg_t,

pub const InitError = error{
    OutOfMemory,
    Unexpected,
};
pub fn empty() Self {
    var result = Self{ .message = undefined };

    _ = zmq.zmq_msg_init(&result.message);

    return result;
}

pub fn withSize(msgSize: usize) InitError!Self {
    var result = Self{ .message = undefined };

    if (zmq.zmq_msg_init_size(&result.message, msgSize) == -1) {
        return switch (errno()) {
            zmq.ENOMEM => InitError.OutOfMemory,
            else => InitError.Unexpected,
        };
    }

    return result;
}

pub fn withBuffer(ptr: *const anyopaque, len: usize) InitError!Self {
    var result = Self{ .message = undefined };

    if (zmq.zmq_msg_init_buffer(&result.message, ptr, len) == -1) {
        return switch (errno()) {
            zmq.ENOMEM => InitError.OutOfMemory,
            else => InitError.Unexpected,
        };
    }

    return result;
}

pub fn deinit(self: *Self) void {
    _ = zmq.zmq_msg_close(&self.message);
}

pub fn data(self: *const Self) ?*anyopaque {
    return zmq.zmq_msg_data(&self.message);
}

pub fn size(self: *const Self) usize {
    return zmq.zmq_msg_size(&self.message);
}

pub fn more(self: *const Self) bool {
    return zmq.zmq_msg_more(&self.message) != 0;
}
