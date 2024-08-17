return {
    labels = { "", "", "Roll", "Pitch", "Yaw", "Coll", "", "Rate", "", "Acro+", "", "Expo" },
    fields = {
        { min = 1, max = 200, scale = 0.1 },
        { min = 1, max = 200, scale = 0.1 },
        { min = 1, max = 200, scale = 0.1 },
        { min = 0, max = 200, scale = 4 },
        { min = 0, max = 255, scale = 1 },
        { min = 0, max = 255, scale = 1 },
        { min = 0, max = 255, scale = 1 },
        { min = 0, max = 255, scale = 1 },
        { min = 0, max = 100, scale = 1 },
        { min = 0, max = 100, scale = 1 },
        { min = 0, max = 100, scale = 1 },
        { min = 0, max = 100, scale = 1 }
    },
    defaults = { 360, 360, 360, 12.5, 0, 0, 0, 0, 0, 0, 0, 0 }
}
