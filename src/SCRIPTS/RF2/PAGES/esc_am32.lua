local escParameters = nil
local escCount = 0

rf2.selectedEsc = rf2.selectedEsc or 0

local function clearForm(page)
    page.labels = {}
    page.fields = {}
    collectgarbage()
end

local receivedEscParameters -- forward declaration needed

local endEscEditing = function(field, page)
    rf2.selectedEsc = field.data.value
    clearForm(page)
    rf2.useApi("mspEsc4wif").selectEsc(rf2.selectedEsc)
    rf2.useApi("mspEscAm32").read(receivedEscParameters, page)
end

receivedEscParameters = function(page, data)
    escParameters = data
    clearForm(page)
    --local buildForm = rf2.executeScript("PAGES/esc_am32_form")
    --page.labels, page.fields = buildForm(escParameters, escCount, endEscEditing)
    page.labels, page.fields = rf2.executeScript("PAGES/esc_am32_form", escParameters, escCount, endEscEditing)
    page.readOnly = false
    rf2.onPageReady(page)
end

local function onProcessedMspStatus(page, status)
    escCount = status.motorCount
end

local page = {
    read = function(self)
        if not self.isReady then rf2.onPageReady(self) end
        rf2.useApi("mspEsc4wif").selectEsc(rf2.selectedEsc)
        rf2.useApi("mspStatus").getStatus(onProcessedMspStatus, self)
        rf2.useApi("mspEscAm32").read(receivedEscParameters, self)
    end,
    write = function(self)
        rf2.useApi("mspEscAm32").write(escParameters)
        rf2.settingsSaved(false, false)
    end,
    unload = function(self)
        rf2.useApi("mspEsc4wif").clearEscSelection()
    end,
    title       = "AM32",
    readOnly    = true
}

page.labels, page.fields = rf2.executeScript("PAGES/esc_am32_form", nil)

return page