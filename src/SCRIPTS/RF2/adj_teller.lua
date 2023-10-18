local timeLastChange = -1
local timeExitTool
local adjfuncIdChanged
local adjfuncValueChanged
local adjfuncIdSensorId
local adjfuncValueSensorId
local currentAdjfuncId
local currentAdjfuncValue


local adjfunctions = {
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
    id63 = { name = "Cross Coup Cutoff", wavs = { "crossc", "cutoff" } }
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

local function init()
    timeLastChange = 0
    adjfuncIdChanged = false
    adjfuncValueChanged = false

    local sensorName
    if runningInSimulator then sensorName = "Tmp1" else sensorName = "5110" end
    adjfuncIdSensorId = getTelemetryId(sensorName)
    if adjfuncIdSensorId == -1 then
        showValue("No "..sensorName.." sensor found")
        timeExitTool = getTime() + 200
        return
    end
    currentAdjfuncId = getValue(adjfuncIdSensorId)

    if runningInSimulator then sensorName = "Tmp2" else sensorName = "5111" end
    adjfuncValueSensorId = getTelemetryId(sensorName)
    if adjfuncValueSensorId == -1 then
        showValue("No "..sensorName.." sensor found")
        timeExitTool = getTime() + 200
        return
    end
    currentAdjfuncValue = getValue(adjfuncValueSensorId)

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
            adjfunction = adjfunctions["id"..currentAdjfuncId]
            if adjfunction ~= nil then
                for index, value in ipairs(adjfunction.wavs) do
                    playFile("/SCRIPTS/RF2/SOUNDS/"..value..".wav")
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

    local newAdjfuncId = getValue(adjfuncIdSensorId)
    if newAdjfuncId ~= currentAdjfuncId then
        currentAdjfuncId = newAdjfuncId
        adjfuncIdChanged = true
        invalidate = true
    end

    local newAdjfuncValue = getValue(adjfuncValueSensorId)
    if newAdjfuncValue ~= currentAdjfuncValue then
        currentAdjfuncValue = newAdjfuncValue
        adjfuncValueChanged = true
        invalidate = true
    end

    if invalidate then
        timeLastChange = getTime()
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
