local i = 1
local scripts = assert(loadScript("COMPILE/scripts.lua"))

collectgarbage()

local function compile()
    local script = scripts(i)
    i = i + 1
    if script then
        lcd.clear()
        lcd.drawText(2, 2, "Compiling...", SMLSIZE)
        lcd.drawText(2, 22, script, SMLSIZE)
        assert(loadScript("/SCRIPTS/"..script, 'c'))
        collectgarbage()
        return 0
    end
    local file = io.open("COMPILE/scripts_compiled.lua", 'w')
    io.write(file, "return true")
    io.close(file)
    assert(loadScript("COMPILE/scripts_compiled.lua", 'c'))
    return 1
end

return compile
