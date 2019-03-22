local keywords = {
    "auto",
    "double",
    "int",
    "struct",
    "break",
    "else",
    "long",
    "switch",
    "case",
    "enum",
    "register",
    "typedef",
    "char",
    "extern",
    "return",
    "union",
    "const",
    "float",
    "short",
    "unsigned",
    "continue",
    "for",
    "signed",
    "void",
    "default",
    "goto",
    "sizeof",
    "volatile",
    "do",
    "if",
    "static",
    "while"
}

local fastOct = {}
local fastDec = {}
local fastHex = {}
local fastAlpha = {}
local fastAlphaUnder = {"_" = true}
local fastSeperator = {}

do
    local i = 48
    local v = 0
    local c
    while i <= 55 do
        c = string.char(i)
        fastOct[c] = v
        fastDec[c] = v
        fastHex[c] = v
        i = i + 1
        v = v + 1
    end
    while i <= 57 do
        c = string.char(i)
        fastDec[c] = v
        fastHex[c] = v
        i = i + 1
        v = v + 1
    end
    i = 65
    local c2
    while i <= 70 do
        c = string.char(i)
        c2 = string.char(i + 32)
        fastHex[c] = v
        fastHex[c2] = v
        fastAlpha[c] = true
        fastAlpha[c2] = true
        fastAlphaUnder[c] = true
        fastAlphaUnder[c2] = true
        i = i + 1
        v = v + 1
    end
    while i <= 90 do
        c = string.char(i)
        c2 = string.char(i + 32)
        fastAlpha[c] = true
        fastAlpha[c2] = true
        fastAlphaUnder[c] = true
        fastAlphaUnder[c2] = true
        i = i + 1
    end
end

local function startsWith(s1, s2)
    if (#s1 < #s2) or (s1 == s2) then
        return false
    end
    return string.sub(s1, 1, #s2) == s2
end

local function pullKeyword(str)
    for i=1, #keywords do
        if startsWith(str, keywords[i]) then
            local s = keywords[i]
            return {#s, s}
        end
    end
    return
end

local opCont = {
    ["{"] = true,
    ["}"] = true,
    ["("] = true,
    [")"] = true,
    ["["] = true,
    ["]"] = true,
    [";"] = true,
    [","] = true,
    ["."] = true,
    [":"] = true,
    ["+"] = {["+"] = true, ["="] = true},
    ["-"] = {["-"] = true, ["="] = true, [">"] = true},
    ["*"] = {["="] = true},
    ["/"] = {["="] = true},
    ["%"] = {["="] = true},
    ["<"] = {["<"] = {["="] = true}, ["="] = true},
    [">"] = {[">"] = {["="] = true}, ["="] = true},
    ["&"] = {["&"] = true, ["="] = true},
    ["^"] = {["="] = true},
    ["|"] = {["|"] = true, ["="] = true},
    ["?"] = true,
    ["!"] = {["="] = true},
    ["~"] = true,
    ["="] = {["="] = true}
}

local function pullOperator(str)
    local length = #str
    if length == 0 then return end
    local i = 1
    local c
    local o = opCont
    while i <= length do
        c = string.sub(str, i, i)
        o = o[c]
        if not o then
            if i == 1 then return end
            return string.sub(str, 1, i - 1)
        end
        i = i + 1
        if o == true then
            return string.sub(str, 1, i)
        end
    end
    return str
end

local function findCharsByList(str, start, list)
    local length = #str
    if length == 0 then return end
    local i = start
    local c
    while i <= length do
        c = string.sub(str, i, i)
        if not list[c] then
            i = i - start
            if i == 0 then return end
            return i
        end
    end
    return length - start + 1
end

local function pullNumber(str)
    local length = #str
    if length == 0 then return end
    local c = string.sub(str, 1, 1)
    if c == "0" then
        if length == 1 then return {1, 0} end
        c = string.sub(str, 2, 2)
        if (c == "x") or (c == "X") then
            local r = findCharsByList(str, 3, fastHex)
            if not r then return end
            local s = string.sub(str, 1, r + 2)
        else
            local r = findCharsByList(str, 2, fastOct)
            if not r then return end
            return string.sub(str, 1, r + 2)
        end
    end
    local r = findCharsByList(str, 1, fastDec)
    if not r then
        

local function pullIdentifier(str)
    local length = #str
    if length == 0 then
        return
    end
    local s1 = string.sub(str, 1, 1)
    if not fastAlphaUnder[s1] then
        return
    end
    local i = findCharsByList(str, )
    return str
end

local function tokenise(txt)
    local tokenList = {}
    while #txt > 0 do
        local v = pullKeyword(txt)
        if v then
            tokenList[#tokenList + 1] = {"key", v}
        else
            v = pull
