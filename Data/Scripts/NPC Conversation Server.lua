-- Custom 
--local EXIT_TARGET = script:GetCustomProperty("ExitTarget"):WaitForObject()
local origin

function StopMovement(other, playerRotation, PositionNPC)
    other.isMovementEnabled = false
    other:SetWorldRotation(playerRotation)
    origin = PositionNPC
end

function ReturnMovement(other)
    local playerPosition = other:GetWorldPosition(other:GetWorldPosition())
    other.isMovementEnabled = true
    --other:AddImpulse(((playerPosition - origin) * other.mass * 4))
end

Events.ConnectForPlayer("TriggerOverlap", StopMovement)
Events.ConnectForPlayer("ExitConversation", ReturnMovement)