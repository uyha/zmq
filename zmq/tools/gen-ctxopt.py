from urllib import request

from parsel import Selector

url = "https://libzmq.readthedocs.io/en/latest/zmq_ctx_set.html"
with request.urlopen(url) as resp:
    sel = Selector(resp.read().decode())

bool_options = ["blocky", "zero_copy_recv", "ipv6"]

print("pub const Option = enum(c_int) {")
for text in sel.xpath("//div[@class='sect2']/h3/text()"):
    raw = text.get()
    assert raw is not None
    assert isinstance(raw, str)

    name, _ = raw.split(":")
    name = name.strip()
    zig = name.lstrip("ZMQ_").lower()
    print(f"    {zig} = zmq.{name},")

print("};")
print("")

print("pub fn OptionType(option: Option) type {")
print("    return switch (option) {")
print(f"        {", ".join(f".{opt}" for opt in bool_options)} => bool,")
print("        else => c_int,")
print("    };")
print("}")
