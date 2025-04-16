local profileSwitcher = {
    mspStatus = assert(rf2.loadScript("MSP/mspStatus.lua"))(),
    editing = false,
    profileAdjustmentTS = nil,

    getStatus = function(page)
        local self = page.profileSwitcher
        self.mspStatus.getStatus(self.onProcessedMspStatus, page)
    end,

    checkStatus = function(page)
        local self = page.profileSwitcher
        if self.profileAdjustmentTS and rf2.clock() - self.profileAdjustmentTS > 0.5 then
            rf2.reloadPage()
        elseif rf2.mspQueue:isProcessed() and not self.editing then
            self.mspStatus.getStatus(self.onProcessedMspStatus, page)
        end
    end,

    onProcessedMspStatus = function(page, status)
        local self = page.profileSwitcher
        local currentField = page.fields[1]
        if currentField.data.value ~= status.profile and not self.editing then
            if currentField.data.value then
                self.profileAdjustmentTS = rf2.clock()
            end
            currentField.data.value = status.profile
            rf2.lcdNeedsInvalidate = true
        end

        page.isReady = true
    end,

    startPidEditing = function(field, page)
        page.profileSwitcher.editing = true
    end,

    endPidEditing = function(field, page)
        rf2.useApi("mspSetProfile").setPidProfile(field.data.value, function() rf2.reloadPage() end, nil)
    end
}

return profileSwitcher