from dataclasses import dataclass
from urllib import request

from parsel import Selector

url = "https://libzmq.readthedocs.io/en/latest/zmq_setsockopt.html"
with request.urlopen(url) as resp:
    sel = Selector(resp.read().decode())


@dataclass
class Option:
    name: str
    macro: str
    value_type: str
    comment: str | None


deprecated = {
    "ZMQ_CONNECT_RID",
    "ZMQ_IDENTITY",
    "ZMQ_IPC_FILTER_GID",
    "ZMQ_IPC_FILTER_PID",
    "ZMQ_IPC_FILTER_UID",
}

options: list[Option] = []

for option in sel.xpath("//div[@class='sect2']"):
    name = option.xpath("h3/text()").get()
    assert name is not None
    name = name.split(":")[0].strip()

    assert name.startswith("ZMQ_")
    if name in deprecated:
        continue

    zig_name = f"{name.lstrip("ZMQ_").lower()}"
    macro = f"zmq.{name}"

    try:
        value_type, value_unit, *_ = option.xpath("./div[@class='hdlist']//tr")
    except ValueError:
        continue

    assert (
        "".join(value_type.xpath("./td[1]/text()").getall()).strip()
        == "Option value type"
    )
    unit_label = "".join(value_unit.xpath("./td[1]/text()").getall()).strip()
    assert unit_label == "Option value unit" or unit_label == "Option value size"

    value_type = "".join(value_type.xpath("./td[2]//text()").getall()).strip()
    value_unit = "".join(value_unit.xpath("./td[2]//text()").getall()).strip()

    comment = value_unit
    match ((value_type, value_unit, name)):
        case (_, _, "ZMQ_RECONNECT_STOP"):
            comment = None
            zig_type = """
packed struct(c_int) {
  conn_refused : bool = false,
  handshake_failed : bool = false,
  after_disconnect : bool = false,
  _padding : u29 = 0,
}""".strip()
        case (_, _, "ZMQ_ROUTER_NOTIFY"):
            comment = None
            zig_type = """
packed struct(c_int) {
  connect : bool = false,
  disconnect : bool = false,
  _padding : u29 = 0,
}""".strip()
        case (_, _, "ZMQ_NORM_MODE"):
            comment = None
            zig_type = """
enum(c_int) {
    fixed = zmq.ZMQ_NORM_FIXED,
    cc = zmq.ZMQ_NORM_CC,
    ccl = zmq.ZMQ_NORM_CCL,
    cce = zmq.ZMQ_NORM_CCE,
}""".strip()
        case ("int", "0, 1", _):
            comment = None
            zig_type = "bool"
        case ("int", "0,1", _):
            comment = None
            zig_type = "bool"
        case ("int", "boolean", _):
            comment = None
            zig_type = "bool"
        case ("int", _, _):
            zig_type = "c_int"
        case ("uint64_t", _, _):
            zig_type = "u64"
        case ("int64_t", _, _):
            zig_type = "i64"
        case ("character string", _, _):
            zig_type = "[:0]const u8"
        case ("binary data", _, _):
            zig_type = "[]const u8"
        case ("binary data or Z85 text string", _, _):
            comment = "32 or 41 characters"
            zig_type = "[]const u8"
        case _:
            print(value_type, value_unit)
            raise NotImplementedError()

    if comment is not None:
        comment = comment.replace("N/A", "").replace("⇐", "<=").strip()

        if comment == "(bitmap)" or len(comment) == 0:
            comment = None

    options.append(
        Option(name=zig_name, macro=macro, value_type=zig_type, comment=comment)
    )


print("pub const Option = enum(c_int) {")
for opt in options:
    print(f"    {opt.name} = {opt.macro},")
print("};")

print("pub fn OptionType(option: Option) type {")
print("   return switch(option) {")
for opt in options:
    print(
        f"        .{opt.name} => {opt.value_type}, {f'// {opt.comment}' if opt.comment is not None else ''}"
    )
print("    };")
print("}")
