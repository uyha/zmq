// Auto generated, change by updating tools/gen-ctxopt.py instead
const zmq = @import("libzmq");
const posix = @import("std").posix;
pub const Type = @import("type.zig").Type;

pub const Mechanism = enum(c_int) {
    null = zmq.ZMQ_NULL,
    plain = zmq.ZMQ_PLAIN,
    curve = zmq.ZMQ_CURVE,
    gssapi = zmq.ZMQ_GSSAPI,
};
pub const ReconnectStop = packed struct(c_int) {
    conn_refused: bool = false,
    handshake_failed: bool = false,
    after_disconnect: bool = false,
    _padding: u29 = 0,
};
pub const RouterNotify = packed struct(c_int) {
    connect: bool = false,
    disconnect: bool = false,
    _padding: u30 = 0,
};
pub const NormMode = enum(c_int) {
    fixed = zmq.ZMQ_NORM_FIXED,
    cc = zmq.ZMQ_NORM_CC,
    ccl = zmq.ZMQ_NORM_CCL,
    cce = zmq.ZMQ_NORM_CCE,
    ecnonly = zmq.ZMQ_NORM_CCE_ECNONLY,
};
pub const PrincipalNameType = enum(c_int) {
    hostbased = zmq.ZMQ_GSSAPI_NT_HOSTBASED,
    user_name = zmq.ZMQ_GSSAPI_NT_USER_NAME,
    unparsed = zmq.ZMQ_GSSAPI_NT_KRB5_PRINCIPAL,
};

pub const SetOption = enum(c_int) {
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
    maxmsgsize = zmq.ZMQ_MAXMSGSIZE,
    metadata = zmq.ZMQ_METADATA,
    multicast_hops = zmq.ZMQ_MULTICAST_HOPS,
    multicast_maxtpdu = zmq.ZMQ_MULTICAST_MAXTPDU,
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
    zap_domain = zmq.ZMQ_ZAP_DOMAIN,
    zap_enforce_domain = zmq.ZMQ_ZAP_ENFORCE_DOMAIN,
    vmci_buffer_size = zmq.ZMQ_VMCI_BUFFER_SIZE,
    vmci_buffer_min_size = zmq.ZMQ_VMCI_BUFFER_MIN_SIZE,
    vmci_buffer_max_size = zmq.ZMQ_VMCI_BUFFER_MAX_SIZE,
    vmci_connect_timeout = zmq.ZMQ_VMCI_CONNECT_TIMEOUT,
    multicast_loop = zmq.ZMQ_MULTICAST_LOOP,
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
pub fn SetOptionType(option: SetOption) type {
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
        .gssapi_service_principal_nametype => PrincipalNameType,
        .gssapi_principal_nametype => PrincipalNameType,
        .handshake_ivl => c_int, // milliseconds
        .hello_msg => []const u8,
        .heartbeat_ivl => c_int, // milliseconds
        .heartbeat_timeout => c_int, // milliseconds
        .heartbeat_ttl => c_int, // milliseconds
        .immediate => bool,
        .invert_matching => bool,
        .ipv6 => bool,
        .linger => c_int, // milliseconds
        .maxmsgsize => i64, // bytes
        .metadata => [:0]const u8,
        .multicast_hops => c_int, // network hops
        .multicast_maxtpdu => c_int, // bytes
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
        .reconnect_stop => ReconnectStop,
        .recovery_ivl => c_int, // milliseconds
        .req_correlate => bool,
        .req_relaxed => bool,
        .router_handover => bool,
        .router_mandatory => bool,
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
        .zap_domain => [:0]const u8,
        .zap_enforce_domain => bool,
        .vmci_buffer_size => u64, // bytes
        .vmci_buffer_min_size => u64, // bytes
        .vmci_buffer_max_size => u64, // bytes
        .vmci_connect_timeout => c_int, // milliseconds
        .multicast_loop => bool,
        .router_notify => RouterNotify,
        .in_batch_size => c_int, // messages
        .out_batch_size => c_int, // messages
        .norm_mode => NormMode,
        .norm_unicast_nack => bool,
        .norm_buffer_size => c_int, // kilobytes
        .norm_segment_size => c_int, // bytes
        .norm_block_size => c_int, // >0, <=255
        .norm_num_parity => c_int, // >0, <255
        .norm_num_autoparity => c_int, // >=0, <255
        .norm_push => bool,
    };
}

