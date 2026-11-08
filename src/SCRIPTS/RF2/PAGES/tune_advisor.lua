-- Tune Advisor: reads the FC's in-flight rate-loop statistics (MSP/mspTuneAdvisor.lua,
-- rotorflight-firmware flight/tune_advisor.c) and turns them into concrete changes, one
-- axis at a time: what was measured, which setting to change (named by the page it lives
-- on, in the units that page shows), and why. The FC only measures; the rules below are
-- the advice. They match the Ethos suite's Tune Advisor page.
--
-- Every text line is a read-only field so the page scrolls on small screens (the LCD
-- page scrolls with the focused field). The lines are rebuilt when new data arrives.

local template = rf2.executeScript(rf2.radio.template)
local mspTuneAdvisor = rf2.useApi("mspTuneAdvisor")
local margin = template.margin
local indent = template.indent
local lineSpacing = template.lineSpacing
local sp = template.listSpacing.field
local yMinLim = rf2.radio.yMinLimit
local x = margin
local narrow = LCD_W < 300          -- 128/212 wide: labels and values on separate lines

local labels = {}
local fields = {}
local axisNames = { [0] = "Roll", "Pitch", "Yaw" }
local cutoffNames = { [0] = "Cutoff point R", "Cutoff point P", "Cutoff point Y" }
local selectedAxis = 0
local lastSignature = nil
local unsupported = false
local lastPoll = 0
local POLL_INTERVAL = 2

-- Feed-forward match
local FF_MIN_COUNT = 1000           -- 10 s of usable 40-200 deg/s stick
local FF_MIN_CORR = 0.85
local FF_HOT = 1.15
local FF_LOW = 0.85
local FF_STEP_MAX = 0.2             -- change FF by at most 20% per step
local GAIN_MAX = 1000
-- Collective fact
local BAND_MIN_COUNT = 300
local COLL_SPREAD = 1.25
-- Full stick
local FULL_MIN_COUNT = 100
local FULL_SAT_SHARE = 0.5
local FULL_REACH = 0.8
-- Stick releases
local STOPS_MIN = 10
local REBOUND_BAD = 0.12
local ITERM_PUSH = 0.03
local P_STEP = 1.2
local CUTOFF_STEP = 0.8             -- lower cutoff = more relax, less bounce-back
local CUTOFF_MIN = 1

