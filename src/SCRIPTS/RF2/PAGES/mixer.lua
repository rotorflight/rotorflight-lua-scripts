local template = rf2.executeScript(rf2.radio.template)
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
local mixerConfig = rf2.useApi("mspMixer").getDefaults()
local mixerOverride = false

local function onClickOverride(field, page)
    if not mixerOverride then
        mixerOverride = true
        field.t = "[Disable Mixer Passthrough]"
    else
        mixerOverride = false
        field.t = "[Enable Mixer Passthrough]"
    end

    local mspMixer = rf2.useApi("mspMixer")
    for i = 1, 4 do
        if mixerOverride then
            mspMixer.enableOverride(i)
        else
            mspMixer.disableOverride(i)
        end
    end
end

labels[#labels + 1] = { t = "Swashplate",               x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Geo correction",           x = x + indent, y = incY(lineSpacing), sp = x + sp, data = mixerConfig.swash_geo_correction,  id = "mixerCollectiveGeoCorrection" }
fields[#fields + 1] = { t = "Total pitch limit",        x = x + indent, y = incY(lineSpacing), sp = x + sp, data = mixerConfig.swash_pitch_limit,     id = "mixerTotalPitchLimit" }
fields[#fields + 1] = { t = "Phase angle",              x = x + indent, y = incY(lineSpacing), sp = x + sp, data = mixerConfig.swash_phase,           id = "mixerSwashPhase" }
if rf2.apiVersion >= 12.08 then
    fields[#fields + 1] = { t = "Pos coll tilt corr",   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = mixerConfig.collective_tilt_correction_pos }
    fields[#fields + 1] = { t = "Neg coll tilt corr",   x = x + indent, y = incY(lineSpacing), sp = x + sp, data = mixerConfig.collective_tilt_correction_neg }
end
fields[#fields + 1] = { t = "TTA precomp",              x = x + indent, y = incY(lineSpacing), sp = x + sp, data = mixerConfig.swash_tta_precomp }

incY(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Swashplate Link Trims",    x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Roll trim",                x = x + indent, y = incY(lineSpacing), sp = x + sp, data = mixerConfig.swash_trim_roll,       id = "mixerSwashRollTrim" }
fields[#fields + 1] = { t = "Pitch trim",               x = x + indent, y = incY(lineSpacing), sp = x + sp, data = mixerConfig.swash_trim_pitch,      id = "mixerSwashPitchTrim" }
fields[#fields + 1] = { t = "Coll. trim",               x = x + indent, y = incY(lineSpacing), sp = x + sp, data = mixerConfig.swash_trim_collective, id = "mixerSwashCollectiveTrim" }

incY(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Motorised Tail",           x = x,          y = incY(lineSpacing) }
fields[#fields + 1] = { t = "Motor idle thrott",        x = x + indent, y = incY(lineSpacing), sp = x + sp, data = mixerConfig.tail_motor_idle,       id = "mixerTailMotorIdle" }
fields[#fields + 1] = { t = "Center trim",              x = x + indent, y = incY(lineSpacing), sp = x + sp, data = mixerConfig.tail_center_trim,      id = "mixerTailRotorCenterTrim" }

if rf2.apiVersion >= 12.08 then
    incY(lineSpacing * 0.5)

    fields[#fields + 1] = { t = "[Enable Mixer Passthrough]", x = x,    y = incY(lineSpacing), w = 250, preEdit = onClickOverride }
end

local function receivedMixerConfig(page, _)
    rf2.onPageReady(page)
end

return {
    read = function(self)
        rf2.useApi("mspMixer").read(receivedMixerConfig, self, mixerConfig)
    end,
    write = function(self)
        rf2.useApi("mspMixer").write(mixerConfig)
        rf2.settingsSaved(true, false)
    end,
    title       = "Mixer",
    labels      = labels,
    fields      = fields
}
