local function setPidProfile(profileIndex)
    local message = {
        command = 210, -- MSP_SELECT_SETTING
        payload = { profileIndex }
    }
    rf2.mspQueue:add(message)
end

local function setRateProfile(profileIndex)
    setPidProfile(profileIndex + 128)
end

return {
    setPidProfile = setPidProfile,
    setRateProfile = setRateProfile
}