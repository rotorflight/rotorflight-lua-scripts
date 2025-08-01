local function pilotConfigReset()
    -- Reset FM8-GV8, see background.lua
    model.setGlobalVariable(7, 8, 0)
end

return pilotConfigReset