const std = @import("std");
const c = std.c;
const zmq = @import("libzmq");

const Context = @import("Context.zig");
const Message = @import("Message.zig");

const opt = @import("socket/option.zig");
const SetOption = opt.SetOption;
const SetOptionType = opt.SetOptionType;

pub const Type = @import("socket/type.zig").Type;

const Self = @This();

handle: *anyopaque,

pub const InitError = error{
    TooManyOpenFiles,
    InvalidContext,
    Unexpected,
};
pub fn init(context: Context, socket_type: Type) InitError!Self {
    const handle = zmq.zmq_socket(context.handle, @intFromEnum(socket_type));

    if (handle == null) {
        return switch (c._errno().*) {
            zmq.EMFILE => InitError.TooManyOpenFiles,
            zmq.EFAULT, zmq.ETERM => InitError.InvalidContext,
            else => InitError.Unexpected,
        };
    }

    return .{ .handle = handle.? };
}

pub const ConnectError = error{
    EndpointInvalid,
    TransportNotSupported,
    TransportNotCompatible,
    ContextInvalid,
    SocketInvalid,
    NoThreadAvaiable,
    Unexpected,
};
pub fn connect(socket: Self, endpoint: [:0]const u8) ConnectError!void {
    if (zmq.zmq_connect(socket.handle, endpoint.ptr) != -1) {
        return;
    }

    return switch (c._errno().*) {
        zmq.EINVAL => ConnectError.EndpointInvalid,
        zmq.ETERM => ConnectError.ContextInvalid,
        zmq.ENOTSOCK => ConnectError.SocketInvalid,
        zmq.EPROTONOSUPPORT => ConnectError.TransportNotSupported,
        zmq.ENOCOMPATPROTO => ConnectError.TransportNotCompatible,
        zmq.EMTHREAD => ConnectError.NoThreadAvaiable,
        else => ConnectError.Unexpected,
    };
}

pub const BindError = error{
    EndpointInvalid,
    TransportNotSupported,
    TransportNotCompatible,
    AddressInUse,
    AddressNotLocal,
    NonexistentInterface,
    ContextInvalid,
    SocketInvalid,
    NoThreadAvaiable,
    Unexpected,
};
pub fn bind(socket: Self, endpoint: [:0]const u8) BindError!void {
    if (zmq.zmq_bind(socket.handle, endpoint.ptr) != -1) {
        return;
    }
    return switch (c._errno().*) {
        zmq.EINVAL => BindError.EndpointInvalid,
        zmq.EPROTONOSUPPORT => BindError.TransportNotSupported,
        zmq.ENOCOMPATPROTO => BindError.TransportNotCompatible,
        zmq.EADDRINUSE => BindError.AddressInUse,
        zmq.EADDRNOTAVAIL => BindError.AddressNotLocal,
        zmq.ENODEV => BindError.NonexistentInterface,
        zmq.ETERM => BindError.ContextInvalid,
        zmq.ENOTSOCK => BindError.SocketInvalid,
        zmq.EMTHREAD => BindError.NoThreadAvaiable,
        else => ConnectError.Unexpected,
    };
}

const SendFlags = packed struct(c_int) {
    dont_wait: bool = false,
    send_more: bool = false,
    _padding: u30 = 0,

    pub const noblock: SendFlags = .{ .dont_wait = true };
    pub const more: SendFlags = .{ .send_more = true };
    pub const morenoblock: SendFlags = .{ .dont_wait = true, .send_more = true };
};
const SendError = error{
    WouldBlock,
    SendMsgNotSupported,
    MultipartNotSupported,
    InappropriateStateActionFailed,
    ContextInvalid,
    SocketInvalid,
    Interrupted,
    MessageInvalid,
    CannotRoute,
    Unexpected,
};

fn sendError() SendError {
    return switch (c._errno().*) {
        zmq.EAGAIN => SendError.WouldBlock,
        zmq.ENOTSUP => SendError.SendMsgNotSupported,
        zmq.EINVAL => SendError.MultipartNotSupported,
        zmq.EFSM => SendError.InappropriateStateActionFailed,
        zmq.ETERM => SendError.ContextInvalid,
        zmq.ENOTSOCK => SendError.SocketInvalid,
        zmq.EINTR => SendError.Interrupted,
        zmq.EFAULT => SendError.MessageInvalid,
        zmq.EHOSTUNREACH => SendError.CannotRoute,
        else => SendError.Unexpected,
    };
}
pub fn sendMsg(self: Self, message: *Message, flags: SendFlags) SendError!void {
    const result = zmq.zmq_msg_send(&message.message, self.handle, @bitCast(flags));
    if (result == -1) {
        return sendError();
    }
}
pub fn sendBuffer(self: Self, ptr: *const anyopaque, len: usize, flags: SendFlags) SendError!void {
    const result = zmq.zmq_send(self.handle, ptr, len, @bitCast(flags));
    if (result == -1) {
        return sendError();
    }
}
pub fn sendConst(self: Self, ptr: *const anyopaque, len: usize, flags: SendFlags) SendError!void {
    const result = zmq.zmq_send_const(self.handle, ptr, len, @bitCast(flags));
    if (result == -1) {
        return sendError();
    }
}

pub fn deinit(socket: Self) void {
    _ = zmq.zmq_close(socket.handle);
}

pub const SetError = error{
    OptionInvalid,
    ContextInvalid,
    SocketInvalid,
    Interrupted,
    Unexpected,
};
pub fn set(socket: Self, comptime option: SetOption, value: SetOptionType(option)) SetError!void {
    const Value = @TypeOf(value);
    const raw_value = switch (@typeInfo(Value)) {
        .bool => @as(c_int, @intFromBool(value)),
        .@"struct" => |Struct| switch (Struct.layout) {
            .@"packed" => @as(Struct.backing_integer.?, @bitCast(value)),
            else => @compileError("Unrecognized type: " ++ @typeName(Value)),
        },
        .@"enum" => @intFromEnum(value),
        else => @compileError("Unrecognized type: " ++ @typeName(Value)),
    };
    const RawValue = @TypeOf(raw_value);

    const ptr, const size = switch (RawValue) {
        []const u8, [:0]const u8 => .{ raw_value.ptr, raw_value.len },
        c_int, u64, i64 => .{ &raw_value, @sizeOf(RawValue) },
        else => @compileError("Unrecognized type: " ++ @typeName(RawValue)),
    };

    if (zmq.zmq_setsockopt(
        socket.handle,
        @intFromEnum(option),
        ptr,
        size,
    ) == 0) {
        return;
    }

    return switch (c._errno().*) {
        zmq.EINVAL => SetError.OptionInvalid,
        zmq.ETERM => SetError.ContextInvalid,
        zmq.ENOTSOCK => SetError.SocketInvalid,
        zmq.EINTR => SetError.Interrupted,
        else => SetError.Unexpected,
    };
}
