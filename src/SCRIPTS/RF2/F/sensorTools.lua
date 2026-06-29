local UNIT_SYMBOLS = {
  [UNIT_RAW]                    = "",
  [UNIT_VOLTS]                  = "V",
  [UNIT_AMPS]                   = "A",
  [UNIT_MILLIAMPS]              = "mA",
  [UNIT_KTS]                    = "kts",
  [UNIT_METERS_PER_SECOND]      = "m/s",
  [UNIT_FEET_PER_SECOND]        = "f/s",
  [UNIT_KMH]                    = "km/h",
  [UNIT_MPH]                    = "mph",
  [UNIT_METERS]                 = "m",
  [UNIT_FEET]                   = "ft",
  [UNIT_CELSIUS]                = "°C",
  [UNIT_FAHRENHEIT]             = "°F",
  [UNIT_PERCENT]                = "%",
  [UNIT_MAH]                    = "mAh",
  [UNIT_WATTS]                  = "W",
  [UNIT_MILLIWATTS]             = "mW",
  [UNIT_DB]                     = "dB",
  [UNIT_RPMS]                   = "rpm",
  [UNIT_G]                      = "g",
  [UNIT_DEGREE]                 = "°",
  [UNIT_RADIANS]                = "rad",
  [UNIT_MILLILITERS]            = "ml",
  [UNIT_FLOZ]                   = "fl.oz",
  [UNIT_MILLILITERS_PER_MINUTE] = "ml/min",
  [UNIT_HOURS]                  = "h",
  [UNIT_MINUTES]                = "min",
  [UNIT_SECONDS]                = "s",
}

local function getUnitSymbol(unit)
  return UNIT_SYMBOLS[unit] or ""
end

return {
    getUnitSymbol = getUnitSymbol
}