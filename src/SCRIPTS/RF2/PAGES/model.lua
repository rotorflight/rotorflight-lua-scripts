local template = rf2.executeScript(rf2.radio.template)
local settings = rf2.loadSettings()
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
local modelName = "---"
local flighStats = rf2.useApi("mspFlightStats").getDefaults()
local pilotConfig = rf2.useApi("mspPilotConfig").getDefaults()
local setNameOnTxFieldIndex
local t = rf2.i18n.t

local function buildForm(page)
    page.labels = nil
    page.fields = nil
    labels = {}
    fields = {}
    collectgarbage()

    x = margin
    y = yMinLim - tableSpacing.header

    labels[#labels + 1] = { t = modelName,      x = x, y = incY(lineSpacing) }
    fields[#fields + 1] = { t = t("Model_ID"),  x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_id }

    if rf2.apiVersion >= 12.09 then
        incY(lineSpacing * 0.5)
        labels[#labels + 1] = { t = t("Model_Stats"),     x = x, y = incY(lineSpacing) }
        fields[#fields + 1] = { t = t("Model_Stats_Enabled"), x = x, y = incY(lineSpacing), sp = x + sp, data = flighStats.statsEnabled,
            postEdit = function(self, page)
                if self.data.value == 0 then
                    flighStats.stats_min_armed_time_s.value = -1   -- stats disabled
                else
                    flighStats.stats_min_armed_time_s.value = 15   -- >= 15s armed counts as a flight
                end
                buildForm(page)
                rf2.onPageReady(page)
            end
        }

        if flighStats.statsEnabled.value and flighStats.statsEnabled.value == 1 then
            fields[#fields + 1] = { t = t("Model_Total_Flights"), x = x, y = incY(lineSpacing), sp = x + sp, data = flighStats.stats_total_flights, readOnly = true }

            local function formatSeconds(seconds)
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
            local totalTime = formatSeconds(flighStats.stats_total_time_s.value)
            fields[#fields + 1] = { t = t("Model_Total_Time"), x = x, y = incY(lineSpacing), sp = x + sp, data = { value = totalTime }, readOnly = true  }

            fields[#fields + 1] = { t = t("Model_Total_Dist"), x = x, y = incY(lineSpacing), sp = x + sp, data = flighStats.stats_total_dist_m, readOnly = true  }
            fields[#fields + 1] = { t = t("Model_Min_Armed_Time"), x = x, y = incY(lineSpacing), sp = x + sp, data = flighStats.stats_min_armed_time_s }

            local function resetStats(self, page)
                flighStats.stats_total_flights.value = 0
                flighStats.stats_total_time_s.value = 0
                flighStats.stats_total_dist_m.value = 0
                buildForm(page)
                rf2.onPageReady(page)
            end
            fields[#fields + 1] = { t = t("Model_Reset_Stats"), x = x + indent * 3, y = incY(lineSpacing * 1.3), preEdit = resetStats }
        end
    end

    incY(lineSpacing * 0.5)
    labels[#labels + 1] = { t = t("Model_Radio_Config"),     x = x, y = incY(lineSpacing) }
    labels[#labels + 1] = { t = t("Model_Requires_Rf2bg"),   x = x + indent, y = incY(lineSpacing), bold = false }

    local function getAutoSetName()
        if rf2.apiVersion >= 12.07 and rf2.apiVersion < 12.09 then
            return settings.autoSetName or 0
        end
        local getBit = rf2.executeScript("F/getBit")
        return getBit(pilotConfig.model_flags.value, pilotConfig.model_flags.MODEL_SET_NAME) or 0
    end
    incY(lineSpacing * 0.25)
    setNameOnTxFieldIndex = #fields + 1
    fields[setNameOnTxFieldIndex] = { t = t("Model_Set_Name_Tx"), x = x, y = incY(lineSpacing), sp = x + sp, data = { value = getAutoSetName() or 0, min = 0, max = 1, table = { [0] = "Off", "On" } } }

    incY(lineSpacing * 0.25)
    fields[#fields + 1] = { t = t("Model_Param") .. " 1 " .. t("Model_Type"),  x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param1_type }
    fields[#fields + 1] = { t = t("Model_Param") .. " 1 " .. t("Model_Value"), x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param1_value }
    fields[#fields + 1] = { t = t("Model_Param") .. " 2 " .. t("Model_Type"),  x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param2_type }
    fields[#fields + 1] = { t = t("Model_Param") .. " 2 " .. t("Model_Value"), x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param2_value }
    fields[#fields + 1] = { t = t("Model_Param") .. " 3 " .. t("Model_Type"),  x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param3_type }
    fields[#fields + 1] = { t = t("Model_Param") .. " 3 " .. t("Model_Value"), x = x, y = incY(lineSpacing), sp = x + sp, data = pilotConfig.model_param3_value }

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

local function setAutoSetName()
    local autoSetName = fields[setNameOnTxFieldIndex].data.value
    if rf2.apiVersion >= 12.07 and rf2.apiVersion < 12.09 then
        settings.autoSetName = autoSetName
        rf2.saveSettings(settings)
        return
    end

    local setBit = rf2.executeScript("F/setBit")
    pilotConfig.model_flags.value = setBit(pilotConfig.model_flags.value, pilotConfig.model_flags.MODEL_SET_NAME, autoSetName)
end

return {
    read = function(self)
        rf2.useApi("mspName").getModelName(onReceivedModelName, self)
        if rf2.apiVersion >= 12.09 then
            rf2.useApi("mspFlightStats").read(nil, nil, flighStats)
        end
        rf2.useApi("mspPilotConfig").read(onReceivedPilotConfig, self, pilotConfig)
    end,
    write = function(self)
        setAutoSetName()
        if rf2.apiVersion >= 12.09 then
            rf2.useApi("mspFlightStats").write(flighStats)
        end
        rf2.useApi("mspPilotConfig").write(pilotConfig)
        rf2.executeScript("F/pilotConfigReset")()
        rf2.settingsSaved(true, false)
    end,
    title       = "Model",
    labels      = labels,
    fields      = fields
}
