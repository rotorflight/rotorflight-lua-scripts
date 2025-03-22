local function getDefaults()
    local data = {}
    data.pid_mode = { min = 0, max = 250 }
    data.error_decay_time_ground = { min = 0, max = 250, scale = 10 }
    data.error_decay_time_cyclic = { min = 0, max = 250, scale = 10 }
    data.error_decay_time_yaw = { min = 0, max = 250, scale = 10 }
    data.error_decay_limit_cyclic = { min = 0, max = 250 }
    data.error_decay_limit_yaw = { min = 0, max = 250 }
    data.error_rotation = { min = 0, max = 1, table = { [0] = "OFF", "ON" } }
    data.error_limit_roll = { min = 0, max = 180 }
    data.error_limit_pitch = { min = 0, max = 180 }
    data.error_limit_yaw = { min = 0, max = 180 }
    data.gyro_cutoff_roll = { min = 0, max = 250 }
    data.gyro_cutoff_pitch = { min = 0, max = 250 }
    data.gyro_cutoff_yaw = { min = 0, max = 250 }
    data.dterm_cutoff_roll = { min = 0, max = 250 }
    data.dterm_cutoff_pitch = { min = 0, max = 250 }
    data.dterm_cutoff_yaw = { min = 0, max = 250 }
    data.iterm_relax_type = { min = 0, max = 2, table = { [0] = "OFF", "RP", "RPY" } }
    data.iterm_relax_cutoff_roll = { min = 1, max = 100 }
    data.iterm_relax_cutoff_pitch = { min = 1, max = 100 }
    data.iterm_relax_cutoff_yaw = { min = 1, max = 100 }
    data.yaw_cw_stop_gain = { min = 25, max = 250 }
    data.yaw_ccw_stop_gain = { min = 25, max = 250 }
    data.yaw_precomp_cutoff = { min = 0, max = 250 }
    data.yaw_cyclic_ff_gain = { min = 0, max = 250 }
    data.yaw_collective_ff_gain = { min = 0, max = 250 }
    if rf2.apiVersion < 12.08 then
        data.yaw_collective_dynamic_gain = { min = 0, max = 250 }
        data.yaw_collective_dynamic_decay = { min = 0, max = 250 }
    end
    data.pitch_collective_ff_gain = { min = 0, max = 250 }
    data.angle_level_strength = { min = 25, max = 255 }
    data.angle_level_limit = { min = 10, max = 80 }
    data.horizon_level_strength = { min = 0, max = 200 }
    data.trainer_gain = { min = 0, max = 250 }
    data.trainer_angle_limit = { min = 0, max = 250 }
    data.cyclic_cross_coupling_gain =  { min = 0, max = 250 }
    data.cyclic_cross_coupling_ratio =  { min = 0, max = 200 }
    data.cyclic_cross_coupling_cutoff =  { min = 1, max = 250 }
    data.offset_limit_roll = { min = 0, max = 180 }
    data.offset_limit_pitch = { min = 0, max = 180 }
    data.bterm_cutoff_roll = { min = 0, max = 250 }
    data.bterm_cutoff_pitch = { min = 0, max = 250 }
    data.bterm_cutoff_yaw = { min = 0, max = 250 }
    if rf2.apiVersion >= 12.08 then
        data.yaw_inertia_precomp_gain = { min = 0, max = 250 }
        data.yaw_inertia_precomp_cutoff = { min = 0, max = 250, scale = 10 }
    end
    return data
end

