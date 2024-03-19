local toolName = "TNS|Rotorflight 2|TNE"
chdir("/SCRIPTS/RF2")

apiVersion = 0
mcuId = nil
runningInSimulator = string.sub(select(2,getVersion()), -4) == "simu"

-- valid values are 'en', 'fr', 'de', ...
-- adding a new languages, add a file in LANGUAGES folder & add it to COMPILE/scripts.lua
local locale = 'en'

local run = nil
local scriptsCompiled = assert(loadScript("COMPILE/scripts_compiled.lua"))()

local function createProtectedTable(originalTable)
    return setmetatable({}, {
        __index = function(_, key)
            if originalTable[key] == nil then
                error("Error : Key '" .. key .. "' does not exist", 2)
            else
                return originalTable[key]
            end
        end
    })
end

-- log gracefully key used but not translated
unsafeLocalization = assert(loadScript('languages/'.. locale ..'.lua'))()

-- localization is used at compile time and runtime
localization = createProtectedTable(unsafeLocalization)

if scriptsCompiled then
    protocol = assert(loadScript("protocols.lua"))()
    radio = assert(loadScript("radios.lua"))().msp

    assert(loadScript(protocol.mspTransport))()
    assert(loadScript("MSP/common.lua"))()
    run = assert(loadScript("ui.lua"))()
else
    run = assert(loadScript("COMPILE/compile.lua"))()
end

return { run=run }
