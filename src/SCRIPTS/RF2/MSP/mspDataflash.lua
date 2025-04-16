local function getDataflashSummary(callback, callbackParam)
    local message = {
        command = 70, -- MSP_DATAFLASH_SUMMARY
        processReply = function(self, buf)
            local summary = {}
            --rf2.print("buf length: "..#buf)
            local flags = rf2.mspHelper.readU8(buf)
            summary.ready = bit32.band(flags, 1) ~= 0
            summary.supported = bit32.band(flags, 2) ~= 0
            summary.sectors = rf2.mspHelper.readU32(buf)
            summary.totalSize = rf2.mspHelper.readU32(buf)
            summary.usedSize = rf2.mspHelper.readU32(buf)
            --rf2.print("summary.ready: "..tostring(summary.ready))
            --rf2.print("summary.supported: "..tostring(summary.supported))
            --rf2.print("summary.sectors: "..tostring(summary.sectors))
            --rf2.print("summary.totalSize: "..tostring(summary.totalSize))
            --rf2.print("summary.usedSize: "..tostring(summary.usedSize))

            callback(callbackParam, summary)
        end,
        simulatorResponse = {
            0x03,                   -- Flags: 3 (binary 00000011, indicating ready and supported)
            0x01,0x00,0x00,0x00,    -- Sectors: 1 (little-endian, 32-bit integer)
            0x00,0x00,0x40,0x06,    -- Total size: 100 MB (104857600 bytes, little-endian, 32-bit integer)
            0x00, 0x00, 0x00, 0x05  -- Used size: 80% of total size (83886080 bytes, little-endian, 32-bit integer)
        }
    }
    rf2.mspQueue:add(message)
end

local function eraseDataflash(callback, callbackParam)
    local message = {
        command = 72, -- MSP_DATAFLASH_ERASE
        processReply = function(self, buf)
            local summary = {}
            --rf2.print("buf length: "..#buf)
            callback(callbackParam, summary)
        end,
        simulatorResponse = { }
    }
    rf2.mspQueue:add(message)
end

return {
    getDataflashSummary = getDataflashSummary,
    eraseDataflash = eraseDataflash
}