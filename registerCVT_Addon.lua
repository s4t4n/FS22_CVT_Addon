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
  	g_specializationManager:addSpecialization("CVTaddon", "CVTaddon", g_currentModDirectory.."CVT_Addon.lua", nil)
end

for typeName, typeEntry in pairs(g_vehicleTypeManager.types) do
    if
		SpecializationUtil.hasSpecialization(Motorized, typeEntry.specializations)
	-- or SpecializationUtil.hasSpecialization(Vehicles, typeEntry.specializations)
	-- or SpecializationUtil.hasSpecialization(Cylindered, typeEntry.specializations)
    
    and not SpecializationUtil.hasSpecialization(Locomotive, typeEntry.specializations)
    and not SpecializationUtil.hasSpecialization(ConveyorBelt, typeEntry.specializations)
    
    then
     	g_vehicleTypeManager:addSpecialization(typeName, specName)
    end
end
