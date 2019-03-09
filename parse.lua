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
    

local function pullStatement(str, i)
end

local function parse(str)
    local tree = {}
    local pos = tree
    local consts = {}
    local labels = {}
    local types = {}
    local varTypes = {}
    while true do
        
