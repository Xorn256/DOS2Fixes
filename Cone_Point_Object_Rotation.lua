---@param object IEoCServerObject
---@param rotation number Angle in degrees
---@param distance number Distance away from object in meters
---@return vec3
local function FindPointRotatedFromObject(object, rotation, distance)
    local _, ry, _ = Osi.GetRotation(object.MyGuid)
    local newRot = math.rad(ry + rotation)
    local rotMat = Ext.Math.BuildRotation3({0,1,0}, newRot)
    local pos = object.WorldPos
    local newPos = {pos[1] - rotMat[7] * distance, pos[2], pos[3] - rotMat[9] * distance}
    return newPos
end

---@param position vec3
---@param radius number
---@param object IEoCServerObject|nil size of object that must fit into position
---@return vec3
local function FindValidGridPosition(position, radius, object)
    local fitObject = object ~= nil and object.MyGuid or ""
    local newPos = table.pack(Osi.FindValidPosition(position[1], position[2], position[3], radius, fitObject))
    return newPos
end

---@param object IEoCServerObject|nil
---@param skill string|nil
---@param origin vec3
---@param target vec3
---@param duration number
---@param surfaceType SurfaceType
---@param growTimer number
---@param growStep number
---@param shape integer
---@param radius number
---@param angleOrBase number
---@param height number
local function CreateZone(object, skill, origin, target, duration, surfaceType, growTimer, growStep, shape, radius, angleOrBase, height)
    local validTarget = FindValidGridPosition(target, 2, object)
    if validTarget[1] ~= nil then
        local surface = Ext.Surface.Action.Create("ZoneAction")
        surface.Position = origin
        surface.Target = validTarget
        surface.Duration = duration
        surface.SurfaceType = surfaceType
        surface.GrowTimer = growTimer
        surface.GrowStep = growStep
        surface.Shape = shape
        surface.Radius = radius
        surface.AngleOrBase = angleOrBase
        surface.MaxHeight = height

        if object ~= nil and object.Stats ~= nil then
            surface.OwnerHandle = object.Handle
            if skill ~= nil then
                local skillData = Ext.Stats.Get(skill)
                local damageList, deathType = Game.Math.GetSkillDamage(skillData, object.Stats, false, false, origin, validTarget, object.Stats.Level, false)
                surface.DamageList:CopyFrom(damageList)
                surface.DeathType = deathType
                surface.SkillId =  skill
            end
        end

        Ext.Surface.Action.Execute(surface)
    end
end

function CreateTestZones()
    local duration = 6
    local growTimer = 0.05
    local growStep = 8
    local coneDistance = 8
    local width = 1
    local height = 2
    local angle = 35

    local fane = Ext.Entity.GetCharacter("02a77f1f-872b-49ca-91ab-32098c443beb")
    local coneEndPoint = FindPointRotatedFromObject(fane, 0, coneDistance)
    local coneEdgeDistance = coneDistance/math.cos(math.rad(angle))

    ---Outward cone from caster
    --CreateZone(fane, "Cone_Flamebreath", fane.WorldPos, coneEndPoint, duration, "Fire", growTimer, growStep, 0, coneDistance, 5, height)

    ---Inward zone from cone front
    CreateZone(nil, nil, coneEndPoint, fane.WorldPos, duration, "Water", growTimer, growStep, 1, coneDistance, width, height)

    ---Inward zones from cone edges
    local oilZoneOrigin = FindPointRotatedFromObject(fane, angle, coneEdgeDistance)
    CreateZone(nil, nil, oilZoneOrigin, fane.WorldPos, duration, "Oil", growTimer, growStep, 1, coneEdgeDistance, width, height)

    local poisonZoneOrigin = FindPointRotatedFromObject(fane, -angle, coneEdgeDistance)
    CreateZone(nil, nil, poisonZoneOrigin, fane.WorldPos, duration, "Poison", growTimer, growStep, 1, coneEdgeDistance, width, height)
end