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
        cc,
        cxx,
        "-DWITH_TLS=OFF",
        "-DWITH_PERF_TOOL=OFF",
        "-DZMQ_BUILD_TESTS=OFF",
        "-DENABLE_CPACK=OFF",
        "-DENABLE_DRAFTS=ON",
        "-Wno-dev",
        build_type,
        "-S",
    });
    cmake_configure.addDirectoryArg(upstream.path(""));
    cmake_configure.addArg("-B");
    const build_dir = cmake_configure.addOutputDirectoryArg("build");

    const cmake_build = b.addSystemCommand(&.{ cmake, "--build" });
    cmake_build.addDirectoryArg(build_dir);

    const library = b.addTranslateC(.{
        .root_source_file = upstream.path("include/zmq.h"),
        .target = target,
        .optimize = optimize,
    });
    library.step.dependOn(&cmake_build.step);

    const module = b.addModule("libzmq", .{
        .root_source_file = library.getOutput(),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
    });
    module.addObjectFile(build_dir.path(b, "lib/libzmq.a"));

    return module;
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libzmq_module = buildLibzmq(b, target, optimize);

    const zmq = b.addStaticLibrary(.{
        .name = "zmq",
        .root_source_file = b.path("src/zmq.zig"),
        .target = target,
        .optimize = optimize,
    });
    zmq.root_module.addImport("libzmq", libzmq_module);
    b.installArtifact(zmq);

    const zmq_test = b.addTest(.{
        .root_source_file = b.path("test/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    zmq_test.root_module.addImport("zmq", &zmq.root_module);
    const zmq_test_run = b.addRunArtifact(zmq_test);

    const test_step = b.step("test", "Run all the tests");
    test_step.dependOn(&zmq_test_run.step);
}
