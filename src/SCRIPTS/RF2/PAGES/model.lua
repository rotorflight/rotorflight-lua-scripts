local template = assert(rf2.loadScript(rf2.radio.template))()
local settingsHelper = assert(rf2.loadScript("PAGES/helpers/settingsHelper.lua"))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local function incY(val) y = y + val return y end
local labels = {}
local fields = {}
local pilotConfig = rf2.useApi("mspPilotConfig").getDefaults()
local settings = settingsHelper.loadSettings()

x = margin
y = yMinLim - tableSpacing.header

labels[1] = { t = "---",                    x = x, y = incY(lineSpacing) }

incY(lineSpacing * 0.25)
fields[1] = { t = "Set name on TX",         x = x, y = incY(lineSpacing), sp = x + sp, data = { value = settings.autoSetName or 0, min = 0, max = 1, table = { [0] = "Off", "On" } } }
labels[2] = { t = "Note: requires rf2bg",   x = x + indent, y = incY(lineSpacing) }

incY(lineSpacing * 0.25)
fields[#fields + 1] = { t = "Model ID",     x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_id }
fields[#fields + 1] = { t = "Param1 type",  x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param1_type }
fields[#fields + 1] = { t = "Param1 value", x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param1_value }
fields[#fields + 1] = { t = "Param2 type",  x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param2_type }
fields[#fields + 1] = { t = "Param2 value", x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param2_value }
fields[#fields + 1] = { t = "Param3 type",  x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param3_type }
fields[#fields + 1] = { t = "Param3 value", x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param3_value }

local function onReceivedModelName(page, name)
    labels[1].t = name
end

local function onReceivedPilotConfig(page, config)
    rf2.onPageReady(page)
end

local function pilotConfigReset()
    -- Reset FM8-GV8, see background.lua
    model.setGlobalVariable(7, 8, 0)
end

return {
    read = function(self)
        rf2.useApi("mspName").getModelName(onReceivedModelName, self)
        rf2.useApi("mspPilotConfig").read(onReceivedPilotConfig, self, pilotConfig)
    end,
    write = function(self)
        rf2.useApi("mspPilotConfig").write(pilotConfig)
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
