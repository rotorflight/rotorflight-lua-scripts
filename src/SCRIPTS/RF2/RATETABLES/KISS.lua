return {
    labels = { "", "", "ROLL", "PITCH", "YAW", "COL", "RC", "Rate", "", "Rate", "RC", "Curve" },
    fields = {
        { min = 1, max = 255, scale = 100 },
        { min = 1, max = 255, scale = 100 },
        { min = 1, max = 255, scale = 100 },
        { min = 0, max = 255, scale = 100 },
        { min = 0, max = 99,  scale = 100 },
        { min = 0, max = 99,  scale = 100 },
        { min = 0, max = 99,  scale = 100 },
        { min = 0, max = 99,  scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 },
        { min = 0, max = 100, scale = 100 }
    },
    defaults = { 1.8, 1.8, 1.8, 2.5, 0, 0, 0, 0, 0, 0, 0, 0 }
}
