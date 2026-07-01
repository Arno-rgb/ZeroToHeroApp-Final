local ServerScriptService = game:GetService("ServerScriptService")

local LEGACY_STATION_SCRIPT_NAMES = {
	"StrengthForge.server",
	"AscensionStrengthForgeTrainingServer",
}

for _, scriptName in ipairs(LEGACY_STATION_SCRIPT_NAMES) do
	local legacyScript = ServerScriptService:FindFirstChild(scriptName)
	if legacyScript and legacyScript:IsA("BaseScript") then
		legacyScript.Disabled = true
	end
end

local TrainingStationService = require(script.Parent:WaitForChild("Services"):WaitForChild("TrainingStationService"))

TrainingStationService.Start()
