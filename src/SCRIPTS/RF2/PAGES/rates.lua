local template = assert(rf2.loadScript(rf2.radio.template))()
local mspSetProfile = assert(rf2.loadScript("MSP/mspSetProfile.lua"))()
local mspStatus = assert(rf2.loadScript("MSP/mspStatus.lua"))()
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

y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "",      x = x, y = inc.y(tableSpacing.header) }
labels[#labels + 1] = { t = "",      x = x, y = inc.y(tableSpacing.header) }
labels[#labels + 1] = { t = "ROLL",  x = x, y = inc.y(tableSpacing.row) }
labels[#labels + 1] = { t = "PITCH", x = x, y = inc.y(tableSpacing.row) }
labels[#labels + 1] = { t = "YAW",   x = x, y = inc.y(tableSpacing.row) }
labels[#labels + 1] = { t = "COL",   x = x, y = inc.y(tableSpacing.row) }

x = x + tableSpacing.col
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "RC",    x = x, y = inc.y(tableSpacing.header) }
labels[#labels + 1] = { t = "Rate",  x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 255, vals = { 2 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 255, vals = { 8 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 255, vals = { 14 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 255, vals = { 20 }, scale = 100 }

x = x + tableSpacing.col
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "Super", x = x, y = inc.y(tableSpacing.header) }
labels[#labels + 1] = { t = "Rate",  x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 4 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 10 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 255, vals = { 16 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 255, vals = { 22 }, scale = 100 }

x = x + tableSpacing.col
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "RC",    x = x, y = inc.y(tableSpacing.header) }
labels[#labels + 1] = { t = "Expo",  x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 3 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 9 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 15 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 21 }, scale = 100 }

local endRateEditing = function(field, page)
    mspSetProfile.setRateProfile(field.data.value, function() rf2.reloadPage() end, nil)
end

x = margin
inc.y(lineSpacing*0.4)
fields[#fields + 1] = { t = "Curr Rate profile",   x = x,          y = inc.y(lineSpacing), sp = x + sp, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, postEdit = endRateEditing }
fields[#fields + 1] = { t = "Rates Type",          x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 5,      vals = { 1 }, table = { [0] = "NONE", "BETAFL", "RACEFL", "KISS", "ACTUAL", "QUICK"}, postEdit = function(self, page) page.updateRatesType(page, true) end }
inc.y(lineSpacing*0.4)

labels[#labels + 1] = { t = "Roll dynamics",       x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Response time",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 5 },                  id = "rateSetupResponse"  }
fields[#fields + 1] = { t = "Max acceleration",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 50000, vals = { 6,7 },   scale = 0.1, id = "rateSetupAcceleration" }
labels[#labels + 1] = { t = "Pitch dynamics",      x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Response time",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 11 } ,                id = "rateSetupResponse" }
fields[#fields + 1] = { t = "Max acceleration",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 50000, vals = { 12,13 }, scale = 0.1, id = "rateSetupAcceleration" }
labels[#labels + 1] = { t = "Yaw dynamics",        x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Response time",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 17 },                 id = "rateSetupResponse"  }
fields[#fields + 1] = { t = "Max acceleration",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 50000, vals = { 18,19 }, scale = 0.1, id = "rateSetupAcceleration" }
labels[#labels + 1] = { t = "Collective dynamics", x = x,          y = inc.y(lineSpacing) }
fields[#fields + 1] = { t = "Response time",       x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 250,   vals = { 23 },                 id = "rateSetupResponse" }
fields[#fields + 1] = { t = "Max acceleration",    x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 50000, vals = { 24,25 }, scale = 0.1, id = "rateSetupAcceleration" }

return {
    read        = 111, -- MSP_RC_TUNING
    write       = 204, -- MSP_SET_RC_TUNING
    title       = "Rates",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 25,
    labels      = labels,
    fields      = fields,
    simulatorResponse = { 4, 18, 25, 32, 20, 0, 0, 18, 25, 32, 20, 0, 0, 32, 50, 45, 10, 0, 0, 56, 0, 56, 20, 0, 0 },
    ratesType,
    getRatesType = function(self)
        for i = 1, #self.fields do
            if self.fields[i].vals and self.fields[i].vals[1] == 1 then
                return self.fields[i].table[self.fields[i].value]
            end
        end
    end,
    updateRatesType = function(self, applyDefaults)
        local ratesTable = assert(rf2.loadScript("RATETABLES/"..self.getRatesType(self)..".lua"))()
        for i = 1, #ratesTable.labels do
            self.labels[i].t = ratesTable.labels[i]
        end
        for i = 1, #ratesTable.fields do
            for k, v in pairs(ratesTable.fields[i]) do
                self.fields[i][k] = v
            end
        end
        if applyDefaults and self.ratesType ~= self.getRatesType(self) then
            for i = 1, #ratesTable.defaults do
                local f = self.fields[i]
                f.value = ratesTable.defaults[i]
                for idx=1, #f.vals do
                    self.values[f.vals[idx]] = bit32.rshift(math.floor(f.value*(f.scale or 1) + 0.5), (idx-1)*8)
                end
            end
        else
            for i = 1, 12 do
                local f = self.fields[i]
                f.value = 0
                for idx=1, #f.vals do
                    local raw_val = self.values[f.vals[idx]] or 0
                    raw_val = bit32.lshift(raw_val, (idx-1)*8)
                    f.value = bit32.bor(f.value, raw_val)
                end
                f.value = f.value/(f.scale or 1)
            end
        end
        self.ratesType = self.getRatesType(self)
    end,
    postLoad = function(self)
        self.updateRatesType(self)
        mspStatus.getStatus(self.onProcessedMspStatus, self)
    end,
    onProcessedMspStatus = function(self, status)
        fields[13].data.value = status.rateProfile
        self.isReady = true
    end,
}
