local rateSwitcher = {
    mspStatus = assert(rf2.loadScript("MSP/mspStatus.lua"))(),
    editing = false,
    rateAdjustmentTS = nil,

    getStatus = function(page)
        local self = page.rateSwitcher
        self.mspStatus.getStatus(self.onProcessedMspStatus, page)
    end,

    checkStatus = function(page)
        local self = page.rateSwitcher
        if self.rateAdjustmentTS and rf2.clock() - self.rateAdjustmentTS > 0.5 then
            rf2.reloadPage()
        elseif rf2.mspQueue:isProcessed() and not self.editing then
            self.mspStatus.getStatus(self.onProcessedMspStatus, page)
        end
    end,

    onProcessedMspStatus = function(page, status)
        local self = page.rateSwitcher
        local currentField = page.fields[1]
        if currentField.data.value ~= status.rateProfile and not page.rateSwitcher.editing then
            if currentField.data.value then
                page.rateSwitcher.rateAdjustmentTS = rf2.clock()
            end
            currentField.data.value = status.rateProfile
            rf2.lcdNeedsInvalidate = true
        end

        page.isReady = true
    end,

    startPidEditing = function(field, page)
        page.rateSwitcher.editing = true
    end,

    endPidEditing = function(field, page)
        rf2.useApi("mspSetProfile").setRateProfile(field.data.value, function() rf2.reloadPage() end, nil)
    end
}

return rateSwitcher