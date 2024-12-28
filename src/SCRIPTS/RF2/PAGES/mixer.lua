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

labels[#labels + 1] = { t = "Swashplate",               x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Geo correction",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -125,  max = 125,  vals = { 19 }, scale = 5,      id = "mixerCollectiveGeoCorrection" }
fields[#fields + 1] = { t = "Total pitch limit",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0,     max = 3000, vals = { 10, 11 }, scale = 83.33333333333333, mult = 8.3333333333333, id = "mixerTotalPitchLimit" }
fields[#fields + 1] = { t = "Phase angle",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -1800, max = 1800, vals = { 8, 9 }, scale = 10, mult = 5, id = "mixerSwashPhase" }
fields[#fields + 1] = { t = "TTA precomp",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0,     max = 250,  vals = { 18 } }

inc.y(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Swashplate Link Trims",    x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Roll trim %",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -1000, max = 1000, vals = { 12, 13 }, scale = 10, id = "mixerSwashRollTrim" }
fields[#fields + 1] = { t = "Pitch trim %",             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -1000, max = 1000, vals = { 14, 15 }, scale = 10, id = "mixerSwashPitchTrim" }
fields[#fields + 1] = { t = "Coll. trim %",             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -1000, max = 1000, vals = { 16, 17 }, scale = 10, id = "mixerSwashCollectiveTrim" }

inc.y(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Motorised Tail",           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Motor idle thr%",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0,     max = 250,  vals = { 3 }, scale = 10,      id = "mixerTailMotorIdle" }
fields[#fields + 1] = { t = "Center trim",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -500,  max = 500,  vals = { 4,5 }, scale = 10,    id = "mixerTailRotorCenterTrim" }

local mixerOverride = false
local function disableMixerOverride(mixerIndex)
    local message = {
        command = 191, -- MSP_SET_MIXER_OVERRIDE
        payload = { mixerIndex }
    }
    rf2.mspHelper.writeU16(message.payload, 2501)
    rf2.mspQueue:add(message)
end

local function enableMixerOverride(mixerIndex)
    local message = {
        command = 191, -- MSP_SET_MIXER_OVERRIDE
        payload = { mixerIndex }
    }
    rf2.mspHelper.writeU16(message.payload, 2502)
    rf2.mspQueue:add(message)
end
local function onClickOverride(field, page)
    if not mixerOverride then
        mixerOverride = true
        field.t = "[Disable Mixer Passthrough]"
    else
        mixerOverride = false
        field.t = "[Mixer Passthrough Override]"
    end

    for i = 1, 4 do
        if mixerOverride then
            enableMixerOverride(i)
        else
            disableMixerOverride(i)
        end
    end
end

inc.y(lineSpacing * 0.25)
fields[#fields + 1] = { t = "[Mixer Passthrough Override]", x = x + indent * 2, y = inc.y(lineSpacing), preEdit = onClickOverride }

return {
    read        = 42, -- MSP_MIXER_CONFIG
    write       = 43, -- MSP_SET_MIXER_CONFIG
    eepromWrite = true,
    reboot      = false,
    title       = "Mixer",
    minBytes    = 19,
    labels      = labels,
    fields      = fields,
    postLoad    = function(self)
        self.isReady     = true
    end,
    simulatorResponse = { 0, 0, 0, 0, 0, 2, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
}
