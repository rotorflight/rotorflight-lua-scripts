local function setRateDefaults(data)
    data.roll_rcRates = { value = 0, min = 1, max = 0 }
    data.roll_rcExpo = { value = 0, min = 0, max = 0 }
    data.roll_rates = { value = 0, min = 0, max = 0 }
    data.pitch_rcRates = { value = 0 , min = 1, max = 0 }
    data.pitch_rcExpo = { value = 0, min = 0, max = 0 }
    data.pitch_rates = { value = 0, min = 0, max = 0 }
    data.yaw_rcRates = { value = 0, min = 1, max = 0 }
    data.yaw_rcExpo = { value = 0, min = 0, max = 0 }
    data.yaw_rates = { value = 0, min = 0, max = 0 }
    data.collective_rcRates = { value = 0, min = 0, max = 0 }
    data.collective_rcExpo = { value = 0, min = 0, max = 0 }
    data.collective_rates = { value = 0, min = 0, max = 0 }

    data.columnHeaders = { "RC", "Rate", "", "Rate", "RC", "Expo" }

    return data
end

return setRateDefaults