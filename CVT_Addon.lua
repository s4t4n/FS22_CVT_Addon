-- @titel       LessMotorBrakeforce Script for FarmingSimulator 2022
-- @new titel   CVT_Addon Script for FarmingSimulator 2022
-- @author      s4t4n
-- @credits		Frvetz - ebenso ein riesen Dank an dieser Stelle!
-- @version     v1.0.0.0 Release Modhub
-- @version		v1.0.0.1 Small Changes(FS22 1.2.0.2)
-- @date        23/07/2022
-- @info        CVTaddon Script for FarmingSimulator 2022
-- changed		app to pre 23.12.2022 SbSh(s4t4n)
-- changelog	Anpassung an FS22_realismAddon_gearbox von modelleicher
--				+ Vario Fahrstufen und Beschleunigungsrampen
--				RegisterScript Umstellung, der Dank geht hier an modelleicher!
-- Script Ver	0.2.0.67
-- last update	14.01.23


-- source(g_currentModDirectory .. "CVT_Addon_HUD.lua")
CVTaddon = {};
CVTaddon.modDirectory = g_currentModDirectory;

-- local sbshDebugOn = true;
-- local sbshFlyDebugOn = true;

function CVTaddon.prerequisitesPresent(specializations) 
    return true
end 

-- function Cylindered.prerequisitesPresent(specializations)
    -- return SpecializationUtil.hasSpecialization(VehicleSettings, specializations)
-- end

function CVTaddon.registerEventListeners(vehicleType) 
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", CVTaddon) 
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", CVTaddon)
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", CVTaddon)
	SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", CVTaddon)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", CVTaddon)
    SpecializationUtil.registerEventListener(vehicleType, "onDraw", CVTaddon) 
	addModEventListener(CVTaddon)
end 

