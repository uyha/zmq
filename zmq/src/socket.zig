const std = @import("std");
const c = std.c;
const zmq = @import("libzmq");

const Context = @import("context.zig").Context;
const Message = @import("Message.zig");

const opt = @import("socket/option.zig");
const SetOption = opt.SetOption;
const SetOptionType = opt.SetOptionType;
const GetOption = opt.GetOption;
const GetOptionType = opt.GetOptionType;
const Mechanism = opt.Mechanism;
const ReconnectStop = opt.ReconnectStop;
const RouterNotify = opt.RouterNotify;
const NormMode = opt.NormMode;
const PrincipalNameType = opt.PrincipalNameType;

pub const Type = @import("socket/type.zig").Type;

const poll = @import("poll.zig");

const errno = @import("errno.zig").errno;

pub const Socket = opaque {
    const Self = @This();

    pub const InitError = error{
        TooManyOpenFiles,
        InvalidContext,
        Unexpected,
    };
    pub fn init(context: *Context, socket_type: Type) InitError!*Self {
        if (zmq.zmq_socket(context, @intFromEnum(socket_type))) |handle| {
            return @ptrCast(handle);
        } else {
            return switch (errno()) {
                zmq.EMFILE => InitError.TooManyOpenFiles,
                zmq.EFAULT, zmq.ETERM => InitError.InvalidContext,
                else => InitError.Unexpected,
            };
        }
    }
    pub fn deinit(self: *Self) void {
        _ = zmq.zmq_close(self);
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
    pub fn connect(self: *Self, endpoint: [:0]const u8) ConnectError!void {
        if (zmq.zmq_connect(self, endpoint.ptr) != -1) {
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
    pub fn disconnect(self: *Self, endpoint: [:0]const u8) DisconnectError!void {
        if (zmq.zmq_disconnect(self, endpoint.ptr) != -1) {
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
    pub fn bind(self: *Self, endpoint: [:0]const u8) BindError!void {
        if (zmq.zmq_bind(self, endpoint.ptr) != -1) {
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
    pub fn unbind(self: *Self, endpoint: [:0]const u8) UnbindError!void {
        if (zmq.zmq_unbind(self, endpoint.ptr) != -1) {
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

    pub const SendFlags = packed struct(c_int) {
        dont_wait: bool = false,
        send_more: bool = false,
        _padding: u30 = 0,

        pub const noblock: SendFlags = .{ .dont_wait = true };
        pub const more: SendFlags = .{ .send_more = true };
        pub const morenoblock: SendFlags = .{ .dont_wait = true, .send_more = true };
    };
    pub const SendError = error{
        WouldBlock,
        SendNotSupported,
        MultipartNotSupported,
        InappropriateStateActionFailed,
        ContextInvalid,
        SocketInvalid,
        Interrupted,
        MessageInvalid,
        CannotRoute,
        Unexpected,
    };

    fn sendError(err: c_int) SendError {
        return switch (err) {
            zmq.EAGAIN => SendError.WouldBlock,
            zmq.ENOTSUP => SendError.SendNotSupported,
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
    pub fn sendMsg(self: *Self, message: *Message, flags: SendFlags) SendError!void {
        const result = zmq.zmq_msg_send(&message.message, self, @bitCast(flags));
        if (result == -1) {
            return sendError(errno());
        }
    }
    pub fn sendBuffer(self: *Self, ptr: *const anyopaque, len: usize, flags: SendFlags) SendError!void {
        const result = zmq.zmq_send(self, ptr, len, @bitCast(flags));
        if (result == -1) {
            return sendError(errno());
        }
    }
    pub fn sendConst(self: *Self, ptr: *const anyopaque, len: usize, flags: SendFlags) SendError!void {
        const result = zmq.zmq_send_const(self, ptr, len, @bitCast(flags));
        if (result == -1) {
            return sendError(errno());
        }
    }

    pub const RecvFlags = packed struct(c_int) {
        dont_wait: bool = false,
        _padding: u31 = 0,

        pub const noblock: RecvFlags = .{ .dont_wait = true };
    };
    pub const RecvError = error{
        WouldBlock,
        RecvNotSupported,
        InappropriateStateActionFailed,
        ContextInvalid,
        SocketInvalid,
        Interrupted,
        Unexpected,
    };
    fn recvError(err: c_int) RecvError {
        return switch (err) {
            zmq.EAGAIN => RecvError.WouldBlock,
            zmq.ENOTSUP => RecvError.RecvNotSupported,
            zmq.EFSM => RecvError.InappropriateStateActionFailed,
            zmq.ETERM => RecvError.ContextInvalid,
            zmq.ENOTSOCK => RecvError.SocketInvalid,
            zmq.EINTR => RecvError.Interrupted,
            else => RecvError.Unexpected,
        };
    }
    pub fn recv(self: *Self, buffer: []u8, flags: RecvFlags) RecvError!usize {
        return switch (zmq.zmq_recv(self, buffer.ptr, buffer.len, @bitCast(flags))) {
            -1 => recvError(errno()),
            else => |size| @intCast(size),
        };
    }

    pub const RecvMsgError = RecvError || error{MessageInvalid};
    pub fn recvMsg(self: *Self, msg: *Message, flags: RecvFlags) RecvMsgError!usize {
        return result: switch (zmq.zmq_recvmsg(self, &msg.message, @bitCast(flags))) {
            -1 => {
                const err = errno();
                break :result switch (err) {
                    zmq.EFAULT => RecvMsgError.MessageInvalid,
                    else => recvError(err),
                };
            },
            else => |size| @intCast(size),
        };
    }

    pub const SetError = error{
        OptionInvalid,
        ContextInvalid,
        SocketInvalid,
        Interrupted,
        Unexpected,
    };
    pub fn set(self: *Self, comptime option: SetOption, value: SetOptionType(option)) SetError!void {
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
            self,
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
    pub fn get(self: *Self, comptime option: GetOption, out: *GetOptionType(option)) SetError!void {
        const Out = @TypeOf(out.*);
        const result = result: switch (@typeInfo(Out)) {
            .bool => {
                var value: c_int = undefined;
                var size: usize = @sizeOf(@TypeOf(value));

                const result = zmq.zmq_getsockopt(self, @intFromEnum(option), &value, &size);

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
                break :result zmq.zmq_getsockopt(self, @intFromEnum(option), out, &size);
            },
            .@"enum" => {
                var size: usize = @sizeOf(Out);
                break :result zmq.zmq_getsockopt(self, @intFromEnum(option), out, &size);
            },
            .int => {
                var size: usize = @sizeOf(Out);
                break :result zmq.zmq_getsockopt(self, @intFromEnum(option), out, &size);
            },
            .pointer => |Pointer| {
                if (Pointer.size != .slice) {
                    @compileError("Unrecognized type: " ++ @typeName(Out));
                }
                break :result zmq.zmq_getsockopt(
                    self,
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

    pub fn pollItem(self: *Self, events: poll.Events) poll.Item {
        return .{
            .socket = self,
            .events = @bitCast(events),
        };
    }
};
