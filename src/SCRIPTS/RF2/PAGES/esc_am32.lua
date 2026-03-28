local escParameters = nil
local escCount = 0
local selectedEsc = 0

local function clearForm(page)
    page.labels = {}
    page.fields = {}
    collectgarbage()
end

local receivedEscParameters -- forward declaration needed

local endEscEditing = function(field, page)
    selectedEsc = field.data.value
    clearForm(page)
    rf2.useApi("mspEsc4wif").selectEsc(selectedEsc)
    rf2.useApi("mspEscAm32").read(receivedEscParameters, page)
end

receivedEscParameters = function(page, data)
    escParameters = data
    clearForm(page)
    page.labels, page.fields = rf2.executeScript("PAGES/esc_am32_form", escParameters, escCount, selectedEsc, endEscEditing)
    page.readOnly = false
    rf2.onPageReady(page)
end

local function onProcessedMspStatus(page, status)
    escCount = status.motorCount
end

local page = {
    read = function(self)
        if not self.isReady then rf2.onPageReady(self) end
        rf2.useApi("mspEsc4wif").selectEsc(selectedEsc, 1)
        rf2.useApi("mspStatus").getStatus(onProcessedMspStatus, self)
        rf2.useApi("mspEscAm32").read(receivedEscParameters, self)
    end,
    write = function(self)
        clearForm(self)
        rf2.useApi("mspEscAm32").write(escParameters)
        escParameters = nil
        rf2.useApi("mspEscAm32").read(receivedEscParameters, self)
    end,
    unload = function(self)
        rf2.useApi("mspEsc4wif").clearEscSelection()
    end,
    title       = "AM32",
    readOnly    = true
}

page.labels, page.fields = rf2.executeScript("PAGES/esc_am32_form", nil)

return page