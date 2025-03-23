local mspHelper = {
    readU8 = function(buf)
        local offset = buf.offset or 1
        local value = buf[offset]
        buf.offset = offset + 1
        return value
    end,
    readU16 = function(buf)
        local offset = buf.offset or 1
        local value = buf[offset]
        value = bit32.bor(value, bit32.lshift(buf[offset + 1], 8))
        buf.offset = offset + 2
        return value
    end,
    readU32 = function(buf)
        local offset = buf.offset or 1
        local value = 0
        for i = 0, 3 do
            value = bit32.bor(value, bit32.lshift(buf[offset + i], i * 8))
        end
        buf.offset = offset + 4
        return value
    end,
    readText = function(buf, length)
        local offset = buf.offset or 1
        local text = ""
        for i = 0, length - 1 do
            text = text..string.char(buf[offset + i])
        end
        buf.offset = offset + length
        return text
    end,
    writeU8 = function(buf, value)
        local byte1 = bit32.band(value,  0xFF)
        buf[#buf + 1] = byte1
    end,
    writeU16 = function(buf, value)
        for i = 0, 1 do
            buf[#buf + 1] = bit32.band(bit32.rshift(value, i * 8), 0xFF)
        end
    end,
    writeU32 = function(buf, value)
        for i = 0, 3 do
            buf[#buf + 1] = bit32.band(bit32.rshift(value, i * 8), 0xFF)
        end
    end,
    writeText = function(buf, text)
        for i = 1, #text do
            buf[#buf + 1] = string.byte(text, i)
        end
    end,
}

mspHelper.readS8 = function(buf)
    local value = mspHelper.readU8(buf)
    if bit32.band(value, bit32.lshift(1, 7)) ~= 0 then value = value - (2 ^ 8) end
    return value
end

mspHelper.readS16 = function(buf)
    local value = mspHelper.readU16(buf)
    if bit32.band(value, bit32.lshift(1, 15)) ~= 0 then value = value - (2 ^ 16) end
    return value
end

return mspHelper