-- Rate columns that scale the whole curve linearly, per rates_type, as the Rates page
-- shows them (MSP/RATES/*.lua: shown value = raw / scale). The other types (Betaflight,
-- Raceflight, KISS) get a percentage instead.
local RATES_ACTUAL, RATES_QUICK, RATES_ROTORFLIGHT = 4, 5, 6
local LINEAR_RATES = {
    [RATES_ACTUAL] = {
        { key = "rcRate", name = "Center Sens", scale = 0.1, max = 200 },
        { key = "sRate", name = "Max Rate", scale = 0.1, max = 200 },
    },
    [RATES_QUICK] = {
        { key = "rcRate", name = "RC Rate", scale = 100, max = 255 },
        { key = "sRate", name = "Max Rate", scale = 0.1, max = 100 },
    },
    [RATES_ROTORFLIGHT] = {
        { key = "rcRate", name = "Rate", scale = 0.2, max = 200 },
    },
}

local function round(v) return math.floor(v + 0.5) end
local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end

local function ffJudged(a) return a.ffCount >= FF_MIN_COUNT and a.ffCorr >= FF_MIN_CORR end
local function ffOff(a) return ffJudged(a) and (a.ffGain > FF_HOT or a.ffGain < FF_LOW) end

-- Max rate asked at full stick (deg/s), where the rates type makes it direct: the
-- firmware's rate curves (fc/rc_rates.c) at full stick.
local function maxRateAsked(a)
    if a.ratesType == RATES_ACTUAL then return math.max(a.rcRate, a.sRate) * 10 end
    if a.ratesType == RATES_QUICK then return math.max(a.sRate * 10, a.rcRate * 2) end
    if a.ratesType == RATES_ROTORFLIGHT then return a.rcRate * 5 end
    return nil
end

local function rateText(raw, col)
    local v = raw / col.scale
    return col.scale > 1 and string.format("%.2f", v) or string.format("%d", round(v))
end

-- Suggests scaling the rate curve by k (e.g. 1.25 = 25% faster everywhere)
local function rateActions(a, name, k, act)
    local cols = LINEAR_RATES[a.ratesType]
    if not cols then
        act(string.format(k > 1 and "Rates > %s: all rates about %d%% higher"
            or "Rates > %s: all rates about %d%% lower", name, round(math.abs(k - 1) * 100)))
        return
    end
    for _, col in ipairs(cols) do
        local raw = a[col.key]
        local newRaw = clamp(round(raw * k), 1, col.max)
        act(string.format("Rates > %s > %s: %s -> %s", name, col.name, rateText(raw, col), rateText(newRaw, col)))
    end
end

local function rateActionCount(a)
    local cols = LINEAR_RATES[a.ratesType]
    return cols and #cols or 1
end

-- Returns response, stops, actions, whys for one axis (0 roll, 1 pitch, 2 yaw).
-- A change and its reason go in together or not at all, so a reason never shows for a
-- change that was left out: a later change first checks room(). The first change
-- (fly more, FF with its rates, or full-stick rates) always fits. The reasons for
-- changes stay within three; only the closing collective fact can be cut.
local function advise(a, axis)
    local name = axisNames[axis]
    local actions, whys = {}, {}
    local function room(n) return #actions + n <= 3 end
    local function act(s) if #actions < 3 then actions[#actions + 1] = s end end
    local function why(s) if #whys < 3 then whys[#whys + 1] = s end end

    local response
    if a.ffCount < FF_MIN_COUNT then
        response = string.format("Needs more flying (%d%%)", math.floor(100 * a.ffCount / FF_MIN_COUNT))
        act(axis == 0 and "Fly rolls in rate mode, centre the stick after each"
            or axis == 1 and "Fly flips in rate mode, centre the stick after each"
            or "Fly pirouettes in rate mode, centre the stick after each")
        why("Data builds up while you fly in rate mode.")
    elseif a.ffCorr < FF_MIN_CORR then
        response = "Too uneven to judge"
        why("The response varies too much to judge. Common in 3D.")
    elseif ffOff(a) then
        local g = a.ffGain
        local hot = g > FF_HOT
        response = string.format(hot and "%d%% faster than asked" or "%d%% slower than asked", round(math.abs(g - 1) * 100))
        if a.F > 0 then
            local newF = clamp(round(a.F * clamp(1 / g, 1 - FF_STEP_MAX, 1 + FF_STEP_MAX)), 1, GAIN_MAX)
            act(string.format("PID Gains > %s > FF: %d -> %d", name, a.F, newF))
            -- Keep the stick feel: FF x rate is what the pilot feels
            rateActions(a, name, a.F / newF, act)
            why(hot and "The heli turns faster than the stick asks for." or "The heli turns slower than the stick asks for.")
            why("Changing FF and the rates together keeps the stick feel.")
        else
            why("This axis has no FF, so its PID gains set the response.")
        end
    else
        response = "Matches the stick"
        local asked = maxRateAsked(a)
        if axis ~= 2 and asked and a.fullCount >= FULL_MIN_COUNT
                and a.fullSatCount >= FULL_SAT_SHARE * a.fullCount
                and a.fullMaxRate < FULL_REACH * asked and room(rateActionCount(a)) then
            rateActions(a, name, a.fullMaxRate / asked, act)
            why(string.format("Full stick asks %d deg/s but the heli tops out at %d.", asked, a.fullMaxRate))
        end
    end

    local stops
    if a.releases < STOPS_MIN then
        stops = string.format("Needs more stops (%d/%d)", a.releases, STOPS_MIN)
    else
        local rebound = round(a.meanRebound * 100)
        stops = string.format("%d%% bounce-back", rebound)
        if a.meanRebound >= REBOUND_BAD then
            if a.meanIterm >= ITERM_PUSH and a.relaxCutoff > CUTOFF_MIN and room(1) then
                act(string.format("PID Controller > %s: %d -> %d", cutoffNames[axis], a.relaxCutoff,
                    clamp(round(a.relaxCutoff * CUTOFF_STEP), CUTOFF_MIN, a.relaxCutoff - 1)))
                why("After a stop, the I-term pushes the heli back.")
            elseif ffOff(a) and a.F > 0 then
                why(string.format("Stops bounce back %d%%. Fix FF first, then check again.", rebound))
            elseif room(1) then
                act(string.format("PID Gains > %s > P: %d -> %d", name, a.P, clamp(round(a.P * P_STEP), a.P + 1, GAIN_MAX)))
                why(string.format("Stops bounce back %d%%. More P brakes them (or add B).", rebound))
            end
        end
    end

    -- Least important last: a fact, no action
    if ffJudged(a) then
        local lo, hi = a.collBands[1], a.collBands[3]
        if lo.count >= BAND_MIN_COUNT and hi.count >= BAND_MIN_COUNT and lo.gain > 0 and hi.gain > 0 then
            local spread = math.max(lo.gain, hi.gain) / math.min(lo.gain, hi.gain)
            if spread >= COLL_SPREAD then
                why(string.format(hi.gain > lo.gain and "It turns %d%% faster at high collective than at low."
                    or "It turns %d%% faster at low collective than at high.", round((spread - 1) * 100)))
            end
        end
    end

    if #actions == 0 then
        act("No change suggested")
        if #whys == 0 then why("The heli answers the stick as asked.") end
    end
    return response, stops, actions, whys
end

-- Text width: lcd.sizeText where the radio has it, else an average character width
local charW = narrow and 5 or 9
local function textWidth(s)
    if lcd.sizeText then
        local w = lcd.sizeText(s, rf2.radio.textSize)
        if w then return w end
    end
    return #s * charW
end

-- A word too wide for a line of its own is cut into pieces that fit
local function wrap(text, maxW, out)
    local line = ""
    for word in string.gmatch(text, "%S+") do
        local candidate = (line == "") and word or (line .. " " .. word)
        if textWidth(candidate) <= maxW then
            line = candidate
        else
            if line ~= "" then out[#out + 1] = line end
            while #word > 1 and textWidth(word) > maxW do
                local n = #word - 1
                while n > 1 and textWidth(string.sub(word, 1, n)) > maxW do n = n - 1 end
                out[#out + 1] = string.sub(word, 1, n)
                word = string.sub(word, n + 1)
            end
            line = word
        end
    end
    if line ~= "" then out[#out + 1] = line end
end

local page

local function requestAxis()
    lastPoll = rf2.clock()
    mspTuneAdvisor.getAxis(selectedAxis, page.onReceived, page, page.onError)
end

-- Rebuilds every field after the Axis selector from the latest data
local function buildLines(data, response, stops, actions, whys)
    for i = #fields, 2, -1 do fields[i] = nil end
    local y = fields[1].y
    local function incY(val) y = y + val return y end
    local textX = x + indent
    local maxW = LCD_W - textX - margin

    local function text(s, xPos)
        fields[#fields + 1] = { x = xPos, y = incY(lineSpacing), data = { value = s }, readOnly = true }
    end
    local function pair(label, value)
        if narrow then
            text(label, x)
            text(value, textX)
        else
            fields[#fields + 1] = { t = label, x = x, y = incY(lineSpacing), sp = x + sp, data = { value = value }, readOnly = true }
        end
    end
    local function section(title, items)
        if #items == 0 then return end
        incY(lineSpacing * 0.25)
        text(title, x)
        for _, s in ipairs(items) do
            local lines = {}
            wrap(s, maxW, lines)
            for _, l in ipairs(lines) do text(l, textX) end
        end
    end

    if unsupported then
        pair("Flight data", "Needs newer firmware")
    else
        pair("Flight data", string.format("%dm %02ds, %s", math.floor(data.seconds / 60), data.seconds % 60,
            data.collecting and "collecting" or "paused"))
        pair("Response", response)
        pair("Stops", stops)
        section("Suggested changes", actions)
        section("Why", whys)
    end

    incY(lineSpacing * 0.25)
    fields[#fields + 1] = { t = "[Clear data]", x = x, y = incY(lineSpacing), preEdit = page.onClickClear }
end

fields[1] = { t = "Axis", x = x, y = yMinLim, sp = x + (narrow and sp * 0.6 or sp),
    data = { value = 0, min = 0, max = 2, table = axisNames },
    postEdit = function(field, self)
        selectedAxis = field.data.value
        lastSignature = nil
        requestAxis()
    end }

page = {
    read = function(self)
        requestAxis()
    end,
    write       = nil,
    title       = "Tune Advisor",
    labels      = labels,
    fields      = fields,
    readOnly    = true,

    timer = function(self)
        if not unsupported and rf2.mspQueue:isProcessed() and rf2.clock() - lastPoll >= POLL_INTERVAL then
            requestAxis()
        end
    end,

    onReceived = function(self, d)
        unsupported = false
        if d.axis ~= selectedAxis then
            requestAxis()           -- the axis changed while this request was out
            return
        end
        local signature = ((d.seconds * 2 + (d.collecting and 1 or 0)) * 4 + d.axis) * 31
            + d.ffCount + d.releases + d.fullCount + d.F + d.P + d.relaxCutoff
            + (d.ratesType * 256 + d.rcRate) * 256 + d.sRate
        if signature == lastSignature then return end
        lastSignature = signature
        local response, stops, actions, whys = advise(d, selectedAxis)
        buildLines(d, response, stops, actions, whys)
        rf2.onPageReady(self)        -- rebuild the page (important for ui_lvgl)
        rf2.lcdNeedsInvalidate = true
    end,

    -- The queue retries without limit, so an error here is the FC's MSP error reply:
    -- firmware without the command. Say so once and stop polling; changing Axis asks again.
    onError = function(self)
        if unsupported then return end
        unsupported = true
        lastSignature = nil
        buildLines(nil)
        rf2.onPageReady(self)
        rf2.lcdNeedsInvalidate = true
    end,

    onClickClear = function(field, self)
        mspTuneAdvisor.clear(function()
            lastSignature = nil
            requestAxis()
        end, page, page.onError)
    end,
}

return page
