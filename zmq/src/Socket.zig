const std = @import("std");
const c = std.c;
const Context = @import("Context.zig");
const zmq = @import("libzmq");

const Message = @import("Message.zig");

const Self = @This();

pub const Type = enum(c_int) {
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
    if (result != -1) {
        return;
    }

    return sendError();
}
pub fn sendBuffer(self: Self, ptr: *const anyopaque, len: usize, flags: SendFlags) SendError!void {
    const result = zmq.zmq_send(self.handle, ptr, len, @bitCast(flags));
    if (result != -1) {
        return;
    }

    return sendError();
}
pub fn sendConst(self: Self, ptr: *const anyopaque, len: usize, flags: SendFlags) SendError!void {
    const result = zmq.zmq_send_const(self.handle, ptr, len, @bitCast(flags));
    if (result != -1) {
        return;
    }

    return sendError();
}

pub const Option = enum(c_int) {
    affinity = zmq.ZMQ_AFFINITY,
    backlog = zmq.ZMQ_BACKLOG,
    bindtodevice = zmq.ZMQ_BINDTODEVICE,
    busy_poll = zmq.ZMQ_BUSY_POLL,
    connect_routing_id = zmq.ZMQ_CONNECT_ROUTING_ID,
    conflate = zmq.ZMQ_CONFLATE,
    connect_timeout = zmq.ZMQ_CONNECT_TIMEOUT,
    curve_publickey = zmq.ZMQ_CURVE_PUBLICKEY,
    curve_secretkey = zmq.ZMQ_CURVE_SECRETKEY,
    curve_server = zmq.ZMQ_CURVE_SERVER,
    curve_serverkey = zmq.ZMQ_CURVE_SERVERKEY,
    disconnect_msg = zmq.ZMQ_DISCONNECT_MSG,
    hiccup_msg = zmq.ZMQ_HICCUP_MSG,
    gssapi_plaintext = zmq.ZMQ_GSSAPI_PLAINTEXT,
    gssapi_principal = zmq.ZMQ_GSSAPI_PRINCIPAL,
    gssapi_server = zmq.ZMQ_GSSAPI_SERVER,
    gssapi_service_principal = zmq.ZMQ_GSSAPI_SERVICE_PRINCIPAL,
    gssapi_service_principal_nametype = zmq.ZMQ_GSSAPI_SERVICE_PRINCIPAL_NAMETYPE,
    gssapi_principal_nametype = zmq.ZMQ_GSSAPI_PRINCIPAL_NAMETYPE,
    handshake_ivl = zmq.ZMQ_HANDSHAKE_IVL,
    hello_msg = zmq.ZMQ_HELLO_MSG,
    heartbeat_ivl = zmq.ZMQ_HEARTBEAT_IVL,
    heartbeat_timeout = zmq.ZMQ_HEARTBEAT_TIMEOUT,
    heartbeat_ttl = zmq.ZMQ_HEARTBEAT_TTL,
    immediate = zmq.ZMQ_IMMEDIATE,
    invert_matching = zmq.ZMQ_INVERT_MATCHING,
    ipv6 = zmq.ZMQ_IPV6,
    linger = zmq.ZMQ_LINGER,
    axmsgsize = zmq.ZMQ_MAXMSGSIZE,
    etadata = zmq.ZMQ_METADATA,
    ulticast_hops = zmq.ZMQ_MULTICAST_HOPS,
    ulticast_maxtpdu = zmq.ZMQ_MULTICAST_MAXTPDU,
    plain_password = zmq.ZMQ_PLAIN_PASSWORD,
    plain_server = zmq.ZMQ_PLAIN_SERVER,
    plain_username = zmq.ZMQ_PLAIN_USERNAME,
    use_fd = zmq.ZMQ_USE_FD,
    priority = zmq.ZMQ_PRIORITY,
    probe_router = zmq.ZMQ_PROBE_ROUTER,
    rate = zmq.ZMQ_RATE,
    rcvbuf = zmq.ZMQ_RCVBUF,
    rcvhwm = zmq.ZMQ_RCVHWM,
    rcvtimeo = zmq.ZMQ_RCVTIMEO,
    reconnect_ivl = zmq.ZMQ_RECONNECT_IVL,
    reconnect_ivl_max = zmq.ZMQ_RECONNECT_IVL_MAX,
    reconnect_stop = zmq.ZMQ_RECONNECT_STOP,
    recovery_ivl = zmq.ZMQ_RECOVERY_IVL,
    req_correlate = zmq.ZMQ_REQ_CORRELATE,
    req_relaxed = zmq.ZMQ_REQ_RELAXED,
    router_handover = zmq.ZMQ_ROUTER_HANDOVER,
    router_mandatory = zmq.ZMQ_ROUTER_MANDATORY,
    router_raw = zmq.ZMQ_ROUTER_RAW,
    routing_id = zmq.ZMQ_ROUTING_ID,
    sndbuf = zmq.ZMQ_SNDBUF,
    sndhwm = zmq.ZMQ_SNDHWM,
    sndtimeo = zmq.ZMQ_SNDTIMEO,
    socks_proxy = zmq.ZMQ_SOCKS_PROXY,
    socks_username = zmq.ZMQ_SOCKS_USERNAME,
    socks_password = zmq.ZMQ_SOCKS_PASSWORD,
    stream_notify = zmq.ZMQ_STREAM_NOTIFY,
    subscribe = zmq.ZMQ_SUBSCRIBE,
    tcp_keepalive = zmq.ZMQ_TCP_KEEPALIVE,
    tcp_keepalive_cnt = zmq.ZMQ_TCP_KEEPALIVE_CNT,
    tcp_keepalive_idle = zmq.ZMQ_TCP_KEEPALIVE_IDLE,
    tcp_keepalive_intvl = zmq.ZMQ_TCP_KEEPALIVE_INTVL,
    tcp_maxrt = zmq.ZMQ_TCP_MAXRT,
    tos = zmq.ZMQ_TOS,
    unsubscribe = zmq.ZMQ_UNSUBSCRIBE,
    xpub_verbose = zmq.ZMQ_XPUB_VERBOSE,
    xpub_verboser = zmq.ZMQ_XPUB_VERBOSER,
    xpub_manual = zmq.ZMQ_XPUB_MANUAL,
    xpub_manual_last_value = zmq.ZMQ_XPUB_MANUAL_LAST_VALUE,
    xpub_nodrop = zmq.ZMQ_XPUB_NODROP,
    xpub_welcome_msg = zmq.ZMQ_XPUB_WELCOME_MSG,
    xsub_verbose_unsubscribe = zmq.ZMQ_XSUB_VERBOSE_UNSUBSCRIBE,
    only_first_subscribe = zmq.ZMQ_ONLY_FIRST_SUBSCRIBE,
    ap_domain = zmq.ZMQ_ZAP_DOMAIN,
    ap_enforce_domain = zmq.ZMQ_ZAP_ENFORCE_DOMAIN,
    tcp_accept_filter = zmq.ZMQ_TCP_ACCEPT_FILTER,
    ipv4only = zmq.ZMQ_IPV4ONLY,
    vmci_buffer_size = zmq.ZMQ_VMCI_BUFFER_SIZE,
    vmci_buffer_min_size = zmq.ZMQ_VMCI_BUFFER_MIN_SIZE,
    vmci_buffer_max_size = zmq.ZMQ_VMCI_BUFFER_MAX_SIZE,
    vmci_connect_timeout = zmq.ZMQ_VMCI_CONNECT_TIMEOUT,
    ulticast_loop = zmq.ZMQ_MULTICAST_LOOP,
    router_notify = zmq.ZMQ_ROUTER_NOTIFY,
    in_batch_size = zmq.ZMQ_IN_BATCH_SIZE,
    out_batch_size = zmq.ZMQ_OUT_BATCH_SIZE,
    norm_mode = zmq.ZMQ_NORM_MODE,
    norm_unicast_nack = zmq.ZMQ_NORM_UNICAST_NACK,
    norm_buffer_size = zmq.ZMQ_NORM_BUFFER_SIZE,
    norm_segment_size = zmq.ZMQ_NORM_SEGMENT_SIZE,
    norm_block_size = zmq.ZMQ_NORM_BLOCK_SIZE,
    norm_num_parity = zmq.ZMQ_NORM_NUM_PARITY,
    norm_num_autoparity = zmq.ZMQ_NORM_NUM_AUTOPARITY,
    norm_push = zmq.ZMQ_NORM_PUSH,
};
pub fn OptionType(option: Option) type {
    return switch (option) {
        .affinity => u64,
        .backlog => c_int, // connections
        .bindtodevice => [:0]const u8,
        .busy_poll => bool,
        .connect_routing_id => []const u8,
        .conflate => bool,
        .connect_timeout => c_int, // milliseconds
        .curve_publickey => []const u8, // 32 or 41 characters
        .curve_secretkey => []const u8, // 32 or 41 characters
        .curve_server => bool,
        .curve_serverkey => []const u8, // 32 or 41 characters
        .disconnect_msg => []const u8,
        .hiccup_msg => []const u8,
        .gssapi_plaintext => bool,
        .gssapi_principal => [:0]const u8,
        .gssapi_server => bool,
        .gssapi_service_principal => [:0]const u8,
        .gssapi_service_principal_nametype => c_int, // 0, 1, 2
        .gssapi_principal_nametype => c_int, // 0, 1, 2
        .handshake_ivl => c_int, // milliseconds
        .hello_msg => []const u8,
        .heartbeat_ivl => c_int, // milliseconds
        .heartbeat_timeout => c_int, // milliseconds
        .heartbeat_ttl => c_int, // milliseconds
        .immediate => bool,
        .invert_matching => bool,
        .ipv6 => bool,
        .linger => c_int, // milliseconds
        .axmsgsize => i64, // bytes
        .etadata => [:0]const u8,
        .ulticast_hops => c_int, // network hops
        .ulticast_maxtpdu => c_int, // bytes
        .plain_password => [:0]const u8,
        .plain_server => bool,
        .plain_username => [:0]const u8,
        .use_fd => c_int, // file descriptor
        .priority => c_int, // >0
        .probe_router => bool,
        .rate => c_int, // kilobits per second
        .rcvbuf => c_int, // bytes
        .rcvhwm => c_int, // messages
        .rcvtimeo => c_int, // milliseconds
        .reconnect_ivl => c_int, // milliseconds
        .reconnect_ivl_max => c_int, // milliseconds
        .reconnect_stop => packed struct(c_int) {
            conn_refused: bool = false,
            handshake_failed: bool = false,
            after_disconnect: bool = false,
            _padding: u29 = 0,
        },
        .recovery_ivl => c_int, // milliseconds
        .req_correlate => bool,
        .req_relaxed => bool,
        .router_handover => bool,
        .router_mandatory => bool,
        .router_raw => bool,
        .routing_id => []const u8,
        .sndbuf => c_int, // bytes
        .sndhwm => c_int, // messages
        .sndtimeo => c_int, // milliseconds
        .socks_proxy => [:0]const u8,
        .socks_username => [:0]const u8,
        .socks_password => [:0]const u8,
        .stream_notify => bool,
        .subscribe => []const u8,
        .tcp_keepalive => c_int, // -1,0,1
        .tcp_keepalive_cnt => c_int, // -1,>0
        .tcp_keepalive_idle => c_int, // -1,>0
        .tcp_keepalive_intvl => c_int, // -1,>0
        .tcp_maxrt => c_int, // milliseconds
        .tos => c_int, // >0
        .unsubscribe => []const u8,
        .xpub_verbose => bool,
        .xpub_verboser => bool,
        .xpub_manual => bool,
        .xpub_manual_last_value => bool,
        .xpub_nodrop => bool,
        .xpub_welcome_msg => []const u8,
        .xsub_verbose_unsubscribe => bool,
        .only_first_subscribe => bool,
        .ap_domain => [:0]const u8,
        .ap_enforce_domain => bool,
        .tcp_accept_filter => []const u8,
        .ipv4only => bool,
        .vmci_buffer_size => u64, // bytes
        .vmci_buffer_min_size => u64, // bytes
        .vmci_buffer_max_size => u64, // bytes
        .vmci_connect_timeout => c_int, // milliseconds
        .ulticast_loop => bool,
        .router_notify => packed struct(c_int) {
            connect: bool = false,
            disconnect: bool = false,
            _padding: u29 = 0,
        },
        .in_batch_size => c_int, // messages
        .out_batch_size => c_int, // messages
        .norm_mode => enum(c_int) {
            fixed = zmq.ZMQ_NORM_FIXED,
            cc = zmq.ZMQ_NORM_CC,
            ccl = zmq.ZMQ_NORM_CCL,
            cce = zmq.ZMQ_NORM_CCE,
        },
        .norm_unicast_nack => bool,
        .norm_buffer_size => c_int, // kilobytes
        .norm_segment_size => c_int, // bytes
        .norm_block_size => c_int, // >0, <=255
        .norm_num_parity => c_int, // >0, <255
        .norm_num_autoparity => c_int, // >=0, <255
        .norm_push => bool,
    };
}

