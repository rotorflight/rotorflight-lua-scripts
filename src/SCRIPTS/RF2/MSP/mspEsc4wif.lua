local function selectEsc(escIndex, postSendDelay, callback, callbackParam)
    local message = {
        command = 244,     -- MSP_SET_4WIF_ESC_FWD_PROG
        payload = { escIndex },
        postSendDelay = postSendDelay
    }

    if callback then
        message.processReply = function(self)
            if callback then
                callback(callbackParam)
            end
        end
    end

    rf2.mspQueue:add(message)
end

local function clearEscSelection(callback, callbackParam)
    local message = {
        command = 244,     -- MSP_SET_4WIF_ESC_FWD_PROG
        payload = { 100 }  -- Any value > MOTOR_COUNT
    }

    if callback then
        message.processReply = function(self)
            if callback then
                callback(callbackParam)
            end
        end
    end

    rf2.mspQueue:add(message)
end

return {
    selectEsc = selectEsc,
    clearEscSelection = clearEscSelection
}