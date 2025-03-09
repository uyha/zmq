const zmq = @import("zmq");
const std = @import("std");

pub fn main() !void {
    const context: zmq.Context = try .init();
    defer context.deinit();

    const socket: zmq.Socket = try .init(context, .req);
    defer socket.deinit();

    try socket.connect("ipc://hello");

    std.debug.print(
        "{?}\n",
        .{
            zmq.version(),
        },
    );
}
