local adjustmentCollector
local timeLastChange = -1
local timeExitTool
local adjfuncIdChanged
local adjfuncValueChanged
local currentAdjfuncId
local currentAdjfuncValue


local adjfunctions = {
    -- rates
    id5 = { name = localization.pitch_rate, wavs = { "pitch", "rate" } },
    id6 = { name = localization.roll_rate, wavs = { "roll", "rate" } },
    id7 = { name = localization.yaw_rate, wavs = { "yaw", "rate" } },
    id8 = { name = localization.pitch_rc_rate, wavs = { "pitch", "rc", "rate" } },
    id9 = { name = localization.roll_rc_rate, wavs = { "roll", "rc", "rate" } },
    id10 = { name = localization.yaw_rc_rate, wavs = { "yaw", "rc", "rate" } },
    id11 = { name = localization.pitch_rc_expo, wavs = { "pitch", "rc", "expo" } },
    id12 = { name = localization.roll_rc_expo, wavs = { "roll", "rc", "expo" } },
    id13 = { name = localization.yaw_rc_expo, wavs = { "yaw", "rc", "expo" } },

    -- pids
    id14 = { name = localization.pitch_p_gain, wavs = { "pitch", "p", "gain" } },
    id15 = { name = localization.pitch_i_gain, wavs = { "pitch", "i", "gain" } },
    id16 = { name = localization.pitch_d_gain, wavs = { "pitch", "d", "gain" } },
    id17 = { name = localization.pitch_f_gain, wavs = { "pitch", "f", "gain" } },
    id18 = { name = localization.roll_p_gain, wavs = { "roll", "p", "gain" } },
    id19 = { name = localization.roll_i_gain, wavs = { "roll", "i", "gain" } },
    id20 = { name = localization.roll_d_gain, wavs = { "roll", "d", "gain" } },
    id21 = { name = localization.roll_f_gain, wavs = { "roll", "f", "gain" } },
    id22 = { name = localization.yaw_p_gain, wavs = { "yaw", "p", "gain" } },
    id23 = { name = localization.yaw_i_gain, wavs = { "yaw", "i", "gain" } },
    id24 = { name = localization.yaw_d_gain, wavs = { "yaw", "d", "gain" } },
    id25 = { name = localization.yaw_f_gain, wavs = { "yaw", "f", "gain" } },

    id26 = { name = localization.yaw_cw_gain, wavs = { "yaw", "cw", "gain" } },
    id27 = { name = localization.yaw_ccw_gain, wavs = { "yaw", "ccw", "gain" } },
    id28 = { name = localization.yaw_cyclic_ff, wavs = { "yaw", "cyclic", "ff" } },
    id29 = { name = localization.yaw_coll_ff, wavs = { "yaw", "collective", "ff" } },
    id30 = { name = localization.yaw_coll_dyn, wavs = { "yaw", "collective", "dyn" } },
    id31 = { name = localization.yaw_coll_decay, wavs = { "yaw", "collective", "decay" } },
    id32 = { name = localization.pitch_coll_ff, wavs = { "pitch", "collective", "ff" } },

    -- gyro cutoffs
    id33 = { name = localization.pitch_gyro_cutoff,   wavs = { "pitch", "gyro", "cutoff" } },
    id34 = { name = localization.roll_gyro_cutoff,  wavs = { "roll", "gyro", "cutoff" } },
    id35 = { name = localization.yaw_gyro_cutoff,  wavs = { "yaw", "gyro", "cutoff" } },

    -- dterm cutoffs
    id36 = { name = localization.pitch_d_term_cutoff,  wavs = { "pitch", "dterm", "cutoff" } },
    id37 = { name = localization.roll_d_term_cutoff,  wavs = { "roll", "dterm", "cutoff" } },
    id38 = { name = localization.yaw_d_term_cutoff,  wavs = { "yaw", "dterm", "cutoff" } },

    -- rescue
    id39 = { name = localization.rescue_climb_coll,  wavs = { "rescue", "climb", "collective" } },
    id40 = { name = localization.rescue_hover_coll,  wavs = { "rescue", "hover", "collective" } },
    id41 = { name = localization.rescue_hover_alt,  wavs = { "rescue", "hover", "alt" } },
    id42 = { name = localization.rescue_alt_p_gain,  wavs = { "rescue", "alt", "p", "gain" } },
    id43 = { name = localization.rescue_alt_i_gain,  wavs = { "rescue", "alt", "i", "gain" } },
    id44 = { name = localization.rescue_alt_d_gain,  wavs = { "rescue", "alt", "d", "gain" } },

    -- leveling
    id45 = { name = localization.angle_level_gain,  wavs = { "angle", "level", "gain" } },
    id46 = { name = localization.horizon_level_gain,  wavs = { "horizon", "level", "gain" } },
    id47 = { name = localization.acro_trainer_gain, wavs = { "acro", "gain" } },

    -- governor
    id48 = { name = localization.governor_gain, wavs = { "gov", "gain" } },
    id49 = { name = localization.governor_p_gain, wavs = { "gov", "p", "gain" } },
    id50 = { name = localization.governor_i_gain, wavs = { "gov", "i", "gain" } },
    id51 = { name = localization.governor_d_gain, wavs = { "gov", "d", "gain" } },
    id52 = { name = localization.governor_f_gain, wavs = { "gov", "f", "gain" } },
    id53 = { name = localization.governor_tta_gain, wavs = { "gov", "tta", "gain" } },
    id54 = { name = localization.governor_cyclic_ff, wavs = { "gov", "cyclic", "ff" } },
    id55 = { name = localization.governor_coll_ff, wavs = { "gov", "collective", "ff" } },

    -- boost gains
    id56 = { name = localization.pitch_b_gain, wavs = { "pitch", "b", "gain" } },
    id57 = { name = localization.roll_b_gain, wavs = { "roll", "b", "gain" } },
    id58 = { name = localization.yaw_b_gain, wavs = { "yaw", "b", "gain" } },

    -- offset gains
    id59 = { name = localization.pitch_o_gain, wavs = { "pitch", "o", "gain" } },
    id60 = { name = localization.roll_o_gain, wavs = { "roll", "o", "gain" } },

    -- cross-coupling
    id61 = { name = localization.cross_coup_gain, wavs = { "crossc", "gain" } },
    id62 = { name = localization.cross_coup_ratio, wavs = { "crossc", "ratio" } },
    id63 = { name = localization.cross_coup_cutoff, wavs = { "crossc", "cutoff" } }
}


