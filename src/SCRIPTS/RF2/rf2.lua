rf2 = {
    rfbaseDir = "/SCRIPTS/RF2/",
    runningInSimulator = string.sub(select(2,getVersion()), -4) == "simu",
    loadScript = loadScript,
    log = function(str)
        local f = io.open("/LOGS/rf2.log", 'a')
        io.write(f, tostring(str) .. "\n")
        io.close(f)
    end,
    print = function(str)
        if rf2.runningInSimulator then
            print(tostring(str))
        else
            serialWrite(tostring(str).."\r\n") -- 115200 bps
            --rf2.log(str)
        end
    end,
    clock = function()
        return getTime() / 100
    end
}
