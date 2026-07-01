local FeatureFlags = {}

local FLAGS = table.freeze({
	BreakSystemEnabled = false,
})

function FeatureFlags.IsEnabled(flagName)
	return FLAGS[flagName] == true
end

function FeatureFlags.GetFlag(flagName)
	return FLAGS[flagName]
end

function FeatureFlags.GetAll()
	local copy = {}
	for flagName, value in pairs(FLAGS) do
		copy[flagName] = value
	end

	return copy
end

return table.freeze(FeatureFlags)
