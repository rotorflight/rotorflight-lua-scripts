local template = assert(rf2.loadScript(rf2.radio.template))()
local mspPilotConfig = assert(rf2.loadScript("MSP/mspPilotConfig.lua"))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}
local pilotConfig = {}

x = margin
y = yMinLim - tableSpacing.header

fields[1] = { t = "Model ID",             x = x, y = inc.y(lineSpacing), sp = x + sp }
fields[2] = { t = "Param1 type",          x = x, y = inc.y(lineSpacing), sp = x + sp }
fields[3] = { t = "Param1 value",         x = x, y = inc.y(lineSpacing), sp = x + sp }
fields[4] = { t = "Param2 type",          x = x, y = inc.y(lineSpacing), sp = x + sp }
fields[5] = { t = "Param2 value",         x = x, y = inc.y(lineSpacing), sp = x + sp }
fields[6] = { t = "Param3 type",          x = x, y = inc.y(lineSpacing), sp = x + sp }
fields[7] = { t = "Param3 value",         x = x, y = inc.y(lineSpacing), sp = x + sp }

local function setValues()
    fields[1].data = pilotConfig.model_id
    fields[2].data = pilotConfig.model_param1_type
    fields[3].data = pilotConfig.model_param1_value
    fields[4].data = pilotConfig.model_param2_type
    fields[5].data = pilotConfig.model_param2_value
    fields[6].data = pilotConfig.model_param3_type
    fields[7].data = pilotConfig.model_param3_value
end

local function onReceivedPilotConfig(page, config)
    pilotConfig = config
    setValues()
    page.isReady = true
end

local function pilotConfigReset()
    -- Reset FM8-GV9, see background.lua
    model.setGlobalVariable(8, 8, 0)
end

return {
    read = function(self)
        mspPilotConfig.getPilotConfig(onReceivedPilotConfig, self)
    end,
    write = function(self)
        mspPilotConfig.setPilotConfig(pilotConfig)
        pilotConfigReset()
        rf2.settingsSaved()
    end,
    title       = "Model",
    reboot      = false,
    eepromWrite = true,
    labels      = labels,
    fields      = fields
}
