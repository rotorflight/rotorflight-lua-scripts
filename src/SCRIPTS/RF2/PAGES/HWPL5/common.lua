local function getText(array, start, maxLength)
    local tt = {}
    for i = start, start + maxLength do
        local v = array[i]
        if v == 0 then
            break
        end
        table.insert(tt, string.char(v))
    end
    return table.concat(tt)
end

return { getText = getText }