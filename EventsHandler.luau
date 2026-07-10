local CoinFolder = workspace:WaitForChild('SpawnedCoins')
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local CollectCoinEvent = ReplicatedStorage:WaitForChild('CollectCoinEvent')
local JumpPriceEvent = ReplicatedStorage:WaitForChild('JumpPriceEvent')
local SpeedPriceEvent = ReplicatedStorage:WaitForChild('SpeedPriceEvent')
local MultiplierEvent = ReplicatedStorage:WaitForChild('MultiplierEvent')
local XPUpdaterEvent = ReplicatedStorage:WaitForChild('XpUpdater')
local MultiplierStepsEvent = ReplicatedStorage:WaitForChild('MultiplierStepsEvent')
local StepsTriggerEvent = ReplicatedStorage:WaitForChild('StepsTriggerEvent')
local RebirthEvent = ReplicatedStorage:WaitForChild('RebirthEvent')

local RebirthFormula = 1.5

local RebirthConfig = {
	[0] = {
		Price = 1000,
		Currency = "Currency"
	},
	[1] = {
		Price = 5000,
		Currency = "Currency"
	},
	[2] = {
		Price = 10000,
		Currency = "Currency",
		SecondaryPrice = 20000,
		SecondaryCurrency = "Steps"
	}
}

CollectCoinEvent.OnServerEvent:Connect(function(player)
	if player and player:FindFirstChild('leaderstats') and player.leaderstats:FindFirstChild('Currency') then
		local BaseCoinValue = ReplicatedStorage.Coin:GetAttribute('Price') or 1
		-- ADD REBIRTH MULTIPLIER
		local Rebirth = player:GetAttribute('Rebirth')
		local RebirthMultiplier = nil
		if Rebirth == 0 then
			RebirthMultiplier = 1
		else
			RebirthMultiplier = Rebirth * 1.5
		end
		local PlayerMultiplier = player:GetAttribute('CoinMultiplier') or 1
		player.leaderstats.Currency.Value += (BaseCoinValue * PlayerMultiplier * RebirthMultiplier)
		
	end
end)


JumpPriceEvent.OnServerEvent:Connect(function(player)
	local JumpPrice = JumpPriceEvent:GetAttribute('Price')
	player.leaderstats.Currency.Value -= JumpPrice
end)

SpeedPriceEvent.OnServerEvent:Connect(function(player)
	local SpeedPrice = SpeedPriceEvent:GetAttribute('Price')
	player.leaderstats.Currency.Value -= SpeedPrice
end)

MultiplierEvent.OnServerEvent:Connect(function(player)
	local MultiplierPrice = MultiplierEvent:GetAttribute('Price')
	player.leaderstats.Currency.Value -= MultiplierPrice
	local CurrentMultiplier = player:GetAttribute('CoinMultiplier') or 1
	player:SetAttribute("CoinMultiplier", CurrentMultiplier + 0.1)
end)

MultiplierStepsEvent.OnServerEvent:Connect(function(player)
	local MultiplierStepsPrice = MultiplierStepsEvent:GetAttribute('Price')
	player.leaderstats.Currency.Value -= MultiplierStepsPrice
	local CurrentStepsMultiplier = player:GetAttribute('StepsMultiplier') or 1
	local NewStepsMultiplier = CurrentStepsMultiplier + 0.1
	player:SetAttribute('StepsMultiplier', NewStepsMultiplier)
end)

StepsTriggerEvent.Event:Connect(function(player, Distance)
	local StepsMultiplier = player:GetAttribute('StepsMultiplier') or 1
	local oldSteps = player:GetAttribute('Steps') or 0
	local newSteps = oldSteps + (Distance * StepsMultiplier)
	player:SetAttribute('Steps', math.round(newSteps))
end)

RebirthEvent.OnServerEvent:Connect(function(player)
	local currentRebirth = player:GetAttribute('Rebirth') or 0
	
	local requirements = RebirthConfig[currentRebirth]
	if not requirements then
		return
	end
	
	local mainCurrency = player.leaderstats:FindFirstChild(requirements.Currency)
	
	
	if mainCurrency and mainCurrency.Value >= requirements.Price then
		
		if requirements.SecondaryCurrency and requirements.SecondaryPrice then
			local secondaryCurrency = player:GetAttribute('Steps') or 0
			if secondaryCurrency < requirements.SecondaryPrice then
				print("Not enough steps")
				return
			end
			player:SetAttribute('Steps', secondaryCurrency - requirements.SecondaryPrice)
		end
		mainCurrency.Value = mainCurrency.Value - requirements.Price
		player:SetAttribute('Rebirth', currentRebirth + 1)
	end
	
end)