const zmq = @import("libzmq");
const std = @import("std");
const log = std.log.warn;
const posix = std.posix;
const c = @import("std").c;

const errno = @import("errno.zig").errno;
const strerror = @import("errno.zig").strerror;

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
            else => |err| {
                log("{s}\n", .{strerror(err)});
                return InitError.Unexpected;
            },
        };
    }

    return result;
}

pub fn withBuffer(ptr: *const anyopaque, len: usize) InitError!Self {
    var result = Self{ .message = undefined };

    if (zmq.zmq_msg_init_buffer(&result.message, ptr, len) == -1) {
        return switch (errno()) {
            zmq.ENOMEM => InitError.OutOfMemory,
            else => |err| {
                log("{s}\n", .{strerror(err)});
                return InitError.Unexpected;
            },
        };
    }

    return result;
}

pub const FreeFn = fn (data: ?*anyopaque, hint: ?*anyopaque) callconv(.c) void;
pub fn withData(ptr: *anyopaque, len: usize, free_fn: *const FreeFn, hint: ?*anyopaque) InitError!Self {
    var result = Self{ .message = undefined };

    return switch (zmq.zmq_msg_init_data(&result.message, ptr, len, free_fn, hint)) {
        -1 => {
            return switch (errno()) {
                zmq.ENOMEM => InitError.OutOfMemory,
                else => |err| {
                    log("{s}\n", .{strerror(err)});
                    return InitError.Unexpected;
                },
            };
        },
        else => result,
    };
}

pub fn deinit(self: *Self) void {
    _ = zmq.zmq_msg_close(&self.message);
}

test "init and deinit functions" {
    var emptyMsg: Self = .empty();
    defer emptyMsg.deinit();

    var sizeMsg: Self = try .withSize(1);
    defer sizeMsg.deinit();

    const buffer: [32]u8 = undefined;
    var bufferMsg: Self = try .withBuffer(&buffer, buffer.len);
    defer bufferMsg.deinit();

    const free = struct {
        pub fn free(data_ptr: ?*anyopaque, hint: ?*anyopaque) callconv(.c) void {
            if (data_ptr) |ptr| {
                const allocator: *std.mem.Allocator = @alignCast(@ptrCast(hint));
                const actual_data: *std.ArrayListUnmanaged(u8) = @alignCast(@ptrCast(ptr));
                actual_data.deinit(allocator.*);
            }
        }
    }.free;
    const allocator = std.testing.allocator;

    var selfManagedData = try std.ArrayListUnmanaged(u8).initCapacity(allocator, 16);
    try selfManagedData.resize(allocator, 16);
    var dataMsg: Self = try .withData(
        &selfManagedData,
        @sizeOf(@TypeOf(selfManagedData)),
        &free,
        @constCast(&allocator),
    );
    defer dataMsg.deinit();
}

pub fn data(self: *Self) ?*anyopaque {
    return zmq.zmq_msg_data(&self.message);
}

pub fn size(self: *const Self) usize {
    return zmq.zmq_msg_size(&self.message);
}

pub fn slice(self: *Self) ?[]const u8 {
    const ptr = self.data() orelse return null;
    return @as([*]const u8, @ptrCast(ptr))[0..self.size()];
}

test "data, size, and slice" {
    const buffer = "asdf";
    var msg: Self = try .withBuffer(buffer, buffer.len);
    defer msg.deinit();

    try std.testing.expectEqual(buffer.len, msg.size());

    var msgSlice: []const u8 = undefined;
    msgSlice.ptr = @ptrCast(msg.data().?);
    msgSlice.len = msg.size();
    try std.testing.expect(std.mem.eql(u8, buffer, msgSlice));

    try std.testing.expect(std.mem.eql(u8, buffer, msg.slice().?));
}

pub fn more(self: *const Self) bool {
    return zmq.zmq_msg_more(&self.message) != 0;
}

test "more" {
    var msg: Self = .empty();
    defer msg.deinit();

    try std.testing.expect(!msg.more());
}

pub const CopyError = error{ MessageInvalid, Unexpected };
/// This does not actually guarantee to actually copy, the messages can share the
/// underlying buffer. Hence, it is unsafe to modify the content of `source` after the
/// copy. Use `Message.withBuffer` to create an actual copy.
pub fn copy(self: *Self, source: *Self) CopyError!void {
    if (zmq.zmq_msg_copy(&self.message, &source.message) == -1) {
        return switch (errno()) {
            zmq.EFAULT => CopyError.MessageInvalid,
            else => |err| {
                log("{s}\n", .{strerror(err)});
                return CopyError.Unexpected;
            },
        };
    }
}

pub const MoveError = error{ MessageInvalid, Unexpected };
pub fn move(self: *Self, source: *Self) MoveError!void {
    if (zmq.zmq_msg_move(&self.message, &source.message) == -1) {
        return switch (errno()) {
            zmq.EFAULT => MoveError.MessageInvalid,
            else => |err| {
                log("{s}\n", .{strerror(err)});
                return MoveError.Unexpected;
            },
        };
    }
}

test "copy and move" {
    var source: Self = .empty();
    defer source.deinit();

    var dest: Self = .empty();
    defer dest.deinit();

    try source.copy(&dest);
    try source.move(&dest);
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
        else => |err| {
            log("{s}\n", .{strerror(err)});
            return GetsError.Unexpected;
        },
    };
}

test "get and gets" {
    var msg: Self = .empty();
    defer msg.deinit();

    _ = msg.get(.more);
    _ = msg.get(.source_fd);
    _ = msg.get(.shared);

    _ = msg.gets("Socket-Type") catch {};
}

pub const SetRoutingIdError = error{
    /// Routing id is not allow to be zero
    ZeroRoutingId,
    Unexpected,
};
pub fn setRoutingId(self: *Self, routing_id: u32) SetRoutingIdError!void {
    switch (zmq.zmq_msg_set_routing_id(&self.message, routing_id)) {
        -1 => return switch (errno()) {
            zmq.EINVAL => SetRoutingIdError.ZeroRoutingId,
            else => |err| {
                log("{s}\n", .{strerror(err)});
                return SetRoutingIdError.Unexpected;
            },
        },
        else => {},
    }
}

pub fn getRoutingId(self: *Self) u32 {
    return zmq.zmq_msg_routing_id(&self.message);
}

test "get and set routing id" {
    const t = std.testing;

    var msg: Self = .empty();
    defer msg.deinit();

    try t.expectEqual(0, msg.getRoutingId());
    try t.expectEqual(SetRoutingIdError.ZeroRoutingId, msg.setRoutingId(0));
    try msg.setRoutingId(1);
    try t.expectEqual(1, msg.getRoutingId());
}
