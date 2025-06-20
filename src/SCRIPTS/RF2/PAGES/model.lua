local template = rf2.executeScript(rf2.radio.template)
local settingsHelper = rf2.executeScript("PAGES/helpers/settingsHelper")
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
local modelName = "---"

--if rf2.statsEnabled == nil then rf2.statsEnabled = false end

-- local function onStatisticsEnabled(self, page)
--     rf2.useApi("mspRcTuning").getRateDefaults(rcTuning, rcTuning.rates_type.value)
--     rebuildForm(self)
--     rf2.onPageReady(page)
-- end

local function buildForm(page)
    page.labels = nil
    page.fields = nil
    labels = {}
    fields = {}
    collectgarbage()

    x = margin
    y = yMinLim - tableSpacing.header

    labels[1] = { t = modelName,                    x = x, y = incY(lineSpacing) }

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

    if rf2.apiVersion >= 12.09 then
        incY(lineSpacing * 0.25)
        labels[3] = { t = "Statistics",                   x = x, y = incY(lineSpacing) }
        fields[#fields + 1] = { t = "Enabled",            x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.statsEnabled,
            postEdit = function(self, page)
                if self.data.value == 0 then
                    pilotConfig.stats_min_armed_time_s.value = -1
                else
                    pilotConfig.stats_min_armed_time_s.value = 15
                end
                buildForm(page)
                rf2.onPageReady(page)
            end
        }
        if pilotConfig.statsEnabled.value and pilotConfig.statsEnabled.value == 1 then
            fields[#fields + 1] = { t = "Min armed time", x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.stats_min_armed_time_s }
            fields[#fields + 1] = { t = "Total flights",  x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.stats_total_flights }
            fields[#fields + 1] = { t = "Total time",     x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.stats_total_time_s }
            fields[#fields + 1] = { t = "Total distance", x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.stats_total_dist_m }
        end
    end

    page.labels = labels
    page.fields = fields
end

local function onReceivedModelName(page, name)
    modelName = name
end

local function onReceivedPilotConfig(page, config)
    buildForm(page)
    rf2.onPageReady(page)
end

local function pilotConfigReset()
    -- Reset FM8-GV8, see background.lua
    model.setGlobalVariable(7, 8, 0)
end

return {
    read = function(self)
        --buildForm(self)
        rf2.useApi("mspName").getModelName(onReceivedModelName, self)
        rf2.useApi("mspPilotConfig").read(onReceivedPilotConfig, self, pilotConfig)
    end,
    write = function(self)
        rf2.useApi("mspPilotConfig").write(pilotConfig)
        settings.autoSetName = fields[1].data.value
        settingsHelper.saveSettings(settings)
        pilotConfigReset()
        rf2.settingsSaved(true, false)
    end,
    title       = "Model",
    labels      = labels,
    fields      = fields
}
