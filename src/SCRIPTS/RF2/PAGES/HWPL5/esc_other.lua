local template = assert(rf2.loadScript(rf2.radio.template))()
local hwpl5Common = assert(rf2.loadScript("PAGES/HWPL5/common.lua"))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field + indent
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local inc = { x = function(val) x = x + val return x end, y = function(val) y = y + val return y end }
local labels = {}
local fields = {}

local startupPower = {
    [0] = "level-1",
    "level-2",
    "level-3",
    "level-4",
    "level-5",
    "level-6",
    "level-7",
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

labels[#labels + 1] = { t = "ESC",                    x = x,                y = inc.y(lineSpacing) }
y = yMinLim - lineSpacing
labels[#labels + 1] = { t = "---",                    x = x + sp - indent,  y = inc.y(lineSpacing) }
y = yMinLim - lineSpacing
labels[#labels + 1] = { t = "---",                    x = x + sp * 1.9,     y = inc.y(lineSpacing) }

labels[#labels + 1] = { t = "Motor",                  x = x,          y = inc.y(lineSpacing * 2) }
fields[#fields + 1] = { t = "Timing",                 x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 30, vals = { 2 + 76 } }
fields[#fields + 1] = { t = "Startup Power",          x = x + indent, y = inc.y(lineSpacing * 2), sp = x + sp, min = 0, max = #startupPower, vals = { 2 + 79 }, table = startupPower }
fields[#fields + 1] = { t = "Active Freewheel",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = #enabledDisabled, vals = { 2 + 78 }, table = enabledDisabled }

fields[#fields + 1] = { t = "Brake Type",             x = x + indent, y = inc.y(lineSpacing * 2), sp = x + sp, min = 0, max = #brakeType, vals = { 2 + 74 }, table = brakeType }
fields[#fields + 1] = { t = "Brake Force %",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 100, vals = { 2 + 75 } }

return {
    read        = 217, -- MSP_ESC_PARAMETERS
    write       = 218, -- MSP_SET_ESC_PARAMETERS
    eepromWrite = false,
    reboot      = false,
    title       = "Other Settings",
    minBytes    = 81,
    labels      = labels,
    fields      = fields,

    postLoad = function(self)
        -- esc type
        local l = self.labels[1]
        l.t = hwpl5Common.getText(self.values, 2 + 49, 15)

        -- HW ver
        l = self.labels[2]
        l.t = hwpl5Common.getText(self.values, 2 + 17, 15)

        -- FW ver
        l = self.labels[3]
        l.t = hwpl5Common.getText(self.values, 2 + 1, 15)
    end,

    preSave = function (self)
        self.values[2] = 0 -- save cmd
    end,
}
