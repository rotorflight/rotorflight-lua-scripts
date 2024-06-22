local template = assert(loadScript(rf2.radio.template))()
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

fields[#fields + 1] = { t = "Servo",         x = x,          y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 7, vals = { 1 }, table = { [0] = "ELEVATOR", "CYCL L", "CYCL R", "TAIL" }, postEdit = function(self) self.servoChanged(self) end }
fields[#fields + 1] = { t = "Center",        x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 2250, vals = { 2,3 } }
fields[#fields + 1] = { t = "Min",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -1000, max = 1000, vals = { 4,5 } }
fields[#fields + 1] = { t = "Max",           x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = -1000, max = 1000, vals = { 6,7 } }
fields[#fields + 1] = { t = "Scale neg",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 100, max = 1000, vals = { 8,9 } }
fields[#fields + 1] = { t = "Scale pos",     x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 100, max = 1000, vals = { 10,11 } }
fields[#fields + 1] = { t = "Rate",          x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 50, max = 5000, vals = { 12,13 } }
fields[#fields + 1] = { t = "Speed",         x = x + indent, y = inc.y(lineSpacing), sp = x + sp, min = 0, max = 60000, vals = { 14,15 } }

return {
    read        = 120, -- MSP_SERVO_CONFIGURATIONS
    write       = 212, -- MSP_SET_SERVO_CONFIGURATION
    title       = "Servos",
    reboot      = false,
    eepromWrite = true,
    minBytes    = 33,
    labels      = labels,
    fields      = fields,
    postRead = function(self)
        local servoCount = self.values[1]
        self.fields[1].max = servoCount - 1
        self.servoConfiguration = {}
        for i = 1, servoCount do
            self.servoConfiguration[i] = {}
            for j = 1, 16 do
                self.servoConfiguration[i][j] = self.values[1 + (i - 1) * 16 + j]
            end
        end
        if not rf2.lastChangedServo then
            rf2.lastChangedServo = 1
        end
        self.setValues(self, rf2.lastChangedServo)
        self.minBytes = 1 + 16
    end,
    setValues = function(self, servoIndex)
        self.values = {}
        self.values[1] = servoIndex - 1
        for i = 1, 16 do
            self.values[1 + i] = self.servoConfiguration[servoIndex][i]
        end
    end,
    servoChanged = function(self)
        rf2.lastChangedServo = self.values[1] + 1
        self.setValues(self, rf2.lastChangedServo)
        rf2.dataBindFields()
    end
}
