-- References 
local TRIGGER_KAVA = script:GetCustomProperty("TriggerKava"):WaitForObject()
local KAVA = script:GetCustomProperty("Kava"):WaitForObject()
local TRIGGER_YASMINE = script:GetCustomProperty("TriggerYasmine"):WaitForObject()
local YASMINE = script:GetCustomProperty("Yasmine"):WaitForObject()
local CAMERA_KAVA = script:GetCustomProperty("CameraKava"):WaitForObject()
local CAMERA_YASMINE = script:GetCustomProperty("CameraYasmine"):WaitForObject()
local THIRD_PERSON_CAMERA = script:GetCustomProperty("ThirdPersonCamera"):WaitForObject()

-- Custom 
local INTERACT_BUTTON = script:GetCustomProperty("InteractButton"):WaitForObject()
local INTERACTION_PROMPT = script:GetCustomProperty("InteractionPrompt"):WaitForObject()
local DIALOGUE_BACKGROUND = script:GetCustomProperty("DialogueBackground"):WaitForObject()
local DIALOGUE_OPTIONS_PANEL = script:GetCustomProperty("DialogueOptionsPanel"):WaitForObject()
local NPC_RESPONSE_TEXT = script:GetCustomProperty("NPC_ResponseText"):WaitForObject()

-- Buttons 
local EXIT_BUTTON = script:GetCustomProperty("ExitButton"):WaitForObject()
local NEXT_BUTTON = script:GetCustomProperty("NextButton"):WaitForObject()

-- FX 
local UIBUTTON_CLICK = script:GetCustomProperty("UIButtonClick")
local UIBUTTON_HOVER = script:GetCustomProperty("UIButtonHover")

local buttonData = {}
local availableDialogueOptions = DIALOGUE_OPTIONS_PANEL:GetChildren()
local maxDialogueOptions = #DIALOGUE_OPTIONS_PANEL:GetChildren()
local previousOptions = {}
local pickedOptions = {}

local LOCAL_PLAYER = Game.GetLocalPlayer()
local kavaPos = TRIGGER_KAVA:GetPosition()
local yasminePos = TRIGGER_YASMINE:GetPosition()
local isOverlapingKava = false
local isOverlapingYasmine = false
local isKavaTalking = false
local isYasmineTalking = false

local randomDialogue1
local randomDialogue2

local interactProgress = 0
local dialogueProgress = 0
local interactStart = 0
local interactTarget = 0
local dialogueStart = 0
local dialogueTarget = 0

function Init()
	THIRD_PERSON_CAMERA:AttachToPlayer(LOCAL_PLAYER, "root")
	THIRD_PERSON_CAMERA:SetPosition(Vector3.New(0, 0, 200))
	INTERACTION_PROMPT.opacity = 0
	DIALOGUE_OPTIONS_PANEL.visibility = Visibility.FORCE_OFF
	DIALOGUE_BACKGROUND.opacity = 0
end