function CVTaddon:onRegisterActionEvents()
	local spec = self.spec_CVTaddon
	spec.BackupMaxFwSpd = tostring(self.spec_motorized.motor.maxForwardSpeedOrigin)
	spec.BackupMaxBwSpd = tostring(self.spec_motorized.motor.maxBackwardSpeedOrigin)
	spec.calcBrakeForce = string.format("%.2f", spec.BackupMaxFwSpd/100)
	-- spec.currentDirection = self.spec_motorized.motor.currentDirection
    if self.getIsEntered ~= nil and self:getIsEntered() then
        spec.actionEventsV1 = {}
        spec.actionEventsV2 = {}
        spec.actionEventsV3 = {}
        spec.actionEventsV4 = {}
        spec.actionEventsV5 = {}
        spec.actionEventsV6 = {}
        spec.actionEventsV7 = {}
        spec.actionEventsV8 = {}
		local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName) -- debug
		print("storeItem.categoryName: " .. tostring(storeItem.categoryName)) -- debug
		if spec.vOne == nil then
			spec.vOne = 1
		end
		if spec.vTwo == nil then
			spec.vTwo = 4
		end
		if spec.vThree == nil then
			spec.vThree = 2
		end
		if spec.vFour == nil then
			spec.vFour = 1
		end
		if spec.vFive == nil then
			spec.vFive = 1
		end
		if spec.PedalResolution == nil then
			spec.PedalResolution = 0
		end
		if spec.eventActiveV1 == nil then
			spec.eventActiveV1 = true
		end
		if spec.eventActiveV2 == nil then
			spec.eventActiveV2 = true
		end
		if spec.eventActiveV3 == nil then
			spec.eventActiveV3 = true
		end
		if spec.eventActiveV4 == nil then
			spec.eventActiveV4 = true
		end
		if spec.eventActiveV5 == nil then
			spec.eventActiveV5 = true
		end
		if spec.eventActiveV6 == nil then
			spec.eventActiveV6 = true
		end
		if spec.eventActiveV7 == nil then
			spec.eventActiveV7 = true
		end
		if spec.eventActiveV8 == nil then
			spec.eventActiveV8 = true
		end

		-- spec.eventActiveV1 = true
		-- spec.eventActiveV2 = false
		-- spec.eventActiveV3 = true
		-- spec.eventActiveV4 = true
		spec.currSpdCheck = self:getLastSpeed()
		if sbshDebugOn then
			print("CVTaddon: onRegisterActionEvents vOne: ".. tostring(spec.vOne))
			print("CVTaddon: onRegisterActionEvents vTwo: ".. tostring(spec.vTwo))
			print("CVTaddon: onRegisterActionEvents vThree: ".. tostring(spec.vThree))
			print("CVTaddon: onRegisterActionEvents eventActiveV1: ".. tostring(spec.eventActiveV1))
			print("CVTaddon: onRegisterActionEvents eventActiveV2: ".. tostring(spec.eventActiveV2))
			print("CVTaddon: onRegisterActionEvents eventActiveV3: ".. tostring(spec.eventActiveV3))
			print("CVTaddon: onRegisterActionEvents eventActiveV4: ".. tostring(spec.eventActiveV4))
		end
		-- D1
        _, spec.eventIdV1 = self:addActionEvent(spec.actionEventsV1, 'SETVARIOONE', self, CVTaddon.VarioOne, false, true, false, true)
        g_inputBinding:setActionEventTextPriority(spec.eventIdV1, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(spec.eventIdV1, spec.eventActiveV1)
        -- g_inputBinding:setActionEventTextVisibility(spec.eventIdV1, true) -- test if works
		
		-- D2
		_, spec.eventIdV2 = self:addActionEvent(spec.actionEventsV2, 'SETVARIOTWO', self, CVTaddon.VarioTwo, false, true, false, true)
        g_inputBinding:setActionEventTextPriority(spec.eventIdV2, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(spec.eventIdV2, spec.eventActiveV2)
        -- g_inputBinding:setActionEventTextVisibility(spec.eventIdV2, true) -- test if works
		
		-- AR
		_, spec.eventIdV3 = self:addActionEvent(spec.actionEventsV3, 'LMBF_TOGGLE_RAMP', self, CVTaddon.AccRamps, false, true, false, true)
        g_inputBinding:setActionEventTextPriority(spec.eventIdV3, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(spec.eventIdV3, spec.eventActiveV3)
		
		-- BR
		_, spec.eventIdV4 = self:addActionEvent(spec.actionEventsV4, 'LMBF_TOGGLE_BRAMP', self, CVTaddon.BrakeRamps, false, true, false, true)
        g_inputBinding:setActionEventTextPriority(spec.eventIdV4, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(spec.eventIdV4, spec.eventActiveV4)
		
		-- neutral
		_, spec.eventIdV5 = self:addActionEvent(spec.actionEventsV5, 'SETVARION', self, CVTaddon.VarioN, false, true, false, true)
        g_inputBinding:setActionEventTextPriority(spec.eventIdV5, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(spec.eventIdV5, spec.eventActiveV5)
		
		-- rpmUP
		_, spec.eventIdV6 = self:addActionEvent(spec.actionEventsV6, 'SETVARIORPMP', self, CVTaddon.VarioRpmPlus, false, true, false, true)
        g_inputBinding:setActionEventTextPriority(spec.eventIdV6, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(spec.eventIdV6, spec.eventActiveV6)
		-- rpmDn
		_, spec.eventIdV7 = self:addActionEvent(spec.actionEventsV7, 'SETVARIORPMM', self, CVTaddon.VarioRpmMinus, false, true, false, true)
        g_inputBinding:setActionEventTextPriority(spec.eventIdV7, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(spec.eventIdV7, spec.eventActiveV7)
		
		-- Fahrpedalauflösung
		_, spec.eventIdV8 = self:addActionEvent(spec.actionEventsV8, 'SETPEDALWAY_AXIS', self, CVTaddon.VarioPedalRes, false, false, true, true)
        g_inputBinding:setActionEventTextPriority(spec.eventIdV8, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(spec.eventIdV8, spec.eventActiveV8)
		
		-- CVTaddon.updateActionEvents(self)
		--  local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.LOWER_IMPLEMENT, self, Pickup.actionEventTogglePickup, triggerUp, triggerDown, triggerAlways, startActive, callbackState, customIconName)
    end
	if sbshDebugOn then
			print("CVTaddon: onRegisterActionEvents a vOne: ".. tostring(spec.vOne))
			print("CVTaddon: onRegisterActionEvents a vTwo: ".. tostring(spec.vTwo))
			print("CVTaddon: onRegisterActionEvents a vThree: ".. tostring(spec.vThree))
			print("CVTaddon: onRegisterActionEvents a vFour: ".. tostring(spec.vFour))
			print("CVTaddon: onRegisterActionEvents a eventActiveV1: ".. tostring(spec.eventActiveV1))
			print("CVTaddon: onRegisterActionEvents a eventActiveV2: ".. tostring(spec.eventActiveV2))
			print("CVTaddon: onRegisterActionEvents a eventActiveV3: ".. tostring(spec.eventActiveV3))
			print("CVTaddon: onRegisterActionEvents a eventActiveV4: ".. tostring(spec.eventActiveV4))
		end
end

function CVTaddon:onLoad()
	self.spec_CVTaddon = {}
	local spec = self.spec_CVTaddon
	spec.BG1width, spec.BG1height = 0.005, 0.09;
	spec.currBGcolor = { 0.02, 0.02, 0.02, 0.7 }
	-- spec.currentModDirectory = g_currentModDirectory
	CVTaddon.CVTIconBg = Overlay.new(Utils.getFilename("CVTaddon_HUDbg.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	CVTaddon.CVTIconFb = Overlay.new(Utils.getFilename("CVTaddon_HUDfb.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	print("CVT Dir: "..tostring(CVTaddon.modDirectory))
	if spec.vOne == nil then
			spec.vOne = 1
		end
		if spec.vTwo == nil then
			spec.vTwo = 4
		end
		if spec.vThree == nil then
			spec.vThree = 2
		end
		if spec.vFour == nil then
			spec.vFour = 1
		end
		if spec.vFive == nil then
			spec.vFive = 1
		end
		if spec.PedalResolution == nil then
			spec.PedalResolution = 0
		end
		if spec.eventActiveV1 == nil then
			spec.eventActiveV1 = true
		end
		if spec.eventActiveV2 == nil then
			spec.eventActiveV2 = true
		end
		if spec.eventActiveV3 == nil then
			spec.eventActiveV3 = true
		end
		if spec.eventActiveV4 == nil then
			spec.eventActiveV4 = true
		end
		if spec.eventActiveV5 == nil then
			spec.eventActiveV5 = true
		end
		if spec.eventActiveV6 == nil then
			spec.eventActiveV6 = true
		end
		if spec.eventActiveV7 == nil then
			spec.eventActiveV7 = true
		end
		if spec.eventActiveV8 == nil then
			spec.eventActiveV8 = true
		end
	spec.eventIdV1 = nil
	spec.eventIdV2 = nil
	spec.eventIdV3 = nil
	spec.eventIdV4 = nil
	spec.eventIdV5 = nil
	spec.eventIdV6 = nil
	spec.eventIdV7 = nil
	spec.eventIdV8 = nil
	spec.BackupMaxFwSpd = ""
	spec.calcBrakeForce = ""
	
	-- spec.currentModDirectory = g_currentModDirectory
	CVTaddon:VarioOne()
	CVTaddon:VarioTwo()
	CVTaddon:BrakeRamps()
	CVTaddon:AccRamps()
	CVTaddon:VarioRpmPlus()
	CVTaddon:VarioRpmMinus()
	-- CVTaddon:VarioPedalRes()
end

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------
function CVTaddon.initSpecialization()
	local schemaSavegame = Vehicle.xmlSchemaSavegame
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV1")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV2")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV3")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV4")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV5")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV6")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV7")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV8")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#vOne")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#vTwo")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#vThree")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#vFour")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#vFive")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#PedalResolution")
	print("CVT_Addon: init... ")
	print("schemaSavegame: "..tostring(schemaSavegame))
end

function CVTaddon:onPostLoad(savegame)
	if self.spec_motorized ~= nil then
		local spec = self.spec_CVTaddon
		if spec == nil then return end

		if savegame ~= nil then
			local xmlFile = savegame.xmlFile
			local key = savegame.key .. ".FS22_CVT_Addon.CVTaddon"

			spec.eventActiveV1 = xmlFile:getValue(key.."#eventActiveV1", spec.eventActiveV1)
			spec.eventActiveV2 = xmlFile:getValue(key.."#eventActiveV2", spec.eventActiveV2)
			spec.eventActiveV3 = xmlFile:getValue(key.."#eventActiveV3", spec.eventActiveV3)
			spec.eventActiveV4 = xmlFile:getValue(key.."#eventActiveV4", spec.eventActiveV4)
			spec.eventActiveV5 = xmlFile:getValue(key.."#eventActiveV5", spec.eventActiveV5)
			spec.eventActiveV6 = xmlFile:getValue(key.."#eventActiveV6", spec.eventActiveV6)
			spec.eventActiveV7 = xmlFile:getValue(key.."#eventActiveV7", spec.eventActiveV7)
			spec.eventActiveV7 = xmlFile:getValue(key.."#eventActiveV8", spec.eventActiveV8)
			spec.vOne = xmlFile:getValue(key.."#vOne", spec.vOne)
			spec.vTwo = xmlFile:getValue(key.."#vTwo", spec.vTwo)
			spec.vThree = xmlFile:getValue(key.."#vThree", spec.vThree)
			spec.vFour = xmlFile:getValue(key.."#vFour", spec.vFour)
			spec.vFive = xmlFile:getValue(key.."#vFive", spec.vFive)
			spec.PedalResolution = xmlFile:getValue(key.."#PedalResolution", spec.PedalResolution)
			print("CVT_Addon: personal adjustments loaded for "..self:getName())
			print("CVT_Addon: Load Driving Level id: "..tostring(spec.vOne))
			print("CVT_Addon: Load Acceleration Ramp id: "..tostring(spec.vTwo))
			print("CVT_Addon: Load Brake Ramp id: "..tostring(spec.vThree))
		end
	end
end

function CVTaddon:saveToXMLFile(xmlFile, key, usedModNames)
	if self.spec_motorized ~= nil then
		local spec = self.spec_CVTaddon
		
		-- spec.actionsLength = table.getn(spec.actions)
		
		xmlFile:setValue(key.."#eventActiveV1", spec.eventActiveV1)
		xmlFile:setValue(key.."#eventActiveV2", spec.eventActiveV2)
		xmlFile:setValue(key.."#eventActiveV3", spec.eventActiveV3)
		xmlFile:setValue(key.."#eventActiveV4", spec.eventActiveV4)
		xmlFile:setValue(key.."#eventActiveV5", spec.eventActiveV5)
		xmlFile:setValue(key.."#eventActiveV6", spec.eventActiveV6)
		xmlFile:setValue(key.."#eventActiveV7", spec.eventActiveV7)
		xmlFile:setValue(key.."#eventActiveV8", spec.eventActiveV8)
		xmlFile:setValue(key.."#vOne", spec.vOne)
		xmlFile:setValue(key.."#vTwo", spec.vTwo)
		xmlFile:setValue(key.."#vThree", spec.vThree)
		xmlFile:setValue(key.."#vFour", spec.vFour)
		xmlFile:setValue(key.."#vFive", spec.vFive)
		xmlFile:setValue(key.."#PedalResolution", spec.PedalResolution)

		print("CVT_Addon: saved personal adjustments for "..self:getName())
		print("CVT_Addon: Save Driving Level id: "..tostring(spec.vOne))
		print("CVT_Addon: Save Acceleration Ramp id: "..tostring(spec.vTwo))
		print("CVT_Addon: Save Brake Ramp id: "..tostring(spec.vThree))
	end
end
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

function CVTaddon:BrakeRamps()
	local spec = self.spec_CVTaddon
	if sbshDebugOn then
		print("BrRamp Taste gedrückt vThree: "..spec.vThree)
		print("BrRamp Taste gedrückt lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
	end
	if self.CVTaddon == nil then 
        return
    end
	if not spec.eventActiveV4 then
        return
    end
	if (spec.vThree == 1) then -- BRamp 1
		
		if sbshDebugOn then
			print("BrRamp 1 vThree: "..spec.vThree)
			print("BrRamp 1 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
		end
	end
	if (spec.vThree == 2) then -- BRamp 2
		
		if sbshDebugOn then
			print("BrRamp 2 vThree: "..spec.vThree)
			print("BrRamp 2 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
		end
	end
	if (spec.vThree == 3) then -- BRamp 3
		
		if sbshDebugOn then
			print("BrRamp 3 vThree: "..spec.vThree)
			print("BrRamp 3 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
		end
	end
	if (spec.vThree == 4) then -- BRamp 4
		
		if sbshDebugOn then
			print("BrRamp 4 vThree: "..spec.vThree)
			print("BrRamp 4 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
		end
	end
	if (spec.vThree == 5) then -- BRamp 5
		
		if sbshDebugOn then
			print("BrRamp 5 vThree: "..spec.vThree)
			print("BrRamp 5 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
		end
	end
	if spec.vThree == 5 then
		spec.vThree = 1
	else
		spec.vThree = spec.vThree + 1
	end
	if sbshDebugOn then
		print("BrRamp Taste losgelassen vThree: "..spec.vThree)
		print("BrRamp Taste losgelassen lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
	end
end

function CVTaddon:AccRamps()
	local spec = self.spec_CVTaddon
	if sbshDebugOn then
		print("AccRamp Taste gedrückt vTwo: "..spec.vTwo)
		print("AccRamp Taste gedrückt acc: "..self.spec_motorized.motor.accelerationLimit)
	end
	if self.CVTaddon == nil then 
        return
    end
	if not spec.eventActiveV3 then
        return
    end
	if (spec.vTwo == 1) then -- Ramp 1
		-- self.spec_motorized.motor.accelerationLimit = 0.50
		-- self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce-0.10))
		if sbshDebugOn then
			print("AccRamp 1 vTwo: "..spec.vTwo)
			print("AccRamp 1 acc0.5: "..self.spec_motorized.motor.accelerationLimit)
		end
	end
	if (spec.vTwo == 2) then -- Ramp 2
		-- self.spec_motorized.motor.accelerationLimit = 1.00
		-- self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce))
		if sbshDebugOn then
			print("AccRamp 2 vTwo: "..spec.vTwo)
			print("AccRamp 2 acc1.0: "..self.spec_motorized.motor.accelerationLimit)
		end
	end
	if (spec.vTwo == 3) then -- Ramp 3
		-- self.spec_motorized.motor.accelerationLimit = 1.50
		-- self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.03))
		if sbshDebugOn then
			print("AccRamp 3 vTwo: "..spec.vTwo)
			print("AccRamp 3 acc1.5: "..self.spec_motorized.motor.accelerationLimit)
		end
	end
	if (spec.vTwo == 4) then -- Ramp 4
		-- self.spec_motorized.motor.accelerationLimit = 2.00 -- Standard
		-- self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.08))
		-- self.spec_motorized.motor.peakMotorTorque = self.spec_motorized.motor.peakMotorTorque * 0.5
		if sbshDebugOn then
			print("AccRamp 4 vTwo: "..spec.vTwo)
			print("AccRamp 4 acc2.0: "..self.spec_motorized.motor.accelerationLimit)
		end
	end
	if spec.vTwo == 4 then
		spec.vTwo = 1
	else
		spec.vTwo = spec.vTwo + 1
	end
	if sbshDebugOn then
		print("AccRamp Taste losgelassen vTwo: "..spec.vTwo)
		print("AccRamp Taste losgelassen acc: "..self.spec_motorized.motor.accelerationLimit)
	end
end

function CVTaddon:VarioRpmPlus() ----- +
	local spec = self.spec_CVTaddon
	if sbshDebugOn then
		print("VarioRpmPlus Taste gedrückt vFive: "..spec.vFive)
		-- print("VarioRpmPlus : FwS/BwS/lBFS/cBF:")
	end
	if self.CVTaddon == nil then 
        return
    end
	if not spec.eventActiveV6 then
        return
    end
	spec.PTOspice = self.spec_motorized.motor.lastPtoRpm
	if spec.vFive <= 9 then
		spec.vFive = spec.vFive + 1
	end
	if spec.vFive == 10 then
		spec.vFive = 10
		spec.eventActiveV6 = true
	end
	spec.eventActiveV7 = true
	if sbshDebugOn then
		print("VarioRpmPlus vFive: "..spec.vFive)
		-- print("VarioRpmPlus : FwS/BwS/lBFS/cBF:")
	end
	
	if sbshDebugOn then
		print("VarioRpmPlus Taste losgelassen vFive: "..spec.vFive)
		-- print("VarioRpmPlus : FwS/BwS/lBFS/cBF:")
	end
end
function CVTaddon:VarioRpmMinus() ----- -
	local spec = self.spec_CVTaddon
	if sbshDebugOn then
		print("VarioRpmMinus Taste gedrückt vFive: "..spec.vFive)
		-- print("VarioRpmPlus : FwS/BwS/lBFS/cBF:")
	end
	if self.CVTaddon == nil then 
        return
    end
	if not spec.eventActiveV7 then
        return
    end
	if spec.vFive >= 2 then
		spec.vFive = spec.vFive - 1
	end
	if spec.vFive == 1 then
		spec.vFive = 1
		spec.eventActiveV7 = false
	end
	spec.eventActiveV6 = true
	if sbshDebugOn then
		print("VarioRpmMinus vFive: "..spec.vFive)
		-- print("VarioRpmPlus : FwS/BwS/lBFS/cBF:")
	end
	
	if sbshDebugOn then
		print("VarioRpmMinus Taste losgelassen vFive: "..spec.vFive)
		-- print("VarioRpmPlus : FwS/BwS/lBFS/cBF:")
	end
end

function CVTaddon:VarioOne() -- field
	local spec = self.spec_CVTaddon
	local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
	if sbshDebugOn then
		print("VarioOne Taste gedrückt vOne: "..spec.vOne)
		print("VarioOne : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
	end
	if self.CVTaddon == nil then 
        return
    end
	if not spec.eventActiveV1 then
        return
    end
	currentDirection = self.spec_motorized.motor.currentDirection
	if isEntered and spec.isMotorOn then
		if self:getLastSpeed() >= 11 and spec.vFour == 1 then
			g_currentMission:showBlinkingWarning(g_i18n:getText("txt_warn_tofastDn"), 3072)
			self:addDamageAmount(math.min(0.0002*(self:getOperatingTime()/1000000)+(self:getLastSpeed()/100), 1))
			spec.eventActiveV1 = true
			spec.eventActiveV2 = false
		end
		-- if (spec.vOne == 1) then
		if (spec.vOne == 1) then
			if self:getLastSpeed() <=10 then
				if self:getLastSpeed() >1 and spec.vFour == 1 then
					self:addDamageAmount(math.min(0.00008*(self:getOperatingTime()/1000000)+(self.spec_motorized.motor.lastMotorRpm/10000)+(self:getLastSpeed()/100), 1))
				end
				-- spec.vOne = 3.2
				spec.vOne = 2
				-- spec.vFour = 1
				spec.eventActiveV1 = false
				spec.eventActiveV2 = true
				if sbshDebugOn then
					print("VarioOne vOne: "..spec.vOne)
					print("VarioOne : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
				end
			end
		end
		if currentDirection ~= self.spec_motorized.motor.currentDirection then
			spec.vFour = 1
		end
	end
	
	if sbshDebugOn then
		print("VarioOne Taste losgelassen vOne: "..spec.vOne)
		print("VarioOne : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
	end
end

function CVTaddon:VarioTwo() -- street
	local spec = self.spec_CVTaddon
	local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
	if sbshDebugOn then
		print("VarioTwo Taste gedrückt vOne: "..spec.vOne)
		print("VarioTwo : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
		print("VarioTwo : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxBwSpd))
	end
	if self.CVTaddon == nil then 
        return
    end
	if not spec.eventActiveV2 then
        return
    end
	currentDirection = self.spec_motorized.motor.currentDirection
	if isEntered and spec.isMotorOn then
		if self:getLastSpeed() > 10 then
			g_currentMission:showBlinkingWarning(g_i18n:getText("txt_warn_tofastUp"), 3072)
			self:addDamageAmount(math.min(0.00015*(self:getOperatingTime()/1000000), 1)) -- 3.6
		end
		-- if (spec.vOne ~= 1) then
		if (spec.vOne == 2) then
			-- spec.vOne = 1
			spec.vOne = 1
			-- spec.vFour = 1
			local SpeedScale = spec.PedalResolution
			self.spec_motorized.motor.maxForwardSpeed = spec.BackupMaxFwSpd
			self.spec_motorized.motor.maxBackwardSpeed = spec.BackupMaxBwSpd
			-- self.spec_motorized.motor.lowBrakeForceScale = (spec.calcBrakeForce+0.05)
			-- g_inputBinding:setActionEventTextVisibility(spec.eventIdV1, true)
			-- g_inputBinding:setActionEventTextVisibility(spec.eventIdV2, false)
			spec.eventActiveV1 = true
			spec.eventActiveV2 = false
			if sbshDebugOn then
				print("VarioTwo vOne: "..spec.vOne)
				print("VarioTwo : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
				print("VarioTwo : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxBwSpd))
			end
		end
		if currentDirection ~= self.spec_motorized.motor.currentDirection then
			spec.vFour = 1
		end
	end
	if sbshDebugOn then
		print("VarioTwo Taste losgelassen vOne: "..spec.vOne)
		print("VarioTwo : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
		print("VarioTwo : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxFwSpd))
	end
end

function CVTaddon:VarioN() -- neutral
	local spec = self.spec_CVTaddon
	local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
	if sbshDebugOn then
		print("VarioN Taste gedrückt vFour: "..spec.vFour)
		print("VarioN : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
		print("VarioN : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxBwSpd))
	end
	if isEntered and spec.isMotorOn then
		if (spec.vFour == 0) then
			spec.eventActiveV5 = true
			print("Neutral AN") -- debug
			if self:getLastSpeed() > 5 then
				self:addDamageAmount(math.min(0.00015*(self:getOperatingTime()/1000000)+(self.spec_motorized.motor.lastMotorRpm/10000)+(self:getLastSpeed()/100), 1))
			end
		end
		if (spec.vFour == 1) then
			spec.eventActiveV5 = true
			print("Neutral AUS") -- debug
			if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm+150 then
				self:addDamageAmount(math.min(0.00005*(self:getOperatingTime()/1000000)+(self.spec_motorized.motor.lastMotorRpm/10000), 1))
			end
		end
		if spec.vFour == 1 then
			spec.vFour = 0
		else
			spec.vFour = 1
		end
	end
end

--[[function CVTaddon:VarioPedalRes(inputValue) -- Pedal Resolution
	local spec = self.spec_CVTaddon
	-- local vehicle = self.vehicle
	local vehicle = self.vehicle
	local inputValue = vehicle:getAxisForward()
	-- lastAcceleratorPedal
	if sbshDebugOn then
		print("VarioPedalRes Achse bewegt: "..tostring(spec.PedalResolution))
		print("VarioN : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
		print("VarioN : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxBwSpd))
	end
	local spec.PedalResolution = inputValue
	-- self.spec_motorized.motor:getUseAutomaticGearShifting()
end]]--

--[[local function isConfigImplement(implement)
	--return implement.spec_workArea ~= nil or implement.spec_combine ~= nil or implement.spec_forageWagon ~= nil or implement.spec_baler ~= nil
	local returnType
	
	if implement.spec_plow ~= nil then returnType = "Plow"
		elseif implement.spec_combine ~= nil then returnType = "Combine"
		elseif implement.spec_sowingMachine ~= nil then returnType = "Sowingmachine"
		elseif implement.spec_cultivator ~= nil then returnType = "Cultivator"
		elseif implement.spec_mulcher ~= nil then returnType = "Mulcher"
		elseif implement.spec_roller ~= nil then returnType = "Roller"
		elseif implement.spec_forageWagon ~= nil then returnType = "Foragewagon"
		elseif implement.spec_baler ~= nil then returnType = "Baler"
	end
	
	return returnType
end]]--

function CVTaddon:onUpdate(dt)
	local spec = self.spec_CVTaddon
	local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
	local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName)
	local StI = storeItem.categoryName
	local isTractor = StI == "TRACTORSS" or StI == "TRACTORSM" or StI == "TRACTORSL"
	local isErnter = StI == "HARVESTERS" or StI == "FORAGEHARVESTERS" or StI == "POTATOVEHICLES" or StI == "BEETVEHICLES" or StI == "SUGARCANEVEHICLES" or StI == "COTTONVEHICLES" or StI == "MISCVEHICLES"
	local isLoader = StI == "FRONTLOADERVEHICLES" or StI == "TELELOADERVEHICLES" or StI == "SKIDSTEERVEHICLES" or StI == "WHEELLOADERVEHICLES"
	local isPKWLKW = StI == "CARS" or StI == "TRUCKS"
	local isWoodWorker = storeItem.categoryName == "WOODHARVESTING"
	local isFFF = storeItem.categoryName == "FORKLIFTS"
	spec.isMotorOn = self.spec_motorized.motor.lastMotorRpm > 0 and self.spec_motorized.motor.lastMotorRpm ~= nil
	spec.retrpm = string.format("%.2f", self.spec_motorized.motor.lastMotorRpm/10000)
	spec.isVarioTM = self.spec_motorized.motor.lastManualShifterActive == false and self.spec_motorized.motor.groupType == 1 and self.spec_motorized.motor.gearType == 1 and self.spec_motorized.motor.forwardGears == nil
	local currentSpeedDrv = tonumber(string.format("%.2f", self:getLastSpeed()))
	spec.HydrostatPedal = math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
	if isEntered and spec.isVarioTM and not isPKWLKW then
		if self.CVTaddon == nil then
			self.CVTaddon = true

			if self.spec_motorized ~= nil then
				if self.spec_motorized.motor ~= nil then
					print("CVT_Addon: Motorized eingestiegen")
				end;
			end;
		end;
		
		-- ACCELERATION RAMPS - BESCHLEUNIGUNGSRAMPEN
		if spec.isMotorOn then
			-- print("CVT_Addon: Motor AN")
		
			if spec.vFour ~= 0 then
				if spec.vTwo == 1 and spec.isVarioTM then
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_accRamp4")) -- #l10n
					self.spec_motorized.motor.accelerationLimit = 2.00 -- Standard
					self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.08))
					spec.AR_genText = tostring(g_i18n:getText("txt_accRamp4"))
				end
				if spec.vTwo == 2 and spec.isVarioTM then
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_accRamp1")) -- #l10n
					self.spec_motorized.motor.accelerationLimit = 0.50
					self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce-0.10))
					spec.AR_genText = tostring(g_i18n:getText("txt_accRamp1"))
				end
				if spec.vTwo == 3 and spec.isVarioTM then
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_accRamp2")) -- #l10n
					self.spec_motorized.motor.accelerationLimit = 1.00
					self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce))
					spec.AR_genText = tostring(g_i18n:getText("txt_accRamp2"))
				end
				if spec.vTwo == 4 and spec.isVarioTM then
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_accRamp3")) -- #l10n
					self.spec_motorized.motor.accelerationLimit = 1.50
					self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.03))
					spec.AR_genText = tostring(g_i18n:getText("txt_accRamp3"))
				end
			end
			
			-- BRAKE RAMPS - BREMSRAMPEN
			if spec.vThree == 1 and spec.isVarioTM then
				-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp5")) -- #l10n
				self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00500 -- 17 kmh
				spec.BR_genText = tostring(g_i18n:getText("txt_bRamp5"))
			end
			if spec.vThree == 2 and spec.isVarioTM then
				-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp1")) -- #l10n off
				self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00027777777777778 -- 1-2 kmh
				spec.BR_genText = tostring(g_i18n:getText("txt_bRamp1"))
			end
			if spec.vThree == 3 and spec.isVarioTM then
				-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp2")) -- #l10n
				self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00150 -- ca 4 kmh
				spec.BR_genText = tostring(g_i18n:getText("txt_bRamp2"))
			end
			if spec.vThree == 4 and spec.isVarioTM then
				-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp3")) -- #l10n
				self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00250 -- ca 8 kmh
				spec.BR_genText = tostring(g_i18n:getText("txt_bRamp3"))
			end
			if spec.vThree == 5 and spec.isVarioTM then
				-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp4")) -- #l10n
				self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00427 -- 15 km/h
				spec.BR_genText = tostring(g_i18n:getText("txt_bRamp4"))
			end
			
			spec.spiceLoad = tonumber(string.format("%.2f", math.min(math.abs(self.spec_motorized.motor.smoothedLoadPercentage)/5, 0.04)))
			spec.spiceRPM = self.spec_motorized.motor.lastMotorRpm
			spec.spiceMaxSpd = self.spec_motorized.motor.maxForwardSpeed
			
			-- NEUTRAL
			if spec.vFour == 0 then
				self.spec_motorized.motor.minForwardGearRatio = 0
				self.spec_motorized.motor.maxForwardGearRatio = 0
				self.spec_motorized.motor.minBackwardGearRatio = 0
				self.spec_motorized.motor.minBackwardGearRatio = 0
				self.spec_motorized.motor.manualClutchValue = 1
				self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 1
				self.spec_motorized.motor.lowBrakeForceScale = 0
				self.spec_motorized.motor.accelerationLimit = 0
				self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0 -- 0
				self.spec_motorized.motor.maxBackwardSpeed = 0
				-- self.spec_motorized.motor.currentDirection = 0
				-- need to unlock AccelerationPedal when direction is 0 as neutral
				
				local loadsetXP
				local accPedal = self.spec_motorized.motor.lastAcceleratorPedal
				local loadDrive = 0
				loadDrive = math.max(0, accPedal)
				if (self.spec_motorized.motor.lastMotorRpm / self.spec_motorized.motor.maxRpm) < loadDrive then
					loadsetXP = 1;
				else
					loadsetXP = 0;
				end;
				self.spec_motorized.motor.rawLoadPercentage = math.min(math.max(self.spec_motorized.motor.rawLoadPercentage, loadsetXP)*1.8,1)
				self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm + math.abs(accPedal) *80, self.spec_motorized.motor.maxRpm)
				-- g_currentMission:addExtraPrintText(tostring(math.abs(accPedal)))
				-- self.spec_motorized.motor.currentDirection = 0
			end
			if spec.vFour == 1 then
				self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin
				self.spec_motorized.motor.maxForwardGearRatio = self.spec_motorized.motor.maxForwardGearRatioOrigin
				self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minBackwardGearRatioOrigin
				self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minBackwardGearRatioOrigin
				self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin
				self.spec_motorized.motor.manualClutchValue = 0
				loadsetXP = 0;
				--
			end
			
			-- MOTORDREHZAHL (Handgas-digital)    min
			if self.spec_motorized.motor.lastPtoRpm == nil then
				self.spec_motorized.motor.lastPtoRpm = 0
			end
			if spec.vFive == 1 and spec.vFive ~= nil then
				self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 1
			end
			if spec.vFive == 2 and spec.vFive ~= nil then
				-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/1.99), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
				self.spec_motorized.motor.lastMotorRpm = math.min((math.max(self.spec_motorized.motor.minRpm + 150, self.spec_motorized.motor.lastPtoRpm)), self.spec_motorized.motor.maxRpm)
			end
			if spec.vFive == 3 and spec.vFive ~= nil then
				-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/2.97), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
				self.spec_motorized.motor.lastMotorRpm = math.min((math.max(self.spec_motorized.motor.minRpm + 250, self.spec_motorized.motor.lastPtoRpm)), self.spec_motorized.motor.maxRpm)
			end
			if spec.vFive == 4 and spec.vFive ~= nil then
				self.spec_motorized.motor.lastMotorRpm = math.min((math.max(self.spec_motorized.motor.minRpm + 350, self.spec_motorized.motor.lastPtoRpm)), self.spec_motorized.motor.maxRpm)
				-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/3.95), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
			end
			if spec.vFive == 5 and spec.vFive ~= nil then
				self.spec_motorized.motor.lastMotorRpm = math.min((math.max(self.spec_motorized.motor.minRpm + 500, self.spec_motorized.motor.lastPtoRpm)), self.spec_motorized.motor.maxRpm)
				-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/4.92), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
			end
			if spec.vFive == 6 and spec.vFive ~= nil then
				-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/5.88), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
				self.spec_motorized.motor.lastMotorRpm = math.min((math.max(self.spec_motorized.motor.minRpm + 675, self.spec_motorized.motor.lastPtoRpm)), self.spec_motorized.motor.maxRpm)
			end
			if spec.vFive == 7 and spec.vFive ~= nil then
				-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/6.85), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
				self.spec_motorized.motor.lastMotorRpm = math.min((math.max(self.spec_motorized.motor.minRpm + 825, self.spec_motorized.motor.lastPtoRpm)), self.spec_motorized.motor.maxRpm)
			end
			if spec.vFive == 8 and spec.vFive ~= nil then
				-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/7.82), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
				self.spec_motorized.motor.lastMotorRpm = math.min((math.max(self.spec_motorized.motor.minRpm + 1000, self.spec_motorized.motor.lastPtoRpm)), self.spec_motorized.motor.maxRpm)
			end
			if spec.vFive == 9 and spec.vFive ~= nil then
				-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/8.78), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
				self.spec_motorized.motor.lastMotorRpm = math.min((math.max(self.spec_motorized.motor.minRpm + 1150, self.spec_motorized.motor.lastPtoRpm)), self.spec_motorized.motor.maxRpm)
			end
			if spec.vFive == 10 and spec.vFive ~= nil then
				-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/9.72), self.spec_motorized.motor.maxRpm), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
				self.spec_motorized.motor.lastMotorRpm = math.min((math.max(self.spec_motorized.motor.maxRpm-51, self.spec_motorized.motor.lastPtoRpm)), self.spec_motorized.motor.maxRpm)
				
			end
			
			
			
			-- g_currentMission:addExtraPrintText("No: "..tostring(spec.vFive))
			-- g_currentMission:addExtraPrintText("rpm: "..tostring(self.spec_motorized.motor.lastMotorRpm))
			-- g_currentMission:addExtraPrintText("calc rpm: "..(1 + (spec.vFive/10)))
			
			
			
			
			-- -- FAHRSTUFE I. 
			-- if spec.vOne ~= 1 and spec.vOne ~= nil and spec.isVarioTM then
			if spec.vOne ~= 1 and spec.vOne ~= nil and spec.isVarioTM and self.spec_motorized.motor.maxForwardSpeedOrigin > 6.68 then
				spec.spiceDFWspeed = math.min(math.max(spec.BackupMaxFwSpd / 2.1, 4.49), 6.94)
				spec.spiceDBWspeed = math.min(math.max(spec.BackupMaxFwSpd / 1.4, 3.21), 6.36)
				-- spec.spiceDFWspeedT = math.min(math.max(spec.BackupMaxFwSpd / 2.1, 4.49), 6.94) * spec.HydrostatPedal
				-- spec.spiceDBWspeedT = math.min(math.max(spec.BackupMaxFwSpd / 1.4, 3.21), 6.36) * spec.HydrostatPedal
				-- if spec.HydrostatPedal >= 0.25 then
					-- self.spec_motorized.motor.maxForwardSpeed = spec.spiceDFWspeedT
					-- self.spec_motorized.motor.maxBackwardSpeed = spec.spiceDBWspeedT
					-- g_currentMission:addExtraPrintText("TMS Antrieb")
				-- end
				-- if spec.HydrostatPedal < 0.25 then
					-- self.spec_motorized.motor.maxForwardSpeed = spec.spiceDFWspeed
					-- self.spec_motorized.motor.maxBackwardSpeed = spec.spiceDBWspeed
					-- g_currentMission:addExtraPrintText("TMS byPass")
				-- end
				
				self.spec_motorized.motor.maxForwardSpeed = spec.spiceDFWspeed
				self.spec_motorized.motor.maxBackwardSpeed = spec.spiceDBWspeed
				-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_VarioOne")) -- #l10n
				self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 1.4
				if spec.spiceRPM > self.spec_motorized.motor.minRpm + 150 then
					if self.spec_motorized.motor.smoothedLoadPercentage < 0.6 then
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.975), self.spec_motorized.motor.lastPtoRpm)
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
					end
					if self.spec_motorized.motor.smoothedLoadPercentage >= 0.6 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.65 then
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.98), self.spec_motorized.motor.lastPtoRpm)
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
					end
					if self.spec_motorized.motor.smoothedLoadPercentage >= 0.65 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.7 then
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.985), self.spec_motorized.motor.lastPtoRpm)
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
					end
					if self.spec_motorized.motor.smoothedLoadPercentage >= 0.75 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.99), self.spec_motorized.motor.lastPtoRpm)
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
					end
					if self.spec_motorized.motor.smoothedLoadPercentage >= 0.85 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.9 then
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 1), self.spec_motorized.motor.lastPtoRpm)
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
					end
					if self.spec_motorized.motor.smoothedLoadPercentage > 0.9 then
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * 0.92
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * math.min(0.97+spec.spiceLoad, 1)), self.spec_motorized.motor.lastPtoRpm)
					end
				end
			-- end
			-- HYDROSTAT
			elseif spec.vOne ~= 1 and spec.vOne ~= nil and spec.isVarioTM and self.spec_motorized.motor.maxForwardSpeedOrigin <= 6.68 and not isTractor and isWoodWorker then
				-- spec.HydrostatPedal = math.abs(self.spec_motorized.motor.lastAcceleratorPedal) -- nach oben verschoben
				spec.spiceDFWspeedHs = math.min(math.max(spec.BackupMaxFwSpd / 2.1, 2.8), 3.16)
				spec.spiceDBWspeedHs = math.min(math.max(spec.BackupMaxFwSpd / 1.4, 2.8), 3.16)
				spec.spiceDFWspeedH = math.min(math.max(spec.BackupMaxFwSpd / 2.1, 2.8), 3.16) * spec.HydrostatPedal
				spec.spiceDBWspeedH = math.min(math.max(spec.BackupMaxFwSpd / 1.4, 2.8), 3.16) * spec.HydrostatPedal
				if spec.HydrostatPedal >= 0.2 then
					self.spec_motorized.motor.maxForwardSpeed = spec.spiceDFWspeedH
					self.spec_motorized.motor.maxBackwardSpeed = spec.spiceDBWspeedH
					g_currentMission:addExtraPrintText("Hydrostat Antrieb")
				end
				if spec.HydrostatPedal < 0.2 then
					self.spec_motorized.motor.maxForwardSpeed = spec.spiceDFWspeedHs
					self.spec_motorized.motor.maxBackwardSpeed = spec.spiceDBWspeedHs
					g_currentMission:addExtraPrintText("Hydrostat byPass")
				end
				
				self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 2.1
				if spec.spiceRPM > self.spec_motorized.motor.minRpm + 150 then
					if self.spec_motorized.motor.smoothedLoadPercentage < 0.4 then
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.98), self.spec_motorized.motor.lastPtoRpm)
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
					end
					if self.spec_motorized.motor.smoothedLoadPercentage > 0.6 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.99), self.spec_motorized.motor.lastPtoRpm)
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
					end
					if self.spec_motorized.motor.smoothedLoadPercentage > 0.8 then
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * 0.92
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * math.min(0.97+spec.spiceLoad, 1)), self.spec_motorized.motor.lastPtoRpm)
					end
				end
			end
			
			-- -- FAHRSTUFE II. (Street/light weight transport or work) inputbinding
			if spec.vOne == 1 and spec.vOne ~= nil and spec.isVarioTM then
				self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 0.76
				-- pedal TMS tryout
				-- spec.spiceDFWspeed = spec.BackupMaxFwSpd
				-- spec.spiceDBWspeed = spec.BackupMaxFwSpd
				-- spec.spiceDFWspeedT = spec.BackupMaxFwSpd * spec.HydrostatPedal
				-- spec.spiceDBWspeedT = spec.BackupMaxFwSpd * spec.HydrostatPedal
				-- if spec.HydrostatPedal >= 0.25 then -- need to smoothe downspeed
					-- self.spec_motorized.motor.maxForwardSpeed = spec.spiceDFWspeedT
					-- self.spec_motorized.motor.maxBackwardSpeed = spec.spiceDBWspeedT
					-- g_currentMission:addExtraPrintText("TMS Antrieb")
				-- end
				-- if spec.HydrostatPedal < 0.25 then
					-- self.spec_motorized.motor.maxForwardSpeed = spec.BackupMaxFwSpd
					-- self.spec_motorized.motor.maxBackwardSpeed = spec.BackupMaxBwSpd
					-- g_currentMission:addExtraPrintText("TMS byPass")
				-- end
				
				-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_VarioTwo")) -- #l10n
							
				if spec.spiceRPM > self.spec_motorized.motor.minRpm + 150 then
					if self.spec_motorized.motor.smoothedLoadPercentage < 0.4 then
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.97), self.spec_motorized.motor.lastPtoRpm)
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
					end
					if self.spec_motorized.motor.smoothedLoadPercentage >= 0.4 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.5 then
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.975), self.spec_motorized.motor.lastPtoRpm)
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
					end
					if self.spec_motorized.motor.smoothedLoadPercentage >= 0.5 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.6 then
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.98), self.spec_motorized.motor.lastPtoRpm)
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
					end
					if self.spec_motorized.motor.smoothedLoadPercentage >= 0.6 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.7 then
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.985), self.spec_motorized.motor.lastPtoRpm)
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
					end
					if self.spec_motorized.motor.smoothedLoadPercentage >= 0.7 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.99), self.spec_motorized.motor.lastPtoRpm)
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
					end
					if self.spec_motorized.motor.smoothedLoadPercentage > 0.8 then
						-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * 0.92
						self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * math.min(0.96+spec.spiceLoad, 1)), self.spec_motorized.motor.lastPtoRpm)
					end
				end
			end
		end
	end
	-- for vehicleType, vehicle in pairs(g_vehicleTypeManager.types) do
	-- and vehicleType ~= "locomotive" and vehicleType ~= "ConveyorBelt" and vehicleType ~= "woodCrusherTrailerDrivable"
		-- if vehicle ~= nil then
			-- print("CVT VT: "..self:vehicle.vehicleType)
		-- end
	-- end
	-- g_currentMission:addExtraPrintText("moveTime: " .. tostring(self.spec_attacherJointControl.jointDesc.moveTime))
	-- g_currentMission:addExtraPrintText("operatingTime: " .. tostring(self:getOperatingTime()/100000))
	g_currentMission:addExtraPrintText("lastAcceleratorPedal: " .. tostring(self.spec_motorized.motor.lastAcceleratorPedal))
	-- g_currentMission:addExtraPrintText("getTypeByName: " .. tostring(self.spec_motorized.vehicle.vehicleType))
	-- g_vehicleTypeManager:getTypeByName(self.typeName)))
		
	g_currentMission:addExtraPrintText("storeItem.categoryName: " .. tostring(storeItem.categoryName))
	-- g_currentMission:addExtraPrintText("lastRotSpeed: " .. tostring(tool.lastRotSpeed))
	
	if sbshFlyDebugOn then
	-- -- Dev Text Help Zeug -------------------------------------------------------------------------------------------------------------------------------
			
			-- g_currentMission:addExtraPrintText("lastManualShifterActive: " .. tostring(self.spec_motorized.motor.lastManualShifterActive))
			-- g_currentMission:addExtraPrintText("lowBrakeForceSpeedLimit: " .. tostring(self.spec_motorized.motor.lowBrakeForceSpeedLimit))
			-- g_currentMission:addExtraPrintText("forwardGears: " .. tostring(self.spec_motorized.motor.forwardGears)) -- works for isVarioTM
			-- print("lowBrakeForceSpeedLimit: " .. tostring(self.spec_motorized.motor.lowBrakeForceSpeedLimit))
			-- print("lowBrakeForceScale: " .. tostring(self.spec_motorized.motor.lowBrakeForceScale))
			
			-- g_currentMission:addExtraPrintText("gearRatio: " .. self.spec_motorized.motor.gearRatio)
			-- g_currentMission:addExtraPrintText("differentialRotSpeed: " .. self.spec_motorized.motor.differentialRotSpeed)
			-- g_currentMission:addExtraPrintText("clutchSlippingTimer: " .. self.spec_motorized.motor.clutchSlippingTimer)
			-- g_currentMission:addExtraPrintText("clutchSlippingGearRatio: " .. self.spec_motorized.motor.clutchSlippingGearRatio)
			-- g_currentMission:addExtraPrintText("dampingRateZeroThrottleClutchEngaged: " .. self.spec_motorized.motor.dampingRateZeroThrottleClutchEngaged)
			-- g_currentMission:addExtraPrintText("motorRotSpeedClutchEngaged: " .. self.spec_motorized.motor.motorRotSpeedClutchEngaged)
			-- g_currentMission:addExtraPrintText("manualClutchValue: " .. self.spec_motorized.motor.manualClutchValue)
			g_currentMission:addExtraPrintText("currentDirection: " .. tostring(self.spec_motorized.motor.currentDirection))
			-- g_currentMission:addExtraPrintText("accelerationLimit: " .. self.spec_motorized.motor.accelerationLimit)
			-- g_currentMission:addExtraPrintText("directionLastGear: " .. tostring(self.spec_motorized.motor.directionLastGear))
			-- g_currentMission:addExtraPrintText("targetGear: " .. tostring(self.spec_motorized.motor.targetGear))
			-- g_currentMission:addExtraPrintText("directionChangeGearIndex: " .. tostring(self.spec_motorized.motor.directionChangeGearIndex))
			g_currentMission:addExtraPrintText("lastAcceleratorPedal: " .. tostring(self.spec_motorized.motor.lastAcceleratorPedal))
			-- g_currentMission:addExtraPrintText("age: " .. tostring(Vehicle.getSpecValueOperatingTime))
			-- g_currentMission:addExtraPrintText("age: " .. tostring(Vehicle.operatingTime))
			g_currentMission:addExtraPrintText("groupType: " .. tostring(self.spec_motorized.motor.groupType))
			g_currentMission:addExtraPrintText("gearType: " .. tostring(self.spec_motorized.motor.gearType))
			g_currentMission:addExtraPrintText("gearShiftMode: " .. tostring(self.spec_motorized.motor.gearShiftMode))
			
	--------------------------------------------------------------------------------------------------------------------------------------------------------------
	end
	g_currentMission:addExtraPrintText("isTractor: "..tostring(isTractor))
	g_currentMission:addExtraPrintText("isErnter: "..tostring(isErnter))
	g_currentMission:addExtraPrintText("isLoader: "..tostring(isLoader))
	g_currentMission:addExtraPrintText("isPKWLKW: "..tostring(isPKWLKW))
	g_currentMission:addExtraPrintText("isWoodWorker: "..tostring(isWoodWorker))
	g_currentMission:addExtraPrintText("isFFF: "..tostring(isFFF))
	g_currentMission:addExtraPrintText("StI: "..tostring(StI))

