const zmq = @import("libzmq");
const std = @import("std");
const c = @import("std").c;

const opt = @import("context/option.zig");
const SetOption = opt.SetOption;
const SetOptionType = opt.SetOptionType;
const GetOption = opt.GetOption;
const GetOptionType = opt.GetOptionType;

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

pub const SetError = error{ OptionInvalid, Unexpected };
pub fn set(self: Self, comptime option: SetOption, value: SetOptionType(option)) SetError!void {
    const Value = @TypeOf(value);
    const raw_value = switch (Value) {
        bool => @as(c_int, @intFromBool(value)),
        c_int, [:0]const u8 => value,
        else => @compileError("Unrecognized type: " ++ @typeName(Value)),
    };
    const RawValue = @TypeOf(raw_value);

    const ptr, const size = switch (RawValue) {
        c_int => .{ &raw_value, @sizeOf(RawValue) },
        [:0]const u8 => .{ raw_value.ptr, raw_value.len + 1 },
        else => @compileError("Unrecognized type: " ++ @typeName(RawValue)),
    };
    if (zmq.zmq_ctx_set_ext(
        self.handle,
        @intFromEnum(option),
        ptr,
        size,
    ) == -1) {
        return switch (c._errno().*) {
            zmq.EINVAL => SetError.OptionInvalid,
            else => SetError.Unexpected,
        };
    }
}
