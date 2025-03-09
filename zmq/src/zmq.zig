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
        InvalidEndpoint,
        InvalidContext,
        InvalidSocket,
        TransportNotSupported,
        TransportNotCompatible,
        NoThreadAvaiable,
        Unexpected,
    };
    pub fn connect(socket: Socket, endpoint: []const u8) ConnectError!void {
        if (zmq.zmq_connect(socket.handle, endpoint.ptr) == -1) {
            return switch (c._errno().*) {
                zmq.EINVAL => ConnectError.InvalidEndpoint,
                zmq.ETERM => ConnectError.InvalidContext,
                zmq.ENOTSOCK => ConnectError.InvalidSocket,
                zmq.EPROTONOSUPPORT => ConnectError.TransportNotSupported,
                zmq.ENOCOMPATPROTO => ConnectError.TransportNotCompatible,
                zmq.EMTHREAD => ConnectError.NoThreadAvaiable,
                else => ConnectError.Unexpected,
            };
        }
    }

    pub fn deinit(socket: Socket) void {
        _ = zmq.zmq_close(socket.handle);
    }
};
