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
local mspGovernorProfile = rf2.useApi("mspGovernorProfile")
local governorProfile = mspGovernorProfile.getDefaults()

fields[#fields + 1] = { t = "Current PID profile",        x = x, y = inc.y(lineSpacing), sp = x + sp * 1.17, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = profileSwitcher.startPidEditing, postEdit = profileSwitcher.endPidEditing }

inc.y(lineSpacing * 0.25)
fields[#fields + 1] = { t = "Full headspeed",             x = x, y = inc.y(lineSpacing), sp = x + sp, data = governorProfile.headspeed, id = "govHeadspeed"}
fields[#fields + 1] = { t = "Max throttle",               x = x, y = inc.y(lineSpacing), sp = x + sp, data = governorProfile.max_throttle, id = "govMaxThrottle" }
if rf2.apiVersion >= 12.07 then
    fields[#fields + 1] = { t = "Min throttle", x = x, y = inc.y(lineSpacing), sp = x + sp, data = governorProfile.min_throttle, id = "govMinThrottle" }
end
fields[#fields + 1] = { t = "PID master gain",  x = x, y = inc.y(lineSpacing), sp = x + sp, data = governorProfile.gain, id = "govMasterGain" }
fields[#fields + 1] = { t = "P-gain",           x = x, y = inc.y(lineSpacing), sp = x + sp, data = governorProfile.p_gain, id = "govPGain" }
fields[#fields + 1] = { t = "I-gain",           x = x, y = inc.y(lineSpacing), sp = x + sp, data = governorProfile.i_gain, id = "govIGain" }
fields[#fields + 1] = { t = "D-gain",           x = x, y = inc.y(lineSpacing), sp = x + sp, data = governorProfile.d_gain, id = "govDGain" }
fields[#fields + 1] = { t = "FF-gain",          x = x, y = inc.y(lineSpacing), sp = x + sp, data = governorProfile.f_gain, id = "govFGain" }
fields[#fields + 1] = { t = "Yaw precomp.",     x = x, y = inc.y(lineSpacing), sp = x + sp, data = governorProfile.yaw_ff_weight, id = "govYawPrecomp" }
fields[#fields + 1] = { t = "Cyclic precomp.",  x = x, y = inc.y(lineSpacing), sp = x + sp, data = governorProfile.cyclic_ff_weight, id = "govCyclicPrecomp" }
fields[#fields + 1] = { t = "Coll precomp.",    x = x, y = inc.y(lineSpacing), sp = x + sp, data = governorProfile.collective_ff_weight, id = "govCollectivePrecomp" }
fields[#fields + 1] = { t = "TTA gain",         x = x, y = inc.y(lineSpacing), sp = x + sp, data = governorProfile.tta_gain, id = "govTTAGain" }
fields[#fields + 1] = { t = "TTA limit",        x = x, y = inc.y(lineSpacing), sp = x + sp, data = governorProfile.tta_limit, id = "govTTALimit" }

local function receivedGovernorProfile(page)
    rf2.lcdNeedsInvalidate = true
    page.isReady = true
end

return {
    read = function(self)
        mspGovernorProfile.read(governorProfile, receivedGovernorProfile, self)
    end,
    write = function(self)
        mspGovernorProfile.write(governorProfile)
        rf2.settingsSaved()
    end,
    title       = "Profile - Governor",
    reboot      = false,
    eepromWrite = true,
    labels      = labels,
    fields      = fields,
    profileSwitcher = profileSwitcher,

    postLoad = function(self)
        self.profileSwitcher.getStatus(self)
    end,

    timer = function(self)
        self.profileSwitcher.checkStatus(self)
    end,
}
