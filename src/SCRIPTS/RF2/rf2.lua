rf2 = {
    luaVersion = "2.2.1",
    baseDir = "/SCRIPTS/RF2/",
    runningInSimulator = string.sub(select(2, getVersion()), -4) == "simu",

    loadScript = function(script)
        local startsWith = function(str, prefix)
            return string.sub(str, 1, #prefix) == prefix
        end
        local endsWith = function(str, suffix)
            return suffix == "" or string.sub(str, -#suffix) == suffix
        end
        if not startsWith(script, rf2.baseDir) then
            script = rf2.baseDir .. script
        end
        if not endsWith(script, ".lua") then
            script = script .. ".lua"
        end
        collectgarbage()
        return loadScript(script)
    end,

    executeScript = function(scriptName, ...)
        return assert(rf2.loadScript(scriptName))(...)
    end,

    useApi = function(apiName)
        return rf2.executeScript("MSP/" .. apiName)
    end,

    loadSettings = function()
        return rf2.executeScript("PAGES/helpers/settingsHelper").loadSettings();
    end,

    saveSettings = function(settings)
        return rf2.executeScript("PAGES/helpers/settingsHelper").saveSettings(settings);
    end,

    clock = function()
        return getTime() / 100
    end,

    apiVersion = nil,

    units = {
        percentage = "%",
        degrees = del and "°" or "@", -- OpenTX uses @
        degreesPerSecond = (del and "°" or "@") .. "/s",
        herz = " Hz",
        seconds = " s",
        milliseconds = " ms",
        volt = "V",
        celsius = " C",
        rpm = " RPM",
        meters = " m"
    },

    --[[
    print = function(format, ...)
        local str = string.format("RF2: " .. format, ...)
        if rf2.runningInSimulator then
            print(str)
        else
            --serialWrite(str .. "\r\n") -- 115200 bps
            --rf2.log(str)
        end
    end,

    log = function(str)
        if rf2.runningInSimulator then
            rf2.print(tostring(str))
        else
            if not rf2.logfile then
                rf2.logfile = io.open("/LOGS/rf2.log", "a")
            end
            io.write(rf2.logfile, string.format("%.2f ", rf2.clock()) .. tostring(str) .. "\n")
        end
    end,

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

    dumpTable = function(table, maxDepth)
        local seen = {}
        maxDepth = maxDepth or 2

        local function dumpTableInternal(tbl, indent, depth)
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
                    dumpTableInternal(v, indent .. "  ", depth + 1)
                    rf2.print(indent .. "}")
                else
                    rf2.print(indent .. keyStr .. " = " .. tostring(v))
                end
            end
        end

        dumpTableInternal(table, "", 0)
    end,

    printGlobals = function(maxDepth)
        rf2.dumpTable(_G, maxDepth)
    end,

    isInteger = function(n)
        return type(n) == "number" and n == math.floor(n)
    end,
    --]]
}
