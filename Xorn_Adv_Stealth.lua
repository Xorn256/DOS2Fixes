local NETCHANNEL = "Xorn_Toggle_Interactivity"


local toggleInteractivityStatuses = {
  SNEAKING = true,
  INVISIBLE = true,
  SHADE_INVISIBLE = true
}

---@param character EsvCharacter|EclCharacter
---@param state boolean
local function ToggleInteractivity(character, state)
    character.WalkThrough = state
    character.CanShootThrough = state
end

if Ext.IsServer() then
    Ext.Events.BeforeStatusApply:Subscribe(function(e)
	if toggleInteractivityStatuses[e.Status.StatusId] then
            local esvChar = Ext.Entity.GetGameObject(e.Status.TargetHandle)
            if esvChar ~= nil and Ext.Types.GetObjectType(esvChar) == "esv::Character" then
                ToggleInteractivity(esvChar, true)
                Ext.Net.BroadcastMessage(NETCHANNEL, Ext.Json.Stringify{Character = esvChar.NetID, State = true})
            end
        end
    end)

    Ext.Events.BeforeStatusDelete:Subscribe(function(e)
	if toggleInteractivityStatuses[e.Status.StatusId] then
            local esvChar = Ext.Entity.GetGameObject(e.Status.TargetHandle)
            if esvChar ~= nil and Ext.Types.GetObjectType(esvChar) == "esv::Character" then
                ToggleInteractivity(esvChar, false)
                Ext.Net.BroadcastMessage(NETCHANNEL, Ext.Json.Stringify{Character = esvChar.NetID, State = false})
            end
        end
    end)
end

if Ext.IsClient() then
    Ext.RegisterNetListener(NETCHANNEL, function(_, payload)
        local data = Ext.Json.Parse(payload)
        local eclChar = Ext.Entity.GetCharacter(data.Character)
        if eclChar ~= nil then
            ToggleInteractivity(eclChar, data.State)
        end
    end)
end