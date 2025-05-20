-- Note: voice files were made with Balabolka and the Microsoft Zira voice.

local adjustmentCollector
local timeLastChange = -1
local timeExitTool
local adjfuncIdChanged
local adjfuncValueChanged
local currentAdjfuncId
local currentAdjfuncValue


local adjfunctions = {
    -- see src/main/fc/rc_adjustments.h

    -- rates
    id5 =  { name = "Pitch Rate", wavs = { "pitch", "rate" } },
    id6 =  { name = "Roll Rate", wavs = { "roll", "rate" } },
    id7 =  { name = "Yaw Rate", wavs = { "yaw", "rate" } },
    id8 =  { name = "Pitch RC Rate", wavs = { "pitch", "rc", "rate" } },
    id9 =  { name = "Roll RC Rate", wavs = { "roll", "rc", "rate" } },
    id10 = { name = "Yaw RC Rate", wavs = { "yaw", "rc", "rate" } },
    id11 = { name = "Pitch RC Expo", wavs = { "pitch", "rc", "expo" } },
    id12 = { name = "Roll RC Expo", wavs = { "roll", "rc", "expo" } },
    id13 = { name = "Yaw RC Expo", wavs = { "yaw", "rc", "expo" } },

    -- pids
    id14 = { name = "Pitch P Gain", wavs = { "pitch", "p", "gain" } },
    id15 = { name = "Pitch I Gain", wavs = { "pitch", "i", "gain" } },
    id16 = { name = "Pitch D Gain", wavs = { "pitch", "d", "gain" } },
    id17 = { name = "Pitch F Gain", wavs = { "pitch", "f", "gain" } },
    id18 = { name = "Roll P Gain", wavs = { "roll", "p", "gain" } },
    id19 = { name = "Roll I Gain", wavs = { "roll", "i", "gain" } },
    id20 = { name = "Roll D Gain", wavs = { "roll", "d", "gain" } },
    id21 = { name = "Roll F Gain", wavs = { "roll", "f", "gain" } },
    id22 = { name = "Yaw P Gain", wavs = { "yaw", "p", "gain" } },
    id23 = { name = "Yaw I Gain", wavs = { "yaw", "i", "gain" } },
    id24 = { name = "Yaw D Gain", wavs = { "yaw", "d", "gain" } },
    id25 = { name = "Yaw F Gain", wavs = { "yaw", "f", "gain" } },

    id26 = { name = "Yaw CW Gain", wavs = { "yaw", "cw", "gain" } },
    id27 = { name = "Yaw CCW Gain", wavs = { "yaw", "ccw", "gain" } },
    id28 = { name = "Yaw Cyclic FF", wavs = { "yaw", "cyclic", "ff" } },
    id29 = { name = "Yaw Coll FF", wavs = { "yaw", "collective", "ff" } },
    id30 = { name = "Yaw Coll Dyn", wavs = { "yaw", "collective", "dyn" } },
    id31 = { name = "Yaw Coll Decay", wavs = { "yaw", "collective", "decay" } },
    id32 = { name = "Pitch Coll FF", wavs = { "pitch", "collective", "ff" } },

    -- gyro cutoffs
    id33 = { name = "Pitch Gyro Cutoff", wavs = { "pitch", "gyro", "cutoff" } },
    id34 = { name = "Roll Gyro Cutoff", wavs = { "roll", "gyro", "cutoff" } },
    id35 = { name = "Yaw Gyro Cutoff", wavs = { "yaw", "gyro", "cutoff" } },

    -- dterm cutoffs
    id36 = { name = "Pitch D-term Cutoff", wavs = { "pitch", "dterm", "cutoff" } },
    id37 = { name = "Roll D-term Cutoff", wavs = { "roll", "dterm", "cutoff" } },
    id38 = { name = "Yaw D-term Cutoff", wavs = { "yaw", "dterm", "cutoff" } },

    -- rescue
    id39 = { name = "Rescue Climb Coll", wavs = { "rescue", "climb", "collective" } },
    id40 = { name = "Rescue Hover Coll", wavs = { "rescue", "hover", "collective" } },
    id41 = { name = "Rescue Hover Alt", wavs = { "rescue", "hover", "alt" } },
    id42 = { name = "Rescue Alt P Gain", wavs = { "rescue", "alt", "p", "gain" } },
    id43 = { name = "Rescue Alt I Gain", wavs = { "rescue", "alt", "i", "gain" } },
    id44 = { name = "Rescue Alt D Gain", wavs = { "rescue", "alt", "d", "gain" } },

    -- leveling
    id45 = { name = "Angle Level Gain", wavs = { "angle", "level", "gain" } },
    id46 = { name = "Horizon Level Gain", wavs = { "horizon", "level", "gain" } },
    id47 = { name = "Acro Trainer Gain", wavs = { "acro", "gain" } },

    -- governor
    id48 = { name = "Governor Gain", wavs = { "gov", "gain" } },
    id49 = { name = "Governor P Gain", wavs = { "gov", "p", "gain" } },
    id50 = { name = "Governor I Gain", wavs = { "gov", "i", "gain" } },
    id51 = { name = "Governor D Gain", wavs = { "gov", "d", "gain" } },
    id52 = { name = "Governor F Gain", wavs = { "gov", "f", "gain" } },
    id53 = { name = "Governor TTA Gain", wavs = { "gov", "tta", "gain" } },
    id54 = { name = "Governor Cyclic FF", wavs = { "gov", "cyclic", "ff" } },
    id55 = { name = "Governor Coll FF", wavs = { "gov", "collective", "ff" } },

    -- boost gains
    id56 = { name = "Pitch B Gain", wavs = { "pitch", "b", "gain" } },
    id57 = { name = "Roll B Gain", wavs = { "roll", "b", "gain" } },
    id58 = { name = "Yaw B Gain", wavs = { "yaw", "b", "gain" } },

    -- offset gains
    id59 = { name = "Pitch O Gain", wavs = { "pitch", "o", "gain" } },
    id60 = { name = "Roll O Gain", wavs = { "roll", "o", "gain" } },

    -- cross-coupling
    id61 = { name = "Cross Coup Gain", wavs = { "crossc", "gain" } },
    id62 = { name = "Cross Coup Ratio", wavs = { "crossc", "ratio" } },
    id63 = { name = "Cross Coup Cutoff", wavs = { "crossc", "cutoff" } },

    -- accelerometer
    id64 = { name = "Accelerometer Pitch Trim", wavs = { "accpitchtrim" } },
    id65 = { name = "Accelerometer Roll Trim", wavs = { "accrolltrim" } },

    -- Yaw Inertia precomp
    id66 = { name = "Yaw Inertia Precomp Gain", wavs = { "ya-in-pr-ga" } },
    id67 = { name = "Yaw Inertia Precomp Cutoff", wavs = { "ya-in-pr-cu" } },

    -- Setpoint boost
    id68 = { name = "Pitch Setpoint Boost Gain", wavs = { "pi-se-bo-ga" } },
    id69 = { name = "Roll Setpoint Boost Gain", wavs = { "ro-se-bo-ga" } },
    id70 = { name = "Yaw Setpoint Boost Gain", wavs = { "ya-se-bo-ga" } },
    id71 = { name = "Collective Setpoint Boost Gain", wavs = { "co-se-bo-ga" } },

    -- Yaw dynamic deadband
    id72 = { name = "Yaw Dynamic Ceiling Gain", wavs = { "ya-dy-ce-ga" } },
    id73 = { name = "Yaw Dynamic Deadband Gain", wavs = { "ya-dy-de-ga" } },
    id74 = { name = "Yaw Dynamic Deadband Filter", wavs = { "ya-dy-de-fi" } },

    -- Precomp cutoff
    id75 = { name = "Yaw Precomp Cutoff", wavs = { "ya-pr-cu" } },
}

