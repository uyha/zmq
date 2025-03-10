const std = @import("std");
const c = std.c;
const zmq = @import("libzmq");

const Context = @import("Context.zig");
const Message = @import("Message.zig");

const opt = @import("socket/option.zig");
pub const SetOption = opt.SetOption;
pub const SetOptionType = opt.SetOptionType;
pub const GetOption = opt.GetOption;
pub const GetOptionType = opt.GetOptionType;
pub const Mechanism = opt.Mechanism;
pub const ReconnectStop = opt.ReconnectStop;
pub const RouterNotify = opt.RouterNotify;
pub const NormMode = opt.NormMode;
pub const PrincipalNameType = opt.PrincipalNameType;

pub const Type = @import("socket/type.zig").Type;

const errno = @import("errno.zig").errno;

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
        return switch (errno()) {
            zmq.EMFILE => InitError.TooManyOpenFiles,
            zmq.EFAULT, zmq.ETERM => InitError.InvalidContext,
            else => InitError.Unexpected,
        };
    }

    return .{ .handle = handle.? };
}
pub fn deinit(socket: Self) void {
    _ = zmq.zmq_close(socket.handle);
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

    return switch (errno()) {
        zmq.EINVAL => ConnectError.EndpointInvalid,
        zmq.ETERM => ConnectError.ContextInvalid,
        zmq.ENOTSOCK => ConnectError.SocketInvalid,
        zmq.EPROTONOSUPPORT => ConnectError.TransportNotSupported,
        zmq.ENOCOMPATPROTO => ConnectError.TransportNotCompatible,
        zmq.EMTHREAD => ConnectError.NoThreadAvaiable,
        else => ConnectError.Unexpected,
    };
}

pub const DisconnectError = error{
    EndpointInvalid,
    ContextInvalid,
    SocketInvalid,
    EndpointNotBound,
    Unexpected,
};
pub fn disconnect(socket: Self, endpoint: [:0]const u8) DisconnectError!void {
    if (zmq.zmq_disconnect(socket.handle, endpoint.ptr) != -1) {
        return;
    }

    return switch (errno()) {
        zmq.EINVAL => DisconnectError.EndpointInvalid,
        zmq.ETERM => DisconnectError.ContextInvalid,
        zmq.ENOTSOCK => DisconnectError.SocketInvalid,
        zmq.ENOENT => DisconnectError.EndpointNotBound,
        else => DisconnectError.Unexpected,
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
    return switch (errno()) {
        zmq.EINVAL => BindError.EndpointInvalid,
        zmq.EPROTONOSUPPORT => BindError.TransportNotSupported,
        zmq.ENOCOMPATPROTO => BindError.TransportNotCompatible,
        zmq.EADDRINUSE => BindError.AddressInUse,
        zmq.EADDRNOTAVAIL => BindError.AddressNotLocal,
        zmq.ENODEV => BindError.NonexistentInterface,
        zmq.ETERM => BindError.ContextInvalid,
        zmq.ENOTSOCK => BindError.SocketInvalid,
        zmq.EMTHREAD => BindError.NoThreadAvaiable,
        else => BindError.Unexpected,
    };
}

pub const UnbindError = error{
    EndpointInvalid,
    ContextInvalid,
    SocketInvalid,
    EndpointNotBound,
    Unexpected,
};
pub fn unbind(socket: Self, endpoint: [:0]const u8) UnbindError!void {
    if (zmq.zmq_unbind(socket.handle, endpoint.ptr) != -1) {
        return;
    }
    return switch (errno()) {
        zmq.EINVAL => UnbindError.EndpointInvalid,
        zmq.ETERM => UnbindError.ContextInvalid,
        zmq.ENOTSOCK => UnbindError.SocketInvalid,
        zmq.ENOENT => UnbindError.EndpointNotBound,
        else => UnbindError.Unexpected,
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
    return switch (errno()) {
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

pub const SetError = error{
    OptionInvalid,
    ContextInvalid,
    SocketInvalid,
    Interrupted,
    Unexpected,
};
pub fn set(self: Self, comptime option: SetOption, value: SetOptionType(option)) SetError!void {
    const Value = @TypeOf(value);
    const raw_value = switch (@typeInfo(Value)) {
        .bool => @as(c_int, @intFromBool(value)),
        .@"struct" => |Struct| switch (Struct.layout) {
            .@"packed" => @as(Struct.backing_integer.?, @bitCast(value)),
            else => @compileError("Unrecognized type: " ++ @typeName(Value)),
        },
        .@"enum" => @intFromEnum(value),
        .pointer => value,
        else => @compileError("Unrecognized type: " ++ @typeName(Value)),
    };
    const RawValue = @TypeOf(raw_value);

    const ptr, const size = switch (RawValue) {
        []const u8, [:0]const u8 => .{ raw_value.ptr, raw_value.len },
        c_int, u64, i64 => .{ &raw_value, @sizeOf(RawValue) },
        else => @compileError("Unrecognized type: " ++ @typeName(RawValue)),
    };

    if (zmq.zmq_setsockopt(
        self.handle,
        @intFromEnum(option),
        ptr,
        size,
    ) == 0) {
        return;
    }

    return switch (errno()) {
        zmq.EINVAL => SetError.OptionInvalid,
        zmq.ETERM => SetError.ContextInvalid,
        zmq.ENOTSOCK => SetError.SocketInvalid,
        zmq.EINTR => SetError.Interrupted,
        else => SetError.Unexpected,
    };
}

pub const GetError = error{
    OptionInvalid,
    ContextInvalid,
    SocketInvalid,
    Interrupted,
    Unexpected,
};
pub fn get(self: Self, comptime option: GetOption, out: *GetOptionType(option)) SetError!void {
    const Out = @TypeOf(out.*);
    const result = result: switch (@typeInfo(Out)) {
        .bool => {
            var value: c_int = undefined;
            var size: usize = @sizeOf(@TypeOf(value));

            const result = zmq.zmq_getsockopt(self.handle, @intFromEnum(option), &value, &size);

            if (result != -1) {
                out.* = value != 0;
            }

            break :result result;
        },
        .@"struct" => |Struct| {
            if (Struct.layout != .@"packed") {
                @compileError("Unrecognized type: " ++ @typeName(Out));
            }
            var size: usize = @sizeOf(Out);
            break :result zmq.zmq_getsockopt(self.handle, @intFromEnum(option), out, &size);
        },
        .@"enum" => {
            var size: usize = @sizeOf(Out);
            break :result zmq.zmq_getsockopt(self.handle, @intFromEnum(option), out, &size);
        },
        .int => {
            var size: usize = @sizeOf(Out);
            break :result zmq.zmq_getsockopt(self.handle, @intFromEnum(option), out, &size);
        },
        .pointer => |Pointer| {
            if (Pointer.size != .slice) {
                @compileError("Unrecognized type: " ++ @typeName(Out));
            }
            break :result zmq.zmq_getsockopt(
                self.handle,
                @intFromEnum(option),
                out.ptr,
                &out.len,
            );
        },
        else => @compileError("Unrecognized type: " ++ @typeName(Out)),
    };

    if (result == -1) {
        return switch (errno()) {
            zmq.EINVAL => SetError.OptionInvalid,
            zmq.ETERM => SetError.ContextInvalid,
            zmq.ENOTSOCK => SetError.SocketInvalid,
            zmq.EINTR => SetError.Interrupted,
            else => SetError.Unexpected,
        };
    }
}
