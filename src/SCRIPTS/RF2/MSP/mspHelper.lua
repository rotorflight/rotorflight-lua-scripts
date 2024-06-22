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
        --value = value | buf[offset + 1] << 8
        value = bit32.bor(value, bit32.lshift(buf[offset + 1], 8))
        buf.offset = offset + 2
        return value
    end,
    readS16 = function(buf)
        local offset = buf.offset or 1
        local value = buf[offset]
        --value = value | buf[offset + 1] << 8
        value = bit32.bor(value, bit32.lshift(buf[offset + 1], 8))
        --if value & (1 << 15) ~= 0 then value = value - (2 ^ 16) end
        if bit32.band(value, bit32.lshift(1, 15)) ~= 0 then value = value - (2 ^ 16) end
        buf.offset = offset + 2
        return value
    end,
    readU32 = function(buf)
        local offset = buf.offset or 1
        local value = 0
        for i = 0, 3 do
            --value = value | buf[offset + i] << (i * 8)
            value = bit32.bor(value, bit32.lshift(buf[offset + i], 8))
        end
        buf.offset = offset + 2
        return value
    end,
    writeU8 = function(buf, value)
        --local byte1 = value & 0xFF
        local byte1 = bit32.band(value,  0xFF)
        buf[#buf + 1] = byte1
    end,
    writeU16 = function(buf, value)
        --local byte1 = value & 0xFF
        local byte1 = bit32.band(value,  0xFF)
        --local byte2 = (value >> 8) & 0xFF
        local byte2 = bit32.band(bit32.rshift(value, 8), 0xFF)
        buf[#buf + 1] = byte1
        buf[#buf + 1] = byte2
    end,
    writeU32 = function(buf, value)
        --local byte1 = value & 0xFF
        local byte1 = bit32.band(value,  0xFF)
        --local byte2 = (value >> 8) & 0xFF
        local byte2 = bit32.band(bit32.rshift(value, 8), 0xFF)
        --local byte3 = (value >> 16) & 0xFF
        local byte3 = bit32.band(bit32.rshift(value, 16), 0xFF)
        --local byte4 = (value >> 24) & 0xFF
        local byte4 = bit32.band(bit32.rshift(value, 24), 0xFF)
        buf[#buf + 1] = byte1
        buf[#buf + 1] = byte2
        buf[#buf + 1] = byte3
        buf[#buf + 1] = byte4
    end,
}

return mspHelper