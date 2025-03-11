const zmq = @import("zmq");
const std = @import("std");

pub fn main() !void {
    const context: *zmq.Context = try .init();
    defer context.deinit();

    const socket: *zmq.Socket = try .init(context, .pull);
    defer socket.deinit();

    var message: zmq.Message = .empty();
    defer message.deinit();

    try socket.bind("ipc:///home/uy/Personal/playground/python/hello");

    var poller: *zmq.Poller = try .init();
    try poller.add(socket, null, .in);

    var events: [1]zmq.Poller.Event = .{
        .{ .events = .in },
    };

    while (poller.wait(&events[0], -1)) {
        if (events[0].socket == socket) {
            _ = try socket.recvMsg(&message, .{});
            std.debug.print("{?s}\n", .{message.slice()});
        }
    } else |err| {
        std.debug.print("{}\n", .{err});
    }
}
