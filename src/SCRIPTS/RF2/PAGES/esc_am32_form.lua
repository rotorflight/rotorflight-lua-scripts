local template = rf2.executeScript(rf2.radio.template)
local indent = template.indent
local lineSpacing = template.lineSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = template.margin
local y = yMinLim - lineSpacing
template = nil

local labels = {}
local fields = {}

local function incY(val) y = y + val return y end

local function addField(text, data, w)
    if not data.hidden then
        fields[#fields + 1] = { t = text, x = x, y = incY(lineSpacing), sp = x + sp, w = w, data = data }
    end
end

local function buildForm(escParameters, escCount, selectedEsc, endEscEditing)
    y = yMinLim - lineSpacing

    if not escParameters then
        labels[1] = { t = "ESC not ready, waiting...", x = x, y = incY(lineSpacing) }
        fields[1] = { t = nil, x = 0, y = 0, data = nil, readOnly = true } -- dummy field since ui.lua expects at least one field
        return labels, fields
    end

    labels[1] = {
        t = escParameters.firmwareVersion,
        x = x,
        y = incY(lineSpacing)
    }

    fields[1] = {
        t = "ESC",
        x = x + indent,
        y = incY(lineSpacing),
        sp = x + sp,
        data = { value = selectedEsc, min = 0, max = escCount - 1, table = { [0] = "1", "2", "3", "4" } },
        postEdit = endEscEditing
    }

    labels[#labels + 1] = { t = "Basic", x = x, y = incY(lineSpacing) }
    addField("Motor direction", escParameters.motor_direction)
    addField("Motor KV", escParameters.motor_kv)
    addField("Motor poles", escParameters.motor_poles)
    addField("Startup power", escParameters.startup_power)
    addField("PWM frequency", escParameters.pwm_frequency)
    addField("Compl. PWM", escParameters.complementary_pwm)
    addField("Brake on stop", escParameters.brake_on_stop)
    addField("Brake strength", escParameters.brake_strength)
    addField("Running brake", escParameters.running_brake_level)
    addField("Beep volume", escParameters.beep_volume)

    labels[#labels + 1] = { t = "Advanced", x = x, y = incY(lineSpacing * 2) }
    addField("Timing", escParameters.timing_advance)
    addField("Stuck rotor prot.", escParameters.stuck_rotor_protection)
    addField("Sinusoidal startup", escParameters.sinusoidal_startup)
    addField("Sine mode power", escParameters.sine_mode_power)
    addField("Sine mode range", escParameters.sine_mode_range)
    addField("Bidir mode", escParameters.bidirectional_mode)
    addField("Protocol", escParameters.esc_protocol, 135)
    addField("Var. PWM freq", escParameters.variable_pwm_frequency)
    addField("Stall protection", escParameters.stall_protection)
    addField("Telemetry interval", escParameters.interval_telemetry)
    addField("Auto advance", escParameters.auto_advance)

    labels[#labels + 1] = { t = "Limits", x = x, y = incY(lineSpacing * 2) }
    addField("Temperature limit", escParameters.temperature_limit)
    addField("Current limit", escParameters.current_limit)
    addField("Low volt. cutoff", escParameters.low_voltage_cutoff)
    addField("Low volt. treshold", escParameters.low_voltage_threshold)
    addField("Servo low treshold", escParameters.servo_low_threshold)
    addField("Servo high treshold", escParameters.servo_high_threshold)
    addField("Servo neutral", escParameters.servo_neutral)
    addField("Servo deadband", escParameters.servo_dead_band)
    addField("RC car reversing", escParameters.rc_car_reversing)
    addField("Use Hall sensors", escParameters.use_hall_sensors)

    return labels, fields
end

return buildForm(...)