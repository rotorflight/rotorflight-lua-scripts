local function loadTranslations(l)
    local file = "LANG/" .. l .. ".lua"
    local chunk, err = rf2.loadScript(file)
    if not chunk then
        -- It's normal for a language file not to exist, so we don't log an error.
        -- The fallback mechanism will handle it.
        return nil
    end
    local ok, result = pcall(chunk)
    if not ok then
        return nil
    end
    return result
end

---
-- Loads the translation file for the current system language.
-- It falls back to English ('en') if the system language file is not found,
-- and then to an empty table if English is also not found.
-- @return table The translations table.
local function getTranslations()
    local settings = getGeneralSettings()
    local lang = settings.language
    local translations = loadTranslations(lang) or loadTranslations("en") or {}

    function translations.t(key)
        return translations[key] or key
    end

    return translations
end

return getTranslations()