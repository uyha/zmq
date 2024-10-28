comptime {
    const testing = @import("std").testing;

    testing.refAllDecls(@import("context.zig"));
}

test "Version" {
    // const testing = @import("std").testing;
}
