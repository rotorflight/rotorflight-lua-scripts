rf2 = {
    baseDir = "/SCRIPTS/RF2/",
    runningInSimulator = string.sub(select(2,getVersion()), -4) == "simu",

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

    units = {
        percentage = "%",
        degrees = del and "°" or "@", -- OpenTX uses @
        herz = " Hz",
    },

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
    --]]
}
