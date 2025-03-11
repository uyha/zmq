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

pub const Capability = enum { ipc, pgm, tipc, norm, curve, gssapi, draft };
pub fn has(capability: Capability) bool {
    return zmq.zmq_has(std.enums.tagName(Capability, capability).?.ptr) != 0;
}

pub const Context = @import("Context.zig");
pub const Message = @import("Message.zig");
pub const Socket = @import("Socket.zig");
pub const errno = @import("errno.zig").errno;

pub const poll = @import("poll.zig");