local function getTelemetryId(name)
    field = getFieldInfo(name)
    if field then
        return field.id
    else
        return -1
    end
end

local function showValue(v)
    lcd.clear()
    lcd.drawText(1, 1, tostring(v), 0)
end

local sportAdjustmentsCollector = {}
sportAdjustmentsCollector.__index = sportAdjustmentsCollector

function sportAdjustmentsCollector:new(idSensorName, valueSensorName)
    local self = setmetatable({}, sportAdjustmentsCollector)
    self.adjfuncId = 0
    self.adjfuncValue = 0
    self.adjfuncIdSensorId = getTelemetryId(idSensorName)
    if self.adjfuncIdSensorId == -1 then
        self.initFailedMessage = "No " .. idSensorName .. " sensor found"
        return self
    end
    self.adjfuncValueSensorId = getTelemetryId(valueSensorName)
    if self.adjfuncValueSensorId == -1 then
        self.initFailedMessage = "No " .. valueSensorName .. " sensor found"
        return self
    end

    function self:getAdjfuncIdAndValue()
        self.adjfuncId = getValue(self.adjfuncIdSensorId)
        self.adjfuncValue = getValue(self.adjfuncValueSensorId)
        return self.adjfuncId, self.adjfuncValue
    end

    return self
end

local crsfAdjustmentsCollector = {}
crsfAdjustmentsCollector.__index = crsfAdjustmentsCollector

function crsfAdjustmentsCollector:new()
    local self = setmetatable({}, crsfAdjustmentsCollector)
    self.adjfuncId = 0
    self.adjfuncValue = 0
    self.flightmodeSensorId = getTelemetryId("FM")
    if self.flightmodeSensorId == -1 then
        self.initFailedMessage = "No FM sensor found"
        return self
    end

    function self:getAdjfuncIdAndValue()
        local fm = getValue(self.flightmodeSensorId)
        local startIndex, _ = string.find(fm, ":")
        if startIndex and startIndex > 1 then
            self.adjfuncId = string.sub(fm, 1, startIndex - 1)
            self.adjfuncValue = string.sub(fm, startIndex + 1)
        end
        return self.adjfuncId, self.adjfuncValue
    end

    return self
end

local function init()
    timeLastChange = 0
    adjfuncIdChanged = false
    adjfuncValueChanged = false

    if runningInSimulator then
        adjustmentCollector = sportAdjustmentsCollector:new("Tmp1", "Tmp2")
    elseif protocol.mspTransport == "MSP/sp.lua" then
        adjustmentCollector = sportAdjustmentsCollector:new("5110", "5111")
    else
        adjustmentCollector = crsfAdjustmentsCollector:new()
    end

    if adjustmentCollector.initFailedMessage then
        showValue(adjustmentCollector.initFailedMessage)
        timeExitTool = getTime() + 200
        return
    end

    currentAdjfuncId, currentAdjfuncValue = adjustmentCollector:getAdjfuncIdAndValue()

    showValue("Waiting for adjustment...")
end

local function run()
    if timeLastChange == -1 then init() end

    if timeExitTool then
        -- just show message
        if getTime() > timeExitTool then return 2 end
        return 0
    end

    if timeLastChange and getTime() - timeLastChange > 100 then
        timeLastChange = nil

        if adjfuncIdChanged then
            adjfunction = adjfunctions["id" .. currentAdjfuncId]
            if adjfunction ~= nil then
                for index, value in ipairs(adjfunction.wavs) do
                    playFile("/SCRIPTS/RF2/SOUNDS/" .. value .. ".wav")
                end
            end
        end

        if adjfuncValueChanged or adjfuncIdChanged then
            playNumber(currentAdjfuncValue, 0, 0)
        end

        adjfuncIdChanged = false
        adjfuncValueChanged = false
    end

    local invalidate = false

    local newAdjfuncId, newAdjfuncValue = adjustmentCollector:getAdjfuncIdAndValue()
    if newAdjfuncId ~= currentAdjfuncId then
        currentAdjfuncId = newAdjfuncId
        adjfuncIdChanged = true
        invalidate = true
    end
    if newAdjfuncValue ~= currentAdjfuncValue then
        currentAdjfuncValue = newAdjfuncValue
        adjfuncValueChanged = true
        invalidate = true
    end

    if invalidate then
        timeLastChange = getTime()
        local adjfunction = adjfunctions["id" .. currentAdjfuncId]
        if adjfunction ~= nil then
            showValue(adjfunction.name .. ": " .. currentAdjfuncValue)
        else
            showValue("Unknown adjfunc " .. currentAdjfuncId .. ": " .. currentAdjfuncValue)
        end
    end

    return 0
end

return { run = run }
