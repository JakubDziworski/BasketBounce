Utils = class("Utils")
Utils.__index = Utils

function Utils:tableContains(tabl,value)
    if(tabl == nil or value == nil) then return false end
    for k,v in pairs(tabl) do
        if(v == value)then return true end
    end
    return false
end
