return {
    labels = { "", "", "Roll", "Pitch", "Yaw", "Coll", "RC", "Rate", "", "Rate", "RC", "Expo" },
    fields = {
        { min = 0, max = 255, scale = 100 },
        { min = 0, max = 255, scale = 100 },
        { min = 0, max = 255, scale = 100 },
        { min = 0, max = 255, scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 }
    },
    defaults = { 1.8, 1.8, 1.8, 2.03, 0, 0, 0, 0.01, 0, 0, 0, 0 }
}
