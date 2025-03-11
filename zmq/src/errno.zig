const std = @import("std");
const zmq = @import("libzmq");

pub fn errno() c_int {
    return zmq.zmq_errno();
}

pub fn strerror(err: c_int) [:0]const u8 {
    var result: [:0]const u8 = undefined;
    result.ptr = zmq.zmq_strerror(err);
    result.len = 0;
    while (result[result.len] != 0) {
        result.len += 1;
    }

    return result;
}

test "strerror" {
    _ = strerror(1);
}
