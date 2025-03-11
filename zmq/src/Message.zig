const zmq = @import("libzmq");
const std = @import("std");
const posix = std.posix;
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

pub fn data(self: *Self) ?*anyopaque {
    return zmq.zmq_msg_data(&self.message);
}

pub fn size(self: *const Self) usize {
    return zmq.zmq_msg_size(&self.message);
}

pub fn slice(self: *Self) ?[]u8 {
    var result: []u8 = undefined;
    result.ptr = @ptrCast(self.data() orelse return null);
    result.len = self.size();
    return result;
}

pub fn more(self: *const Self) bool {
    return zmq.zmq_msg_more(&self.message) != 0;
}

pub const CopyError = error{ MessageInvalid, Unexpected };
/// This does not actually guarantee to actually copy, the messages can share the
/// underlying buffer. Hence, it is unsafe to modify the content of `source` after the
/// copy. Use `Message.withBuffer` to create an actual copy.
pub fn copy(self: *Self, source: *Self) CopyError!void {
    if (zmq.zmq_msg_copy(&self.message, &source.message) == -1) {
        return switch (errno()) {
            zmq.EFAULT => CopyError.MessageInvalid,
            else => CopyError.Unexpected,
        };
    }
}

pub const MoveError = error{ MessageInvalid, Unexpected };
pub fn move(self: *Self, source: *Self) MoveError!void {
    if (zmq.zmq_msg_move(&self.message, &source.message) == -1) {
        return switch (errno()) {
            zmq.EFAULT => MoveError.MessageInvalid,
            else => MoveError.Unexpected,
        };
    }
}

pub const Property = enum(c_int) {
    more = zmq.ZMQ_MORE,
    source_fd = zmq.ZMQ_SRCFD,
    shared = zmq.ZMQ_SHARED,
};
pub fn PropertyType(property: Property) type {
    return switch (property) {
        .more, .shared => bool,
        .source_fd => posix.socket_t,
    };
}
pub fn get(self: *const Self, comptime property: Property) PropertyType(property) {
    return switch (property) {
        .more, .shared => zmq.zmq_msg_get(&self.message, @intFromEnum(property)) != 0,
        .source_fd => zmq.zmq_msg_get(&self.message, @intFromEnum(property)),
    };
}

pub const GetsError = error{ PropertyUnkown, Unexpected };
pub fn gets(self: *Self, property: [:0]const u8) GetsError![*:0]const u8 {
    return if (zmq.zmq_msg_gets(&self.message, property)) |result|
        result
    else switch (errno()) {
        zmq.EINVAL => GetsError.PropertyUnkown,
        else => GetsError.Unexpected,
    };
}
