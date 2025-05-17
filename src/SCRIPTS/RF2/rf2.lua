rf2 = {
    baseDir = "/SCRIPTS/RF2/",
    runningInSimulator = string.sub(select(2, getVersion()), -4) == "simu",

    loadScript = loadScript,

    log = function(str)
        if rf2.runningInSimulator then
            print(tostring(str))
        else
            if not rf2.logfile then
                rf2.logfile = io.open("/LOGS/rf2.log", "a")
            end
            io.write(rf2.logfile, string.format("%.2f ", rf2.clock()) .. tostring(str) .. "\n")
        end
    end,

    print = function(str)
        if rf2.runningInSimulator then
            print("RF2: " .. tostring(str))
        else
            --serialWrite(tostring(str).."\r\n") -- 115200 bps
            --rf2.log(str)
        end
    end,

    useApi = function(apiName)
        collectgarbage()
        return assert(rf2.loadScript(rf2.baseDir.."MSP/" .. apiName .. ".lua"))()
    end,

    clock = function()
        return getTime() / 100
    end,

    apiVersion = nil,

    isEdgeTx = select(6, getVersion()) == "EdgeTX",

    units = {
        percentage = "%",
        degrees = del and "°" or "@", -- OpenTX uses @
        degreesPerSecond = (del and "°" or "@") .. "/s",
        herz = " Hz",
        seconds = " s",
        milliseconds = " ms",
        volt = "V",
        celsius = " C",
        rpm = " RPM"
    },

    -- Color radios on EdgeTX >= 2.11 do not send EVT_VIRTUAL_ENTER anymore after EVT_VIRTUAL_ENTER_LONG
    useKillEnterBreak = not(lcd.setColor and select(3, getVersion()) >= 2 and select(4, getVersion()) >= 11),

    --[[
    showMemoryUsage = function(remark)
        if not rf2.oldMemoryUsage then
            collectgarbage()
            rf2.oldMemoryUsage = collectgarbage("count")
            rf2.print(string.format("MEM %s: %d", remark, rf2.oldMemoryUsage*1024))
            return
        end
        collectgarbage()
        local currentMemoryUsage = collectgarbage("count")
        local increment = currentMemoryUsage - rf2.oldMemoryUsage
        if increment ~= 0 then
            rf2.print(string.format("MEM %s: %d (+%d)", remark, currentMemoryUsage*1024, increment*1024))
        end
        rf2.oldMemoryUsage = currentMemoryUsage
    end,

    printGlobals = function(maxDepth)
        local seen = {}

        local function dumpTable(tbl, indent, depth)
            if seen[tbl] or depth > maxDepth then
                rf2.print(indent .. "*already visited or max depth*")
                return
            end
            seen[tbl] = true

            for k, v in pairs(tbl) do
                local keyStr = tostring(k)
                local vType = type(v)
                if vType == "table" then
                    rf2.print(indent .. keyStr .. " = {")
                    dumpTable(v, indent .. "  ", depth + 1)
                    rf2.print(indent .. "}")
                else
                    rf2.print(indent .. keyStr .. " = " .. tostring(v))
                end
            end
        end

        dumpTable(_G, "", 0)
    end,

    isInteger = function(n)
        return type(n) == "number" and n == math.floor(n)
    end,
    --]]
}
