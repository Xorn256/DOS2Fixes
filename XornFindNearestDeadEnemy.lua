---@param target string|integer|ObjectHandle Character UUID or handle or NetID
---@return string Closest character GUID to target
local function XornFindNearestCharacter(target, radius)
    local esvChar = Ext.GetCharacter(target)
    if not esvChar then return end

    local nearbyChars = esvChar:GetNearbyCharacters(radius)
    local targetGUID = esvChar.MyGuid
    local nearbyDist = 30.0
    local nearbyGUID
    for i, charGUID in ipairs(nearbyChars) do
        if IsTagged(charGUID, "Dead") == 1 and
        CharacterIsDeadOrFeign(charGUID) == 0 and
        CharacterIsEnemy(charGUID, target) == 1 then
            local d = GetDistanceTo(targetGUID, charGUID)
            if d < nearbyDist then
                nearbyDist = d
                nearbyGUID = charGUID
            end
        end
    end

    return nearbyGUID
end

Ext.NewQuery(XornFindNearestCharacter, "Xorn_QRY_Find_Nearest_Ally", "[in](CHARACTERGUID)_Target, [out](CHARACTERGUID)_NearbyCharacter")