-- Protocol version
local MSP_VERSION = bit32.lshift(1,5)
local MSP_STARTFLAG = bit32.lshift(1,4)

-- Sequence number for next MSP packet
local mspSeq = 0
local mspRemoteSeq = 0
local mspRxBuf = {}
local mspRxError = false
local mspRxSize = 0
local mspRxCRC = 0
local mspRxReq = 0
local mspStarted = false
local mspLastReq = 0
local mspTxBuf = {}
local mspTxIdx = 1
local mspTxCRC = 0

function mspProcessTxQ()
    if (#(mspTxBuf) == 0) then
        return false
    end
    if not rf2.protocol.push() then
        return true
    end
    --rf2.print("Sending mspTxBuf size "..tostring(#mspTxBuf).." at Idx "..tostring(mspTxIdx).." for cmd: "..tostring(mspLastReq))
    local payload = {}
    payload[1] = mspSeq + MSP_VERSION
    mspSeq = bit32.band(mspSeq + 1, 0x0F)
    if mspTxIdx == 1 then
        -- start flag
        payload[1] = payload[1] + MSP_STARTFLAG
    end
    local i = 2
    while (i <= rf2.protocol.maxTxBufferSize) and mspTxIdx <= #mspTxBuf do
        payload[i] = mspTxBuf[mspTxIdx]
        mspTxIdx = mspTxIdx + 1
        mspTxCRC = bit32.bxor(mspTxCRC,payload[i])
        i = i + 1
    end
    if i <= rf2.protocol.maxTxBufferSize then
        payload[i] = mspTxCRC
        rf2.protocol.mspSend(payload)
        mspTxBuf = {}
        mspTxIdx = 1
        mspTxCRC = 0
        return false
    end
    rf2.protocol.mspSend(payload)
    return true
end

function mspSendRequest(cmd, payload)
    --rf2.print("Sending cmd "..cmd)
    -- busy
    if #(mspTxBuf) ~= 0 or not cmd then
        --rf2.print("Existing mspTxBuf is still being sent, failed send of cmd: "..tostring(cmd))
        return nil
    end
    mspTxBuf[1] = #(payload)
    mspTxBuf[2] = bit32.band(cmd,0xFF)  -- MSP command
    for i=1,#(payload) do
        mspTxBuf[i+2] = bit32.band(payload[i],0xFF)
    end
    mspLastReq = cmd
    return mspProcessTxQ()
end

local function mspReceivedReply(payload)
    --rf2.print("Starting mspReceivedReply")
    local idx = 1
    local status = payload[idx]
    local version = bit32.rshift(bit32.band(status, 0x60), 5)
    local start = bit32.btest(status, 0x10)
    local seq = bit32.band(status, 0x0F)
    idx = idx + 1
    --rf2.print("payload length: "..#payload)
    --rf2.print(" msp sequence #:  "..string.format("%u",seq))
    if start then
        -- start flag set
        mspRxBuf = {}
        mspRxError = bit32.btest(status, 0x80)
        mspRxSize = payload[idx]
        mspRxReq = mspLastReq
        idx = idx + 1
        if version == 1 then
            --rf2.print("version == 1")
            mspRxReq = payload[idx]
            idx = idx + 1
        end
        mspRxCRC = bit32.bxor(mspRxSize, mspRxReq)
        if mspRxReq == mspLastReq then
            mspStarted = true
            --rf2.print("Started cmd "..mspLastReq)
        end
    elseif not mspStarted then
		--rf2.print("  mspReceivedReply: missing Start flag")
        return nil
    elseif bit32.band(mspRemoteSeq + 1, 0x0F) ~= seq then
        mspStarted = false
        return nil
    end
    while (idx <= rf2.protocol.maxRxBufferSize) and (#mspRxBuf < mspRxSize) do
        mspRxBuf[#mspRxBuf + 1] = payload[idx]
        mspRxCRC = bit32.bxor(mspRxCRC, payload[idx])
        idx = idx + 1
    end
    if idx > rf2.protocol.maxRxBufferSize then
		--rf2.print("  mspReceivedReply:  payload continues into next frame.")
        -- Store the last sequence number so we can start there on the next continuation payload
        mspRemoteSeq = seq
        return false
    end
    mspStarted = false
    -- check CRC
    if mspRxCRC ~= payload[idx] and version == 0 then
		rf2.print("  mspReceivedReply:  payload checksum incorrect, message failed!")
        --rf2.print("    Calculated mspRxCRC:  0x"..string.format("%X", mspRxCRC))
        --rf2.print("    CRC from payload:     0x"..string.format("%X", payload[idx]))
        return nil
    end
    --rf2.print("  Got reply for cmd "..mspRxReq)
    return true
end

function mspPollReply()
    local startTime = rf2.clock()
    while (rf2.clock() - startTime < 0.05) do
        local mspData = rf2.protocol.mspPoll()
        if mspData ~= nil and mspReceivedReply(mspData) then
            mspLastReq = 0
            return mspRxReq, mspRxBuf, mspRxError
        end
    end
end

function mspClearTxBuf()
    mspTxBuf = {}
end