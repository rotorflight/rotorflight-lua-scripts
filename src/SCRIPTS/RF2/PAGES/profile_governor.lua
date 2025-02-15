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
local governorProfile = {}

fields[1] = { t = "Current PID profile",        x = x, y = inc.y(lineSpacing), sp = x + sp * 1.17, data = { value = nil, min = 0, max = 5, table = { [0] = "1", "2", "3", "4", "5", "6" } }, preEdit = profileSwitcher.startPidEditing, postEdit = profileSwitcher.endPidEditing }

inc.y(lineSpacing * 0.25)
fields[2] = { t = "Full headspeed",             x = x, y = inc.y(lineSpacing), sp = x + sp, id = "govHeadspeed"}
fields[3] = { t = "Max throttle",               x = x, y = inc.y(lineSpacing), sp = x + sp, id = "govMaxThrottle" }
if rf2.apiVersion >= 12.07 then
    fields[#fields + 1] = { t = "Min throttle", x = x, y = inc.y(lineSpacing), sp = x + sp, id = "govMinThrottle" }
end
fields[#fields + 1] = { t = "PID master gain",  x = x, y = inc.y(lineSpacing), sp = x + sp, id = "govMasterGain" }
fields[#fields + 1] = { t = "P-gain",           x = x, y = inc.y(lineSpacing), sp = x + sp, id = "govPGain" }
fields[#fields + 1] = { t = "I-gain",           x = x, y = inc.y(lineSpacing), sp = x + sp, id = "govIGain" }
fields[#fields + 1] = { t = "D-gain",           x = x, y = inc.y(lineSpacing), sp = x + sp, id = "govDGain" }
fields[#fields + 1] = { t = "FF-gain",          x = x, y = inc.y(lineSpacing), sp = x + sp, id = "govFGain" }
fields[#fields + 1] = { t = "Yaw precomp.",     x = x, y = inc.y(lineSpacing), sp = x + sp, id = "govYawPrecomp" }
fields[#fields + 1] = { t = "Cyclic precomp.",  x = x, y = inc.y(lineSpacing), sp = x + sp, id = "govCyclicPrecomp" }
fields[#fields + 1] = { t = "Coll precomp.",    x = x, y = inc.y(lineSpacing), sp = x + sp, id = "govCollectivePrecomp" }
fields[#fields + 1] = { t = "TTA gain",         x = x, y = inc.y(lineSpacing), sp = x + sp, id = "govTTAGain" }
fields[#fields + 1] = { t = "TTA limit",        x = x, y = inc.y(lineSpacing), sp = x + sp, id = "govTTALimit" }

local function setValues()
    fields[2].data = governorProfile.headspeed
    fields[3].data = governorProfile.max_throttle
    local field = 3
    local incField = function() field = field + 1 return field end -- todo: refactor ui.lua to not iterate between 0 and #fields
    if rf2.apiVersion >= 12.07 then
        fields[incField()].data = governorProfile.min_throttle
        extraField = 1
    end
    fields[incField()].data = governorProfile.gain
    fields[incField()].data = governorProfile.p_gain
    fields[incField()].data = governorProfile.i_gain
    fields[incField()].data = governorProfile.d_gain
    fields[incField()].data = governorProfile.f_gain
    fields[incField()].data = governorProfile.yaw_ff_weight
    fields[incField()].data = governorProfile.cyclic_ff_weight
    fields[incField()].data = governorProfile.collective_ff_weight
    fields[incField()].data = governorProfile.tta_gain
    fields[incField()].data = governorProfile.tta_limit
end

local function receivedGovernorProfile(page, profile)
    governorProfile = profile
    setValues()
    rf2.lcdNeedsInvalidate = true
    page.isReady = true
end

return {
    read = function(self)
        rf2.useApi("mspGovernorProfile").getGovernorProfile(receivedGovernorProfile, self)
    end,
    write = function(self)
        rf2.useApi("mspGovernorProfile").setGovernorProfile(governorProfile)
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
