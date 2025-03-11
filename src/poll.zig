const zmq = @import("libzmq");
const log = @import("std").log.warn;

const errno = @import("errno.zig").errno;
const strerror = @import("errno.zig").strerror;

const Socket = @import("socket.zig").Socket;
const Events = @import("events.zig").Events;

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
            else => |err| {
                log("{s}\n", .{strerror(err)});
                return PollError.Unexpected;
            },
        },
        else => |size| @intCast(size),
    };
}

test "poll" {
    var items: [1]Item = .{.{}};
    _ = poll(&items, 0) catch {};
}
