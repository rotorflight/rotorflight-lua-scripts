local function setRateDefaults(data)
    data.roll_rcRates = { value = 36, min = 1, max = 200, scale = 0.1 }
    data.roll_rcExpo = { value = 0, min = 0, max = 100 }
    data.roll_rates = { value = 0, min = 0, max = 255 }
    data.pitch_rcRates = { value = 36, min = 1, max = 200, scale = 0.1 }
    data.pitch_rcExpo = { value = 0, min = 0, max = 100 }
    data.pitch_rates = { value = 0, min = 0, max = 255 }
    data.yaw_rcRates = { value = 36, min = 1, max = 200, scale = 0.1 }
    data.yaw_rcExpo = { value = 0, min = 0, max = 100 }
    data.yaw_rates = { value = 0, min = 0, max = 255 }
    data.collective_rcRates = { value = 50, min = 1, max = 200, scale = 4 }
    data.collective_rcExpo = { value = 0, min = 0, max = 100 }
    data.collective_rates = { value = 0, min = 0, max = 255 }

    data.columnHeaders = { "", "Rate", "", "Acro+", "", "Expo" }

    return data
end

return setRateDefaults