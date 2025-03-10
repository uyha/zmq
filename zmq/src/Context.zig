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
