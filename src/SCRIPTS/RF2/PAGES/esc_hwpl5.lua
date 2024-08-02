local template = assert(rf2.loadScript(rf2.radio.template))()
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

local flightMode = {
    [0] = "Fixed Wing",
    "Ext Gov",
    "Governor",
    "Gov Store",
}

local rotation = {
    [0] = "CW",
    "CCW",
}

local lipoCellCount = {
    [0] = "Auto",
    "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "11S", "12S", "13S", "14S",
}

local cutoffType = {
    [0] = "Soft",
    "Hard"
}

local cutoffVoltage = {
    [0] = "Disabled",
    "2.8", "2.9", "3.0", "3.1", "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8",
}

local restartTime = {
    [0] = "1s",
    "1.5s",
    "2s",
    "2.5s",
    "3s",
}

local startupPower = {
    [0] = "Level 1",
    "Level 2",
    "Level 3",
    "Level 4",
    "Level 5",
    "Level 6",
    "Level 7",
}

local enabledDisabled = {
    [0] = "Enabled",
    "Disabled",
}

local brakeType = {
    [0] = "Disabled",
    "Normal",
    "Proportional",
    "Reverse"
}

labels[1] = { t = "ESC not ready, waiting...", x = x,   y = inc.y(lineSpacing) }
labels[2] = { t = "---",                x = x + indent, y = inc.y(lineSpacing) }
labels[3] = { t = "---",                x = x + indent, y = inc.y(lineSpacing) }

fields[1] = { t = "Flight Mode",        x = x,          y = inc.y(lineSpacing * 2), sp = x + sp, min = 0, max = #flightMode, vals = { 2+64 }, table = flightMode }
fields[2] = { t = "Rotation",           x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #rotation, vals = { 2+77 }, table = rotation }

labels[4] = { t = "Voltage",            x = x,          y = inc.y(lineSpacing * 2) }
fields[3] = { t = "BEC Voltage",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 54, max = 84, vals = { 2+68 }, scale = 10 }
fields[4] = { t = "Lipo Cell Count",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #lipoCellCount, vals = { 2+65 }, table = lipoCellCount }
fields[5] = { t = "Volt Cutoff Type",   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #cutoffType, vals = { 2+66 }, table = cutoffType }
fields[6] = { t = "Cuttoff Voltage",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #cutoffVoltage, vals = { 2+67 }, table = cutoffVoltage }

labels[5] = { t = "Governor",           x = x,          y = inc.y(lineSpacing) }
fields[7] = { t = "P-Gain",             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 9, vals = { 2+70 } }
fields[8] = { t = "I-Gain",             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 9, vals = { 2+71 } }

labels[6] = { t = "Soft Start",         x = x,          y = inc.y(lineSpacing) }
fields[9] = { t = "Startup Time",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 4, max = 25, vals = { 2+69 } }
fields[10] = { t = "Restart Time",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #restartTime, vals = { 2+73 }, table = restartTime }
fields[11] = { t = "Auto Restart",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 90, vals = { 2+72 } }

labels[7] = { t = "Motor",              x = x,          y = inc.y(lineSpacing) }
fields[12] = { t = "Timing",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 30, vals = { 2+76 } }
fields[13] = { t = "Startup Power",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #startupPower, vals = { 2+79 }, table = startupPower }
fields[14] = { t = "Active Freewheel",  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #enabledDisabled, vals = { 2+78 }, table = enabledDisabled }
fields[15] = { t = "Brake Type",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #brakeType, vals = { 2+74 }, table = brakeType }
fields[16] = { t = "Brake Force %",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100, vals = { 2+75 } }

local function getText(array, start, maxLength)
    local text = ""
    for i = start, start + maxLength - 1 do
        local v = array[i]
        if v == 0 then
            break
        end
        text = text..string.char(v)
    end
    return text
end

return {
    read        = 217, -- MSP_ESC_PARAMETERS
    write       = 218, -- MSP_SET_ESC_PARAMETERS
    eepromWrite = false,
    reboot      = false,
    title       = "Platinum V5 Setup",
    minBytes    = 81,
    labels      = labels,
    fields      = fields,
    simulatorResponse = { 253, 0, 32, 32, 32, 80, 76, 45, 48, 52, 46, 49, 46, 48, 50, 32, 32, 32, 72, 87, 49, 49, 48, 54, 95, 86, 49, 48, 48, 52, 53, 54, 78, 66, 80, 108, 97, 116, 105, 110, 117, 109, 95, 86, 53, 32, 32, 32, 32, 32, 80, 108, 97, 116, 105, 110, 117, 109, 32, 86, 53, 32, 32, 32, 32, 0, 0, 0, 3, 0, 11, 6, 5, 25, 1, 0, 0, 24, 0, 0, 2 },

    postRead = function(self)
        if self.values[1] ~= 0xFD then -- Hobbywing Platinum V5 signature
            self.values = nil
            self.labels[1].t = "Invalid ESC detected"
            return -1
        end
    end,

    postLoad = function(self)
        -- ESC type
        local l = self.labels[1]
        -- local type = getText(self, 2+33, 16)
        l.t = getText(self.values, 2+49, 16)

        -- HW ver
        l = self.labels[2]
        l.t = "HW: "..getText(self.values, 2+17, 16)

        -- FW ver
        l = self.labels[3]
        l.t = "FW:"..getText(self.values, 2+1, 16)

        -- BEC offset
        local f = self.fields[3]
        f.value = f.value + 5.4

        -- Startup Time
        f = self.fields[9]
        f.value = f.value + 4

    end,

    preSave = function (self)
        self.values[2] = 0 -- save cmd

        -- BEC offset
        local f = self.fields[3]
        self.values[f.vals[1]] = f.value * 10 - 54

        -- Startup Time
        f = self.fields[9]
        self.values[f.vals[1]] = f.value - 4

        return self.values
    end,
}
