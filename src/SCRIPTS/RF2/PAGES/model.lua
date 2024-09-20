local template = assert(rf2.loadScript(rf2.radio.template))()
local mspPilotConfig = assert(rf2.loadScript("MSP/mspPilotConfig.lua"))()
local mspName = assert(rf2.loadScript("MSP/mspName.lua"))()
local settingsHelper = assert(rf2.loadScript("PAGES/helpers/settingsHelper.lua"))()
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
local settings = settingsHelper.loadSettings()

x = margin
y = yMinLim - tableSpacing.header

labels[1] = { t = "---",                  x = x, y = inc.y(lineSpacing) }

inc.y(lineSpacing * 0.25)
fields[1] = { t = "Set name on TX",       x = x, y = inc.y(lineSpacing), sp = x + sp }
labels[2] = { t = "Note: requires rf2bg", x = x + indent, y = inc.y(lineSpacing) }

inc.y(lineSpacing * 0.25)
fields[2] = { t = "Model ID",             x = x, y = inc.y(lineSpacing), sp = x + sp }
fields[3] = { t = "Param1 type",          x = x, y = inc.y(lineSpacing), sp = x + sp }
fields[4] = { t = "Param1 value",         x = x, y = inc.y(lineSpacing), sp = x + sp }
fields[5] = { t = "Param2 type",          x = x, y = inc.y(lineSpacing), sp = x + sp }
fields[6] = { t = "Param2 value",         x = x, y = inc.y(lineSpacing), sp = x + sp }
fields[7] = { t = "Param3 type",          x = x, y = inc.y(lineSpacing), sp = x + sp }
fields[8] = { t = "Param3 value",         x = x, y = inc.y(lineSpacing), sp = x + sp }

local function setValues()
    rf2.print("Auto set name" .. (settings.autoSetName or 0))
    fields[1].data = { value = settings.autoSetName or 0, min = 0, max = 1, table = { [0] = "Off", "On" } }
    fields[2].data = pilotConfig.model_id
    fields[3].data = pilotConfig.model_param1_type
    fields[4].data = pilotConfig.model_param1_value
    fields[5].data = pilotConfig.model_param2_type
    fields[6].data = pilotConfig.model_param2_value
    fields[7].data = pilotConfig.model_param3_type
    fields[8].data = pilotConfig.model_param3_value
end

local function onReceivedModelName(page, name)
    labels[1].t = name
    mspName = nil
end

local function onReceivedPilotConfig(page, config)
    pilotConfig = config
    setValues()
    collectgarbage()
    page.isReady = true
end

local function pilotConfigReset()
    -- Reset FM8-GV8, see background.lua
    model.setGlobalVariable(8, 7, 0)
end

return {
    read = function(self)
        mspName.getModelName(onReceivedModelName, self)
        mspPilotConfig.getPilotConfig(onReceivedPilotConfig, self)
    end,
    write = function(self)
        mspPilotConfig.setPilotConfig(pilotConfig)
        settings.autoSetName = fields[1].data.value
        settingsHelper.saveSettings(settings)
        pilotConfigReset()
        rf2.settingsSaved()
    end,
    title       = "Model",
    reboot      = false,
    eepromWrite = true,
    labels      = labels,
    fields      = fields
}
