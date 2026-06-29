-- Usage: local fontTools = rf2.executeScript("F/fontTools")()

local fontSizes = { XXLSIZE, DBLSIZE, MIDSIZE, STDSIZE, SMLSIZE, TINSIZE }
local fontNames = { "XXLSIZE", "DBLSIZE", "MIDSIZE", "STDSIZE", "SMLSIZE", "TINSIZE" }

local xlSize = _G["XLSIZE"]
if type(xlSize) == "number" then
    table.insert(fontSizes, 2, xlSize)
    table.insert(fontNames, 2, "XLSIZE")
end

-- Return the measured font height, or -1 when the test string exceeds maxW
local function measureFont(fontConst, maxW, testString)
    local testText = testString or "X"
    local textW, textH = lcd.sizeText(testText, fontConst)

    if maxW and textW > maxW then return -1 end

    return textH
end

local function getFontIndex(fontConst)
    for i = 1, #fontSizes do
        if fontSizes[i] == fontConst then return i end
    end

    return nil
end

-- Pick the largest fitting font, optionally limited to fonts smaller than
-- smallerThanFont
-- heightTolerance keeps the height fit check slightly forgiving because rendered text
-- can end up a couple of pixels taller than a strict sizeText limit suggests
-- If nothing fits, return the smallest available font anyway so callers do
-- not need a separate nil fallback path
local function selectFont(availableH, availableW, testString, smallerThanFont, heightTolerance)
    local maxH = availableH + (heightTolerance or 2)
    local startIndex = 1

    if smallerThanFont then
        local maxIndex = getFontIndex(smallerThanFont)
        if maxIndex then startIndex = math.min(maxIndex + 1, #fontSizes) end
    end

    for i = startIndex, #fontSizes do
        local fontConst = fontSizes[i]
        if fontConst then
            local fontH = measureFont(fontConst, availableW, testString)
            if fontH > 0 and fontH <= maxH then return fontConst end
        end
    end

    return fontSizes[#fontSizes]
end

-- Return the smallest font from a list of already selected font constants
-- Pass the font values returned by selectFont(...); because fontSizes is
-- ordered from largest to smallest, this just keeps the highest matching index
local function pickSmallestFont(...)
    local selectedFont = nil
    local selectedIndex = nil

    for i = 1, select("#", ...) do
        local fontConst = select(i, ...)
        if fontConst then
            for j = 1, #fontSizes do
                if fontSizes[j] == fontConst and (not selectedIndex or j > selectedIndex) then
                    selectedFont = fontConst
                    selectedIndex = j
                    break
                end
            end
        end
    end

    return selectedFont or STDSIZE
end

-- Return the symbolic EdgeTX font name for a font constant when needed
-- for e.g. debug output
local function getFontName(fontConst)
    local index = getFontIndex(fontConst)
    if index then return fontNames[index] end

    return nil
end

return {
    measureFont = measureFont,
    selectFont = selectFont,
    pickSmallestFont = pickSmallestFont,
    getFontName = getFontName
}
