local function setPidProfile(profileIndex, callback, callbackParam)
    local message = {
        command = 210, -- MSP_SELECT_SETTING
        payload = { profileIndex },
        processReply = function(self, buf)
            if callback then callback(callbackParam) end
        end
    }
    rf2.mspQueue:add(message)
end

local function setRateProfile(profileIndex, callback, callbackParam)
    setPidProfile(profileIndex + 128, callback, callbackParam)
end

return {
    setPidProfile = setPidProfile,
    setRateProfile = setRateProfile
}