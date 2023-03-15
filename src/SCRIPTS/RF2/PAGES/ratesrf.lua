local template = assert(loadScript(radio.template))()
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = radio.yMinLimit
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

x = x + tableSpacing.col
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "RC",    x = x, y = inc.y(tableSpacing.header) }
labels[#labels + 1] = { t = "Rate",  x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 255, vals = { 2 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 255, vals = { 7 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 255, vals = { 12 }, scale = 100 }

x = x + tableSpacing.col
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "Super", x = x, y = inc.y(tableSpacing.header) }
labels[#labels + 1] = { t = "Rate",  x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 4 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 9 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 255, vals = { 14 }, scale = 100 }

x = x + tableSpacing.col
y = yMinLim - tableSpacing.header
labels[#labels + 1] = { t = "RC",    x = x, y = inc.y(tableSpacing.header) }
labels[#labels + 1] = { t = "Expo",  x = x, y = inc.y(tableSpacing.header) }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 3 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 8 }, scale = 100 }
fields[#fields + 1] = {              x = x, y = inc.y(tableSpacing.row), min = 0, max = 100, vals = { 13 }, scale = 100 }

x = margin
inc.y(lineSpacing*0.4)
fields[#fields + 1] = { t = "Rates Type", x = x, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 4, vals = { 1 }, table = { [0] = "BF", "RF", "KISS", "ACTUAL", "QUICK"}, postEdit = function(self) self.updateRatesType(self, true) end }

return {
    read        = 111, -- MSP_RC_TUNING
    write       = 204, -- MSP_SET_RC_TUNING
    title       = "Rates",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 16,
    labels      = labels,
    fields      = fields,
    ratesType,
    getRatesType = function(self)
        for i = 1, #self.fields do
            if self.fields[i].vals and self.fields[i].vals[1] == 1 then
                return self.fields[i].table[self.fields[i].value]
            end
        end
    end,
    updateRatesType = function(self, applyDefaults)
        local ratesTable = assert(loadScript("RATETABLES/"..self.getRatesType(self)..".lua"))()
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
            for i = 1, 9 do
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
    end,
}
