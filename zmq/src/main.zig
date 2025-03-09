const zmq = @import("zmq");
const std = @import("std");

pub fn main() !void {
    const context: zmq.Context = try .init();
    defer context.deinit();

    const socket: zmq.Socket = try .init(context, .push);
    defer socket.deinit();

    const content = "Hello";
    var message: zmq.Message = try .withBuffer(content, content.len);
    defer message.deinit();

    try socket.connect("ipc:///home/uy/Personal/playground/python/hello");
    std.debug.print("{!}\n", .{socket.sendMsg(&message, .more)});
    std.debug.print("{!}\n", .{socket.sendConst(content, content.len, .noblock)});
}
