const zmq = @import("libzmq");
const std = @import("std");
const c = @import("std").c;

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

pub fn withSize(size: usize) InitError!Self {
    var result = Self{ .message = undefined };

    if (zmq.zmq_msg_init_size(&result.message, size) == -1) {
        return switch (c._errno().*) {
            zmq.ENOMEM => InitError.OutOfMemory,
            else => InitError.Unexpected,
        };
    }

    return result;
}

pub fn withBuffer(ptr: *const anyopaque, len: usize) InitError!Self {
    var result = Self{ .message = undefined };

    if (zmq.zmq_msg_init_buffer(&result.message, ptr, len) == -1) {
        return switch (c._errno().*) {
            zmq.ENOMEM => InitError.OutOfMemory,
            else => InitError.Unexpected,
        };
    }

    return result;
}

pub fn deinit(self: *Self) void {
    _ = zmq.zmq_msg_close(&self.message);
}

pub fn data(self: *Self, Data: type) *Data {
    return @ptrCast(zmq.zmq_msg_data(&self.message));
}
