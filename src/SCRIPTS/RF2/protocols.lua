local protocol = rf2.executeScript("F/getProtocol")()
assert(protocol, "Unsupported protocol!")
return protocol
