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
fields[#fields + 1] = { t = "I-term relax type",       x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 2, vals = { 17 }, table = { [0] = "OFF", "RP", "RPY" } }
fields[#fields + 1] = { t = "Cutoff point R",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 100, vals = { 18 } }
fields[#fields + 1] = { t = "Cutoff point P",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 100, vals = { 19 } }
fields[#fields + 1] = { t = "Cutoff point Y",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 100, vals = { 20 } }
-- TODO? toggle 'I-term limits', off = 1000

inc.y(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Main Rotor",              x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Coll to pitch gain",      x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 28 } }
labels[#labels + 1] = { t = "Cross-Coupling",          x = x + indent, y = inc.y(lineSpacing), bold = false }
fields[#fields + 1] = { t = "Gain",                    x = x + indent*2, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 34 } }
fields[#fields + 1] = { t = "Ratio",                   x = x + indent*2, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 35 } }
fields[#fields + 1] = { t = "Cutoff",                  x = x + indent*2, y = inc.y(lineSpacing), sp = x + sp, min = 1, max = 250, vals = { 36 } }

inc.y(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Tail Rotor",              x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "CW stop gain",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 25, max = 250, vals = { 21 } }
fields[#fields + 1] = { t = "CCW stop gain",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 25, max = 250, vals = { 22 } }
fields[#fields + 1] = { t = "Precomp cutoff",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 23 } }
fields[#fields + 1] = { t = "Cyclic FF gain",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 24 } }
fields[#fields + 1] = { t = "Coll FF gain",            x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 25 } }
fields[#fields + 1] = { t = "Coll imp FF gain",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 26 } }
fields[#fields + 1] = { t = "Coll imp FF decay",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 27 } }

inc.y(lineSpacing * 0.25)
labels[#labels + 1] = { t = "Acro Trainer",            x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Leveling gain",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 25, max = 255, vals = { 32 } }
fields[#fields + 1] = { t = "Maximum angle",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 80, vals = { 33 } }
labels[#labels + 1] = { t = "Angle Mode",              x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Leveling gain",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 29 } }
fields[#fields + 1] = { t = "Maximum angle",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 10, max = 90, vals = { 30 } }
labels[#labels + 1] = { t = "Horizon Mode",            x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Leveling gain",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 200, vals = { 31 } }

inc.y(lineSpacing * 0.25)
fields[#fields + 1] = { t = "Piro compensation",       x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 7 }, table = { [0] = "OFF", "ON" } }
labels[#labels + 1] = { t = "Error Decay Ground",      x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Time",                    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 2 }, scale = 10 }
labels[#labels + 1] = { t = "Error Decay Cyclic",      x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Time",                    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 3 }, scale = 10 }
fields[#fields + 1] = { t = "Limit",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 5 } }
labels[#labels + 1] = { t = "Error Decay Yaw",         x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Time",                    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 4 }, scale = 10 }
fields[#fields + 1] = { t = "Limit",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 6 } }
labels[#labels + 1] = { t = "Error Limit",             x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Roll",                    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 180, vals = { 8 } }
fields[#fields + 1] = { t = "Pitch",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 180, vals = { 9 } }
fields[#fields + 1] = { t = "Yaw",                     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 180, vals = { 10 } }
labels[#labels + 1] = { t = "HSI Offset Limit",        x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Roll",                    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 180, vals = { 37 } }
fields[#fields + 1] = { t = "Pitch",                   x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 180, vals = { 38 } }

inc.y(lineSpacing * 0.25)
labels[#labels + 1] = { t = "PID Controller",          x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "R bandwidth",             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 11 } }
fields[#fields + 1] = { t = "P bandwidth",             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 12 } }
fields[#fields + 1] = { t = "Y bandwidth",             x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 13 } }
fields[#fields + 1] = { t = "R D-term cutoff",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 14 } }
fields[#fields + 1] = { t = "P D-term cutoff",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 15 } }
fields[#fields + 1] = { t = "Y D-term cutoff",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 16 } }
fields[#fields + 1] = { t = "R B-term cutoff",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 39 } }
fields[#fields + 1] = { t = "P B-term cutoff",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 40 } }
fields[#fields + 1] = { t = "Y B-term cutoff",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250, vals = { 41 } }

return {
    read        = 94, -- MSP_PID_PROFILE
    write       = 95, -- MSP_SET_PID_PROFILE
    title       = "Profile - Various",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 41,
    labels      = labels,
    fields      = fields,
    --simulatorResponse = { 3, 25, 250, 0, 12, 0, 1, 30, 30, 45, 50, 50, 100, 15, 15, 20, 2, 10, 10, 15, 100, 100, 5, 0, 30, 0, 25, 0, 40, 55, 40, 75, 20, 25, 0, 15, 45, 45, 15, 15, 20 },
    profileSwitcher = profileSwitcher,

    postLoad = function(self)
        self.profileSwitcher.getStatus(self)
    end,

    timer = function(self)
        self.profileSwitcher.checkStatus(self)
    end,
}
