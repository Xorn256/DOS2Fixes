---@class OverheadMessager
OverheadMessager = {
    NetChannel = ModuleUUID.."OverheadMessager"
}

---@param type integer
---@param object Guid|ComponentHandle
---@param message string
---@param duration number in seconds
---@param messageIsHandle integer
function OverheadMessager:DisplayMessage(type, object, message, duration, messageIsHandle)
    local root = Ext.UI.GetByType(Ext.UI.TypeID.overhead):GetRoot()
    local eclObject = Ext.Entity.GetGameObject(object)
    local handle
    if eclObject ~= nil then
        handle = Ext.UI.HandleToDouble(eclObject.Handle)
    end
    if handle ~= nil then
        if messageIsHandle == 1 then
            message = Ext.L10N.GetTranslatedString(message, "")
        end
        if type == 0 then
            root.addOverhead(handle, message, duration)
        elseif type == 1 then
            root.addOverheadDamage(handle, message)
        elseif type == 2 then
            root.addADialog(handle, message, duration)
        end
        root.updateOHs()
    end
end

function OverheadMessager:SendToClients(type, object, message, duration, messageIsHandle)
    Ext.Net.BroadcastMessage(self.NetChannel, Ext.Json.Stringify{
        Type = type,
        Object = object,
        Message = message,
        Duration = duration,
        MessageIsHandle = messageIsHandle
    })
end

if Ext.IsServer() then
    function DisplayMessage(type, object, message, duration, messageIsHandle)
        Osi.DisplayText(object, "")
        OverheadMessager:SendToClients(type, object, message, duration, messageIsHandle)
    end
end
if Ext.IsClient() then
    Ext.RegisterNetListener(OverheadMessager.NetChannel, function(_, payload)
        local entry = Ext.Json.Parse(payload)
        OverheadMessager:DisplayMessage(entry.Type, entry.Object, entry.Message, entry.Duration, entry.MessageIsHandle)
    end)
end