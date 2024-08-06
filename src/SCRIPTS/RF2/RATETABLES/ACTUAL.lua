return {
    labels = { "", "", "ROLL", "PITCH", "YAW", "COL", 
        (LCD_W<480) and "Centr" or "Center",
        "Rate",
        "Max", "Rate", 
        "Expo", "" 
    },
    fields = {
        { min = 1, max = 200, scale = 0.1 },
        { min = 1, max = 200, scale = 0.1 },
        { min = 1, max = 200, scale = 0.1 },
        { min = 0, max = 100, scale = 4 },
        { min = 0, max = 200, scale = 0.1 },
        { min = 0, max = 200, scale = 0.1 },
        { min = 0, max = 200, scale = 0.1 },
        { min = 0, max = 100, scale = 4 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 }
    },
    defaults = { 360, 360, 360, 12, 360, 360, 360, 12, 0, 0, 0, 0 }
}
