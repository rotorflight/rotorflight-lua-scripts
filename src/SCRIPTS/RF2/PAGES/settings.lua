local template = assert(rf2.loadScript(rf2.radio.template))()
local settingsHelper = assert(rf2.loadScript("PAGES/helpers/settingsHelper.lua"))()
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
local settings = settingsHelper.loadSettings()
local hideShow = { [0] = "Hide", "Show" }

y = yMinLim - tableSpacing.header
labels[1] = { t = "Display Various Pages",   x = x, y = incY(lineSpacing) }
fields[1] = { t = "Model on TX",             x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[2] = { t = "Experimental (!)",        x = x + indent, y = incY(lineSpacing), sp = x + sp }

incY(lineSpacing * 0.5)
labels[2] = { t = "Display ESC Pages",       x = x, y = incY(lineSpacing) }
fields[3] = { t = "FlyRotor",                x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[4] = { t = "HW Platinum V5",          x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[5] = { t = "Scorpion Tribunus",       x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[6] = { t = "XDFly",                   x = x + indent, y = incY(lineSpacing), sp = x + sp }
fields[7] = { t = "YGE",                     x = x + indent, y = incY(lineSpacing), sp = x + sp }

local function setValues()
    fields[1].data = { value = settings.showModelOnTx or 0, min = 0, max = 1, table = hideShow }
    fields[2].data = { value = settings.showExperimental or 0, min = 0, max = 1, table = hideShow }
    fields[3].data = { value = settings.showFlyRotor or 0, min = 0, max = 1, table = hideShow }
    fields[4].data = { value = settings.showPlatinumV5 or 0, min = 0, max = 1, table = hideShow }
    fields[5].data = { value = settings.showTribunus or 0, min = 0, max = 1, table = hideShow }
    fields[6].data = { value = settings.showXdfly or 0, min = 0, max = 1, table = hideShow }
    fields[7].data = { value = settings.showYge or 0, min = 0, max = 1, table = hideShow }
end

return {
    read = function(self)
        setValues()
        rf2.lcdNeedsInvalidate = true
        self.isReady = true
    end,
    write = function(self)
        settings.showModelOnTx = fields[1].data.value
        settings.showExperimental = fields[2].data.value
        settings.showFlyRotor = fields[3].data.value
        settings.showPlatinumV5 = fields[4].data.value
        settings.showTribunus = fields[5].data.value
        settings.showXdfly = fields[6].data.value
        settings.showYge = fields[7].data.value
        settingsHelper.saveSettings(settings)
        rf2.loadPageFiles(true)
        rf2.settingsSaved()
    end,
    title       = "Settings",
    reboot      = false,
    eepromWrite = false,
    labels      = labels,
    fields      = fields
}
