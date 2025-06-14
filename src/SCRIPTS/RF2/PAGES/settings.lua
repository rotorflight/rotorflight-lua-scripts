local template = rf2.executeScript(rf2.radio.template)
local settingsHelper = rf2.executeScript("PAGES/helpers/settingsHelper")
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
local offOn = { [0] = "Off", "On" }

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

incY(lineSpacing * 0.5)
labels[3] = { t = "Rf2bg Options",           x = x, y = incY(lineSpacing) }
fields[8] = { t = "Adjustment Teller",       x = x + indent, y = incY(lineSpacing), sp = x + sp }

if rf2.canUseLvgl then
    incY(lineSpacing * 0.5)
    labels[4] = { t = "Tool Options",        x = x, y = incY(lineSpacing) }
    fields[9] = { t = "Use touch UI",        x = x + indent, y = incY(lineSpacing), sp = x + sp }
end

local function setValues()
    fields[1].data = { value = settings.showModelOnTx or 0, min = 0, max = 1, table = hideShow }
    fields[2].data = { value = settings.showExperimental or 0, min = 0, max = 1, table = hideShow }
    fields[3].data = { value = settings.showFlyRotor or 0, min = 0, max = 1, table = hideShow }
    fields[4].data = { value = settings.showPlatinumV5 or 0, min = 0, max = 1, table = hideShow }
    fields[5].data = { value = settings.showTribunus or 0, min = 0, max = 1, table = hideShow }
    fields[6].data = { value = settings.showXdfly or 0, min = 0, max = 1, table = hideShow }
    fields[7].data = { value = settings.showYge or 0, min = 0, max = 1, table = hideShow }
    fields[8].data = { value = settings.useAdjustmentTeller or 0, min = 0, max = 1, table = offOn }
    if rf2.canUseLvgl then
        fields[9].data = { value = settings.useLvgl or 1, min = 0, max = 1, table = offOn }
    end
end

return {
    read = function(self)
        setValues()
        rf2.onPageReady(self)
    end,
    write = function(self)
        settings.showModelOnTx = fields[1].data.value
        settings.showExperimental = fields[2].data.value
        settings.showFlyRotor = fields[3].data.value
        settings.showPlatinumV5 = fields[4].data.value
        settings.showTribunus = fields[5].data.value
        settings.showXdfly = fields[6].data.value
        settings.showYge = fields[7].data.value
        settings.useAdjustmentTeller = fields[8].data.value
        if rf2.canUseLvgl then
            settings.useLvgl = fields[9].data.value
        end
        settingsHelper.saveSettings(settings)
        rf2.reloadMainMenu(true)
        rf2.settingsSaved(false, false)
    end,
    title       = "Settings",
    labels      = labels,
    fields      = fields
}
