local function setRateDefaults(data)
    data.roll_rcRates = { value = 180, min = 0, max = 255, scale = 100 }
    data.roll_rcExpo = { value = 0, min = 0, max = 100, scale = 100 }
    data.roll_rates = { value = 0, min = 0, max = 99, scale = 100 }
    data.pitch_rcRates = { value = 180, min = 0, max = 255, scale = 100 }
    data.pitch_rcExpo = { value = 0, min = 0, max = 100, scale = 100 }
    data.pitch_rates = { value = 0, min = 0, max = 99, scale = 100 }
    data.yaw_rcRates = { value = 180, min = 0, max = 255, scale = 100 }
    data.yaw_rcExpo = { value = 0, min = 0, max = 100, scale = 100 }
    data.yaw_rates = { value = 0, min = 0, max = 99, scale = 100 }
    data.collective_rcRates = { value = 250, min = 0, max = 255, scale = 100 }
    data.collective_rcExpo = { value = 0, min = 0, max = 100, scale = 100 }
    data.collective_rates = { value = 0, min = 0, max = 99, scale = 100 }

    data.columnHeaders = { "RC", "Rate", "", "Rate", "RC", "Curve" }

    return data
end

return setRateDefaults