end

-- function CVTaddon.createBackground()
	-- local width, height = getNormalizedScreenValues(unpack(CVTaddon.BGSIZE.BACKGROUND))
	-- local backgroundOverlay = Overlay.new(nil, 0.2, 0.9542, width, height)
	-- -- local boxOverlay = Overlay.new(_, 0.2, 0.9542, 0.04, 0.0358)

	-- backgroundOverlay:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_CENTER)

	-- return backgroundOverlay
-- end

function CVTaddon:onDraw(vehicle, dt)
	local spec = self.spec_CVTaddon
	local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName)
	local StI = storeItem.categoryName
	local isTractor = StI == "TRACTORSS" or StI == "TRACTORSM" or StI == "TRACTORSL"
	local isErnter = StI == "HARVESTERS" or StI == "FORAGEHARVESTERS" or StI == "POTATOVEHICLES" or StI == "BEETVEHICLES" or StI == "SUGARCANEVEHICLES" or StI == "COTTONVEHICLES" or StI == "MISCVEHICLES"
	local isLoader = StI == "FRONTLOADERVEHICLES" or StI == "TELELOADERVEHICLES" or StI == "SKIDSTEERVEHICLES" or StI == "WHEELLOADERVEHICLES"
	local isPKWLKW = StI == "CARS" or StI == "TRUCKS"
	local isWoodWorker = storeItem.categoryName == "WOODHARVESTING"
	local isFFF = storeItem.categoryName == "FORKLIFTS"
	
	if g_currentMission.hud.isVisible and spec.isVarioTM then
	

        -- calculate position and size
		-- render BG
		-- h -
        -- local D_posX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1.3) -0.018
        local posX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1.3) - 0.015
		
		-- v |
		local D_posY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY + 0.02
        local AR_posY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY
        local BR_posY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY - 0.02
        
		local BG_PosX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1.2) - 0.01
		local BG_PosY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY - 0.019
		
        -- local SpeedMeterDisplay = g_currentMission.inGameMenu.hud.speedMeter
		-- local width, height = getNormalizedScreenValues(unpack(CVTaddon.BGSIZE.BACKGROUND))
		local BGcvt = 1
		local overlayP = 1
		-- local overlay.overlay = 1
		local Transparancy = 0.6
		-- local CVTaddon.overlayP = overlayP
		-- if CVTaddon.overlay[overlay] == nil then

        local size = 0.014 * g_gameSettings.uiScale
		local drawHgStep = ""
		for i=1, spec.vFive-1 do
			drawHgStep = drawHgStep .."["
		end
		-- if spec.vOne == 3.2 then
		if spec.vOne == 2 then
			spec.D_insTextV = "txt_VarioOne"
		end
		-- if spec.vOne == 1 then
		if spec.vOne == 1 then
			spec.D_insTextV = "txt_VarioTwo"
		end
		if spec.vFour == 0 then
			spec.N_insTextV = "txt_VarioN"
		elseif spec.vFour == 1 then
			if self.spec_motorized.motor.currentDirection == 1 then
				spec.N_insTextV = "txt_VarioD"
			elseif self.spec_motorized.motor.currentDirection == -1 then
				spec.N_insTextV = "txt_VarioR"
			end
		end
        -- add current driving level to table
        spec.D_genText = tostring(g_i18n:getText(spec.D_insTextV))
        spec.N_genText = tostring(g_i18n:getText(spec.N_insTextV))
        -- render
		if spec.transparendSpd == nil then
			spec.transparendSpd = 0.6
			spec.transparendSpdT = 1
		end
		if self:getLastSpeed() > 20 then
			spec.transparendSpd = (1- (self:getLastSpeed()/20-1))
			spec.transparendSpdT = (1- (self:getLastSpeed()/20-1))
		elseif self:getLastSpeed() <= 20 or self:getLastSpeed() == nil then
			spec.transparendSpdT = 1
		end
		setTextColor(0, 0.9, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))
		-- setOverlayColor(CVTaddon.overlayP, 0.5, 1, 0, 0.6)
        -- setTextColor(1,1,1,1)
        setTextAlignment(RenderText.ALIGN_LEFT)
        setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
        setTextBold(false)
		
		-- add background overlay box ----------------------------------------------------------------------------------
		-- local fontName = self.xmlFile:getValue(spec.D_genText .. "#font", "DIGIT"):upper();
        -- local fontMaterial = g_materialManager:getFontMaterial(fontName, self.customEnvironment);
		-----------------------------------------------------------------------------------------------------------------
		if spec.AR_genText ~= nil and spec.BR_genText ~= nil and spec.D_genText ~= nil then
			if not isPKWLKW then
				spec.currBGcolor = { 0.02, 0.02, 0.02, math.max(math.min(spec.transparendSpd, 0.6), 0.2) }
				CVTaddon.CVTIconBg:setColor(unpack(spec.currBGcolor))
				CVTaddon.CVTIconFb:setColor(0, 0, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))
				-- CVTaddon.CVTIcon:setColor(unpack(SpeedMeterDisplay.COLOR.GEARS_BG));
				CVTaddon.CVTIconBg:setPosition(posX-0.01, BR_posY-0.032)
				CVTaddon.CVTIconFb:setPosition(posX-0.01, BR_posY-0.032)
				CVTaddon.CVTIconBg:setScale(0.04, 0.094)
				CVTaddon.CVTIconFb:setScale(0.04, 0.094)
				-- CVTaddon.CVTIcon:setDimension(0.4, 0.8)
				CVTaddon.CVTIconBg:render()
				CVTaddon.CVTIconFb:render()
				if spec.isMotorOn then
					setTextBold(true)
					renderText(posX, D_posY+0.03, size+0.025, spec.D_genText)
					renderText(posX-0.01, D_posY, size, spec.N_genText)
					setTextBold(false)
					renderText(posX, AR_posY-0.005, size, spec.AR_genText)
					renderText(posX, BR_posY-0.012, size, spec.BR_genText)
					setTextAlignment(RenderText.ALIGN_RIGHT)
					renderText(posX+0.015, D_posY+0.016, size-0.006, drawHgStep)
				end
			end
			
----------------------------------------------------------------------------------------------------------------------			
----------------------------------------------------------------------------------------------------------------------	
			
----------------------------------------------------------------------------------------------------------------------			
----------------------------------------------------------------------------------------------------------------------			
			
		end
		
 		-- Back to roots
        setTextColor(1,1,1,1)
        setTextAlignment(RenderText.ALIGN_LEFT)
        setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE)
        setTextBold(false)

		setTextLineHeightScale(RenderText.DEFAULT_LINE_HEIGHT_SCALE)
		setTextLineBounds(0, 0)
		setTextWrapWidth(0)
	end
end


-- Drivable = true
-- addModEventListener(CVTaddon)
-- Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, CVTaddon.registerActionEvents)
-- Drivable.onUpdate  = Utils.appendedFunction(Drivable.onUpdate, CVTaddon.onUpdate);