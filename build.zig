const std = @import("std");

fn buildLibzmq(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Module {
    const upstream = b.dependency("upstream", .{});
    const triple = target.result.linuxTriple(b.allocator) catch @panic("OOM");
    const cc = b.fmt(
        "-DCMAKE_C_COMPILER='{s};cc;--target={s}'",
        .{ b.graph.zig_exe, triple },
    );
    const cxx = b.fmt(
        "-DCMAKE_CXX_COMPILER='{s};c++;--target={s}'",
        .{ b.graph.zig_exe, triple },
    );
    const build_type = if (optimize == .Debug) "-DCMAKE_BUILD_TYPE=Debug" else "-DCMAKE_BUILD_TYPE=Release";
    const cmake = b.findProgram(&.{"cmake"}, &.{}) catch @panic("CMake not found");

    const cmake_configure = b.addSystemCommand(&.{
        cmake,
        "-G=Ninja",
        "-B",
        upstream.path("build").getPath(b),
        "-S",
        upstream.path("").getPath(b),
        cc,
        cxx,
        "-DWITH_PERF_TOOL=OFF",
        "-DZMQ_BUILD_TESTS=OFF",
        "-DENABLE_CPACK=OFF",
        "-DENABLE_DRAFTS=ON",
        build_type,
    });

    const cmake_build = b.addSystemCommand(&.{
        cmake,
        "--build",
        upstream.path("build").getPath(b),
    });
    cmake_build.step.dependOn(&cmake_configure.step);

    const lib_file = b.addInstallFile(
        upstream.path("build/lib/libzmq.a"),
        "libzmq.a",
    );
    lib_file.step.dependOn(&cmake_build.step);

    const library = b.addTranslateC(.{
        .root_source_file = upstream.path("include/zmq.h"),
        .target = target,
        .optimize = optimize,
    });
    library.step.dependOn(&lib_file.step);

    const module = b.addModule("libzmq", .{
        .root_source_file = library.getOutput(),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    module.addLibraryPath(lib_file.source.dirname());
    module.linkSystemLibrary("zmq", .{
        .use_pkg_config = .no,
    });

    return module;
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    _ = buildLibzmq(b, target, optimize);
}
