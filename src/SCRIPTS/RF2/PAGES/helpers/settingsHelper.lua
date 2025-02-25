function addDirtyTrackingToTable(originalTable)
    local proxyTable = {}
    local dirty = false
    function proxyTable:resetDirtyFlag() dirty = false end
    function proxyTable:isDirty() return dirty end

    -- Metatable to track changes
    local mt = {
        __index = originalTable,
        __newindex = function(t, key, value)
            if originalTable[key] ~= value then
                dirty = true
                originalTable[key] = value
            end
        end
    }

    setmetatable(proxyTable, mt)
    proxyTable:resetDirtyFlag()
    return proxyTable
end

function saveTable(table, filename)
    local file, err = io.open(filename, "w")
    if not file then return err end

    local function serialize(tbl, indent)
        indent = indent or ""
        local str = "{\n"
        for k, v in pairs(tbl) do
            if type(v) ~= "function" then
                str = str .. indent .. "  [" .. string.format("%q", k) .. "] = "
                if type(v) == "table" then
                    str = str .. serialize(v, indent .. "  ")
                elseif type(v) == "string" then
                    str = str .. string.format("%q", v)
                else
                    str = str .. v
                end
                str = str .. ",\n"
            end
        end
        str = str .. indent .. "}"
        return str
    end

    io.write(file, "return " .. serialize(table))
    io.close(file)
    return nil
end

function loadTable(filename)
    local func, err = rf2.loadScript(filename)
    if not func then return nil, err end
    return func()
end

local function loadSettings()
    local settings, loadErr = loadTable("settings.lua") or {}
    if loadErr then rf2.print(loadErr) end
    return addDirtyTrackingToTable(settings)
end

local function saveSettings(settings)
    if settings:isDirty() then
        local originalTable = getmetatable(settings).__index or settings
        local saveErr = saveTable(originalTable, rf2.baseDir .."settings.lua")
        if saveErr then rf2.print(saveErr) end
    end
end

--[[ Example usage
local myTable = loadSettings()
myTable.a = 2
myTable.b = "dsadsad"
saveSettings(myTable)
--]]

return {
    loadSettings = loadSettings,
    saveSettings = saveSettings
}