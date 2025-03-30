-- This script will replace keys with indexes, in order to minimize memory usage.

local mspRcTuningReplacements = {
    files = { "MSP/mspRcTuning.lua", "MSP/RATES/ACTUAL.lua", "MSP/RATES/BETAFL.lua", "MSP/RATES/KISS.lua", "MSP/RATES/NONE.lua", "MSP/RATES/QUICK.lua", "MSP/RATES/RACEFL.lua", "PAGES/rates.lua", "PAGES/rate_dynamics.lua" },

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

    { "simulatorResponse = {", "--simulatorResponse = {"}
}

local mspPidTuningReplacements = {
    files = { "MSP/mspPidTuning.lua", "PAGES/profile_pids.lua" },

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
    { "simulatorResponse = {", "--simulatorResponse = {"}
}

local mspPidProfileReplacements = {
    files = { "MSP/mspPidProfile.lua", "PAGES/profile_various.lua", "PAGES/profile_pidcon.lua" },

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
    { "simulatorResponse = {", "--simulatorResponse = {"}
}

function replace(r)
    for _, filename in ipairs(r.files) do
        print("Opening ".. "../src/SCRIPTS/RF2/"..filename)
        local input_file = io.open("../src/SCRIPTS/RF2/"..filename, "r")
        if input_file then
            --local temp_file = io.open(filename .. ".tmp", "w") -- Temporary file to store changes
            local temp_file = io.open(filename, "w") -- Temporary file to store changes

            for line in input_file:lines() do
                local new_line = line
                for _, v in ipairs(r) do
                    new_line = string.gsub(new_line, v[1], v[2])
                end
                temp_file:write(new_line .. "\n")
            end

            input_file:close()
            temp_file:close()

            -- Replace original file with the updated file
            --os.remove(filename)
            --os.rename(filename .. ".tmp", filename)

            print("Updated " .. filename)
        else
            print("Could not open " .. filename)
        end
    end
end

replace(mspRcTuningReplacements)
replace(mspPidTuningReplacements)
replace(mspPidProfileReplacements)