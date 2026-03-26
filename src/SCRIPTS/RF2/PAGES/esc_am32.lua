local template = rf2.executeScript(rf2.radio.template)
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local tableSpacing = template.tableSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = margin
local y = yMinLim - lineSpacing
local function incY(val) y = y + val return y end
local labels = {}
local fields = {}
local escParameters = nil
local escCount, selectedEsc = 0, 0
local receivedEscParameters   -- forward function declaration needed

labels[1] = { t = "ESC not ready, waiting...", x = x, y = incY(lineSpacing) }
fields[1] = { t = nil, x = 0, y = 0, data = nil, readOnly = true } -- dummy field since ui.lua expects at least one field

local function clearForm(page)
    y = yMinLim - lineSpacing
    labels = {}
    fields = {}
    page.labels = labels
    page.fields = fields
    collectgarbage()
end

local endEscEditing = function(field, page)
    clearForm(page) -- needed to free some memory
    selectedEsc = field.data.value
    rf2.useApi("mspEsc4wif").selectEsc(selectedEsc)
    rf2.useApi("mspEscAm32").read(receivedEscParameters, page)
end

local function addField(text, data, w)
    if not data.hidden then
        fields[#fields + 1] = { t = text, x = x, y = incY(lineSpacing), sp = x + sp, w = w, data = data }
    end
end

local function buildForm(page)
    clearForm(page)

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
end

receivedEscParameters = function(page, data)
    escParameters = data
    buildForm(page)
    page.readOnly = false
    rf2.onPageReady(page)
end

local function onProcessedMspStatus(page, status)
    escCount = status.motorCount
end

return {
    read = function(self)
        if not self.isReady then rf2.onPageReady(self) end
        rf2.useApi("mspEsc4wif").selectEsc(selectedEsc)
        rf2.useApi("mspStatus").getStatus(onProcessedMspStatus, self)
        rf2.useApi("mspEscAm32").read(receivedEscParameters, self)
    end,
    write = function(self)
        rf2.useApi("mspEscAm32").write(escParameters)
        rf2.settingsSaved(false, false)
    end,
    unload = function(self)
        rf2.useApi("mspEsc4wif").clearEscSelection()
    end,
    title       = "AM32",
    labels      = labels,
    fields      = fields,
    readOnly    = true
}
