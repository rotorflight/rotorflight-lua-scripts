local function hasSensor(name)
    local sensorsDiscovered
    if getFieldInfo ~= nil then
        -- EdgeTX
        sensorsDiscovered = getFieldInfo(name) ~= nil
    else
        -- OpenTX
        sensorsDiscovered = getValue(name) ~= nil
    end
    return sensorsDiscovered
end

return hasSensor