function PickRandomElement(availableDialogueOptions, pickedOptions)
	local index = math.random(1, #availableDialogueOptions)
	local option = table.remove(availableDialogueOptions, index)
	table.insert(pickedOptions, option)
	if #availableDialogueOptions == 0 then
		for _, entry in ipairs(pickedOptions) do
			table.insert(availableDialogueOptions, entry)
		end
	end
	if #pickedOptions == maxDialogueOptions then
		for entry in ipairs(pickedOptions) do
			pickedOptions[entry] = nil
		end
	end
	print(index)
	return option
end

function RandomizeDialogue()
	DIALOGUE_OPTIONS_PANEL.visibility = Visibility.FORCE_ON
	for _, button in ipairs(DIALOGUE_OPTIONS_PANEL:GetChildren()) do
		button.y = 400
	end
	randomDialogue1 = PickRandomElement(availableDialogueOptions, pickedOptions)
	randomDialogue2 = PickRandomElement(availableDialogueOptions, pickedOptions)
	randomDialogue1.y = -40
	randomDialogue2.y = 40

	NEXT_BUTTON.isInteractable = false
	NEXT_BUTTON.visibility = Visibility.FORCE_OFF
end

function DisplayPrompt(bool)
	if bool then
		interactStart = INTERACTION_PROMPT.opacity
		interactTarget = 1
		interactProgress = 0
	else
		interactStart = INTERACTION_PROMPT.opacity
		interactTarget = 0
		interactProgress = 0
	end
end

function DisplayDialogueOptions(bool)
	if bool then
		dialogueStart = DIALOGUE_BACKGROUND.opacity
		dialogueTarget = 1
        dialogueProgress = 0
	else
		dialogueStart = DIALOGUE_BACKGROUND.opacity
		dialogueTarget = 0
        dialogueProgress = 0

		TRIGGER_KAVA:SetPosition(kavaPos + Vector3.New(0, 0, -200))
		TRIGGER_YASMINE:SetPosition(yasminePos + Vector3.New(0, 0, -200))
		Task.Wait(2)
		TRIGGER_KAVA:SetPosition(kavaPos)
		TRIGGER_YASMINE:SetPosition(yasminePos)
	end
end

function GreetNPC()
	DIALOGUE_OPTIONS_PANEL.visibility = Visibility.FORCE_OFF
	NEXT_BUTTON.visibility = Visibility.FORCE_ON
	NEXT_BUTTON.isInteractable = true
end

function StartConversation(bool, other)
	if bool then
		if isKavaTalking then
			KAVA:LookAtContinuous(other, true, 0)
			Task.Wait()
			LOCAL_PLAYER:SetLookWorldRotation(KAVA:GetWorldRotation() + Rotation.New(0, 0, 180))
			THIRD_PERSON_CAMERA:Detach()
			THIRD_PERSON_CAMERA.followPlayer = nil
			THIRD_PERSON_CAMERA.rotationMode = RotationMode.CAMERA
			THIRD_PERSON_CAMERA:SetPositionOffset(Vector3.New(0,-10,0))
			THIRD_PERSON_CAMERA.currentDistance = 100
			THIRD_PERSON_CAMERA:MoveTo(CAMERA_KAVA:GetWorldPosition(), 1)
			THIRD_PERSON_CAMERA:RotateTo(CAMERA_KAVA:GetWorldRotation(), 1)
		elseif isYasmineTalking then
			YASMINE:LookAtContinuous(other, true, 0)
			Task.Wait()
			LOCAL_PLAYER:SetLookWorldRotation(YASMINE:GetWorldRotation() + Rotation.New(0, 0, 180))
			THIRD_PERSON_CAMERA:Detach()
			THIRD_PERSON_CAMERA.followPlayer = nil
			THIRD_PERSON_CAMERA.rotationMode = RotationMode.CAMERA
			THIRD_PERSON_CAMERA:SetPositionOffset(Vector3.New(0,-10,0))
			THIRD_PERSON_CAMERA.currentDistance = 100
			THIRD_PERSON_CAMERA:MoveTo(CAMERA_YASMINE:GetWorldPosition(), 1)
			THIRD_PERSON_CAMERA:RotateTo(CAMERA_YASMINE:GetWorldRotation(), 1)
		end
		--RandomizeDialogue()
		UI.SetCanCursorInteractWithUI(true)
		UI.SetCursorVisible(true)
		UI.SetCursorLockedToViewport(true)
	else
		KAVA:StopRotate()
		YASMINE:StopRotate()
		THIRD_PERSON_CAMERA.followPlayer = other
		THIRD_PERSON_CAMERA.rotationMode = RotationMode.LOOK_ANGLE
		THIRD_PERSON_CAMERA:AttachToPlayer(other, "root")
		THIRD_PERSON_CAMERA:MoveTo(Vector3.New(0, 0, 200), 1)
		THIRD_PERSON_CAMERA.currentDistance = 400
		UI.SetCanCursorInteractWithUI(false)
		UI.SetCursorVisible(false)
		UI.SetCursorLockedToViewport(false)
	end
end

function OnBindingPressed(other, binding)
	if other == LOCAL_PLAYER then
		if binding == "ability_extra_33" and isOverlapingKava then
			NPC_RESPONSE_TEXT.text = TRIGGER_KAVA:GetCustomProperty("GreetingText")
			KAVA:PlayAnimation(TRIGGER_KAVA:GetCustomProperty("GreetingAnim"))
			isKavaTalking = true
			isYasmineTalking = false
			isOverlapingKava = false
			StartConversation(true, other)
			Events.BroadcastToServer("TriggerOverlap", KAVA:GetWorldRotation() + Rotation.New(0, 0, 180), KAVA:GetWorldPosition())
			GreetNPC()
			DisplayDialogueOptions(true)
			DisplayPrompt(false)
		elseif binding == "ability_extra_33" and isOverlapingYasmine then
			NPC_RESPONSE_TEXT.text = TRIGGER_YASMINE:GetCustomProperty("GreetingText")
			YASMINE:PlayAnimation(TRIGGER_YASMINE:GetCustomProperty("GreetingAnim"))
			isYasmineTalking = true
			isKavaTalking = false
			isOverlapingYasmine = false
			StartConversation(true, other)
			Events.BroadcastToServer("TriggerOverlap", YASMINE:GetWorldRotation() + Rotation.New(0, 0, 180), YASMINE:GetWorldPosition())
			GreetNPC()
			DisplayDialogueOptions(true)
			DisplayPrompt(false)
		elseif binding == "ability_extra_33" and isKavaTalking or isYasmineTalking then
			NPC_RESPONSE_TEXT.text = ""
			Events.BroadcastToServer("ExitConversation")
			DisplayDialogueOptions(false)
			isKavaTalking = false
			isYasmineTalking = false
		end
	end
end

function MenuButtonPressed(button)
	if button == EXIT_BUTTON then
		World.SpawnAsset(UIBUTTON_CLICK)
		Events.BroadcastToServer("ExitConversation")
		isKavaTalking = false
		isYasmineTalking = false
		DisplayDialogueOptions(false)
		NPC_RESPONSE_TEXT.text = ""
	end
	if button == NEXT_BUTTON then
		World.SpawnAsset(UIBUTTON_CLICK)
		RandomizeDialogue()
		NPC_RESPONSE_TEXT.text = ""
	end
end

function DialogueButtonHovered()
	World.SpawnAsset(UIBUTTON_HOVER)
end

function DialogueButtonPressed(button)
	World.SpawnAsset(UIBUTTON_CLICK)
	DIALOGUE_OPTIONS_PANEL.visibility = Visibility.FORCE_OFF
	NPC_RESPONSE_TEXT.text = buttonData[button].text
	NEXT_BUTTON.isInteractable = true
	NEXT_BUTTON.visibility = Visibility.FORCE_ON
	if isKavaTalking and not isYasmineTalking then
		local availableVoiceLines = buttonData[button].kava:GetChildren()
		local randomVoiceLine = math.random(1, #availableVoiceLines)
		if availableVoiceLines[randomVoiceLine]:IsA("Folder") then
			for _, SFX in ipairs(availableVoiceLines[randomVoiceLine]:GetChildren()) do
				SFX:Play()
			end
		else
			availableVoiceLines[randomVoiceLine]:Play()
		end
		KAVA:PlayAnimation(buttonData[button].animation)
	elseif isYasmineTalking and not isKavaTalking then
		local availableVoiceLines = buttonData[button].yasmine:GetChildren()
		local randomVoiceLine = math.random(1, #availableVoiceLines)
		if availableVoiceLines[randomVoiceLine]:IsA("Folder") then
			for _, SFX in ipairs(availableVoiceLines[randomVoiceLine]:GetChildren()) do
				SFX:Play()
			end
		else
			availableVoiceLines[randomVoiceLine]:Play()
		end
		YASMINE:PlayAnimation(buttonData[button].animation)
	end
end

function OnBeginOverlap(trigger, other)
	if other:IsA("Player") then
		if other == LOCAL_PLAYER then
			DisplayPrompt(true)
			if trigger == TRIGGER_KAVA then
				INTERACT_BUTTON.text = TRIGGER_KAVA:GetCustomProperty("InteractText")
				isOverlapingKava = true
				isOverlapingYasmine = false
			elseif trigger == TRIGGER_YASMINE then
				INTERACT_BUTTON.text = TRIGGER_YASMINE:GetCustomProperty("InteractText")
				isOverlapingKava = false
				isOverlapingYasmine = true
			end
		end
	end
end

function OnEndOverlap(trigger, other)
	if other:IsA("Player") then
		if other == LOCAL_PLAYER then
			StartConversation(false, other)
			if trigger == TRIGGER_KAVA then
				isOverlapingKava = false
			elseif trigger == TRIGGER_YASMINE then
				isOverlapingYasmine = false
			end
			DisplayPrompt(false)
		end
	end
end

Init()

function Tick(deltaTime)
	interactProgress = CoreMath.Clamp(interactProgress + deltaTime*3)
	dialogueProgress = CoreMath.Clamp(dialogueProgress + deltaTime*3)
	INTERACTION_PROMPT.opacity = CoreMath.Lerp(interactStart, interactTarget, interactProgress)
	DIALOGUE_BACKGROUND.opacity = CoreMath.Lerp(dialogueStart, dialogueTarget, dialogueProgress)
end

for _, button in ipairs(DIALOGUE_OPTIONS_PANEL:GetChildren()) do
	buttonData[button] = {}
	buttonData[button].kava = button:GetCustomProperty("VO_Kava"):WaitForObject()
	buttonData[button].yasmine = button:GetCustomProperty("VO_Yasmine"):WaitForObject()
	buttonData[button].animation = button:GetCustomProperty("Animation")
	buttonData[button].text = button:GetCustomProperty("NPC_Response")

	button.pressedEvent:Connect(DialogueButtonPressed)
	button.hoveredEvent:Connect(DialogueButtonHovered)
end

TRIGGER_KAVA.beginOverlapEvent:Connect(OnBeginOverlap)
TRIGGER_KAVA.endOverlapEvent:Connect(OnEndOverlap)
TRIGGER_YASMINE.beginOverlapEvent:Connect(OnBeginOverlap)
TRIGGER_YASMINE.endOverlapEvent:Connect(OnEndOverlap)
LOCAL_PLAYER.bindingPressedEvent:Connect(OnBindingPressed)
EXIT_BUTTON.pressedEvent:Connect(MenuButtonPressed)
NEXT_BUTTON.pressedEvent:Connect(MenuButtonPressed)
EXIT_BUTTON.hoveredEvent:Connect(DialogueButtonHovered)
NEXT_BUTTON.hoveredEvent:Connect(DialogueButtonHovered)