pub const GetOption = enum(c_int) {
    affinity = zmq.ZMQ_AFFINITY,
    backlog = zmq.ZMQ_BACKLOG,
    bindtodevice = zmq.ZMQ_BINDTODEVICE,
    connect_timeout = zmq.ZMQ_CONNECT_TIMEOUT,
    curve_publickey = zmq.ZMQ_CURVE_PUBLICKEY,
    curve_secretkey = zmq.ZMQ_CURVE_SECRETKEY,
    curve_serverkey = zmq.ZMQ_CURVE_SERVERKEY,
    events = zmq.ZMQ_EVENTS,
    fd = zmq.ZMQ_FD,
    gssapi_plaintext = zmq.ZMQ_GSSAPI_PLAINTEXT,
    gssapi_principal = zmq.ZMQ_GSSAPI_PRINCIPAL,
    gssapi_server = zmq.ZMQ_GSSAPI_SERVER,
    gssapi_service_principal = zmq.ZMQ_GSSAPI_SERVICE_PRINCIPAL,
    gssapi_service_principal_nametype = zmq.ZMQ_GSSAPI_SERVICE_PRINCIPAL_NAMETYPE,
    gssapi_principal_nametype = zmq.ZMQ_GSSAPI_PRINCIPAL_NAMETYPE,
    handshake_ivl = zmq.ZMQ_HANDSHAKE_IVL,
    immediate = zmq.ZMQ_IMMEDIATE,
    invert_matching = zmq.ZMQ_INVERT_MATCHING,
    ipv6 = zmq.ZMQ_IPV6,
    last_endpoint = zmq.ZMQ_LAST_ENDPOINT,
    linger = zmq.ZMQ_LINGER,
    maxmsgsize = zmq.ZMQ_MAXMSGSIZE,
    mechanism = zmq.ZMQ_MECHANISM,
    multicast_hops = zmq.ZMQ_MULTICAST_HOPS,
    multicast_maxtpdu = zmq.ZMQ_MULTICAST_MAXTPDU,
    plain_password = zmq.ZMQ_PLAIN_PASSWORD,
    plain_server = zmq.ZMQ_PLAIN_SERVER,
    plain_username = zmq.ZMQ_PLAIN_USERNAME,
    use_fd = zmq.ZMQ_USE_FD,
    priority = zmq.ZMQ_PRIORITY,
    rate = zmq.ZMQ_RATE,
    rcvbuf = zmq.ZMQ_RCVBUF,
    rcvhwm = zmq.ZMQ_RCVHWM,
    rcvmore = zmq.ZMQ_RCVMORE,
    rcvtimeo = zmq.ZMQ_RCVTIMEO,
    reconnect_ivl = zmq.ZMQ_RECONNECT_IVL,
    reconnect_ivl_max = zmq.ZMQ_RECONNECT_IVL_MAX,
    reconnect_stop = zmq.ZMQ_RECONNECT_STOP,
    recovery_ivl = zmq.ZMQ_RECOVERY_IVL,
    routing_id = zmq.ZMQ_ROUTING_ID,
    sndbuf = zmq.ZMQ_SNDBUF,
    sndhwm = zmq.ZMQ_SNDHWM,
    sndtimeo = zmq.ZMQ_SNDTIMEO,
    socks_proxy = zmq.ZMQ_SOCKS_PROXY,
    tcp_keepalive = zmq.ZMQ_TCP_KEEPALIVE,
    tcp_keepalive_cnt = zmq.ZMQ_TCP_KEEPALIVE_CNT,
    tcp_keepalive_idle = zmq.ZMQ_TCP_KEEPALIVE_IDLE,
    tcp_keepalive_intvl = zmq.ZMQ_TCP_KEEPALIVE_INTVL,
    tcp_maxrt = zmq.ZMQ_TCP_MAXRT,
    thread_safe = zmq.ZMQ_THREAD_SAFE,
    tos = zmq.ZMQ_TOS,
    type = zmq.ZMQ_TYPE,
    zap_domain = zmq.ZMQ_ZAP_DOMAIN,
    zap_enforce_domain = zmq.ZMQ_ZAP_ENFORCE_DOMAIN,
    vmci_buffer_size = zmq.ZMQ_VMCI_BUFFER_SIZE,
    vmci_buffer_min_size = zmq.ZMQ_VMCI_BUFFER_MIN_SIZE,
    vmci_buffer_max_size = zmq.ZMQ_VMCI_BUFFER_MAX_SIZE,
    vmci_connect_timeout = zmq.ZMQ_VMCI_CONNECT_TIMEOUT,
    multicast_loop = zmq.ZMQ_MULTICAST_LOOP,
    router_notify = zmq.ZMQ_ROUTER_NOTIFY,
    in_batch_size = zmq.ZMQ_IN_BATCH_SIZE,
    out_batch_size = zmq.ZMQ_OUT_BATCH_SIZE,
    topics_count = zmq.ZMQ_TOPICS_COUNT,
    norm_mode = zmq.ZMQ_NORM_MODE,
    norm_unicast_nack = zmq.ZMQ_NORM_UNICAST_NACK,
    norm_buffer_size = zmq.ZMQ_NORM_BUFFER_SIZE,
    norm_segment_size = zmq.ZMQ_NORM_SEGMENT_SIZE,
    norm_block_size = zmq.ZMQ_NORM_BLOCK_SIZE,
    norm_num_parity = zmq.ZMQ_NORM_NUM_PARITY,
    norm_num_autoparity = zmq.ZMQ_NORM_NUM_AUTOPARITY,
    norm_push = zmq.ZMQ_NORM_PUSH,
};
pub fn GetOptionType(option: GetOption) type {
    return switch (option) {
        .affinity => u64,
        .backlog => c_int, // connections
        .bindtodevice => [:0]u8,
        .connect_timeout => c_int, // milliseconds
        .curve_publickey => []u8, // 32 or 41 characters
        .curve_secretkey => []u8, // 32 or 41 characters
        .curve_serverkey => []u8, // 32 or 41 characters
        .events => c_int, // (flags)
        .fd => posix.socket_t,
        .gssapi_plaintext => bool,
        .gssapi_principal => [:0]u8,
        .gssapi_server => bool,
        .gssapi_service_principal => [:0]u8,
        .gssapi_service_principal_nametype => PrincipalNameType,
        .gssapi_principal_nametype => PrincipalNameType,
        .handshake_ivl => c_int, // milliseconds
        .immediate => bool,
        .invert_matching => bool,
        .ipv6 => bool,
        .last_endpoint => [:0]u8,
        .linger => c_int, // milliseconds
        .maxmsgsize => i64, // bytes
        .mechanism => Mechanism,
        .multicast_hops => c_int, // network hops
        .multicast_maxtpdu => c_int, // bytes
        .plain_password => [:0]u8,
        .plain_server => bool,
        .plain_username => [:0]u8,
        .use_fd => posix.socket_t,
        .priority => c_int, // >0
        .rate => c_int, // kilobits per second
        .rcvbuf => c_int, // bytes
        .rcvhwm => c_int, // messages
        .rcvmore => bool,
        .rcvtimeo => c_int, // milliseconds
        .reconnect_ivl => c_int, // milliseconds
        .reconnect_ivl_max => c_int, // milliseconds
        .reconnect_stop => ReconnectStop,
        .recovery_ivl => c_int, // milliseconds
        .routing_id => []u8, // >1, <=255 bytes
        .sndbuf => c_int, // bytes
        .sndhwm => c_int, // messages
        .sndtimeo => c_int, // milliseconds
        .socks_proxy => [:0]u8,
        .tcp_keepalive => c_int, // -1,0,1
        .tcp_keepalive_cnt => c_int, // -1,>0
        .tcp_keepalive_idle => c_int, // -1,>0
        .tcp_keepalive_intvl => c_int, // -1,>0
        .tcp_maxrt => c_int, // milliseconds
        .thread_safe => bool,
        .tos => c_int, // >0
        .type => Type,
        .zap_domain => [:0]u8,
        .zap_enforce_domain => bool,
        .vmci_buffer_size => u64, // bytes
        .vmci_buffer_min_size => u64, // bytes
        .vmci_buffer_max_size => u64, // bytes
        .vmci_connect_timeout => c_int, // milliseconds
        .multicast_loop => bool,
        .router_notify => RouterNotify,
        .in_batch_size => c_int, // messages
        .out_batch_size => c_int, // messages
        .topics_count => c_int,
        .norm_mode => NormMode,
        .norm_unicast_nack => bool,
        .norm_buffer_size => c_int, // kilobytes
        .norm_segment_size => c_int, // bytes
        .norm_block_size => c_int, // >0, <=255
        .norm_num_parity => c_int, // >0, <255
        .norm_num_autoparity => c_int, // >=0, <255
        .norm_push => bool,
    };
}
