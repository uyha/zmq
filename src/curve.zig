const zmq = @import("libzmq");

pub const Error = error{
    // TODO: Replace this with conditional compilation
    NotSupported,
};
pub const KeyPair = struct {
    public_key: [40:0]u8 = .{0} ** 40,
    secret: [40:0]u8 = .{0} ** 40,
};
pub fn keypair() Error!KeyPair {
    var result: KeyPair = undefined;

    return switch (zmq.zmq_curve_keypair(
        &result.public_key,
        &result.secret,
    )) {
        // TODO: Replace this with conditional compilation
        -1 => Error.NotSupported,
        else => result,
    };
}

pub fn publicKey(secret: *const [40:0]u8) Error![40:0]u8 {
    var result: [40:0]u8 = undefined;
    result[40] = 0;

    return switch (zmq.zmq_curve_public(
        &result,
        secret,
    )) {
        // TODO: Replace this with conditional compilation
        -1 => Error.NotSupported,
        else => result,
    };
}
test "keypair and public" {
    const t = @import("std").testing;
    const secret: [40:0]u8 = .{0} ** 40;
    try t.expectEqual(Error.NotSupported, keypair());
    try t.expectEqual(Error.NotSupported, publicKey(&secret));
}
