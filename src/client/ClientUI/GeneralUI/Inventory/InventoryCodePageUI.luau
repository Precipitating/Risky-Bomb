local StarterPlayer = game:GetService("StarterPlayer")
local ReplicatedStorage = game:GetService("ReplicatedStorage").Shared
local InventoryUIFunctions = require(script.Parent.InventoryUIFunctions)
local ModularTextButtonUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextButtonUI)
local ModularTextLabelUI = require(StarterPlayer.StarterPlayerScripts.Client.ClientUI.ModularUI.ModularTextLabelUI)
local React = require(ReplicatedStorage.Packages.React)
local SoundManager = require(ReplicatedStorage.Sound.SoundManager)

local e = React.createElement

type InventoryCodePageUIProps = {
	Position: UDim2,
	Size: UDim2,
	AnchorPoint: Vector2?,
	IsOpen: boolean,
}
local function InventoryCodePageUI(props: InventoryCodePageUIProps)
	local textBoxInstance = nil
	if not props.IsOpen then
		return nil
	end

	return e("Frame", {
		Position = props.Position,
		Size = props.Size,
		Visible = props.IsOpen,
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
		BackgroundTransparency = 0.9,
		BackgroundColor3 = Color3.fromRGB(0, 81, 255),
		BorderSizePixel = 0,
	}, {
		Corner = e("UICorner", {
			CornerRadius = UDim.new(0.05, 0),
		}),
		Stroke = e("UIStroke", {
			Thickness = 2,
			Color = Color3.fromRGB(255, 255, 255),
		}),

		UIPad = e("UIPadding", {
			PaddingLeft = UDim.new(0.05, 0),
		}),

		Title = ModularTextLabelUI({
			Position = UDim2.fromScale(0.5, 0.2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = "<u>Redeem Code</u>",
			RichText = true,
			TextColor = Color3.fromRGB(255, 255, 255),
			BackgroundTransparency = 1,
			Font = Enum.Font.Antique,
			TextScaled = true,
			Size = UDim2.fromScale(0.8, 0.2),
		}),

		InputCode = e(React.Fragment, nil, {
			InputTextBox = e("TextBox", {
				ref = function(instance)
					textBoxInstance = instance
				end,
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Size = UDim2.fromScale(0.8, 0.2),
				BackgroundTransparency = 1,
				Text = "Input Code",
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Font = Enum.Font.FredokaOne,
				TextScaled = true,
			}, {
				Stroke = e("UIStroke", {
					Thickness = 2,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
					Color = Color3.fromRGB(255, 255, 255),
				}),
				Corner = e("UICorner", {
					CornerRadius = UDim.new(0.1, 0),
				}),
				UIPad = e("UIPadding", {
					PaddingLeft = UDim.new(0.05, 0),
					PaddingRight = UDim.new(0.05, 0),
				}),
			}),
		}),
		SubmitButton = ModularTextButtonUI({
			Position = UDim2.fromScale(0.5, 0.8),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = "Submit",
			StrokeThickness = 0.05,
			BackgroundColor = Color3.fromRGB(0, 121, 196),
			Font = Enum.Font.FredokaOne,
			TextColor = Color3.fromRGB(255, 255, 255),
			isOpen = props.IsOpen,
			Size = UDim2.fromScale(0.4, 0.3),
			AspectRatio = 3,
			OnClick = function()
				local result = InventoryUIFunctions:RedeemCode(textBoxInstance.Text)
				textBoxInstance.Text = ""

				if not result then
					SoundManager.PlayExistingSound(SoundManager.UISounds.Error)
				else
					SoundManager.PlayExistingSound(SoundManager.UISounds.Success)
				end
			end,
		}),
	})
end

return InventoryCodePageUI
