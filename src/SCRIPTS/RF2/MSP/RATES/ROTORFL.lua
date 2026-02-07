local function setRateDefaults(data)
    data.roll_rcRates = { value = 50, min = 2, max = 200, scale = 0.2 }
    data.roll_rcExpo = { value = 40, min = 0, max = 100, scale = 1 }
    data.roll_rates = { value = 24, min = 0, max = 127, scale = 1 }
    data.pitch_rcRates = { value = 50 , min = 2, max = 200, scale = 0.2 }
    data.pitch_rcExpo = { value = 40, min = 0, max = 100, scale = 1 }
    data.pitch_rates = { value = 24, min = 0, max = 127, scale = 1 }
    data.yaw_rcRates = { value = 80, min = 2, max = 200, scale = 0.2 }
    data.yaw_rcExpo = { value = 50, min = 0, max = 100, scale = 1 }
    data.yaw_rates = { value = 24, min = 0, max = 127, scale = 1 }
    data.collective_rcRates = { value = 100, min = 0, max = 200, scale = 8, mult = 2 }
    data.collective_rcExpo = { value = 0, min = 0, max = 100, scale = 1 }
    data.collective_rates = { value = 24, min = 0, max = 127, scale = 1 }

    data.columnHeaders = { "", "Rate", "", "Shape", "", "Expo" }

    return data
end

return setRateDefaults