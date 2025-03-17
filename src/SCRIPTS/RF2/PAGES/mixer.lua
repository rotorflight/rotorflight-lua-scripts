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
local mspMixer = rf2.useApi("mspMixer")
local mixerConfig = mspMixer.getDefaults()

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
        field.t = "[Enable Mixer Passthrough]"
    end

    for i = 1, 4 do
        if mixerOverride then
            enableMixerOverride(i)
        else
            disableMixerOverride(i)
        end
    end
end

labels[#labels + 1] = { t = "Swashplate",               x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Geo correction",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = mixerConfig.swash_geo_correction,  id = "mixerCollectiveGeoCorrection" }
fields[#fields + 1] = { t = "Total pitch limit",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = mixerConfig.swash_pitch_limit,     id = "mixerTotalPitchLimit" }
fields[#fields + 1] = { t = "Phase angle",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = mixerConfig.swash_phase,           id = "mixerSwashPhase" }
fields[#fields + 1] = { t = "TTA precomp",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = mixerConfig.swash_tta_precomp }

inc.y(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Swashplate Link Trims",    x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Roll trim",                x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = mixerConfig.swash_trim_roll,       id = "mixerSwashRollTrim" }
fields[#fields + 1] = { t = "Pitch trim",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = mixerConfig.swash_trim_pitch,      id = "mixerSwashPitchTrim" }
fields[#fields + 1] = { t = "Coll. trim",               x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = mixerConfig.swash_trim_collective, id = "mixerSwashCollectiveTrim" }

inc.y(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Motorised Tail",           x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Motor idle thr",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = mixerConfig.tail_motor_idle,       id = "mixerTailMotorIdle" }
fields[#fields + 1] = { t = "Center trim",              x = x + indent, y = inc.y(lineSpacing), sp = x + sp, data = mixerConfig.tail_center_trim,      id = "mixerTailRotorCenterTrim" }

if rf2.apiVersion >= 12.08 then
    inc.y(lineSpacing * 0.5)
    fields[#fields + 1] = { t = "[Enable Mixer Passthrough]", x = x,    y = inc.y(lineSpacing), preEdit = onClickOverride }
end

local function receivedMixerConfig(page)
    rf2.lcdNeedsInvalidate = true
    page.isReady = true
end

return {
    read = function(self)
        mspMixer.read(mixerConfig, receivedMixerConfig, self)
    end,
    write = function(self)
        mspMixer.write(mixerConfig)
        rf2.settingsSaved()
    end,
    eepromWrite = true,
    reboot      = false,
    title       = "Mixer",
    labels      = labels,
    fields      = fields
}
