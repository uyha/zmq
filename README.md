# Zig binding for ZeroMQ

## Binding functions status

All the binding functions live in the `zimq` module.

### Atomic Counter

- [X] `zmq_atomic_counter_dec` -> `AtomicCounter.dec`
- [X] `zmq_atomic_counter_destroy` -> `AtomicCounter.deinit`
- [X] `zmq_atomic_counter_inc` -> `AtomicCounter.inc`
- [X] `zmq_atomic_counter_new` -> `AtomicCounter.init`
- [X] `zmq_atomic_counter_set` -> `AtomicCounter.set`
- [X] `zmq_atomic_counter_value` -> `AtomicCounter.value`

### Context

- [ ] ~~`zmq_ctx_get`~~ (`zmq_ctx_get_ext` is used instead)
- [X] `zmq_ctx_get_ext` -> `Context.get`
- [X] `zmq_ctx_new` -> `Context.init`
- [ ] ~~`zmq_ctx_set`~~ (`zmq_ctx_set_ext` is used instead)
- [X] `zmq_ctx_set_ext` -> `Context.set`
- [X] `zmq_ctx_shutdown` -> `Context.shutdown`
- [X] `zmq_ctx_term` -> `Context.deinit`

### Socket

- [X] `zmq_bind` -> `Socket.bind`
- [X] `zmq_close` -> `Socket.deinit`
- [X] `zmq_connect` -> `Socket.connect`
- [X] `zmq_connect_peer` -> `Socket.connectPeer`
- [X] `zmq_disconnect` -> `Socket.disconnect`
- [X] `zmq_getsockopt` -> `Socket.get`
- [X] `zmq_recv` -> `Socket.recv`
- [ ] ~~`zmq_recvmsg`~~ (to be deprecated, `zmq_msg_recv` is used instead)
- [X] `zmq_msg_recv` -> `Socket.recvMsg`
- [X] `zmq_send` -> `Socket.sendBuffer`
- [X] `zmq_send_const` -> `Socket.sendConst`
- [ ] ~~`zmq_sendmsg`~~ (to be deprecated, `zmq_msg_send` is used instead)
- [X] `zmq_msg_send` -> `Socket.sendMsg`
- [X] `zmq_setsockopt` -> `Socket.set`
- [X] `zmq_socket` -> `Socket.init`
- [X] `zmq_socket_monitor` -> `Socket.monitor`
- [X] `zmq_socket_monitor_versioned` -> `Socket.monitorVersioned`
- [X] `zmq_socket_monitor_pipes_stats` -> `Socket.pipesStats`
- [X] `zmq_unbind` -> `Socket.unbind`

### Message

- [X] `zmq_msg_close` -> `Message.deinit`
- [X] `zmq_msg_copy` -> `Message.copy`
- [X] `zmq_msg_data` -> `Message.data` (`Message.slice` provides better access to
the underlying data)
- [X] `zmq_msg_get` -> `Message.get`
- [X] `zmq_msg_gets` -> `Message.gets`
- [X] `zmq_msg_init` -> `Message.empty`
- [X] `zmq_msg_init_buffer` -> `Message.withBuffer`
- [X] `zmq_msg_init_data` -> `Message.withData`
- [X] `zmq_msg_init_size` -> `Message.withSize`
- [X] `zmq_msg_more` -> `Message.more`
- [X] `zmq_msg_move` -> `Message.move`
- [X] `zmq_msg_routing_id` -> `Message.getRoutingId`
- [ ] `zmq_msg_set` (currently useless)
- [X] `zmq_msg_set_routing_id` -> `Message.setRoutingId`
- [X] `zmq_msg_size` -> `Message.size`

### Curve

- [X] `zmq_curve_keypair` -> `curve.keypair`
- [X] `zmq_curve_public` -> `curve.publicKey`

### Polling

- [X] `zmq_poll` -> `poll.poll`
- [X] `zmq_ppoll` -> `poll.ppoll`

### Poller

- [X] `zmq_poller_new` -> `Poller.init`
- [X] `zmq_poller_destroy` -> `Poller.deinit`
- [X] `zmq_poller_size` -> `Poller.size`
- [X] `zmq_poller_add` -> `Poller.add`
- [X] `zmq_poller_modify` -> `Poller.modify`
- [X] `zmq_poller_remove` -> `Poller.remove`
- [X] `zmq_poller_add_fd` -> `Poller.add_fd`
- [X] `zmq_poller_modify_fd` -> `Poller.modify_fd`
- [X] `zmq_poller_remove_fd` -> `Poller.remove_fd`
- [X] `zmq_poller_wait` -> `Poller.wait`
- [X] `zmq_poller_wait_all` -> `Poller.wait_all`
- [X] `zmq_poller_fd` -> `Poller.fd`

### Proxy

- [x] `zmq_proxy` -> `proxy`
- [x] `zmq_proxy_steerable` -> `proxySteerable`

### Timer

- [X] `zmq_timers_new` -> `Timers.init`
- [X] `zmq_timers_destroy` -> `Timers.deinit`
- [X] `zmq_timers_add` -> `Timers.add`
- [X] `zmq_timers_cancel` -> `Timers.cancel`
- [X] `zmq_timers_set_interval` -> `Timers.setInterval`
- [X] `zmq_timers_reset` -> `Timers.reset`
- [X] `zmq_timers_timeout` -> `Timers.timeout`
- [X] `zmq_timers_execute` -> `Timers.execute`

### Z85

- [X] `zmq_z85_encode` -> `z85.encode`
- [X] `zmq_z85_decode` -> `z85.decode`

### Runtime inspection

- [X] `zmq_has` -> `has`
- [X] `zmq_version` -> `version`

### Utilities

- [X] `zmq_errno` -> `errno`
- [X] `zmq_strerror` -> `strerror`
