-- @titel       CVTaddon Script for FarmingSimulator 2022
-- @author      s4t4n, frvetz
-- @credits		modelleicher - vielen Dank für die Erlaubnis der Nutzung deines registers
-- @date        03/01/2023
-- @info        CVTaddon Script for FarmingSimulator 2022


g_specializationManager:addSpecialization("CVTaddon", "CVTaddon", g_currentModDirectory.."CVT_Addon.lua")
-- g_specializationManager:addSpecialization("CVTaddonHUD", "CVTaddonHUD", g_currentModDirectory.."CVT_AddonHUD.lua")

LMBFRegister = {}

LMBFRegister.done = false

function LMBFRegister:register(name)

    if not LMBFRegister.done then
    
        for _, vehicle in pairs(g_vehicleTypeManager:getTypes()) do
            
            local motorized = false;
            local CVTaddon = false;
            -- local CVTaddonHUD = false;
            
            for _, spec in pairs(vehicle.specializationNames) do
            
                if spec == "motorized" then -- check for motorized, only insert into motorized
                    motorized = true;
                end
                if spec == "CVTaddon" then -- don't insert if already inserted
                    CVTaddon = true;
                end
				-- if spec == "CVTaddonHUD" then -- don't insert if already inserted
                    -- CVTaddonHUD = true;
                -- end
                
            end    
            if motorized and not CVTaddon then
                g_vehicleTypeManager:addSpecialization(vehicle.name, "FS22_CVT_Addon.CVTaddon")
            end
        end
        
        LMBFRegister.done = true
    end
end
LMBFRegister:register()
TypeManager.finalizeTypes = Utils.prependedFunction(TypeManager.finalizeTypes, LMBFRegister.register)