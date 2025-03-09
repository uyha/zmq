const zmq = @import("libzmq");
const std = @import("std");
const c = @import("std").c;

pub const Version = struct {
    major: c_int,
    minor: c_int,
    patch: c_int,
};
pub fn version() Version {
    var result: Version = undefined;

    zmq.zmq_version(
        &result.major,
        &result.minor,
        &result.patch,
    );

    return result;
}

pub const Context = struct {
    handle: *anyopaque,

    pub const InitError = error{ TooManyOpenFiles, Unexpected };
    pub inline fn init() InitError!Context {
        const handle = zmq.zmq_ctx_new();
        if (handle == null) {
            return switch (c._errno().*) {
                zmq.EMFILE => InitError.TooManyOpenFiles,
                else => InitError.Unexpected,
            };
        }

        return .{ .handle = handle.? };
    }

    pub fn deinit(self: Context) void {
        _ = zmq.zmq_ctx_term(self.handle);
    }
};

pub const Message = struct {
    message: zmq.struct_zmq_msg_t,

    pub const InitError = error{
        OutOfMemory,
        Unexpected,
    };
    pub fn empty() Message {
        var result = Message{ .message = undefined };

        _ = zmq.zmq_msg_init(&result.message);

        return result;
    }

    pub fn withSize(size: usize) InitError!Message {
        var result = Message{ .message = undefined };

        if (zmq.zmq_msg_init_size(&result.message, size) == -1) {
            return switch (c._errno().*) {
                zmq.ENOMEM => InitError.OutOfMemory,
                else => InitError.Unexpected,
            };
        }

        return result;
    }

    pub fn deinit(self: *Message) void {
        _ = zmq.zmq_msg_close(&self.message);
    }

    pub fn data(self: *Message, Data: type) *Data {
        return @ptrCast(zmq.zmq_msg_data(&self.message));
    }
};

pub const SocketType = enum(c_int) {
    req = zmq.ZMQ_REQ,
    rep = zmq.ZMQ_REP,
    dealer = zmq.ZMQ_DEALER,
    router = zmq.ZMQ_ROUTER,
    @"pub" = zmq.ZMQ_PUB,
    sub = zmq.ZMQ_SUB,
    xpub = zmq.ZMQ_XPUB,
    xsub = zmq.ZMQ_XSUB,
    push = zmq.ZMQ_PUSH,
    pull = zmq.ZMQ_PULL,
    pair = zmq.ZMQ_PAIR,
};

pub const Socket = struct {
    handle: *anyopaque,

    pub const InitError = error{
        TooManyOpenFiles,
        InvalidContext,
        Unexpected,
    };
    pub fn init(context: Context, socket_type: SocketType) InitError!Socket {
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
    pub fn connect(socket: Socket, endpoint: [:0]const u8) ConnectError!void {
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
    pub fn bind(socket: Socket, endpoint: [:0]const u8) BindError!void {
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
    pub fn send_msg(self: Socket, message: *Message, send_flags: SendFlags) SendError!void {
        const result = zmq.zmq_msg_send(&message.message, self.handle, @bitCast(send_flags));
        std.debug.print("{}\n", .{result});
        if (result != -1) {
            return;
        }

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

    pub const Option = enum(c_int) {
        affinity = zmq.ZMQ_AFFINITY,
        backlog = zmq.ZMQ_BACKLOG,
        immediate = zmq.ZMQ_IMMEDIATE,
        bind_to_device = zmq.ZMQ_BINDTODEVICE,
    };
    fn OptionType(option: Option) type {
        return switch (option) {
            .affinity => u64,
            .backlog => c_int,
            .immediate => bool,
            .bind_to_device => []const u8,
        };
    }

    pub const SetOptionError = error{
        ContextInvalid,
        SocketInvalid,
        Interrupted,
        Unexpected,
    };
    pub fn setOption(socket: Socket, comptime option: Option, value: OptionType(option)) SetOptionError!void {
        const raw_value = switch (option) {
            .immediate => @as(c_int, @intFromBool(value)),
            else => value,
        };
        const RawValueType = @TypeOf(raw_value);

        const ptr = if (RawValueType == []const u8) raw_value.ptr else &raw_value;
        const size = if (RawValueType == []const u8) raw_value.len else @sizeOf(RawValueType);

        if (zmq.zmq_setsockopt(socket.handle, @intFromEnum(option), ptr, size) == 0) {
            return;
        }

        return switch (c._errno().*) {
            zmq.ETERM => SetOptionError.ContextInvalid,
            zmq.ENOTSOCK => SetOptionError.SocketInvalid,
            zmq.EINTR => SetOptionError.Interrupted,
            else => SetOptionError.Unexpected,
        };
    }

    pub fn deinit(socket: Socket) void {
        _ = zmq.zmq_close(socket.handle);
    }
};
