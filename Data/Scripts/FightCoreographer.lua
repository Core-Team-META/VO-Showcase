
-- Custom 
local FIGHT_SEQUENCE = script:GetCustomProperty("FightSequence")
local ACTOR_1 = script:GetCustomProperty("Actor1"):WaitForObject()
local ACTOR_2 = script:GetCustomProperty("Actor2"):WaitForObject()
local ACTOR_1_ATTACK = script:GetCustomProperty("Actor1Attack")
local ACTOR_2_REACT = script:GetCustomProperty("Actor2React")
local DEMON_STRIKE = script:GetCustomProperty("DemonStrike"):WaitForObject()
local WHELP_REACT = script:GetCustomProperty("WhelpReact"):WaitForObject()
local DEMON_WIND_UP = script:GetCustomProperty("DemonWindUp"):WaitForObject()
local IMPACT = script:GetCustomProperty("Impact"):WaitForObject()
local DEMON_BOAST = script:GetCustomProperty("DemonBoast"):WaitForObject()
local ACTOR_1_BOAST = script:GetCustomProperty("Actor1Boast")
local WHELP_DEATH = script:GetCustomProperty("WhelpDeath"):WaitForObject()
local ACTOR_2_DEATH = script:GetCustomProperty("Actor2Death")
local ACTOR_2_RESET = script:GetCustomProperty("Actor2Reset")
local WHELP_RESET = script:GetCustomProperty("WhelpReset"):WaitForObject()
local WHELP_FRIED = script:GetCustomProperty("WhelpFried"):WaitForObject()
local DEMON_RESET = script:GetCustomProperty("DemonReset"):WaitForObject()


local startTime = time()
local isActive = false
local whelpPosition = ACTOR_2:GetPosition()

function RemoveWhelp()
    ACTOR_2:MoveTo(whelpPosition - Vector3.New(0, 0, 300), 1.5, true)
    WHELP_FRIED:Play()
    ACTOR_2.playbackRateMultiplier = .7
    ACTOR_1:PlayAnimation("unarmed_ready_to_rumble")
    for _, SFX in ipairs(DEMON_RESET:GetChildren()) do
        SFX:Play()
    end

    isActive = true
end
function ResetWhelp()
    ACTOR_2:MoveTo(whelpPosition, 1, true)
    ACTOR_2.playbackRateMultiplier = .6
    ACTOR_2:PlayAnimation(ACTOR_2_RESET, {startPosition = 0})
    WHELP_RESET:Play()
    Task.Wait(.9)
    ACTOR_2:PlayAnimation("unarmed_jump_end", {startPosition = 0})
    isActive = true
end
function Death()
    WHELP_DEATH:Play()
    ACTOR_2.playbackRateMultiplier = .7
    ACTOR_2:PlayAnimation(ACTOR_2_DEATH, {startPosition = 0})
    isActive = true
end
function Boast()
    DEMON_BOAST:Play()
    ACTOR_1.playbackRateMultiplier = .7
    ACTOR_1:PlayAnimation(ACTOR_1_BOAST, {startPosition = .1})
    isActive = true
end
function WindUp()
    DEMON_WIND_UP:Play()
    ACTOR_1.playbackRateMultiplier = 0.05
    ACTOR_1:PlayAnimation(ACTOR_1_ATTACK, {startPosition = 0.17})
    isActive = true
end
function Strike()
    ACTOR_1.playbackRateMultiplier = .8
    ACTOR_1:PlayAnimation(ACTOR_1_ATTACK, {startPosition = 0.18})
    DEMON_STRIKE:Play()
    isActive = true
end
function Impact()
    IMPACT:Play()
    isActive = true
end
function React()
    ACTOR_2.playbackRateMultiplier = .8
    ACTOR_2:PlayAnimation(ACTOR_2_REACT)
    local options = WHELP_REACT:GetChildren()
    local random = math.random(1, #options)
    options[random]:Play()
    isActive = true
end
function Tick()
    if startTime then
        local playback = time() - startTime
        local curveValue = FIGHT_SEQUENCE:GetValue(playback)
    
        if curveValue == 0 then
            isActive = false
        end
        if curveValue == 0.5 and not isActive then
            WindUp()
        end
        if curveValue == 1 and not isActive then
            Strike()
        end
        if curveValue == 1.5 and not isActive then
            Impact()
        end
        if curveValue == 2 and not isActive then
            React()
        end
        if curveValue == 2.5 and not isActive then
            Boast()
        end
        if curveValue == 3 and not isActive then
            Death()
        end
        if curveValue == 3.5 and not isActive then
            RemoveWhelp()
        end
        if curveValue == 4 and not isActive then
            ResetWhelp()
        end
    end
end