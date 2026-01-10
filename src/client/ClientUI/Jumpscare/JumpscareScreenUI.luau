local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local JumpscareUIFunctions = require(script.Parent.JumpscareUIFunctions)
local React = require(ReplicatedStorage.Packages.react)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)
local Remotes = ReplicatedStorage.Remotes
local e = React.createElement

local function JumpscareScreenUI()
	local isVisible, setIsVisible = React.useState(false)
	local image, setImage = React.useState(JumpscareUIFunctions.GetRandomJumpscareImage())

	React.useEffect(function()
		local connection
		connection = Remotes.JumpscarePlayer.OnClientEvent:Connect(function()
			setImage(JumpscareUIFunctions.GetRandomJumpscareImage())
			setIsVisible(true)
			local sound: Sound = SoundManager.PlayGlobal(JumpscareUIFunctions.GetRandomJumpscareSound())
			sound.Ended:Wait()
			setIsVisible(false)
		end)

		return function()
			if connection then
				connection:Disconnect()
			end
		end
	end, {})
	return e("ImageLabel", {
		Size = UDim2.fromScale(1, 1),
		Active = false,
		Visible = isVisible,
		Image = image,
		ZIndex = 2,
	}, {})
end

return JumpscareScreenUI