local function getPidProfile(callback, callbackParam, data)
    data = data or getDefaults()
    local message = {
        command = 94, -- MSP_PID_PROFILE
        processReply = function(self, buf)
            data.pid_mode.value = rf2.mspHelper.readU8(buf)
            data.error_decay_time_ground.value = rf2.mspHelper.readU8(buf)
            data.error_decay_time_cyclic.value = rf2.mspHelper.readU8(buf)
            data.error_decay_time_yaw.value = rf2.mspHelper.readU8(buf)
            data.error_decay_limit_cyclic.value = rf2.mspHelper.readU8(buf)
            data.error_decay_limit_yaw.value = rf2.mspHelper.readU8(buf)
            data.error_rotation.value = rf2.mspHelper.readU8(buf)
            data.error_limit_roll.value = rf2.mspHelper.readU8(buf)
            data.error_limit_pitch.value = rf2.mspHelper.readU8(buf)
            data.error_limit_yaw.value = rf2.mspHelper.readU8(buf)
            data.gyro_cutoff_roll.value = rf2.mspHelper.readU8(buf)
            data.gyro_cutoff_pitch.value = rf2.mspHelper.readU8(buf)
            data.gyro_cutoff_yaw.value = rf2.mspHelper.readU8(buf)
            data.dterm_cutoff_roll.value = rf2.mspHelper.readU8(buf)
            data.dterm_cutoff_pitch.value = rf2.mspHelper.readU8(buf)
            data.dterm_cutoff_yaw.value = rf2.mspHelper.readU8(buf)
            data.iterm_relax_type.value = rf2.mspHelper.readU8(buf)
            data.iterm_relax_cutoff_roll.value = rf2.mspHelper.readU8(buf)
            data.iterm_relax_cutoff_pitch.value = rf2.mspHelper.readU8(buf)
            data.iterm_relax_cutoff_yaw.value = rf2.mspHelper.readU8(buf)
            data.yaw_cw_stop_gain.value = rf2.mspHelper.readU8(buf)
            data.yaw_ccw_stop_gain.value = rf2.mspHelper.readU8(buf)
            data.yaw_precomp_cutoff.value = rf2.mspHelper.readU8(buf)
            data.yaw_cyclic_ff_gain.value = rf2.mspHelper.readU8(buf)
            data.yaw_collective_ff_gain.value = rf2.mspHelper.readU8(buf)
            if rf2.apiVersion < 12.08 then
                data.yaw_collective_dynamic_gain.value = rf2.mspHelper.readU8(buf)
                data.yaw_collective_dynamic_decay.value = rf2.mspHelper.readU8(buf)
            else
                buf.offset = buf.offset + 2
            end
            data.pitch_collective_ff_gain.value = rf2.mspHelper.readU8(buf)
            data.angle_level_strength.value = rf2.mspHelper.readU8(buf)
            data.angle_level_limit.value = rf2.mspHelper.readU8(buf)
            data.horizon_level_strength.value = rf2.mspHelper.readU8(buf)
            data.trainer_gain.value = rf2.mspHelper.readU8(buf)
            data.trainer_angle_limit.value = rf2.mspHelper.readU8(buf)
            data.cyclic_cross_coupling_gain.value =  rf2.mspHelper.readU8(buf)
            data.cyclic_cross_coupling_ratio.value =  rf2.mspHelper.readU8(buf)
            data.cyclic_cross_coupling_cutoff.value =  rf2.mspHelper.readU8(buf)
            data.offset_limit_roll.value = rf2.mspHelper.readU8(buf)
            data.offset_limit_pitch.value = rf2.mspHelper.readU8(buf)
            data.bterm_cutoff_roll.value = rf2.mspHelper.readU8(buf)
            data.bterm_cutoff_pitch.value = rf2.mspHelper.readU8(buf)
            data.bterm_cutoff_yaw.value = rf2.mspHelper.readU8(buf)
            if rf2.apiVersion >= 12.08 then
                data.yaw_inertia_precomp_gain.value = rf2.mspHelper.readU8(buf)
                data.yaw_inertia_precomp_cutoff.value = rf2.mspHelper.readU8(buf)
            end
            callback(callbackParam, data)
        end,
        simulatorResponse = { 3, 25, 250, 0, 12, 0, 1, 30, 30, 45, 50, 50, 100, 15, 15, 20, 2, 10, 10, 15, 100, 100, 5, 0, 30, 0, 25, 0, 40, 55, 40, 75, 20, 25, 0, 15, 45, 45, 15, 15, 20, 0, 0 },
    }
    rf2.mspQueue:add(message)
end

