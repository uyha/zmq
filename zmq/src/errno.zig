const zmq = @import("libzmq");

pub fn errno() c_int {
    return zmq.zmq_errno();
}
