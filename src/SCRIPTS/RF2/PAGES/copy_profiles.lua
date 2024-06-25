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

fields[#fields + 1] = { t = "Profile type",                x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 1, vals = { 1 }, table = { [0] = "PID", "Rate" } }
fields[#fields + 1] = { t = "Source profile",              x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 5, vals = { 3 }, table = { [0] = "1", "2", "3", "4", "5", "6" } }
fields[#fields + 1] = { t = "Dest. profile",               x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 5, vals = { 2 }, table = { [0] = "1", "2", "3", "4", "5", "6" } }
labels[#labels + 1] = { t = "Use Save to copy the source", x = x, y = inc.y(lineSpacing) }
labels[#labels + 1] = { t = "profile to the destination.", x = x, y = inc.y(lineSpacing) }

return {
    read        = 101, -- MSP_STATUS
    write       = 183, -- MSP_COPY_PROFILE
    reboot      = false,
    eepromWrite = true,
    title       = "Copy",
    minBytes    = 30,
    labels      = labels,
    fields      = fields,
    simulatorResponse = { 252, 1, 127, 0, 35, 0, 0, 0, 0, 0, 0, 122, 1, 182, 0, 0, 26, 0, 0, 0, 0, 0, 2, 0, 6, 0, 6, 1, 4, 1 },
    postRead = function(self)
        self.maxPidProfiles = self.values[25]
        self.currentPidProfile = self.values[24]
        self.values = { 0, self.getDestinationPidProfile(self), self.currentPidProfile }
        self.minBytes = 3
    end,
    getDestinationPidProfile = function(self)
        local destPidProfile
        if (self.currentPidProfile < self.maxPidProfiles - 1) then
            destPidProfile = self.currentPidProfile + 1
        else
            destPidProfile = self.currentPidProfile - 1
        end
        return destPidProfile
    end,
}
