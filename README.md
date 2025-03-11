# Zig binding for ZeroMQ

## Binding functions status

All the binding functions live in the `zmq` namespace.

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
- [ ] `zmq_connect_peer`
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
- [ ] `zmq_socket_monitor`
- [ ] `zmq_socket_monitor_versioned`
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
- [ ] `zmq_msg_init_data`
- [X] `zmq_msg_init_size` -> `Message.withSize`
- [X] `zmq_msg_more` -> `Message.more`
- [X] `zmq_msg_move` -> `Message.move`
- [ ] `zmq_msg_routing_id`
- [ ] `zmq_msg_set` (currently useless)
- [ ] `zmq_msg_set_routing_id`
- [X] `zmq_msg_size` -> `Message.size`

### Curve

- [ ] `zmq_curve_keypair`
- [ ] `zmq_curve_public`

### Polling

- [X] `zmq_poll` -> `poll.poll`
- [ ] `zmq_ppoll`

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

- [ ] `zmq_proxy`
- [ ] `zmq_proxy_steerable`

### Timer

- [ ] `zmq_timers_new`
- [ ] `zmq_timers_destroy`
- [ ] `zmq_timers_add`
- [ ] `zmq_timers_cancel`
- [ ] `zmq_timers_set_interval`
- [ ] `zmq_timers_reset`
- [ ] `zmq_timers_timeout`
- [ ] `zmq_timers_execute`

### Z85

- [ ] `zmq_z85_decode`
- [ ] `zmq_z85_encode`

### Runtime inspection

- [X] `zmq_has` -> `has`
- [X] `zmq_version` -> `version`

### Utilities

- [X] `zmq_errno` -> `errno`
- [X] `zmq_strerror` -> `strerror`
