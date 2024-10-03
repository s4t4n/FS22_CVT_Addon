-- @titel       CVTaddon regScript for FarmingSimulator 2022
-- @author      s4t4n
-- @credits		GLOWIN
-- @date        28/10/2023
-- @info        CVTaddon regScript for FarmingSimulator 2022

LMBFRegister = {}
CVTaddonConfigs = {}

LMBFRegister.done = false

local specName = g_currentModName..".CVTaddon"

if g_specializationManager:getSpecializationByName("CVTaddon") == nil then
	print("CVTa ModName: ".. g_currentModName)
	if g_currentModName ~= "FS22_CVT_Addon" then
		if string.find(tostring(g_currentModName), "master") or string.find(tostring(g_currentModName), "main") or string.find(tostring(g_currentModName), "update") then
			print("Please download the Github Version from the Releases or repack it correctly. Description at the Wiki.")
			print("Or otherwise, download it from the official Modhub.")
		else
			print("Wrong Modname ".. g_currentModName .. " or you downloaded from a website that has stolen the mod")
			print("and did an illegal upload there!")
			print("Keep the original download-link from official Giants Modhub!")
			print("Thank You.")
		end
		LMBFRegister.done = false
		-- break;
	else
		g_specializationManager:addSpecialization("CVTaddon", "CVTaddon", g_currentModDirectory.."CVT_Addon.lua", nil)
		LMBFRegister.done = true
	end
end

for typeName, typeEntry in pairs(g_vehicleTypeManager.types) do
    if
		SpecializationUtil.hasSpecialization(Motorized, typeEntry.specializations)
    and not SpecializationUtil.hasSpecialization(Locomotive, typeEntry.specializations)
    and not SpecializationUtil.hasSpecialization(ConveyorBelt, typeEntry.specializations)
     then
     	g_vehicleTypeManager:addSpecialization(typeName, specName)
    end
end
