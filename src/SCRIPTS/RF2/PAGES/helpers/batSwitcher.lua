local batSwitcher = {
    mspBatteryProfile = rf2.executeScript("MSP/mspBatteryProfile"),
    editing = false,
    adjustmentTS = nil,

    getStatus = function(page, currentField)
        local self = page.batSwitcher
        self.currentField = currentField
        self.mspBatteryProfile.read(self.onProcessedBatteryProfile, page)
    end,

    checkStatus = function(page)
        local self = page.batSwitcher
        if self.adjustmentTS and rf2.clock() - self.adjustmentTS > 0.5 then
            rf2.reloadPage()
        elseif rf2.mspQueue:isProcessed() and not self.editing then
            self.mspBatteryProfile.read(self.onProcessedBatteryProfile, page)
        end
    end,

    onProcessedBatteryProfile = function(page, status)
        local self = page.batSwitcher
        local currentField = self.currentField
        if currentField.data.value ~= status.batteryProfile.value and not page.batSwitcher.editing then
            if currentField.data.value then
                page.batSwitcher.adjustmentTS = rf2.clock()
            end
            currentField.data.value = status.batteryProfile.value
            rf2.lcdNeedsInvalidate = true
        end

        page.isReady = true
    end,

    startEditing = function(field, page)
        local self = page.batSwitcher
        self.editing = true
    end,

    endEditing = function(field, page)
        local self = page.batSwitcher
        local status = { batteryProfile = field.data }
        self.mspBatteryProfile.write(status, function() rf2.reloadPage() end, nil)
    end
}

return batSwitcher