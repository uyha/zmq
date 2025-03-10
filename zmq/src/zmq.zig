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

pub const Context = @import("Context.zig");
pub const Message = @import("Message.zig");
pub const Socket = @import("Socket.zig");
pub const errno = @import("errno.zig").errno;
