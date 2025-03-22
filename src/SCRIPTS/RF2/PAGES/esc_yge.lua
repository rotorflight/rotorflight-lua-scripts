local template = assert(rf2.loadScript(rf2.radio.template))()
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

local escType = {
    [848]  = "YGE 35 LVT BEC",
    [1616] = "YGE 65 LVT BEC",
    [2128] = "YGE 85 LVT BEC",
    [2384] = "YGE 95 LVT BEC",
    [4944] = "YGE 135 LVT BEC",
    [2304] = "YGE 90 HVT Opto",
    [4608] = "YGE 120 HVT Opto",
    [5712] = "YGE 165 HVT",
    [8272] = "YGE 205 HVT",
    [8273] = "YGE 205 HVT BEC",
    [4177] = "YGE Aureus 105",
    [4179] = "YGE Aureus 105v2",
    [5025] = "YGE Aureus 135",
    [5027] = "YGE Aureus 135v2",
    [5457] = "YGE Saphir 155",
    [5459] = "YGE Saphir 155v2",
    [4689] = "YGE Saphir 125",
    [4928] = "YGE Opto 135",
    [9552] = "YGE Opto 255",
    [16464]= "YGE Opto 405",
}

local escFlags = {
    spinDirection = 0,
    f3cAuto = 1,
    keepMah = 2,
    bec12v = 3,
}

local escMode = {
    [0] = "Free (Attention!)",
    "Heli Ext Governor",
    "Heli Governor",
    "Heli Governor Store",
    "Aero Glider",
    "Aero Motor",
    "Aero F3A"
}

local direction = {
    [0] = "Normal",
    "Reverse"
}

local cuttoff = {
    [0] = "Off",
    "Slow Down",
    "Cutoff"
}

local cuttoffVoltage = {
    [0] = "2.9V",
    "3.0V",
    "3.1V",
    "3.2V",
    "3.3V",
    "3.4V",
}

local offOn = {
    [0] = "Off",
    "On"
}

local startupResponse = {
    [0] = "Normal",
    "Smooth"
}

local throttleResponse = {
    [0] = "Slow",
    "Medium",
    "Fast",
    "Custom (PC defined)"
}

local motorTiming = {
    [0] = "Auto Normal",
    "Auto Efficient",
    "Auto Power",
    "Auto Extreme",
    "0 deg",
    "6 deg",
    "12 deg",
    "18 deg",
    "24 deg",
    "30 deg",
}

local motorTimingToUI = {
    [0] = 0,
    4,
    5,
    6,
    7,
    8,
    9,
    [16] = 0,
    [17] = 1,
    [18] = 2,
    [19] = 3,
}

local motorTimingFromUI = {
    [0] = 0,
    17,
    18,
    19,
    1,
    2,
    3,
    4,
    5,
    6,
}

local freewheel = {
    [0] = "Off",
    "Auto",
    "*unused*",
    "Always On",
}

local function getEscTypeLabel(values)
    local idx = bit32.bor(bit32.lshift(values[2 + 24], 8), values[2 + 23])
    return escType[idx] or "YGE ESC ("..idx..")"
end

local function getUInt(array, vals)
    local v = 0
    for idx = 1, #vals do
        local raw_val = array[vals[idx]] or 0
        raw_val = bit32.lshift(raw_val, (idx-1)*8)
        v = bit32.bor(v, raw_val)
    end
    return v
end

local function updateRatio(field, page)
    local fm = page.fields[17]
    local fp = page.fields[18]
    local l = page.labels[9]
    local v = fp.value ~= 0 and fm.value / fp.value or 1
    -- update gear ratio label text
    l.t = string.format("%.2f", v)..":1"
end

labels[1] = { t = "ESC not ready, waiting...", x = x,       y = incY(lineSpacing) }
labels[2] = { t = "---",                    x = x + indent, y = incY(lineSpacing), bold = false }
labels[3] = { t = "---",                    x = x + indent, y = incY(lineSpacing), bold = false }

