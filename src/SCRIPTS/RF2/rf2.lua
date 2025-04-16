rf2 = {
    baseDir = "/SCRIPTS/RF2/",
    runningInSimulator = string.sub(select(2,getVersion()), -4) == "simu",
    enable_serial_debug = false,
    enable_log_to_file = false,

    loadScript = function(file, opt)
        return loadScript(rf2.baseDir .. file, opt)
    end,

    log_to_file = function(str)
        if not rf2.logfile then
            rf2.logfile = io.open("/LOGS/rf2.log", "a")
        end
        -- write only if LOGS dir exist (diferent from LOG)
        if rf2.logfile then
            io.write(rf2.logfile, string.format("%.2f ", rf2.clock()) .. tostring(str) .. "\n")
        end
    end,

    print = function(fmt, ...)
        local str = string.format("[rf2] " .. fmt, ...)
        if rf2.runningInSimulator then
            print(str)
        elseif rf2.enable_serial_debug==true then
            serialWrite(str.."\r\n") -- 115200 bps
        else
            -- no need to log
        end
        if rf2.enable_log_to_file==true then
            rf2.log_to_file(str)
        end
    end,
    log = function(fmt, ...)
        rf2.print(fmt, ...)
    end,

    useApi = function(apiName)
        collectgarbage()
        return assert(rf2.loadScript("MSP/" .. apiName .. ".lua"))()
    end,

    clock = function()
        return getTime() / 100
    end,

    apiVersion = nil,

    isEdgeTx = function()
        return del ~= nil
    end,

    units = {
        percentage = "%",
        degrees = del and "°" or "@", -- OpenTX uses @
        herz = " Hz",
        seconds = " s",
        volt = "V",
        celsius = " C"
    },

    mspQueue = {},

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
