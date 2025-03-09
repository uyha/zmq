const std = @import("std");

fn buildLibzmq(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) *std.Build.Step.Compile {
    var platform_content = std.ArrayListUnmanaged(u8).empty;
    {
        platform_content.appendSlice(
            b.allocator,
            \\ #ifndef __ZMQ_PLATFORM_HPP_INCLUDED__
            \\ #define __ZMQ_PLATFORM_HPP_INCLUDED__
            \\
            ,
        ) catch @panic("OOM");
        defer platform_content.appendSlice(b.allocator,
            \\
            \\ #endif
        ) catch @panic("OOM");

        // TODO: Check poller base on platform, for now, hardcoding for Linux
        platform_content.appendSlice(b.allocator,
            \\ #define ZMQ_USE_CV_IMPL_STL11
            \\
            \\ #define ZMQ_IOTHREAD_POLLER_USE_EPOLL
            \\ #define ZMQ_IOTHREAD_POLLER_USE_EPOLL_CLOEXEC
            \\ #define ZMQ_HAVE_PPOLL
            \\
            \\ #define ZMQ_POLL_BASED_ON_POLL
            \\
            \\ #define HAVE_POSIX_MEMALIGN 1
            \\ #define ZMQ_CACHELINE_SIZE 64
            \\
            \\ #define HAVE_FORK
            \\ #define HAVE_CLOCK_GETTIME
            \\ #define HAVE_MKDTEMP
            \\ #define ZMQ_HAVE_UIO
            \\
            \\ #define ZMQ_HAVE_NOEXCEPT
            \\
            \\ #define ZMQ_HAVE_EVENTFD
            \\ #define ZMQ_HAVE_EVENTFD_CLOEXEC
            \\ #define ZMQ_HAVE_IFADDRS
            \\ #define ZMQ_HAVE_SO_BINDTODEVICE
            \\
            \\ #define ZMQ_HAVE_SO_PEERCRED
            \\ #define ZMQ_HAVE_BUSY_POLL
            \\
            \\ #define ZMQ_HAVE_O_CLOEXEC
            \\
            \\ #define ZMQ_HAVE_SOCK_CLOEXEC
            \\ #define ZMQ_HAVE_SO_KEEPALIVE
            \\ #define ZMQ_HAVE_SO_PRIORITY
            \\ #define ZMQ_HAVE_TCP_KEEPCNT
            \\ #define ZMQ_HAVE_TCP_KEEPIDLE
            \\ #define ZMQ_HAVE_TCP_KEEPINTVL
            \\ #define ZMQ_HAVE_PTHREAD_SETNAME_2
            \\ #define ZMQ_HAVE_PTHREAD_SET_AFFINITY
            \\ #define HAVE_ACCEPT4
            \\ #define HAVE_STRNLEN
            \\
            \\ #define ZMQ_HAVE_IPC
            \\ #define ZMQ_HAVE_STRUCT_SOCKADDR_UN
            \\
            // TODO: Enable WS and GNUTLS after figuring out how to find and link to
            // gnutls.h
            \\ // #define ZMQ_HAVE_WS
            \\ // #define ZMQ_HAVE_WSS
            \\ #define ZMQ_HAVE_TIPC
            \\
            \\ // #define ZMQ_USE_GNUTLS
            \\ #define ZMQ_USE_RADIX_TREE
            \\ #define HAVE_IF_NAMETOINDEX
            \\
        ) catch @panic("OOM");

        platform_content.appendSlice(b.allocator,
            \\
            \\ #define ZMQ_HAVE_LINUX
            \\
        ) catch @panic("OOM");
    }
    const platform = b.addWriteFile(
        "libzmq/include/platform.hpp",
        platform_content.items,
    );

    const upstream = b.dependency("libzmq", .{});
    const translate = b.addTranslateC(.{
        .root_source_file = upstream.path("include/zmq.h"),
        .target = target,
        .optimize = optimize,
    });
    const library = b.addStaticLibrary(.{
        .name = "zmq",
        .root_source_file = translate.getOutput(),
        .target = target,
        .optimize = optimize,
    });
    library.linkLibC();
    library.linkLibCpp();

    library.addIncludePath(
        platform.getDirectory().path(b, "libzmq/include"),
    );
    library.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = &.{
            // "ws_address.cpp",
            // "ws_connecter.cpp",
            // "ws_decoder.cpp",
            // "ws_encoder.cpp",
            // "ws_engine.cpp",
            // "ws_listener.cpp",
            // "wss_address.cpp",
            // "wss_engine.cpp",
            "precompiled.cpp",
            "address.cpp",
            "channel.cpp",
            "client.cpp",
            "clock.cpp",
            "ctx.cpp",
            "curve_mechanism_base.cpp",
            "curve_client.cpp",
            "curve_server.cpp",
            "dealer.cpp",
            "devpoll.cpp",
            "dgram.cpp",
            "dist.cpp",
            "endpoint.cpp",
            "epoll.cpp",
            "err.cpp",
            "fq.cpp",
            "io_object.cpp",
            "io_thread.cpp",
            "ip.cpp",
            "ipc_address.cpp",
            "ipc_connecter.cpp",
            "ipc_listener.cpp",
            "kqueue.cpp",
            "lb.cpp",
            "mailbox.cpp",
            "mailbox_safe.cpp",
            "mechanism.cpp",
            "mechanism_base.cpp",
            "metadata.cpp",
            "msg.cpp",
            "mtrie.cpp",
            "norm_engine.cpp",
            "object.cpp",
            "options.cpp",
            "own.cpp",
            "null_mechanism.cpp",
            "pair.cpp",
            "peer.cpp",
            "pgm_receiver.cpp",
            "pgm_sender.cpp",
            "pgm_socket.cpp",
            "pipe.cpp",
            "plain_client.cpp",
            "plain_server.cpp",
            "poll.cpp",
            "poller_base.cpp",
            "polling_util.cpp",
            "pollset.cpp",
            "proxy.cpp",
            "pub.cpp",
            "pull.cpp",
            "push.cpp",
            "random.cpp",
            "raw_encoder.cpp",
            "raw_decoder.cpp",
            "raw_engine.cpp",
            "reaper.cpp",
            "rep.cpp",
            "req.cpp",
            "router.cpp",
            "select.cpp",
            "server.cpp",
            "session_base.cpp",
            "signaler.cpp",
            "socket_base.cpp",
            "socks.cpp",
            "socks_connecter.cpp",
            "stream.cpp",
            "stream_engine_base.cpp",
            "sub.cpp",
            "tcp.cpp",
            "tcp_address.cpp",
            "tcp_connecter.cpp",
            "tcp_listener.cpp",
            "thread.cpp",
            "trie.cpp",
            "radix_tree.cpp",
            "v1_decoder.cpp",
            "v1_encoder.cpp",
            "v2_decoder.cpp",
            "v2_encoder.cpp",
            "v3_1_encoder.cpp",
            "xpub.cpp",
            "xsub.cpp",
            "zmq.cpp",
            "zmq_utils.cpp",
            "decoder_allocators.cpp",
            "socket_poller.cpp",
            "timers.cpp",
            "radio.cpp",
            "dish.cpp",
            "udp_engine.cpp",
            "udp_address.cpp",
            "scatter.cpp",
            "gather.cpp",
            "ip_resolver.cpp",
            "zap_client.cpp",
            "zmtp_engine.cpp",
            "stream_connecter_base.cpp",
            "stream_listener_base.cpp",
            "tipc_address.cpp",
            "tipc_connecter.cpp",
            "tipc_listener.cpp",
        },
    });

    return library;
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libzmq = buildLibzmq(b, target, optimize);
    b.installArtifact(libzmq);

    const zmq = b.addModule(
        "zmq",
        .{
            .root_source_file = b.path("src/zmq.zig"),
            .target = target,
            .optimize = optimize,
        },
    );
    zmq.addImport("libzmq", libzmq.root_module);

    const main = b.addExecutable(.{
        .name = "main",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(main);
    main.root_module.addImport("zmq", zmq);
    const run_main = b.addRunArtifact(main);

    const run_main_step = b.step("main", "Run main");
    run_main_step.dependOn(&run_main.step);
}