fields[1] = { t = "ESC Mode",               x = x,          y = incY(lineSpacing * 2), sp = x + sp, min = 1, max = #escMode, vals = { 2+3, 2+4 }, table = escMode }
fields[2] = { t = "Direction",              x = x,          y = incY(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 2+53 }, table = direction }
fields[3] = { t = "BEC",                    x = x,          y = incY(lineSpacing), sp = x + sp, min = 55, max = 84, vals = { 2+5, 2+6 }, scale = 10 }

labels[4] = { t = "Protection",             x = x,          y = incY(lineSpacing * 2) }
fields[4] = { t = "Cutoff Handling",        x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 0, max = #cuttoff, vals = { 2+17, 2+18 }, table = cuttoff }
fields[5] = { t = "Cutoff Cell Voltage",    x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 0, max = #cuttoffVoltage, vals = { 2+19, 2+20 }, table = cuttoffVoltage }
fields[6] = { t = "Current Limit (A)",      x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 1, max = 65500, scale = 100, mult = 100, vals = { 2+55, 2+56 } }

-- Advanced
labels[5] = { t = "Advanced",               x = x,          y = incY(lineSpacing) }
fields[7] = { t = "Min Start Power (%)",    x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 0, max = 26, vals = { 2+47, 2+48 } }
fields[8] = { t = "Max Start Power (%)",    x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 0, max = 31, vals = { 2+49, 2+50 } }
fields[9] = { t = "Startup Response",       x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 0, max = #startupResponse, vals = { 2+9, 2+10 }, table = startupResponse }
fields[10] = { t = "Throttle Response",     x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 0, max = #throttleResponse, vals = { 2+15, 2+16 }, table = throttleResponse }
fields[11] = { t = "Motor Timing",          x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 0, max = #motorTiming, vals = { 2+7, 2+8 }, table=motorTiming }
fields[12] = { t = "Active Freewheel",      x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 0, max = #freewheel, vals = { 2+21, 2+22 }, table = freewheel }
fields[13] = { t = "F3C Autorotation",      x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 2+53 }, table = offOn }

-- Other
labels[6] = { t = "Governor",               x = x,          y = incY(lineSpacing) }
fields[14] = { t = "P-Gain",                x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 1, max = 10, vals = { 2+11, 2+12 } }
fields[15] = { t = "I-Gain",                x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 1, max = 10, vals = { 2+13, 2+14 } }

labels[7] = { t = "RPM Settings",           x = x,          y = incY(lineSpacing) }
fields[16] = { t = "Motor Pole Pairs",      x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 1, max = 100, vals = { 2+41, 2+42 } }
fields[17] = { t = "Main Teeth",            x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 1, max = 1800, vals = { 2+45, 2+46 }, change = updateRatio }
fields[18] = { t = "Pinion Teeth",          x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 1, max = 255, vals = { 2+43, 2+44 }, change = updateRatio }
labels[8] =  { t = "Main : Pinion",         x = x + indent, y = incY(lineSpacing), bold = false }
labels[9] =  { t = "1 : 1",                 x = x + sp,     y = y, bold = false }

labels[10] = { t = "Throttle Calibration",  x = x,          y = incY(lineSpacing) }
fields[19] = { t = "Stick Zero (us)",       x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 900, max = 1900, vals = { 2+35, 2+36 } }
fields[20] = { t = "Stick Range (us)",      x = x + indent, y = incY(lineSpacing), sp = x + sp, min = 600, max = 1500, vals = { 2+37, 2+38 } }

return {
    read        = 217, -- MSP_ESC_PARAMETERS
    write       = 218, -- MSP_SET_ESC_PARAMETERS
    eepromWrite = false,
    reboot      = false,
    title       = "YGE ESC",
    minBytes    = 66,
    labels      = labels,
    fields      = fields,
    readOnly    = true,
    simulatorResponse = { 165, 0, 32, 0, 3, 0, 55, 0, 0, 0, 0, 0, 4, 0, 3, 0, 1, 0, 1, 0, 2, 0, 3, 0, 80, 3, 131, 148, 1, 0, 30, 170, 0, 0, 3, 0, 86, 4, 22, 3, 163, 15, 1, 0, 2, 0, 2, 0, 20, 0, 20, 0, 0, 0, 0, 0, 2, 19, 2, 0, 20, 0, 22, 0, 0, 0 },

    svFlags     = 0,

    postRead = function(self)
        if self.values[1] ~= 0xA5 then -- YGE signature
            self.values = nil
            self.labels[1].t = "Invalid ESC detected"
            return -1
        end
        -- The read-only flag is set when the ESC is connected to an RX pin instead of a TX pin in half-duplex mode. Only supported by YGE.
        self.readOnly = bit32.band(self.values[2], 0x40) == 0x40
    end,

    postLoad = function(self)
        -- esc type
        local l = self.labels[1]
        l.t = getEscTypeLabel(self.values)

        -- SN
        l = self.labels[2]
        l.t = "S/N: "..getUInt(self.values, { 2+29, 2+30, 2+31, 2+32 })

        -- FW ver
        l = self.labels[3]
        l.t = string.format("FW: %.5f", getUInt(self.values, { 2+25, 2+26, 2+27, 2+28 }) / 100000)

        -- load flags (use direction field mapping), changed bit will be applied in pre-save
        local f = self.fields[2]
        self.svFlags = self.values[f.vals[1]]

        -- direction (from flags)
        f.value = bit32.extract(self.svFlags, escFlags.spinDirection)

        -- set BEC voltage max [8.4 or 12.3] (from flags)
        f = self.fields[3]
        f.max = bit32.extract(self.svFlags, escFlags.bec12v) == 0 and 84 or 123

        -- motor timing
        local f = self.fields[11]
        local value = bit32.lshift(self.values[f.vals[2]], 8) + self.values[f.vals[1]]
        f.value = motorTimingToUI[value] or 0

        -- F3C autorotation (from flags)
        f = self.fields[13]
        f.value = bit32.extract(self.svFlags, escFlags.f3cAuto)

        -- update gear ratio
        updateRatio(nil, self)

        -- enable 'Save Page'
        self.readOnly = false
    end,

    preSave = function (self)
        -- F3C autorotation
        -- apply bits to saved flags
        local f = self.fields[13]
        self.svFlags = bit32.replace(self.svFlags, f.value, escFlags.f3cAuto)

        -- direction
        -- apply bits to saved flags
        local f = self.fields[2]
        self.svFlags = bit32.replace(self.svFlags, f.value, escFlags.spinDirection)

        -- save flags (use direction field mapping)
        self.values[f.vals[1]] = self.svFlags

        -- motor timing
        f = self.fields[11]
        local value = motorTimingFromUI[f.value] or 0
        self.values[f.vals[1]] = bit32.band(value, 0xFF)
        self.values[f.vals[2]] = bit32.rshift(value, 8)

        return self.values
    end,
}
