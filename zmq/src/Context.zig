const zmq = @import("libzmq");
const std = @import("std");
const c = @import("std").c;

const opt = @import("context/option.zig");
const SetOption = opt.SetOption;
const SetOptionType = opt.SetOptionType;
const GetOption = opt.GetOption;
const GetOptionType = opt.GetOptionType;

const errno = @import("errno.zig").errno;

const Self = @This();

handle: *anyopaque,

pub const InitError = error{ TooManyOpenFiles, Unexpected };
pub inline fn init() InitError!Self {
    const handle = zmq.zmq_ctx_new();
    if (handle == null) {
        return switch (errno()) {
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
        return switch (errno()) {
            zmq.EINVAL => SetError.OptionInvalid,
            else => SetError.Unexpected,
        };
    }
}

pub const GetError = error{Unexpected};
// The underlying function `zmq_ctx_get_ext` does not set the actual length of passed in
// size pointer despite what the document says. Hence, the slice pointer passed in for
// .thread_name_prefix will not have its `len` updated.
pub fn get(self: Self, comptime option: GetOption, out: *GetOptionType(option)) GetError!void {
    const Out = @TypeOf(out);

    const result = get: switch (Out) {
        *bool => {
            var value: c_int = undefined;
            var size: usize = @sizeOf(@TypeOf(value));

            const result = zmq.zmq_ctx_get_ext(
                self.handle,
                @intFromEnum(option),
                &value,
                &size,
            );
            if (result != -1) {
                out.* = value != 0;
            }

            break :get result;
        },
        *[:0]u8 => {
            const result = zmq.zmq_ctx_get_ext(
                self.handle,
                @intFromEnum(option),
                out.ptr,
                &out.len,
            );

            break :get result;
        },
        else => @compileError("Unrecognized type: " ++ @typeName(Out)),
    };

    if (result == -1) {
        return switch (errno()) {
            else => SetError.Unexpected,
        };
    }
}
