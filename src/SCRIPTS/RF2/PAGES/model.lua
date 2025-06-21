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
local setNameOnTxFieldIndex

local function buildForm(page)
    page.labels = nil
    page.fields = nil
    labels = {}
    fields = {}
    collectgarbage()

    x = margin
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = modelName,      x = x, y = incY(lineSpacing) }
    fields[#fields + 1] = { t = "Model ID",     x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_id }

    if rf2.apiVersion >= 12.09 then
        incY(lineSpacing * 0.5)
        labels[#labels + 1] = { t = "Statistics",         x = x, y = incY(lineSpacing) }
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
            fields[#fields + 1] = { t = "Total flights",  x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.stats_total_flights, readOnly = true }

            local formatSeconds = function(seconds)
                local days = math.floor(seconds / 86400)
                seconds = seconds % 86400
                local hours = math.floor(seconds / 3600)
                seconds = seconds % 3600
                local minutes = math.floor(seconds / 60)
                seconds = seconds % 60

                local s = string.format("%02d:%02d:%02d", hours, minutes, seconds)
                if days > 0 then
                    -- e.g. 12d04:30:58
                    return string.format("%dd%s", days, s)
                else
                    -- only 04:30:58
                    return s
                end
            end
            local totalTime = formatSeconds(pilotConfig.stats_total_time_s.value)
            fields[#fields + 1] = { t = "Total time",     x = x, y = incY(lineSpacing), sp = x + sp, data = { value = totalTime }, readOnly = true  }

            fields[#fields + 1] = { t = "Total distance", x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.stats_total_dist_m, readOnly = true  }
            fields[#fields + 1] = { t = "Min armed time", x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.stats_min_armed_time_s }

            local function resetStats(self, page)
                pilotConfig.stats_total_flights.value = 0
                pilotConfig.stats_total_time_s.value = 0
                pilotConfig.stats_total_dist_m.value = 0
                buildForm(page)
                rf2.onPageReady(page)
            end
            fields[#fields + 1] = { t = "[Reset Stats]",  x = x + indent * 3, y = incY(lineSpacing * 1.3), preEdit = resetStats }
        end
    end

    incY(lineSpacing * 0.5)
    labels[#labels + 1] = { t = "Radio Configuration",       x = x, y = incY(lineSpacing) }
    labels[#labels + 1] = { t = "Note: requires rf2bg",   x = x + indent, y = incY(lineSpacing), bold = false }
    incY(lineSpacing * 0.25)
    setNameOnTxFieldIndex = #fields + 1
    fields[setNameOnTxFieldIndex] = { t = "Set name on TX",         x = x, y = incY(lineSpacing), sp = x + sp, data = { value = settings.autoSetName or 0, min = 0, max = 1, table = { [0] = "Off", "On" } } }
    incY(lineSpacing * 0.25)
    fields[#fields + 1] = { t = "Param1 type",  x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param1_type }
    fields[#fields + 1] = { t = "Param1 value", x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param1_value }
    fields[#fields + 1] = { t = "Param2 type",  x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param2_type }
    fields[#fields + 1] = { t = "Param2 value", x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param2_value }
    fields[#fields + 1] = { t = "Param3 type",  x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param3_type }
    fields[#fields + 1] = { t = "Param3 value", x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param3_value }

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
        settings.autoSetName = fields[setNameOnTxFieldIndex].data.value
        settingsHelper.saveSettings(settings)
        pilotConfigReset()
        rf2.settingsSaved(true, false)
    end,
    title       = "Model",
    labels      = labels,
    fields      = fields
}