pub const SetOptionError = error{
    OptionInvalid,
    ContextInvalid,
    SocketInvalid,
    Interrupted,
    Unexpected,
};
pub fn set(socket: Self, comptime option: Option, value: OptionType(option)) SetOptionError!void {
    const raw_value = raw_value: switch (OptionType(option)) {
        bool => @as(c_int, @intFromBool(value)),
        else => |Opt| {
            break :raw_value switch (@typeInfo(Opt)) {
                .@"struct" => |Struct| {
                    if (Struct.layout == .@"packed") {
                        break :raw_value @as(Struct.backing_integer.?, @bitCast(value));
                    } else {
                        @compileError("Unrecognized type: " ++ @typeName(Opt));
                    }
                },
                .@"enum" => @intFromEnum(value),
                else => @compileError("Unrecognized type: " ++ @typeName(Opt)),
            };
        },
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
        zmq.EINVAL => SetOptionError.OptionInvalid,
        zmq.ETERM => SetOptionError.ContextInvalid,
        zmq.ENOTSOCK => SetOptionError.SocketInvalid,
        zmq.EINTR => SetOptionError.Interrupted,
        else => SetOptionError.Unexpected,
    };
}

pub fn deinit(socket: Self) void {
    _ = zmq.zmq_close(socket.handle);
}