local function drawTextMultiline(x, y, text, options)
    local lineSpacing = (LCD_W < 320) and 10 or 25
    for str in string.gmatch(text, "([^\n]+)") do
        lcd.drawText(x, y, str, options)
        y = y + lineSpacing
    end
end

local function getTelemetryId(name)
    local field = getFieldInfo(name)
    if field then
      return field.id
    else
      return -1
    end
end

local function showValue(v)
    lcd.clear()
    drawTextMultiline(1, 1, tostring(v), 0)
end

local sportAdjustmentsCollector = {}
sportAdjustmentsCollector.__index = sportAdjustmentsCollector

function sportAdjustmentsCollector:new(idSensorName, valueSensorName)
    local self = setmetatable({}, sportAdjustmentsCollector)
    self.adjfuncId = 0
    self.adjfuncValue = 0
    self.adjfuncIdSensorId = getTelemetryId(idSensorName)
    if self.adjfuncIdSensorId == -1 then
        self.initFailedMessage = "No "..idSensorName.." sensor found"
        return self
    end
    self.adjfuncValueSensorId = getTelemetryId(valueSensorName)
    if self.adjfuncValueSensorId == -1 then
        self.initFailedMessage = "No "..valueSensorName.." sensor found"
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

    self.adjfuncIdSensorId = getTelemetryId("AdjF")
    self.adjfuncValueSensorId = getTelemetryId("AdjV")
    if self.adjfuncIdSensorId == -1 or self.adjfuncValueSensorId == -1 then
        self.flightmodeSensorId = getTelemetryId("FM")
        if self.flightmodeSensorId == -1 then
            self.initFailedMessage = "No sensors found. The\nadjustment teller needs\n- an FM sensor (RF2) or\n- AdjF and AdjV (RF2.1+)"
            return self
        end
    end

    function self:getAdjfuncIdAndValue()
        if self.flightmodeSensorId then
            local fm = getValue(self.flightmodeSensorId)
            local startIndex, _ = string.find(fm, ":")
            if startIndex and startIndex > 1 then
                self.adjfuncId = string.sub(fm, 1, startIndex-1)
                self.adjfuncValue = string.sub(fm, startIndex+1)
            end
        else
            local adjfuncId = getValue(self.adjfuncIdSensorId)
            if adjfuncId ~= 0 then self.adjfuncId = adjfuncId end
            local adjfuncValue = getValue(self.adjfuncValueSensorId)
            if adjfuncValue ~= 0 then self.adjfuncValue = adjfuncValue end
        end
        return self.adjfuncId, self.adjfuncValue
    end
    return self
