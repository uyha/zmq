const zmq = @import("libzmq");
const std = @import("std");
const c = @import("std").c;

const Self = @This();

handle: *anyopaque,

pub const InitError = error{ TooManyOpenFiles, Unexpected };
pub inline fn init() InitError!Self {
    const handle = zmq.zmq_ctx_new();
    if (handle == null) {
        return switch (c._errno().*) {
            zmq.EMFILE => InitError.TooManyOpenFiles,
            else => InitError.Unexpected,
        };
    }

    return .{ .handle = handle.? };
}

pub fn deinit(self: Self) void {
    _ = zmq.zmq_ctx_term(self.handle);
}

pub const Option = enum(c_int) {
    blocky = zmq.ZMQ_BLOCKY,
    io_threads = zmq.ZMQ_IO_THREADS,
    thread_sched_policy = zmq.ZMQ_THREAD_SCHED_POLICY,
    thread_priority = zmq.ZMQ_THREAD_PRIORITY,
    thread_affinity_cpu_add = zmq.ZMQ_THREAD_AFFINITY_CPU_ADD,
    thread_affinity_cpu_remove = zmq.ZMQ_THREAD_AFFINITY_CPU_REMOVE,
    thread_name_prefix = zmq.ZMQ_THREAD_NAME_PREFIX,
    ax_msgsz = zmq.ZMQ_MAX_MSGSZ,
    ero_copy_recv = zmq.ZMQ_ZERO_COPY_RECV,
    ax_sockets = zmq.ZMQ_MAX_SOCKETS,
    ipv6 = zmq.ZMQ_IPV6,
};

pub fn OptionType(option: Option) type {
    return switch (option) {
        .blocky, .zero_copy_recv, .ipv6 => bool,
        else => c_int,
    };
}

pub const SetError = error{ OptionInvalid, Unexpected };
pub fn set(self: Self, comptime option: Option, value: OptionType(option)) SetError!void {
    const Value = @TypeOf(value);
    const raw_value: c_int = switch (Value) {
        bool => @intFromBool(value),
        c_int => value,
        else => @compileError("Unrecognized type: " ++ @typeName(Value)),
    };
    if (zmq.zmq_ctx_set(self.handle, option, raw_value) == -1) {
        return switch (c._errno().*) {
            zmq.EINVAL => SetError.OptionInvalid,
            else => SetError.Unexpected,
        };
    }
}
