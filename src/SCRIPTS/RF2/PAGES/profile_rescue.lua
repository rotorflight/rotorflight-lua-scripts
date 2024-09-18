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
local profileSwitcher = assert(rf2.loadScript("PAGES/helpers/profileSwitcher.lua"))()

fields[#fields + 1] = { t = "Current PID profile",     x = x,          y = inc.y(lineSpacing), sp = x + sp * 1.17, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = profileSwitcher.startPidEditing, postEdit = profileSwitcher.endPidEditing }

inc.y(lineSpacing * 0.25)
--fields[#fields + 1] = { t = "Enable rescue",     x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2,     vals = { 1 }, table = { [0] = "Off", "On", "Alt hold" } }
fields[#fields + 1] = { t = "Enable rescue",         x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1,     vals = { 1 }, table = { [0] = "Off", "On" } }

inc.y(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Stage 1: Pull-Up",      x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Pull-up collective",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000,  vals = { 9,10 }, mult = 10, scale = 10,   id = "profilesRescuePullupCollective" }
fields[#fields + 1] = { t = "Pull-up time",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 5 }, scale = 10,                 id = "profilesRescuePullupTime" }
fields[#fields + 1] = { t = "Flip to upright",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1,     vals = { 2 }, table = { [0] = "No flip", "Flip" }, id = "profilesRescueFlipMode" }
fields[#fields + 1] = { t = "Flip fail time",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 7 }, scale = 10,                 id = "profilesRescueFlipTime" }
fields[#fields + 1] = { t = "Flip gain",             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 5, max = 250,   vals = { 3 },                             id = "profilesRescueFlipGain" }

inc.y(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Stage 2: Climb",        x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Climb collective",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000,  vals = { 11,12 }, mult = 10, scale = 10,  id = "profilesRescueClimbCollective" }
fields[#fields + 1] = { t = "Climb time",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 6 }, scale = 10,                 id = "profilesRescueClimbTime" }

inc.y(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Stage 3: Hover",        x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Hover collective",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1000,  vals = { 13,14 }, mult = 10, scale = 10,  id = "profilesRescueHoverCollective" }

inc.y(lineSpacing * 0.25)
fields[#fields + 1] = { t = "Exit time",             x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 8 }, scale = 10,                 id = "profilesRescueExitTime" }
fields[#fields + 1] = { t = "Leveling gain",         x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 5, max = 250,   vals = { 4 },                             id = "profilesRescueLevelGain" }
fields[#fields + 1] = { t = "Max leveling rate",     x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 1000,  vals = { 25,26 }, mult = 10,              id = "profilesRescueMaxRate" }
fields[#fields + 1] = { t = "Max leveling accel",    x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 10000, vals = { 27,28 }, mult = 10,              id = "profilesRescueMaxAccel" }
--[[
labels[#labels + 1] = { t = "Altitude hold",         x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Hover altitude",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 10000, vals = { 15,16 }, mult = 10, scale = 100, id = "profilesRescueHoverAltitude" }
fields[#fields + 1] = { t = "P-gain",                x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 10000, vals = { 17,18 },                         id = "profilesRescueAltitudePGain" }
fields[#fields + 1] = { t = "I-gain",                x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 10000, vals = { 19,20 },                         id = "profilesRescueAltitudeIGain" }
fields[#fields + 1] = { t = "D-gain",                x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 10000, vals = { 21,22 },                         id = "profilesRescueAltitudeDGain" }
fields[#fields + 1] = { t = "Max collective",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 1000,  vals = { 23,24 }, mult = 10, scale = 10,  id = "profilesRescueMaxCollective" }
--]]

return {
    read        = 146, -- MSP_RESCUE_PROFILE
    write       = 147, -- MSP_SET_RESCUE_PROFILE
    title       = "Profile - Rescue",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 28,
    labels      = labels,
    fields      = fields,
    simulatorResponse = { 1, 0, 200, 100, 5, 3, 10, 5, 182, 3, 188, 2, 194, 1, 244, 1, 20, 0, 20, 0, 10, 0, 232, 3, 44, 1, 184, 11 },
    profileSwitcher = profileSwitcher,

    postLoad = function(self)
        self.profileSwitcher.getStatus(self)
    end,

    timer = function(self)
        self.profileSwitcher.checkStatus(self)
    end,
}
