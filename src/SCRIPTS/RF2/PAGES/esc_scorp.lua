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
    [0] = "Heli Governor",
    "Heli Governor (stored)",
    "VBar Governor",
    "External Governor",
    "Airplane mode",
    "Boat mode",
    "Quad mode",
}

local rotation = {
    [0] = "CCW",
    "CW",
}

local becVoltage = {
    [0] = "5.1V",
    "6.1V",
    "7.3V",
    "8.3V",
    "Disabled",
}

local teleProtocol = {
    [0] = "Standard",
    "VBar",
    "Jeti Exbus",
    "Unsolicited",
    "Futaba SBUS",
}

local onOff = {
    [0] = "On",
    "Off"
}

labels[1] = { t = "ESC not ready, waiting...", x = x,      y = inc.y(lineSpacing) }
labels[2] = { t = "---",                   x = x + indent, y = inc.y(lineSpacing), bold = false }
labels[3] = { t = "---",                   x = x + indent, y = inc.y(lineSpacing), bold = false }

--- Basic
fields[1] = { t = "Flight Mode",           x = x,          y = inc.y(lineSpacing * 2), sp = x + sp, min = 0, max = #flightMode, vals = { 2+33, 2+34 }, table = flightMode }
fields[2] = { t = "Rotation",              x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #rotation, vals = { 2+37, 2+38 }, table = rotation }
fields[3] = { t = "Telemetry Protocol",    x = x ,         y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #teleProtocol, vals = { 2+39, 2+40 }, table = teleProtocol }
fields[4] = { t = "Startup Sound",         x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #onOff, vals = { 2+53, 2+54 }, table = onOff }
fields[5] = { t = "BEC Voltage",           x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #becVoltage, vals = { 2+35, 2+36 }, table = becVoltage }

labels[4] = { t = "Governor",              x = x,          y = inc.y(lineSpacing * 2) }
fields[6] = { t = "P-Gain",                x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 30,  max = 180, scale = 100, vals = { 2+67, 2+68, 2+69, 2+70 } }
fields[7] = { t = "I-Gain",                x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 150, max = 250, scale = 100, vals = { 2+71, 2+72, 2+73, 2+74 } }

-- Advanced
labels[5] = { t = "Soft Start",            x = x,          y = inc.y(lineSpacing) }
fields[8] = { t = "Start Time (s)",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 60000,  scale = 1000, mult = 100, vals = { 2+61, 2+62 } }
fields[9] = { t = "Runup Time (s)",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 60000,  scale = 1000, mult = 100, vals = { 2+63, 2+64 } }
fields[10] = { t = "Bailout (s)",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100000, scale = 1000, mult = 100, vals = { 2+65, 2+66 } }

-- dont appear to be populated
-- fields[#fields + 1] = { t = "Stick Zero (us)",        x = x + indent, y = inc.y(lineSpacing * 2), sp = x + sp, vals = { 79, 80, 81, 82 } }
-- fields[#fields + 1] = { t = "Stick Max (us)",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, vals = { 75, 76, 77, 78 } }

-- Protection
labels[6] = { t = "Protection",            x = x,          y = inc.y(lineSpacing) }
fields[11] = { t = "Protection Delay (s)", x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 5000,  scale = 1000, mult = 100, vals = { 2+41, 2+42 } }
fields[12] = { t = "Cutoff Handling (%)",  x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 10000, scale = 100,  mult = 100, vals = { 2+49, 2+50 } }
fields[13] = { t = "Max Temp (C)",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 40000, scale = 100,  mult = 100, vals = { 2+45, 2+46 } }
fields[14] = { t = "Max Current (A)",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 30000, scale = 100,  mult = 100, vals = { 2+47, 2+48 } }
fields[15] = { t = "Min Voltage (V)",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 7000,  scale = 100,  mult = 10, vals = { 2+43, 2+44 } }
fields[16] = { t = "Max Used (Ah)",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 6000,  scale = 100,  mult = 10, vals = { 2+51, 2+52 } }

local function rebootEsc(field, page)
    page.values[2] = 0x80
    rf2.saveSettings()
end
fields[17] = { t = "[Reboot ESC]",         x = x + indent * 3, y = inc.y(lineSpacing * 1.3), preEdit = rebootEsc }

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

local function getUInt(array, vals)
    local v = 0
    for idx = 1, #vals do
        local raw_val = array[vals[idx]] or 0
        raw_val = bit32.lshift(raw_val, (idx-1)*8)
        v = bit32.bor(v, raw_val)
    end
    return v
end

return {
    read        = 217, -- MSP_ESC_PARAMETERS
    write       = 218, -- MSP_SET_ESC_PARAMETERS
    eepromWrite = false,
    reboot      = false,
    title       = "Scorpion Setup",
    minBytes    = 3, -- 84,
    labels      = labels,
    fields      = fields,
    values      = nil,
    readOnly    = true,
    simulatorResponse = { 83, 128, 84, 114, 105, 98, 117, 110, 117, 115, 32, 69, 83, 67, 45, 54, 83, 45, 56, 48, 65, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, 3, 0, 3, 0, 1, 0, 3, 0, 136, 19, 22, 3, 16, 39, 64, 31, 136, 19, 0, 0, 1, 0, 7, 2, 0, 6, 63, 0, 160, 15, 64, 31, 208, 7, 100, 0, 0, 0, 200, 0, 0, 0, 1, 0, 0, 0, 200, 250, 0, 0 },

    postRead = function(self)
        if self.values[1] ~= 0x53 then -- Scorpion signature
            self.labels[1].t = "Invalid ESC detected"
            return -1
        end

        -- The 'ability to reboot' flag is only available on Scorpion ESCs. Not used at the moment.
        self.canReboot = bit32.band(self.values[2], 0x80) == 0x80
        if not self.canReboot then
            self.fields[17].readOnly = true
        end

        self.values[2] = 0 -- prevent rebooting when saving
        self.isReady = true
    end,

    postLoad = function(self)
        -- esc type
        local l = self.labels[1]
        l.t = getText(self.values, 3, 32)

        -- SN
        l = self.labels[2]
        l.t = string.format("S/N: %08X", getUInt(self.values, { 2+55, 2+56, 2+57, 2+58 }))

        -- FW version
        l = self.labels[3]
        l.t = "FW: v"..getUInt(self.values, { 2+59, 2+60 })

        -- enable 'Save Page'
        self.readOnly = false
    end,
}
