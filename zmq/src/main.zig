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

    var poll_items = [_]zmq.poll.Item{
        socket.pollItem(.in),
    };
    if (zmq.poll.poll(&poll_items, -1)) |size| {
        for (poll_items[0..size]) |*item| {
            if (item.socket) |sock| {
                std.debug.print(
                    "{any}\n",
                    .{sock.recvMsg(&message, .{})},
                );
                std.debug.print("{s}\n", .{message.slice().?});
            }
        }
    } else |err| {
        std.debug.print("{}\n", .{err});
    }
}
