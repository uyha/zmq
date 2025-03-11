const zmq = @import("zmq");
const std = @import("std");

pub fn main() !void {
    const context: zmq.Context = try .init();
    defer context.deinit();

    const socket: zmq.Socket = try .init(context, .pull);
    defer socket.deinit();

    var message: zmq.Message = .empty();
    defer message.deinit();

    try socket.bind("ipc:///home/uy/Personal/playground/python/hello");
    _ = try socket.recvMsg(&message, .{});
    std.debug.print("{s}\n", .{message.slice().?});
    std.debug.print("{s}\n", .{try message.gets("Socket-Type")});
}
