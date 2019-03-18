-- Really helpful
-- https://en.cppreference.com/w/cpp/language/translation_phases
-- 

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

local fastOctTest = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7
}

local fastDecTest = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9
}

local fastHexTest = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9
    a = 10,
    A = 10,
    b = 11,
    B = 11,
    c = 12,
    C = 12,
    d = 13,
    D = 13,
    e = 14,
    E = 14,
    f = 15,
    F = 15
}

local fastNumberSufixTest = {
    u = true,
    U = true,
    l = true,
    L = true
}

local fastWhiteSpaceTest = {
    [" "] = true,
    ["\t"] = true,
    ["\n"] = true,
    ["\v"] = true,
    ["\f"] = true
}

local fastAlphaTest = {
}

local fastVarTest = {
    ["0"] = 0,
    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
    ["7"] = 7,
    ["8"] = 8,
    ["9"] = 9,
    _ = true
}

do
    local s = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    for i = 1, #s do
        local c = string.sub(s, i, i)
        fastAlphaTest[c] = true
        fastVarTest[c] = true
    end
end

local fastEscTest = {
    ["a"] = "\a",
    ["b"] = "\b",
    ["f"] = "\f",
    ["n"] = "\n",
    ["r"] = "\r",
    ["t"] = "\t",
    ["v"] = "\v"
}

local function pullEscCode(str, start)
    local c = string.sub(str, start, start)
    if fastOctTest[c] then -- pull a octal number, 3 digits max
        local cnt = 1
        local i = start + 1
        while cnt <= 2 do
            c = string.sub(str, i, i)
            if not fastOctTest[c] then
                break
            end
            i = i + 1
            cnt = cnt + 1
        end
        return start, i - 1
    elseif (c == "x") or (c == "X") then
        local i = start + 1
        while true do
            c = string.sub(str, i, i)
            if not fastHexTest[c] then
                break
            end
            i = i + 1
        end
        i = i - 1
        if i == start then
            return nil
        else
            return start, i
        end
    elseif c == "u" then
        if (#str - start) < 4 then
            return nil
        end
        return start, start + 4
    elseif c == "U" then
        if (#str - start) < 8 then
            return nil
        end
        return start, start + 8
    end
    return start, start
end

local function pullCharLiteral(str, start)
    local len = #str
    if ((len - start) < 2) or (not (string.sub(str, start, start) == "'")) then
        return nil
    else
        local i = start + 1
        local c = string.sub(str, i, i)
        if c == "\\" then
            local ok, e = pullEscCode(str, i + 1)
            if not ok then
                return nil
            end
            i = e
        end
        i = i + 1
        c = string.sub(str, i, i)
        if c == "'" then
            return start, i
        else
            return nil
        end
    end
end

local function pullStringLiteral(str, start)
    local startChar = string.sub(str, start, start)
    if startChar ~= "\"" then
        return nil
    else
        local i = start + 1
        local totalLen = #str
        local wasBackSlash = false
        while i <= totalLen do
            local c = string.sub(str, i, i)
            if wasBackSlash then
                wasBackSlash = false
                local ok, e = pullEscCode(str, i)
                if not ok then
                    return nil
                end
                i = e
            else
                if c == "\\" then
                    wasBackSlash = true
                elseif c == "\"" then
                    return start, i
                elseif c == "\n" then
                    return nil
                end
            end
            i = i + 1
        end
        return nil
    end
end

local function pullNumberLiteral(str, start)
    local c = string.sub(str, start, start)
    local i = start
    if c == "0" then
        i = i + 1
        c = string.sub(str, i, i)
        if (c == "x") or (c == "X") then
            repeat
                i = i + 1
                c = string.sub(str, i, i)
            until not fastHexTest[c]
        elseif (c == "b") or (c == "B") then
            repeat
                i = i + 1
                c = string.sub(str, i, i)
            until (c ~= "0") and (c ~= "1")
        elseif fastOctTest[c] then
            repeat
                i = i + 1
                c = string.sub(str, i, i)
            until not fastOctTest[c]
        end
    end
    while fastNumberSufixTest[c] do
        i = i + 1
        c = string.sub(str, i, i)
    end
    return start, i - 1
end

local function skipWhiteSpace(str, i)
    while fastWhiteSpaceTest[string.sub(str, i, i)] do
        i = i + 1
    end
    return i
end

local function tokenise(str)

local function process(str, defaultMacros)
    str = removeComments(removeLineJoins(str))
    
end
