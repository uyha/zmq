const std = @import("std");
const testing = std.testing;
const zmq = @import("zmq");

test "ZMQ version" {
    var major: c_int = undefined;
    var minor: c_int = undefined;
    var patch: c_int = undefined;
    zmq.libzmq.zmq_version(&major, &minor, &patch);

    try testing.expect(major == 4);
    try testing.expect(minor == 3);
    try testing.expect(patch == 5);
}
