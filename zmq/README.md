# Zig binding for ZeroMQ

## Binding functions status

All the binding functions live in the `zmq` namespace.

### Atomic Counter

- [ ] `zmq_atomic_counter_dec`
- [ ] `zmq_atomic_counter_destroy`
- [ ] `zmq_atomic_counter_inc`
- [ ] `zmq_atomic_counter_new`
- [ ] `zmq_atomic_counter_set`
- [ ] `zmq_atomic_counter_value`

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
- [ ] `zmq_recv`
- [ ] ~~`zmq_recvmsg`~~ (to be deprecated, `zmq_msg_recv` is used instead)
- [ ] `zmq_msg_recv`
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
- [ ] `zmq_msg_copy`
- [X] `zmq_msg_data` -> `Message.data`
- [ ] `zmq_msg_get`
- [ ] `zmq_msg_gets`
- [X] `zmq_msg_init` -> `Message.empty`
- [X] `zmq_msg_init_buffer` -> `Message.withBuffer`
- [ ] `zmq_msg_init_data`
- [X] `zmq_msg_init_size` -> `Message.withSize`
- [X] `zmq_msg_more` -> `Message.more`
- [ ] `zmq_msg_move`
- [ ] `zmq_msg_routing_id`
- [ ] `zmq_msg_set` (currently useless)
- [ ] `zmq_msg_set_routing_id`
- [X] `zmq_msg_size` -> `Message.size`

### Curve

- [ ] `zmq_curve_keypair`
- [ ] `zmq_curve_public`

### Polling

- [ ] `zmq_poll`
- [ ] `zmq_ppoll`

### Poller

- [ ] `zmq_poller_new`
- [ ] `zmq_poller_destroy`
- [ ] `zmq_poller_size`
- [ ] `zmq_poller_add`
- [ ] `zmq_poller_modify`
- [ ] `zmq_poller_remove`
- [ ] `zmq_poller_add_fd`
- [ ] `zmq_poller_modify_fd`
- [ ] `zmq_poller_remove_fd`
- [ ] `zmq_poller_wait`
- [ ] `zmq_poller_wait_all`
- [ ] `zmq_poller_fd`

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

### Z885

- [ ] `zmq_z85_decode`
- [ ] `zmq_z85_encode`

### Runtime inspection

- [X] `zmq_has` -> `has`
- [X] `zmq_version` -> `version`

### Utilities

- [X] `zmq_errno` -> `errno`
- [ ] `zmq_strerror`
