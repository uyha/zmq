const zmq = @import("zmq");
const std = @import("std");

pub fn main() !void {
    const context: zmq.Context = try .init();
    defer context.deinit();

    const socket: zmq.Socket = try .init(context, .push);
    defer socket.deinit();

    const content = "Hell";
    _ = content;
    var message: zmq.Message = try .with_size(6);
    defer message.deinit();

    try socket.connect("ipc:///home/uy/Personal/playground/python/hello");
    std.debug.print("{!}\n", .{socket.send_msg(&message, .more)});
    std.debug.print("{!}\n", .{socket.send_msg(&message, .noblock)});
}
