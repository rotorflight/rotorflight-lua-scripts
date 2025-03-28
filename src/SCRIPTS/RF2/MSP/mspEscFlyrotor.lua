local govMode = { [0] = "Ext Governor", "Esc Governor" }
local becVoltage = { [0] = "7.5", "8.0", "8.5", "12" }
local motorDirection =  { [0] = "CW", "CCW" }
local fanControl = { [0] = "Automatic", "Always On" }
local currentGain = { [0] = "-20", "-19", "-18", "-17", "-16", "-15", "-14", "-13", "-12", "-11", "-10",
                            "-9", "-8", "-7", "-6", "-5", "-4", "-3", "-2", "-1",
                            "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
                            "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20" }

local function getDefaults()
    return {
        esc_signature = nil,
        command = nil,
        unknown1 = nil,
        serial_number1 = nil,
        serial_number2 = nil,
        iap_major = nil,
        iap_minor = nil,
        iap_patch = nil,
        fw_major = nil,
        fw_minor = nil,
        fw_patch = nil,
        hw_version = nil,
        unknown2 = nil,
        esc_mode = { min = 0, max = #govMode, table = govMode },
        cell_count = { min = 4, max = 14 },
        low_voltage = { min = 28, max = 38, scale = 10 },
        temperature = { min = 50, max = 135 },
        bec_voltage = { min = 0, max = #becVoltage, table = becVoltage },
        timing = { min = 1, max = 10 },
        motor_direction = { min = 0, max = #motorDirection, table = motorDirection },
        starting_torque = { min = 1, max = 15 },
        response_speed = { min = 1, max = 15 },
        buzzer_volume = { min = 1, max = 5 },
        current_gain = { min = 0, max = #currentGain, table = currentGain },
        fan_control = { min = 0, max = #fanControl, table = fanControl },
        soft_start = { min = 5, max = 55 },
        p_gain = { min = 1, max = 100 },
        i_gain = { min = 1, max = 100 },
        d_gain = { min = 0, max = 100 },
        max_motor_erpm = { min = 0, max = 1000000, mult = 100}
    }
end

function getUInt(buf, length)
    local offset = buf.offset or 1
    local v = 0
    for i = 0, length - 1 do
        v = bit32.bor(v, bit32.lshift(buf[offset + length - 1 - i], i * 8))
    end
    buf.offset = offset + length
    return v
end

local function getEscParameters(callback, callbackParam, data)
    data = data or getDefaults()
    local message = {
        command = 217, -- MSP_ESC_PARAMETERS
        processReply = function(self, buf)
            local signature = rf2.mspHelper.readU8(buf)
            if signature ~= 115 then
                rf2.print("warning: Invalid ESC signature: " .. signature)
                return
            end
            data.esc_signature = signature
            data.command = rf2.mspHelper.readU8(buf)
            data.unknown1 = getUInt(buf, 3)
            data.serial_number1 = getUInt(buf, 4)
            data.serial_number2 = getUInt(buf, 4)
            data.iap_major = rf2.mspHelper.readU8(buf)
            data.iap_minor = rf2.mspHelper.readU8(buf)
            data.iap_patch = rf2.mspHelper.readU8(buf)
            data.fw_major = rf2.mspHelper.readU8(buf)
            data.fw_minor = rf2.mspHelper.readU8(buf)
            data.fw_patch = rf2.mspHelper.readU8(buf)
            data.hw_version = rf2.mspHelper.readU8(buf)
            data.unknown2 = getUInt(buf, 4)
            data.esc_mode.value = rf2.mspHelper.readU8(buf)
            data.cell_count.value = rf2.mspHelper.readU8(buf)
            data.low_voltage.value = rf2.mspHelper.readU8(buf)
            data.temperature.value = rf2.mspHelper.readU8(buf)
            data.bec_voltage.value = rf2.mspHelper.readU8(buf)
            data.timing.value = rf2.mspHelper.readU8(buf)
            data.motor_direction.value = rf2.mspHelper.readU8(buf)
            data.starting_torque.value = rf2.mspHelper.readU8(buf)
            data.response_speed.value = rf2.mspHelper.readU8(buf)
            data.buzzer_volume.value = rf2.mspHelper.readU8(buf)
            data.current_gain.value = rf2.mspHelper.readU8(buf)
            data.fan_control.value = rf2.mspHelper.readU8(buf)
            data.soft_start.value = rf2.mspHelper.readU8(buf)
            data.p_gain.value = getUInt(buf, 2)
            data.i_gain.value = getUInt(buf, 2)
            data.d_gain.value = getUInt(buf, 2)
            data.max_motor_erpm.value = getUInt(buf, 3)
            callback(callbackParam, data)
        end,
        simulatorResponse = { 115, 0, 0, 0, 150, 231, 79, 190, 216, 78, 29, 169, 244, 1, 0, 0, 1, 0, 2, 0, 4, 76, 7, 148, 0, 6, 30, 125, 0, 15, 0, 3, 15, 1, 20, 0, 10, 0, 45, 0, 35, 0, 10, 0, 150, 0 },
        --[[
        simulatorResponse = {
            115,
            0,
            0, 0, 150, -- unknown1
            231, 79, 190, 216, -- serial number1
            78, 29, 169, 244, -- serial number2
            1, 0, 0, -- IAP
            1, 0, 2, -- firmware version
            0, -- hw version 18
            4, 76, 7, 148, -- unknown2
            0, -- esc mode
            6, -- cell count
            30, -- low voltage
            125, -- temperature
            0, -- bec voltage
            15, -- timing
            0, -- motor direction
            3, -- starting torque
            15, -- response speed
            1, -- buzzer volume
            20, -- current gain 33
            0, -- fan control
            10, -- soft start
            0, 45, -- p-gain
            0, 35, -- i-gain
            0, 10, -- d-gain
            0, 150, 0 -- max motor erpm
        }
        --]]
    }
    rf2.mspQueue:add(message)
end

function setUInt(buf, v, length)
    for i = 0, length - 1 do
        buf[#buf + 1] = bit32.band(bit32.rshift(v, (length - 1 - i) * 8), 0xFF)
    end
end

local function setEscParameters(data)
    local message = {
        command = 218, -- MSP_SET_ESC_PARAMETERS
        payload = {},
    }
    rf2.mspHelper.writeU8(message.payload, data.esc_signature)
    rf2.mspHelper.writeU8(message.payload, data.command)
    setUInt(message.payload, data.unknown1, 3)
    setUInt(message.payload, data.serial_number1, 4)
    setUInt(message.payload, data.serial_number2, 4)
    rf2.mspHelper.writeU8(message.payload, data.iap_major)
    rf2.mspHelper.writeU8(message.payload, data.iap_minor)
    rf2.mspHelper.writeU8(message.payload, data.iap_patch)
    rf2.mspHelper.writeU8(message.payload, data.fw_major)
    rf2.mspHelper.writeU8(message.payload, data.fw_minor)
    rf2.mspHelper.writeU8(message.payload, data.fw_patch)
    rf2.mspHelper.writeU8(message.payload, data.hw_version)
    setUInt(message.payload, data.unknown2, 4)
    rf2.mspHelper.writeU8(message.payload, data.esc_mode.value)
    rf2.mspHelper.writeU8(message.payload, data.cell_count.value)
    rf2.mspHelper.writeU8(message.payload, data.low_voltage.value)
    rf2.mspHelper.writeU8(message.payload, data.temperature.value)
    rf2.mspHelper.writeU8(message.payload, data.bec_voltage.value)
    rf2.mspHelper.writeU8(message.payload, data.timing.value)
    rf2.mspHelper.writeU8(message.payload, data.motor_direction.value)
    rf2.mspHelper.writeU8(message.payload, data.starting_torque.value)
    rf2.mspHelper.writeU8(message.payload, data.response_speed.value)
    rf2.mspHelper.writeU8(message.payload, data.buzzer_volume.value)
    rf2.mspHelper.writeU8(message.payload, data.current_gain.value)
    rf2.mspHelper.writeU8(message.payload, data.fan_control.value)
    rf2.mspHelper.writeU8(message.payload, data.soft_start.value)
    setUInt(message.payload, data.p_gain.value, 2)
    setUInt(message.payload, data.i_gain.value, 2)
    setUInt(message.payload, data.d_gain.value, 2)
    setUInt(message.payload, data.max_motor_erpm.value, 3)
    rf2.mspQueue:add(message)
end

return {
    read = getEscParameters,
    write = setEscParameters,
    getDefaults = getDefaults
}