const zmq = @import("zmq");
const std = @import("std");

pub fn main() !void {
    const context: zmq.Context = try .init();
    defer context.deinit();

    const socket: zmq.Socket = try .init(context, .push);
    defer socket.deinit();

    var socktype: zmq.Socket.Type = undefined;
    var invert_matching: bool = undefined;
    var reconnect_stop: zmq.Socket.ReconnectStop = undefined;
    var handshake_ivl: c_int = undefined;
    var routing_id_buffer: [255]u8 = undefined;
    var routing_id: []u8 = &routing_id_buffer;

    try socket.set(.routing_id, "asdfasdf");

    try socket.get(.type, &socktype);
    try socket.get(.invert_matching, &invert_matching);
    try socket.get(.reconnect_stop, &reconnect_stop);
    try socket.get(.handshake_ivl, &handshake_ivl);
    try socket.get(.routing_id, &routing_id);

    std.debug.print("{any}\n", .{socktype});
    std.debug.print("{any}\n", .{invert_matching});
    std.debug.print("{any}\n", .{reconnect_stop});
    std.debug.print("{any}\n", .{handshake_ivl});
    std.debug.print("{s}\n", .{routing_id});

    const content = "Hello";
    var message: zmq.Message = try .withBuffer(content, content.len);
    defer message.deinit();

    try socket.connect("ipc:///home/uy/Personal/playground/python/hello");
    try socket.sendMsg(&message, .more);
    try socket.sendConst(content, content.len, .noblock);
}
