pub const Events = packed struct(c_short) {
    pollin: bool = false,
    pollout: bool = false,
    pollerr: bool = false,
    pollpri: bool = false,
    _padding: u12 = 0,

    pub const in: Events = .{ .pollin = true };
    pub const out: Events = .{ .pollout = true };
    pub const inout: Events = .{ .pollin = true, .pollout = true };
};
