const zmq = @import("libzmq");

pub const AtomicCounter = opaque {
    const Self = @This();
    pub fn init() ?*Self {
        return @ptrCast(zmq.zmq_atomic_counter_new());
    }

    pub fn deinit(self: **Self) void {
        zmq.zmq_atomic_counter_destroy(@ptrCast(self));
    }

    test "init deinit" {
        var aCounter: *Self = init().?;
        defer deinit(&aCounter);
    }

    pub fn set(self: *Self, new_value: c_int) void {
        return zmq.zmq_atomic_counter_set(self, new_value);
    }
    pub fn value(self: *Self) c_int {
        return zmq.zmq_atomic_counter_value(self);
    }
    pub fn inc(self: *Self) c_int {
        return zmq.zmq_atomic_counter_inc(self);
    }

    /// Return if the counter has greater than 1 after decrement
    pub fn dec(self: *Self) bool {
        return zmq.zmq_atomic_counter_dec(self) != 0;
    }

    test "set inc dec value" {
        const t = @import("std").testing;
        var counter: *Self = init().?;
        defer deinit(&counter);

        counter.set(1);
        try t.expectEqual(1, counter.value());
        try t.expectEqual(1, counter.inc());
        try t.expect(counter.dec());
    }
};
