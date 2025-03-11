const zmq = @import("libzmq");
pub const errno = @import("errno.zig").errno;

const Socket = @import("socket.zig").Socket;

pub const Events = packed struct(c_short) {
    pollin: bool = false,
    pollout: bool = false,
    pollerr: bool = false,
    pollpri: bool = false,
    _padding: u12 = 0,

    pub const in: Events = .{ .pollin = true };
    pub const out: Events = .{ .pollout = true };
    pub const inout: Events = .{ .pollin = true, .pollout = true };
};
pub const Item = extern struct {
    socket: ?*Socket = null,
    fd: zmq.zmq_fd_t = 0,
    events: Events = .{},
    revents: Events = .{},
};

pub const PollError = error{ SocketInvalid, Interrupted, Unexpected };
pub fn poll(items: []Item, timeout: c_long) PollError!usize {
    return switch (zmq.zmq_poll(
        @ptrCast(items.ptr),
        @intCast(items.len),
        timeout,
    )) {
        -1 => switch (errno()) {
            // zmq.EFAULT is skip since items cannot be null
            zmq.ETERM => PollError.SocketInvalid,
            zmq.EINTR => PollError.Interrupted,
            else => PollError.Unexpected,
        },
        else => |size| @intCast(size),
    };
}

test "poll" {
    var items: [1]Item = .{.{}};
    _ = poll(&items, 0) catch {};
}
