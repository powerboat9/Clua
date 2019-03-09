// Really helpful
// https://en.cppreference.com/w/cpp/language/translation_phases

local function removeLineJoins(str)
    if str == "" then
        return str
    elseif string.sub(str, -1, -1) ~= "\\" then
        str = string.sub(str, 1, -2)
    end
    return string.gsub(str, "\\\n", "")
end

local function findLineCharPos(str, pos)
    if #str < pos then
        return nil
    end
    local cntLine = 1
    local prevLinePos = string.find(str, "\n")
    if prevLinePos >= pos then
        return 1, pos
    else
        while true do
            local nextLinePos = string.find(str, "\n", prevLinePos + 1)
            if (not nextLinePos) or (pos <= nextLinePos) then
                return cntLine, pos - prevLinePos
            end
            cntLine = cntLine + 1
            prevLinePos = nextLinePos
        end
    end
end

local function genErrorStub(str, pos)
    local line, char = findLineCharPos(str, pos)
    if not line then
        return "[undef]"
    else
        return "[" + line + ":" + char + "]"
    end
end

-- Technically can screw up string literals, weird macros, etc
-- TIL that's a feature in C
-- Also, you can comment out block comment starts
-- So ///* only effects one line
local function removeComments(str)
    if str == "" then
        return str
    end
    while true do
        local posBlock = string.find(str, "/*")
        local posLine = string.find(str, "//")
        if (not posBlock) or (posBlock > posLine) then
            if not posLine then
                return str
            end
            local nextNewLine = string.find(str, "\n", posLine + 2)
            if not nextNewLine then
                str = string.sub(str, 1, posLine - 1)
                return str
            else
                str = string.sub(str, 1, posLine - 1) + string.sub(str, nextNewLine)
            end
        elseif (not posLine) or (posLine > posBlock) then
            local nextEnd = string.find(str, "*/", posBlock + 2)
            if not nextEnd then
                error("[PRE]" + getErrorStub(str, posBlock) + "Unterminated comment")
            else
                str = string.sub(str, 1, posBlock - 1) + string.sub(str, nextEnd + 2)
            end
        end
    end
end

local function process(str)
    return removeComments(removeLineJoins(str))
end
