local function toChoiceTable(t, maxChoices)
    local choiceTable = {
        values = {},
        originalTable = t,
        getChoiceKey = function(self, originalKey)
            local value = self.originalTable[originalKey]
            for k, v in pairs(self.values) do
                if v == value then return k end
            end
        end,
        getOriginalKey = function(self, choiceKey)
            local value = self.values[choiceKey]
            for k, v in pairs(self.originalTable) do
                if v == value then return k end
            end
        end
    }

    local sortedKeys = {}

    -- First add any indexes, sorted ascending
    for k, _ in pairs(t) do
        --print(k)
        sortedKeys[#sortedKeys + 1] = tonumber(k)
    end

    table.sort(sortedKeys)

    -- Now add non numerical keys
    for k, _ in pairs(t) do
        if tonumber(k) == nil then
            sortedKeys[#sortedKeys + 1] = k
        end
    end

    -- Finally assemble the choice table
    for _, k in ipairs(sortedKeys) do
        local v = t[k]
        --rf2.print("Adding choice: " .. tostring(v))
        choiceTable.values[#choiceTable.values + 1] = v
        if maxChoices and #choiceTable.values >= maxChoices then
            break
        end
    end

    return choiceTable
end

return { toChoiceTable = toChoiceTable }
