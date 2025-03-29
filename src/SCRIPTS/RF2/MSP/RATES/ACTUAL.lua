local function setRateDefaults(data)
    data.roll_rcRates = { value = 36, min = 1, max = 200, scale = 0.1 }
    data.roll_rcExpo = { value = 0, min = 0, max = 100, scale = 100 }
    data.roll_rates = { value = 36, min = 0, max = 200, scale = 0.1 }
    data.pitch_rcRates = { value = 36 , min = 1, max = 200, scale = 0.1 }
    data.pitch_rcExpo = { value = 0, min = 0, max = 100, scale = 100 }
    data.pitch_rates = { value = 36, min = 0, max = 200, scale = 0.1 }
    data.yaw_rcRates = { value = 36, min = 1, max = 200, scale = 0.1 }
    data.yaw_rcExpo = { value = 0, min = 0, max = 100, scale = 100 }
    data.yaw_rates = { value = 36, min = 0, max = 200, scale = 0.1 }
    data.collective_rcRates = { value = 48, min = 0, max = 100, scale = 4 }
    data.collective_rcExpo = { value = 0, min = 0, max = 100, scale = 100 }
    data.collective_rates = { value = 48, min = 0, max = 100, scale = 4 }

    data.columnHeaders = { (LCD_W < 320) and "Centr" or "Center", "Sens", "Max", "Rate", "", "Expo" }

    return data
end

return setRateDefaults