local function setPidProfile(data)
    local message = {
        command = 95, -- MSP_SET_PID_PROFILE
        payload = {},
        simulatorResponse = {}
    }
    rf2.mspHelper.writeU8(message.payload, data.pid_mode.value)
    rf2.mspHelper.writeU8(message.payload, data.error_decay_time_ground.value)
    rf2.mspHelper.writeU8(message.payload, data.error_decay_time_cyclic.value)
    rf2.mspHelper.writeU8(message.payload, data.error_decay_time_yaw.value)
    rf2.mspHelper.writeU8(message.payload, data.error_decay_limit_cyclic.value)
    rf2.mspHelper.writeU8(message.payload, data.error_decay_limit_yaw.value)
    rf2.mspHelper.writeU8(message.payload, data.error_rotation.value)
    rf2.mspHelper.writeU8(message.payload, data.error_limit_roll.value)
    rf2.mspHelper.writeU8(message.payload, data.error_limit_pitch.value)
    rf2.mspHelper.writeU8(message.payload, data.error_limit_yaw.value)
    rf2.mspHelper.writeU8(message.payload, data.gyro_cutoff_roll.value)
    rf2.mspHelper.writeU8(message.payload, data.gyro_cutoff_pitch.value)
    rf2.mspHelper.writeU8(message.payload, data.gyro_cutoff_yaw.value)
    rf2.mspHelper.writeU8(message.payload, data.dterm_cutoff_roll.value)
    rf2.mspHelper.writeU8(message.payload, data.dterm_cutoff_pitch.value)
    rf2.mspHelper.writeU8(message.payload, data.dterm_cutoff_yaw.value)
    rf2.mspHelper.writeU8(message.payload, data.iterm_relax_type.value)
    rf2.mspHelper.writeU8(message.payload, data.iterm_relax_cutoff_roll.value)
    rf2.mspHelper.writeU8(message.payload, data.iterm_relax_cutoff_pitch.value)
    rf2.mspHelper.writeU8(message.payload, data.iterm_relax_cutoff_yaw.value)
    rf2.mspHelper.writeU8(message.payload, data.yaw_cw_stop_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.yaw_ccw_stop_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.yaw_precomp_cutoff.value)
    rf2.mspHelper.writeU8(message.payload, data.yaw_cyclic_ff_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.yaw_collective_ff_gain.value)
    if rf2.apiVersion < 12.08 then
        rf2.mspHelper.writeU8(message.payload, data.yaw_collective_dynamic_gain.value)
        rf2.mspHelper.writeU8(message.payload, data.yaw_collective_dynamic_decay.value)
    else
        rf2.mspHelper.writeU8(message.payload, 0)
        rf2.mspHelper.writeU8(message.payload, 0)
    end
    rf2.mspHelper.writeU8(message.payload, data.pitch_collective_ff_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.angle_level_strength.value)
    rf2.mspHelper.writeU8(message.payload, data.angle_level_limit.value)
    rf2.mspHelper.writeU8(message.payload, data.horizon_level_strength.value)
    rf2.mspHelper.writeU8(message.payload, data.trainer_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.trainer_angle_limit.value)
    rf2.mspHelper.writeU8(message.payload, data.cyclic_cross_coupling_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.cyclic_cross_coupling_ratio.value)
    rf2.mspHelper.writeU8(message.payload, data.cyclic_cross_coupling_cutoff.value)
    rf2.mspHelper.writeU8(message.payload, data.offset_limit_roll.value)
    rf2.mspHelper.writeU8(message.payload, data.offset_limit_pitch.value)
    rf2.mspHelper.writeU8(message.payload, data.bterm_cutoff_roll.value)
    rf2.mspHelper.writeU8(message.payload, data.bterm_cutoff_pitch.value)
    rf2.mspHelper.writeU8(message.payload, data.bterm_cutoff_yaw.value)
    if rf2.apiVersion >= 12.08 then
        rf2.mspHelper.writeU8(message.payload, data.yaw_inertia_precomp_gain.value)
        rf2.mspHelper.writeU8(message.payload, data.yaw_inertia_precomp_cutoff.value)
    end
    rf2.mspQueue:add(message)
end

return {
    read = getPidProfile,
    write = setPidProfile,
    getDefaults = getDefaults
}