end

local function init()
    timeLastChange = 0
    adjfuncIdChanged = false
    adjfuncValueChanged = false

    if rf2.runningInSimulator then
        adjustmentCollector = sportAdjustmentsCollector:new("Tmp1", "Tmp2")
    elseif rf2.protocol.mspTransport == "MSP/sp.lua" then
        adjustmentCollector = sportAdjustmentsCollector:new("5110", "5111")
    else
        adjustmentCollector = crsfAdjustmentsCollector:new()
    end

    if adjustmentCollector.initFailedMessage then
        showValue(adjustmentCollector.initFailedMessage)
        timeExitTool = rf2.clock() + 5
        return
    end

    currentAdjfuncId, currentAdjfuncValue = adjustmentCollector:getAdjfuncIdAndValue()

    showValue("Waiting for adjustment...")
end

local function run()
    if timeLastChange == -1 then init() end

    if timeExitTool then
        -- just show message
        if rf2.clock() > timeExitTool then return 2 end
        return 0
    end

    if timeLastChange and rf2.clock() - timeLastChange > 1 then
        timeLastChange = nil

        if adjfuncIdChanged then
            local adjfunction = adjfunctions["id"..currentAdjfuncId]
            if adjfunction ~= nil then
                for index, value in ipairs(adjfunction.wavs) do
                    playFile(rf2.baseDir.."SOUNDS/"..value..".wav")
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
        timeLastChange = rf2.clock()
        local adjfunction = adjfunctions["id"..currentAdjfuncId]
        if adjfunction ~= nil then
            showValue(adjfunction.name..": "..currentAdjfuncValue)
        else
            showValue("Unknown adjfunc "..currentAdjfuncId..": "..currentAdjfuncValue)
        end
    end

    return 0
end

return { run=run }
