print("Minimizing script memory usage...")

-- Step 1:
-- - Remove 'id = "xxx"' entries from fields table in the page files.
-- - Remove 'simulatorResponse = {...}' entries in MSP files.
-- - Remove double spaces in ui.lua to make it compile on some b&w radios.

local genericReplacements = {
    {
        -- Replace rf2.call with pcall. Comment out for debugging minimized scripts.
        files = { "/SCRIPTS/RF2/", "/WIDGETS/" },
        match = "rf2%.call",
        replace = "rf2%.call",
        replacement = "pcall"
    },
    {
        -- Remove debug info from release builds.
        files = "/SCRIPTS/RF2/COMPILE/compile.lua",
        match = "loadScript%(script, %'cd%'%)",
        replace = "loadScript%(script, %'cd%'%)",
        replacement = "loadScript(script, 'c')"
    },
    {
        -- Replace --[NIR with --[[ to comment out debug code that should not be in a release
        files = { "/SCRIPTS/RF2/", "/WIDGETS/" },
        match = "--%[NIR",
        replace = "--%[NIR",
        replacement = "--[["
    },
    {
        -- Remove id = "xxx" from the fields table in page files. This id is not used by the official Rotorflight scripts.
        files = "/SCRIPTS/RF2/PAGES/",
        match = "^%s-fields%[",
        replace = ",%s-id = \"(.-)\"",
        replacement = ""
    },
    {
        -- Remove 'name = "xxx", ' from the adjfunctions fields table in adj_teller.lua.
        -- Names are only used for debugging and are expensive.
        files = "/SCRIPTS/RF2/adj_teller.lua",
        match = "name = \"(.-)\", ",
        replace = "name = \"(.-)\", ",
        replacement = ""
    },
    {
        -- Remove simulatorResponse = {...} from MSP APIs, since they are not used outside the simulator.
        files = "/SCRIPTS/RF2/MSP/",
        match = "simulatorResponse = {(.-)}",
        replace = "simulatorResponse = {(.-)},?",
        replacement = ""
    },
    {
        -- large files (>10K)  can't sometimes be compiled on some b&w radios without making it smaller. This is done by removing all double spaces.
        files = { "/SCRIPTS/RF2/adj_teller.lua", "/SCRIPTS/RF2/rf2tlm_sensors.lua", "/SCRIPTS/RF2/MSP/mspEscAm32.lua" },
        match = "  ",
        replace = "  ",
        replacement = ""
    },
    {
        -- This is also done by replacing ' = ' with '='.
        files = { "/SCRIPTS/RF2/adj_teller.lua", "/SCRIPTS/RF2/rf2tlm_sensors.lua", "/SCRIPTS/RF2/MSP/mspEscAm32.lua" },
        match = " = ",
        replace = " = ",
        replacement = "="
    },
    {
        -- This is also done by removing comments.
        files = { "/SCRIPTS/RF2/adj_teller.lua", "/SCRIPTS/RF2/rf2tlm_sensors.lua", "/SCRIPTS/RF2/MSP/mspEscAm32.lua" },
        match = "%-%-.*",
        replace = "%-%-.*",
        replacement = ""
    },
    {
        -- Remove 'rf2.lcdNeedsInvalidate*' since it isn't used on EdgeTX/OpenTX
        files = { "/SCRIPTS/RF2/" },
        match = "rf2%.lcdNeedsInvalidate.*",
        replace = "rf2%.lcdNeedsInvalidate.*",
        replacement = ""
    },
}

local function processFile(filename, genericReplacement)
    local input_file = io.open(filename, "r")
    if input_file then
        local temp_file = io.open(filename .. ".tmp", "w") -- Temporary file to store changes

        for line in input_file:lines() do
            local new_line = line
            if string.match(new_line, genericReplacement.match) then
                --print("Found '" .. genericReplacement.match .. "'")
                new_line = string.gsub(new_line, genericReplacement.replace, genericReplacement.replacement)
            end
            temp_file:write(new_line .. "\n")
        end

        input_file:close()
        temp_file:close()

        -- Replace original file with the updated file
        os.remove(filename)
        os.rename(filename .. ".tmp", filename)

        print("Updated " .. filename)
    else
        print("Could not open " .. filename)
    end
end

local function processGenericReplacements()
    local files = assert(loadfile("./SCRIPTS/RF2/COMPILE/scripts.lua"))
    local i = 1
    while true do
        local script = files(i)
        i = i + 1
        if script == nil then break end
        for _, genericReplacement in ipairs(genericReplacements) do
            if type(genericReplacement.files) == "table" then
                for _, partialFileName in ipairs(genericReplacement.files) do
                    if string.match(script, partialFileName) then
                        processFile("." .. script, genericReplacement)
                    end
                end
            elseif string.match(script, genericReplacement.files) then
                processFile("." .. script, genericReplacement)
            end
        end
    end
end

processGenericReplacements()

-- Step 2: Replace specific keys with indexes in the specified files.

local mspRcTuningReplacements = {
    files = {
        "SCRIPTS/RF2/MSP/mspRcTuning.lua",
        "SCRIPTS/RF2/MSP/RATES/ACTUAL.lua",
        "SCRIPTS/RF2/MSP/RATES/BETAFL.lua",
        "SCRIPTS/RF2/MSP/RATES/KISS.lua",
        "SCRIPTS/RF2/MSP/RATES/NONE.lua",
        "SCRIPTS/RF2/MSP/RATES/QUICK.lua",
        "SCRIPTS/RF2/MSP/RATES/RACEFL.lua",
        "SCRIPTS/RF2/MSP/RATES/ROTORFL.lua",
        "SCRIPTS/RF2/PAGES/rates.lua",
        "SCRIPTS/RF2/PAGES/rate_dynamics.lua"
    },

    { ".roll_rcRates", "[0]" },
    { ".roll_rcExpo", "[1]" },
    { ".roll_rates", "[2]" },

    { ".pitch_rcRates", "[3]" },
    { ".pitch_rcExpo", "[4]" },
    { ".pitch_rates", "[5]" },

    { ".yaw_rcRates", "[6]" },
    { ".yaw_rcExpo", "[7]" },
    { ".yaw_rates", "[8]" },

    { ".collective_rcRates", "[9]" },
    { ".collective_rcExpo", "[10]" },
    { ".collective_rates", "[11]" },

    { ".roll_response_time", "[12]" },
    { ".roll_accel_limit", "[13]" },
    { ".pitch_response_time", "[14]" },
    { ".pitch_accel_limit", "[15]" },
    { ".yaw_response_time", "[16]" },
    { ".yaw_accel_limit", "[17]" },
    { ".collective_response_time", "[18]" },
    { ".collective_accel_limit", "[19]" },

    { ".roll_setpoint_boost_gain", "[20]" },
    { ".roll_setpoint_boost_cutoff", "[21]" },
    { ".pitch_setpoint_boost_gain", "[22]" },
    { ".pitch_setpoint_boost_cutoff", "[23]" },
    { ".yaw_setpoint_boost_gain", "[24]" },
    { ".yaw_setpoint_boost_cutoff", "[25]" },
    { ".collective_setpoint_boost_gain", "[26]" },
    { ".collective_setpoint_boost_cutoff", "[27]" },
    { ".yaw_dynamic_ceiling_gain", "[28]" },
    { ".yaw_dynamic_deadband_gain", "[29]" },
    { ".yaw_dynamic_deadband_filter", "[30]" },
    { ".cyclic_ring", "[31]" },
    { ".cyclic_polar", "[32]" },
}

local mspPidTuningReplacements = {
    files = { "SCRIPTS/RF2/MSP/mspPidTuning.lua", "SCRIPTS/RF2/PAGES/profile_pids.lua" },

    { ".roll_p", "[0]" },
    { ".roll_i", "[1]" },
    { ".roll_d", "[2]" },
    { ".roll_f", "[3]" },
    { ".pitch_p", "[4]" },
    { ".pitch_i", "[5]" },
    { ".pitch_d", "[6]" },
    { ".pitch_f", "[7]" },
    { ".yaw_p", "[8]" },
    { ".yaw_i", "[9]" },
    { ".yaw_d", "[10]" },
    { ".yaw_f", "[11]" },
    { ".roll_b", "[12]" },
    { ".pitch_b", "[13]" },
    { ".yaw_b", "[14]" },
    { ".roll_o", "[15]" },
    { ".pitch_o", "[16]" },
}

local mspPidProfileReplacements = {
    files = { "SCRIPTS/RF2/MSP/mspPidProfile.lua", "SCRIPTS/RF2/PAGES/profile_various.lua", "SCRIPTS/RF2/PAGES/profile_pidcon.lua" },

    { ".pid_mode", "[0]" },
    { ".error_decay_time_ground", "[1]" },
    { ".error_decay_time_cyclic", "[2]" },
    { ".error_decay_time_yaw", "[3]" },
    { ".error_decay_limit_cyclic", "[4]" },
    { ".error_decay_limit_yaw", "[5]" },
    { ".error_rotation", "[6]" },
    { ".error_limit_roll", "[7]" },
    { ".error_limit_pitch", "[8]" },
    { ".error_limit_yaw", "[9]" },
    { ".gyro_cutoff_roll", "[10]" },
    { ".gyro_cutoff_pitch", "[11]" },
    { ".gyro_cutoff_yaw", "[12]" },
    { ".dterm_cutoff_roll", "[13]" },
    { ".dterm_cutoff_pitch", "[14]" },
    { ".dterm_cutoff_yaw", "[15]" },
    { ".iterm_relax_type", "[16]" },
    { ".iterm_relax_cutoff_roll", "[17]" },
    { ".iterm_relax_cutoff_pitch", "[18]" },
    { ".iterm_relax_cutoff_yaw", "[19]" },
    { ".yaw_cw_stop_gain", "[20]" },
    { ".yaw_ccw_stop_gain", "[21]" },
    { ".yaw_precomp_cutoff", "[22]" },
    { ".yaw_cyclic_ff_gain", "[23]" },
    { ".yaw_collective_ff_gain", "[24]" },
    { ".yaw_collective_dynamic_gain", "[25]" },
    { ".yaw_collective_dynamic_decay", "[26]" },
    { ".pitch_collective_ff_gain", "[27]" },
    { ".angle_level_strength", "[28]" },
    { ".angle_level_limit", "[29]" },
    { ".horizon_level_strength", "[30]" },
    { ".trainer_gain", "[31]" },
    { ".trainer_angle_limit", "[32]" },
    { ".cyclic_cross_coupling_gain", "[33]" },
    { ".cyclic_cross_coupling_ratio", "[34]" },
    { ".cyclic_cross_coupling_cutoff", "[35]" },
    { ".offset_limit_roll", "[36]" },
    { ".offset_limit_pitch", "[37]" },
    { ".bterm_cutoff_roll", "[38]" },
    { ".bterm_cutoff_pitch", "[39]" },
    { ".bterm_cutoff_yaw", "[40]" },
    { ".yaw_inertia_precomp_gain", "[41]" },
    { ".yaw_inertia_precomp_cutoff", "[42]" },
}

local mspEscAm32Replacements = {
    files = { "SCRIPTS/RF2/MSP/mspEscAm32.lua", "SCRIPTS/RF2/PAGES/esc_am32_form.lua" },

    { ".esc_signature", "[0]" },
    { ".esc_command", "[1]" },
    { ".reserved_0", "[2]" },
    { ".eeprom_version", "[3]" },
    { ".reserved_1", "[4]" },
    { ".version_major", "[5]" },
    { ".version_minor", "[6]" },
    { ".max_ramp", "[7]" },
    { ".minimum_duty_cycle", "[8]" },
    { ".disable_stick_calibration", "[9]" },
    { ".absolute_voltage_cutoff", "[10]" },
    { ".current_p", "[11]" },
    { ".current_i", "[12]" },
    { ".current_d", "[13]" },
    { ".active_brake_power", "[14]" },
    { ".reserved_eeprom_3_0", "[15]" },
    { ".reserved_eeprom_3_1", "[16]" },
    { ".reserved_eeprom_3_2", "[17]" },
    { ".reserved_eeprom_3_3", "[18]" },
    { ".timing_advance_encoding", "[19]" },
    { ".motor_direction", "[20]" },
    { ".bidirectional_mode", "[21]" },
    { ".sinusoidal_startup", "[22]" },
    { ".complementary_pwm", "[23]" },
    { ".variable_pwm_frequency", "[24]" },
    { ".stuck_rotor_protection", "[25]" },
    { ".timing_advance", "[26]" },
    { ".pwm_frequency", "[27]" },
    { ".startup_power", "[28]" },
    { ".motor_kv", "[29]" },
    { ".motor_poles", "[30]" },
    { ".brake_on_stop", "[31]" },
    { ".stall_protection", "[32]" },
    { ".beep_volume", "[33]" },
    { ".interval_telemetry", "[34]" },
    { ".servo_low_threshold", "[35]" },
    { ".servo_high_threshold", "[36]" },
    { ".servo_neutral", "[37]" },
    { ".servo_dead_band", "[38]" },
    { ".low_voltage_cutoff", "[39]" },
    { ".low_voltage_threshold", "[40]" },
    { ".rc_car_reversing", "[41]" },
    { ".use_hall_sensors", "[42]" },
    { ".sine_mode_range", "[43]" },
    { ".brake_strength", "[44]" },
    { ".running_brake_level", "[45]" },
    { ".temperature_limit", "[46]" },
    { ".current_limit", "[47]" },
    { ".sine_mode_power", "[48]" },
    { ".esc_protocol", "[49]" },
    { ".auto_advance", "[50]" }
}

local rf2tlm_sensorsReplacements = {
    files = { "SCRIPTS/RF2/rf2tlm_sensors.lua" },

    { "sid=0x", "[0]=0x" },  -- sid becomes [0]
    { ", name=", ", " },     -- name becomes [1]
    { ", unit=", ", " },     -- unit becomes [2]
    { ", prec=", ", " },     -- prec becomes [3]
    { ", dec=", ", " },      -- dec becomes [4]
    {
        "sensor.dec(data, ptr)",
        "(sensor[4])(data, ptr)"
    },
    {
        "setTelemetryValue(sensor.sid, 0, 0, 0, sensor.unit, sensor.prec, sensor.name)",
        "setTelemetryValue(sensor[0], 0, 0, 0, sensor[2], sensor[3], sensor[1])"
    },
    {
        "result[sensor.sid]={ name=sensor.name, sensor.unit, sensor.prec, sensor.dec }",
        "result[sensor[0]]={ sensor[1], sensor[2], sensor[3], sensor[4] }" -- Note: explicitly 1-based so numbers won't change
    },
}

local rf2tlmReplacements = {
    files = { "SCRIPTS/RF2/rf2tlm.lua" },

    {
        "setTelemetryValue(sid, 0, 0, val, sensor.unit, sensor.prec, sensor.name)",
        "setTelemetryValue(sid, 0, 0, val, sensor[2], sensor[3], sensor[1])"
    },
    {
        "sensor.dec(data, ptr)",
        "(sensor[4])(data, ptr)"
    },
}

function escapeLuaPattern(s)
    return (string.gsub(s, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1"))
end

local function replace(r)
    for _, filename in ipairs(r.files) do
        --print("Opening " .. filename)
        local input_file = io.open(filename, "r")
        if input_file then
            local temp_file = io.open(filename .. ".tmp", "w") -- Temporary file to store changes

            for line in input_file:lines() do
                local new_line = line
                for _, v in ipairs(r) do
                    --new_line = string.gsub(new_line, v[1], v[2])
                    new_line = string.gsub(new_line, escapeLuaPattern(v[1]), v[2])
                end
                temp_file:write(new_line .. "\n")
            end

            input_file:close()
            temp_file:close()

            -- Replace original file with the updated file
            os.remove(filename)
            os.rename(filename .. ".tmp", filename)

            print("Updated " .. filename)
        else
            print("Could not open " .. filename)
        end
    end
end

replace(mspRcTuningReplacements)
replace(mspPidTuningReplacements)
replace(mspPidProfileReplacements)
replace(mspEscAm32Replacements)
replace(rf2tlm_sensorsReplacements)
replace(rf2tlmReplacements)
