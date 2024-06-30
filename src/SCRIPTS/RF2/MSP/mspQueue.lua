-- MspQueueController class
local MspQueueController = {}
MspQueueController.__index = MspQueueController

function MspQueueController.new()
    local self = setmetatable({}, MspQueueController)
    self.messageQueue = {}
    self.currentMessage = nil
    self.lastTimeCommandSent = 0
    self.retryCount = 0
    self.maxRetries = 3
    return self
end

function MspQueueController:isProcessed()
    return not self.currentMessage and #self.messageQueue == 0
end

--[[
function joinTableItems(table, delimiter)
    if table == nil or #table == 0 then return "" end
    delimiter = delimiter or ""
    local result = table[1]
    for i = 2, #table do
        result = result .. delimiter .. table[i]
    end
    return result
end
--]]

local function popFirstElement(tbl)
    if tbl == nil or #tbl == 0 then return nil end
    local firstElement = tbl[1]

    for i = 1, #tbl - 1 do
        tbl[i] = tbl[i + 1]
    end
    tbl[#tbl] = nil

    return firstElement
end

function MspQueueController:processQueue()
    if self:isProcessed() then
        return
    end

    if not self.currentMessage then
        self.currentMessage = popFirstElement(self.messageQueue)
        self.retryCount = 0
    end

    local cmd, buf, err
    --rf2.print("retryCount: "..self.retryCount)

    if not rf2.runningInSimulator then
        if self.lastTimeCommandSent == 0 or self.lastTimeCommandSent + 0.5 < rf2.clock() then
            if self.currentMessage.payload then
                rf2.protocol.mspWrite(self.currentMessage.command, self.currentMessage.payload)
            else
                rf2.protocol.mspWrite(self.currentMessage.command, {})
            end
            self.lastTimeCommandSent = rf2.clock()
            self.retryCount = self.retryCount + 1
        end

        mspProcessTxQ()
        cmd, buf, err = mspPollReply()
    else
        if not self.currentMessage.simulatorResponse then
            rf2.print("No simulator response for command "..tostring(self.currentMessage.command))
            self.currentMessage = nil
            return
        end
        cmd = self.currentMessage.command
        buf = self.currentMessage.simulatorResponse
        err = nil
    end

    if cmd then rf2.print("Received cmd: "..tostring(cmd)) end

    if (cmd == self.currentMessage.command and not err) or (self.currentMessage.command == 68 and self.retryCount == 2) then -- 68 = MSP_REBOOT
        --rf2.print("Received: {" .. joinTableItems(buf, ", ") .. "}")
        if self.currentMessage.processReply then
            self.currentMessage:processReply(buf)
        end
        self.currentMessage = nil
    elseif self.retryCount > self.maxRetries then
        self.currentMessage = nil
    end
end

local function deepCopy(original)
    local copy
    if type(original) == "table" then
        copy = {}
        for key, value in next, original, nil do
            copy[deepCopy(key)] = deepCopy(value)
        end
        setmetatable(copy, deepCopy(getmetatable(original)))
    else -- number, string, boolean, etc
        copy = original
    end
    return copy
end

function MspQueueController:add(message)
    message = deepCopy(message)
    rf2.print("Queueing command "..message.command.." at position "..#self.messageQueue + 1)
    self.messageQueue[#self.messageQueue + 1] =  message
    return self
end

return MspQueueController.new()

--[[ Usage example

local myMspMessage =
{
    command = 111,
    processReply = function(self, buf)
        print("Do something with the response buffer")
    end,
    simulatorResponse = { 1, 2, 3, 4 }
}

local anotherMspMessage =
{
    command = 123,
    processReply = function(self, buf)
        print("Received response for command "..tostring(self.command).." with length "..tostring(#buf))
    end,
    simulatorResponse = { 254, 128 }
}

local myMspQueue = MspQueueController.new()
myMspQueue
  :add(myMspMessage)
  :add(anotherMspMessage)

while not myMspQueue:isProcessed() do
    myMspQueue:processQueue()
end
--]]