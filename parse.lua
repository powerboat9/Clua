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

local function pullStringLiteral(str, start)
    local startChar = string.sub(str, start, start)
    if startChar ~= "\"" then
        error("Not a string literal, 2)
    else
        local i = start + 1
        local totalLen = #str
        local wasBackSlash = false
        while true do
            if i > totalLen then
                return nil
            end
            local c = string.sub(str, i, i)
            if wasBackSlash then
                wasBackSlash = false
            else
                if c == "\\" then
                    wasBackSlash = true
                elseif c == "\"" then
                    return start, i
                end
            end
            i = i + 1
        end
    end
end

local function pull

local function parse(code)
    local 
