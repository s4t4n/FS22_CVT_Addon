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
local scrversion = "0.2.0.98";
local modversion = "0.9.9.7";
-- last update	19.02.23
-- last change	saving only for `isVarioTM`, ramps engineBrakeCurve changed
-- issues:




CVTaddon = {};
CVTaddon.modDirectory = g_currentModDirectory;
source(CVTaddon.modDirectory.."events/SyncClientServerEvent.lua")
-- source(g_currentModDirectory .. "CVT_Addon_HUD.lua")  -- need to sync 'spec' between CVT_Addon.lua and CVT_Addon_HUD.lua

local sbshDebugOn = false;
-- local changeFlag = false;
local startetATM = false;
-- local sbshFlyDebugOn = true;

function CVTaddon.prerequisitesPresent(specializations) 
    return true
end 

function CVTaddon.registerEventListeners(vehicleType) 
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", CVTaddon) 
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", CVTaddon)
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", CVTaddon)
	SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", CVTaddon)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", CVTaddon)
    SpecializationUtil.registerEventListener(vehicleType, "onDraw", CVTaddon)
	
	SpecializationUtil.registerEventListener(vehicleType, "onReadStream", CVTaddon);
	SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", CVTaddon);
	SpecializationUtil.registerEventListener(vehicleType, "onReadUpdateStream", CVTaddon);
    SpecializationUtil.registerEventListener(vehicleType, "onWriteUpdateStream", CVTaddon);
	
	addModEventListener(CVTaddon)
end 
	
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

function CVTaddon:onRegisterActionEvents()
	if g_client ~= nil then
		local spec = self.spec_CVTaddon
		spec.BackupMaxFwSpd = tostring(self.spec_motorized.motor.maxForwardSpeedOrigin)
		spec.BackupMaxBwSpd = tostring(self.spec_motorized.motor.maxBackwardSpeedOrigin)
		spec.calcBrakeForce = string.format("%.2f", self.spec_motorized.motor.maxForwardSpeedOrigin/100)
		
		if self.getIsEntered ~= nil and self:getIsEntered() then
			CVTaddon.actionEventsV1 = {}
			CVTaddon.actionEventsV2 = {}
			CVTaddon.actionEventsV3 = {}
			CVTaddon.actionEventsV4 = {}
			CVTaddon.actionEventsV5 = {}
			CVTaddon.actionEventsV6 = {}
			CVTaddon.actionEventsV7 = {}
			CVTaddon.actionEventsV8 = {}
			local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName) -- debug
			if sbshDebugOn then
				print("storeItem.categoryName: " .. tostring(storeItem.categoryName)) -- debug
			end
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
			if CVTaddon.eventActiveV1 == nil then
				CVTaddon.eventActiveV1 = true
			end
			if CVTaddon.eventActiveV2 == nil then
				CVTaddon.eventActiveV2 = true
			end
			if CVTaddon.eventActiveV3 == nil then
				CVTaddon.eventActiveV3 = true
			end
			if CVTaddon.eventActiveV4 == nil then
				CVTaddon.eventActiveV4 = true
			end
			if CVTaddon.eventActiveV5 == nil then
				CVTaddon.eventActiveV5 = true
			end
			if CVTaddon.eventActiveV6 == nil then
				CVTaddon.eventActiveV6 = true
			end
			if CVTaddon.eventActiveV7 == nil then
				CVTaddon.eventActiveV7 = true
			end
			if CVTaddon.eventActiveV8 == nil then
				CVTaddon.eventActiveV8 = true
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
				print("CVTaddon: onRegisterActionEvents eventActiveV1: ".. tostring(CVTaddon.eventActiveV1))
				print("CVTaddon: onRegisterActionEvents eventActiveV2: ".. tostring(CVTaddon.eventActiveV2))
				print("CVTaddon: onRegisterActionEvents eventActiveV3: ".. tostring(CVTaddon.eventActiveV3))
				print("CVTaddon: onRegisterActionEvents eventActiveV4: ".. tostring(CVTaddon.eventActiveV4))
			end
			-- D1
			_, CVTaddon.eventIdV1 = self:addActionEvent(CVTaddon.actionEventsV1, 'SETVARIOONE', self, CVTaddon.VarioOne, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV1, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV1, false)
			-- g_inputBinding:setActionEventTextVisibility(spec.eventIdV1, true) -- test if works
			
			-- D2
			_, CVTaddon.eventIdV2 = self:addActionEvent(CVTaddon.actionEventsV2, 'SETVARIOTWO', self, CVTaddon.VarioTwo, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV2, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV2, false)
			-- g_inputBinding:setActionEventTextVisibility(spec.eventIdV2, true) -- test if works
			
			-- AR
			_, CVTaddon.eventIdV3 = self:addActionEvent(CVTaddon.actionEventsV3, 'LMBF_TOGGLE_RAMP', self, CVTaddon.AccRamps, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV3, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV3, false)
			
			-- BR
			_, CVTaddon.eventIdV4 = self:addActionEvent(CVTaddon.actionEventsV4, 'LMBF_TOGGLE_BRAMP', self, CVTaddon.BrakeRamps, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV4, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV4, false)
			
			-- neutral
			_, CVTaddon.eventIdV5 = self:addActionEvent(CVTaddon.actionEventsV5, 'SETVARION', self, CVTaddon.VarioN, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV5, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV5, false)
			
			-- rpmUP
			_, CVTaddon.eventIdV6 = self:addActionEvent(CVTaddon.actionEventsV6, 'SETVARIORPMP', self, CVTaddon.VarioRpmPlus, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV6, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV6, CVTaddon.eventActiveV6)
			-- rpmDn
			_, CVTaddon.eventIdV7 = self:addActionEvent(CVTaddon.actionEventsV7, 'SETVARIORPMM', self, CVTaddon.VarioRpmMinus, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV7, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV7, CVTaddon.eventActiveV7)
			
			-- Fahrpedalauflösung -- needed?   oder ändern in RPM aka gearbox
			_, CVTaddon.eventIdV8 = self:addActionEvent(CVTaddon.actionEventsV8, 'SETPEDALWAY_AXIS', self, CVTaddon.VarioPedalRes, false, false, true, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV8, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV8, false)
			
			-- CVTaddon.updateActionEvents(self)
			--  local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.LOWER_IMPLEMENT, self, Pickup.actionEventTogglePickup, triggerUp, triggerDown, triggerAlways, startActive, callbackState, customIconName)
		end
		if sbshDebugOn then
			print("CVTaddon: onRegisterActionEvents a vOne: ".. tostring(spec.vOne))
			print("CVTaddon: onRegisterActionEvents a vTwo: ".. tostring(spec.vTwo))
			print("CVTaddon: onRegisterActionEvents a vThree: ".. tostring(spec.vThree))
			print("CVTaddon: onRegisterActionEvents a vFour: ".. tostring(spec.vFour))
			print("CVTaddon: onRegisterActionEvents a eventActiveV1: ".. tostring(CVTaddon.eventActiveV1))
			print("CVTaddon: onRegisterActionEvents a eventActiveV2: ".. tostring(CVTaddon.eventActiveV2))
			print("CVTaddon: onRegisterActionEvents a eventActiveV3: ".. tostring(CVTaddon.eventActiveV3))
			print("CVTaddon: onRegisterActionEvents a eventActiveV4: ".. tostring(CVTaddon.eventActiveV4))
		end
	end -- g_client
end -- onRegisterActionEvents

function CVTaddon:onLoad()
	-- if g_client ~= nil then
	self.spec_CVTaddon = {}
	local spec = self.spec_CVTaddon
	-- local root = Utils.getFilename("hud/", CVTaddon.modDirectory)
	spec.CVTIconBg = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDbg.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconFb = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDfb.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconFs1 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDfs1.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconFs2 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDfs2.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	
	spec.CVTIconHg2 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDhg2.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconHg3 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDhg3.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconHg4 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDhg4.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconHg5 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDhg5.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconPTO = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDpto.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconHg6 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDhg6.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconHg7 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDhg7.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconHg8 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDhg8.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconHg9 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDhg9.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconHg10 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDhg10.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	
	spec.CVTIconAr1 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDar1.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconAr2 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDar2.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconAr3 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDar3.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconAr4 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDar4.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	
	spec.CVTIconBr1 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDbr1.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconBr2 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDbr2.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconBr3 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDbr3.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconBr4 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDbr4.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	
	spec.CVTIconHydro = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDhydro.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconN = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDn.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconN2 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDn2.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	
	spec.CVTIconR = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDr.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconV = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDv.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	
	spec.BG1width, spec.BG1height = 0.005, 0.09;
	spec.currBGcolor = { 0.02, 0.02, 0.02, 0.7 }
	if self.spec_motorized.motor.currentDirection == nil then
		spec.lastDirection = 1
	end
	spec.smoother = 0
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
	if CVTaddon.eventActiveV1 == nil then
		CVTaddon.eventActiveV1 = true
	end
	if CVTaddon.eventActiveV2 == nil then
		CVTaddon.eventActiveV2 = true
	end
	if CVTaddon.eventActiveV3 == nil then
		CVTaddon.eventActiveV3 = true
	end
	if CVTaddon.eventActiveV4 == nil then
		CVTaddon.eventActiveV4 = true
	end
	if CVTaddon.eventActiveV5 == nil then
		CVTaddon.eventActiveV5 = true
	end
	if CVTaddon.eventActiveV6 == nil then
		CVTaddon.eventActiveV6 = true
	end
	if CVTaddon.eventActiveV7 == nil then
		CVTaddon.eventActiveV7 = true
	end
	if CVTaddon.eventActiveV8 == nil then
		CVTaddon.eventActiveV8 = true
	end
	CVTaddon.eventIdV1 = nil
	CVTaddon.eventIdV2 = nil
	CVTaddon.eventIdV3 = nil
	CVTaddon.eventIdV4 = nil
	CVTaddon.eventIdV5 = nil
	CVTaddon.eventIdV6 = nil
	CVTaddon.eventIdV7 = nil
	CVTaddon.eventIdV8 = nil
	spec.BackupMaxFwSpd = ""
	if spec.calcBrakeForce == nil then
		spec.calcBrakeForce = "0.5"
	end
	-- spec.currentModDirectory = g_currentModDirectory
	-- CVTaddon:VarioOne()
	-- CVTaddon:VarioTwo()
	-- CVTaddon:BrakeRamps()
	-- CVTaddon:AccRamps()
	-- CVTaddon:VarioRpmPlus()
	-- CVTaddon:VarioRpmMinus()
	-- CVTaddon:VarioPedalRes()
	spec.dirtyFlag = self:getNextDirtyFlag()
	spec.check = false
end  -- onLoad


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
	print("CVT_Addon: init..... " .. scrversion)
	print("CVT_Addon: Script...: " .. scrversion)
	print("CVT_Addon: Mod......: " .. modversion)
end -- initSpecialization

function CVTaddon:onPostLoad(savegame)
	
	if g_client ~= nil then
		if self.spec_motorized ~= nil then
			local spec = self.spec_CVTaddon
			if spec == nil then return end

			if savegame ~= nil then
				local xmlFile = savegame.xmlFile
				local key = savegame.key .. ".FS22_CVT_Addon.CVTaddon"

				CVTaddon.eventActiveV1 = xmlFile:getValue(key.."#eventActiveV1", CVTaddon.eventActiveV1)
				CVTaddon.eventActiveV2 = xmlFile:getValue(key.."#eventActiveV2", CVTaddon.eventActiveV2)
				CVTaddon.eventActiveV3 = xmlFile:getValue(key.."#eventActiveV3", CVTaddon.eventActiveV3)
				CVTaddon.eventActiveV4 = xmlFile:getValue(key.."#eventActiveV4", CVTaddon.eventActiveV4)
				CVTaddon.eventActiveV5 = xmlFile:getValue(key.."#eventActiveV5", CVTaddon.eventActiveV5)
				CVTaddon.eventActiveV6 = xmlFile:getValue(key.."#eventActiveV6", CVTaddon.eventActiveV6)
				CVTaddon.eventActiveV7 = xmlFile:getValue(key.."#eventActiveV7", CVTaddon.eventActiveV7)
				CVTaddon.eventActiveV8 = xmlFile:getValue(key.."#eventActiveV8", CVTaddon.eventActiveV8)
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
	end -- g_client
end -- onPostLoad

function CVTaddon:saveToXMLFile(xmlFile, key, usedModNames)
	
	if self.spec_motorized ~= nil then
		local spec = self.spec_CVTaddon
		
		-- spec.actionsLength = table.getn(spec.actions)
		if spec.isVarioTM then
			xmlFile:setValue(key.."#eventActiveV1", CVTaddon.eventActiveV1)
			xmlFile:setValue(key.."#eventActiveV2", CVTaddon.eventActiveV2)
			xmlFile:setValue(key.."#eventActiveV3", CVTaddon.eventActiveV3)
			xmlFile:setValue(key.."#eventActiveV4", CVTaddon.eventActiveV4)
			xmlFile:setValue(key.."#eventActiveV5", CVTaddon.eventActiveV5)
			xmlFile:setValue(key.."#eventActiveV6", CVTaddon.eventActiveV6)
			xmlFile:setValue(key.."#eventActiveV7", CVTaddon.eventActiveV7)
			xmlFile:setValue(key.."#eventActiveV8", CVTaddon.eventActiveV8)
			xmlFile:setValue(key.."#vOne", spec.vOne)
			xmlFile:setValue(key.."#vTwo", spec.vTwo)
			xmlFile:setValue(key.."#vThree", spec.vThree)
			xmlFile:setValue(key.."#vFour", spec.vFour)
			xmlFile:setValue(key.."#vFive", spec.vFive)
			xmlFile:setValue(key.."#PedalResolution", spec.PedalResolution)
		end

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
	if g_client ~= nil then
		local spec = self.spec_CVTaddon
		if sbshDebugOn then
			print("BrRamp Taste gedrückt vThree: "..tostring(spec.vThree))
			print("BrRamp Taste gedrückt lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
		end
		if self.CVTaddon == nil then 
			return
		end
		if not CVTaddon.eventActiveV4 then
			return
		end
		if (spec.vThree == 1) then -- BRamp 1
			
			if sbshDebugOn then
				print("BrRamp 1 vThree: "..tostring(spec.vThree))
				print("BrRamp 1 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
			end
		end
		if (spec.vThree == 2) then -- BRamp 2
			
			if sbshDebugOn then
				print("BrRamp 2 vThree: "..tostring(spec.vThree))
				print("BrRamp 2 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
			end
		end
		if (spec.vThree == 3) then -- BRamp 3
			
			if sbshDebugOn then
				print("BrRamp 3 vThree: "..tostring(spec.vThree))
				print("BrRamp 3 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
			end
		end
		if (spec.vThree == 4) then -- BRamp 4
			
			if sbshDebugOn then
				print("BrRamp 4 vThree: "..tostring(spec.vThree))
				print("BrRamp 4 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
			end
		end
		if (spec.vThree == 5) then -- BRamp 5
			
			if sbshDebugOn then
				print("BrRamp 5 vThree: "..tostring(spec.vThree))
				print("BrRamp 5 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
			end
		end
		if spec.vThree == 5 then
			spec.vThree = 1
		else
			spec.vThree = spec.vThree + 1
		end
		if sbshDebugOn then
			print("BrRamp Taste losgelassen vThree: "..tostring(spec.vThree))
			print("BrRamp Taste losgelassen lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
		end
	end --g_client
end -- BrakeRamps

function CVTaddon:AccRamps()
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		
		if sbshDebugOn then
			print("AccRamp Taste gedrückt vTwo: "..tostring(spec.vTwo))
			print("AccRamp Taste gedrückt acc: "..self.spec_motorized.motor.accelerationLimit)
		end
		if self.CVTaddon == nil then 
			return
		end
		if not CVTaddon.eventActiveV3 then
			return
		end
		if (spec.vTwo == 1) then -- Ramp 1
			self.spec_motorized.motor.accelerationLimit = 0.50
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce-0.05))
			if sbshDebugOn then
				print("AccRamp 1 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 1 acc0.5: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 2) then -- Ramp 2
			self.spec_motorized.motor.accelerationLimit = 1.00
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.18))
			if sbshDebugOn then
				print("AccRamp 2 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 2 acc1.0: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 3) then -- Ramp 3
			self.spec_motorized.motor.accelerationLimit = 1.50
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.24))
			if sbshDebugOn then
				print("AccRamp 3 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 3 acc1.5: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 4) then -- Ramp 4
			self.spec_motorized.motor.accelerationLimit = 2.00 -- Standard
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.69))
			-- self.spec_motorized.motor.peakMotorTorque = self.spec_motorized.motor.peakMotorTorque * 0.5
			if sbshDebugOn then
				print("AccRamp 4 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 4 acc2.0: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if spec.vTwo == 4 then
			spec.vTwo = 1
		else
			spec.vTwo = spec.vTwo + 1
		end
		if sbshDebugOn then
			print("AccRamp Taste losgelassen vTwo: "..tostring(spec.vTwo))
			print("AccRamp Taste losgelassen acc: "..self.spec_motorized.motor.accelerationLimit)
		end
	end -- g_client
end -- AccRamps

function CVTaddon:VarioRpmPlus() ----- +
	if g_client ~= nil then
		local spec = self.spec_CVTaddon
		if sbshDebugOn then
			print("VarioRpmPlus Taste gedrückt vFive: "..tostring(spec.vFive))
			-- print("VarioRpmPlus : FwS/BwS/lBFS/cBF:")
		end
		if self.CVTaddon == nil then 
			return
		end
		if not CVTaddon.eventActiveV6 then
			return
		end
		if spec.vFive <= 9 then
			spec.vFive = spec.vFive + 1
		end
		if spec.vFive == 10 then
			spec.vFive = 10
			CVTaddon.eventActiveV6 = true
		end
		CVTaddon.eventActiveV7 = true
		if sbshDebugOn then
			print("VarioRpmPlus vFive: "..tostring(spec.vFive))
			-- print("VarioRpmPlus : FwS/BwS/lBFS/cBF:")
		end
		
		if sbshDebugOn then
			print("VarioRpmPlus Taste losgelassen vFive: "..tostring(spec.vFive))
			-- print("VarioRpmPlus : FwS/BwS/lBFS/cBF:")
		end
	end -- g_client
end

function CVTaddon:VarioRpmMinus() ----- -
	if g_client ~= nil then
		local spec = self.spec_CVTaddon
		if sbshDebugOn then
			print("VarioRpmMinus Taste gedrückt vFive: "..tostring(spec.vFive))
			-- print("VarioRpmPlus : FwS/BwS/lBFS/cBF:")
		end
		if self.CVTaddon == nil then 
			return
		end
		if not CVTaddon.eventActiveV7 then
			return
		end
		if spec.vFive >= 2 then
			spec.vFive = spec.vFive - 1
		end
		if spec.vFive == 1 then
			spec.vFive = 1
			CVTaddon.eventActiveV7 = true
		end
		CVTaddon.eventActiveV6 = true
		if sbshDebugOn then
			print("VarioRpmMinus vFive: "..tostring(spec.vFive))
			-- print("VarioRpmPlus : FwS/BwS/lBFS/cBF:")
		end
		
		if sbshDebugOn then
			print("VarioRpmMinus Taste losgelassen vFive: "..tostring(spec.vFive))
			-- print("VarioRpmPlus : FwS/BwS/lBFS/cBF:")
		end
	end -- g_client
end

function CVTaddon:VarioOne() -- field
	-- changeFlag = true -- tryout
	
	if g_client ~= nil then
		local spec = self.spec_CVTaddon
		-- if spec.vOne == nil then
			-- spec.vOne = 1
		-- end
		
		if sbshDebugOn then
			print("VarioOne Taste gedrückt vOne: ".. tostring(spec.vOne))
			print("Entered: " .. tostring(self:getIsEntered()))
			print("Started: " .. tostring(self:getIsMotorStarted()))
			print("VarioOne : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
		end
		if self.CVTaddon == nil then 
			return
		end
		if not CVTaddon.eventActiveV1 then
			return
		end

		if self:getIsEntered() and self:getIsMotorStarted() then
			if self:getLastSpeed() >= 11 and spec.vFour == 1 then
				g_currentMission:showBlinkingWarning(g_i18n:getText("txt_warn_tofastDn"), 3072)
				self:addDamageAmount(math.min(0.0002*(self:getOperatingTime()/1000000)+(self:getLastSpeed()/100), 1))
				-- CVTaddon.eventActiveV1 = true
				-- CVTaddon.eventActiveV2 = false
			end

			if spec.vOne == 1 then
				if self:getLastSpeed() <=10 then
					if self:getLastSpeed() > 1 and spec.vFour == 1 then
						self:addDamageAmount(math.min(0.00008*(self:getOperatingTime()/1000000)+(self.spec_motorized.motor.lastMotorRpm/10000)+(self:getLastSpeed()/100), 1))
					end
					spec.vOne = 2
					local SpeedScale = spec.PedalResolution
					CVTaddon.eventActiveV1 = true
					CVTaddon.eventActiveV2 = true
					if sbshDebugOn then
						print("VarioOne vOne: ".. tostring(spec.vOne))
						print("VarioOne : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
					end
				end
			end
		end
		
		if sbshDebugOn then
			print("VarioOne Taste losgelassen vOne: ".. tostring(spec.vOne))
			print("VarioOne : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
		end
	end -- g_client
end -- VarioOne

function CVTaddon:VarioTwo() -- street
	-- changeFlag = true -- tryout
	if g_client ~= nil then
		local spec = self.spec_CVTaddon
		-- if spec.vOne == nil then
			-- spec.vOne = 2
		-- end

		if sbshDebugOn then
			print("VarioTwo Taste gedrückt vOne: "..tostring(spec.vOne))
			print("VarioTwo : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
			print("VarioTwo : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxBwSpd))
		end
		if self.CVTaddon == nil then 
			return
		end
		if not CVTaddon.eventActiveV2 then
			return
		end
		if self:getIsEntered() and self:getIsMotorStarted() then
			if self:getLastSpeed() > 10 then
				g_currentMission:showBlinkingWarning(g_i18n:getText("txt_warn_tofastUp"), 3072)
				self:addDamageAmount(math.min(0.00015*(self:getOperatingTime()/1000000), 1)) -- 3.6
			end
			if spec.vOne == 2 then
				spec.vOne = 1
				local SpeedScale = spec.PedalResolution
				self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin
				self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin

				CVTaddon.eventActiveV1 = true
				CVTaddon.eventActiveV2 = true
				if sbshDebugOn then
					print("VarioTwo vOne: "..tostring(spec.vOne))
					print("VarioTwo : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
					print("VarioTwo : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxBwSpd))
				end
			end
		end
		if sbshDebugOn then
			print("VarioTwo Taste losgelassen vOne: "..tostring(spec.vOne))
			print("VarioTwo : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
			print("VarioTwo : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxFwSpd))
		end
	end
end -- VarioTwo

function CVTaddon:VarioN() -- neutral
	if g_client ~= nil then
		local spec = self.spec_CVTaddon
		-- local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
		
		if sbshDebugOn then
			print("VarioN Taste gedrückt vFour: "..spec.vFour)
			print("VarioN : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
			print("VarioN : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxBwSpd))
		end
		if self:getIsEntered() and self:getIsMotorStarted() then
			if (spec.vFour == 0) then
				if self.spec_motorized.motor.currentDirection ~= spec.lastDirection then
					self.spec_motorized.motor.currentDirection = spec.lastDirection
					-- spec.vFour = 1 -- keeps N on
					if sbshFlyDebugOn then
						print("Erster cD")
					end
				end
				CVTaddon.eventActiveV5 = true
				if sbshFlyDebugOn then
					print("Neutral AN") -- debug
				end
				if self:getLastSpeed() > 5 then
					self:addDamageAmount(math.min(0.00015*(self:getOperatingTime()/1000000)+(self.spec_motorized.motor.lastMotorRpm/10000)+(self:getLastSpeed()/100), 1))
				end
			end
			if (spec.vFour == 1) then
				CVTaddon.eventActiveV5 = true
				if sbshFlyDebugOn then
					print("Neutral AUS") -- debug
				end
				if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm+250 then
					self:addDamageAmount(math.min(0.00005*(self:getOperatingTime()/1000000)+(self.spec_motorized.motor.lastMotorRpm/10000), 1))
				end

				if self.spec_motorized.motor.currentDirection ~= spec.lastDirection then
					spec.lastDirection = self.spec_motorized.motor.currentDirection
					if sbshFlyDebugOn then
						print("Zweiter cD")
					end
				end
			end
			if spec.vFour == 1 then
				spec.vFour = 0
			else
				spec.vFour = 1
			end
		end
	end
end -- VarioN

--[[function CVTaddon:VarioPedalRes(inputValue, isActiveForInput, isActiveForInputIgnoreSelection, isSelected) -- Pedal Resolution
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

function CVTaddon:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
	local spec = self.spec_CVTaddon
	local changeFlag = false
	
	
	if g_client ~= nil then
		-- local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
		
		local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName)
		local StI = storeItem.categoryName
		local isTractor = StI == "TRACTORSS" or StI == "TRACTORSM" or StI == "TRACTORSL"
		local isErnter = StI == "HARVESTERS" or StI == "FORAGEHARVESTERS" or StI == "POTATOVEHICLES" or StI == "BEETVEHICLES" or StI == "SUGARCANEVEHICLES" or StI == "COTTONVEHICLES" or StI == "MISCVEHICLES"
		local isLoader = StI == "FRONTLOADERVEHICLES" or StI == "TELELOADERVEHICLES" or StI == "SKIDSTEERVEHICLES" or StI == "WHEELLOADERVEHICLES"
		local isPKWLKW = StI == "CARS" or StI == "TRUCKS"
		local isWoodWorker = storeItem.categoryName == "WOODHARVESTING"
		local isFFF = storeItem.categoryName == "FORKLIFTS"
		-- spec.retrpm = string.format("%.2f", self.spec_motorized.motor.lastMotorRpm/10000)
		spec.isVarioTM = self.spec_motorized.motor.lastManualShifterActive == false and self.spec_motorized.motor.groupType == 1 and self.spec_motorized.motor.gearType == 1 and self.spec_motorized.motor.forwardGears == nil
								
		local currentSpeedDrv = tonumber(string.format("%.2f", self:getLastSpeed()))
		-- spec.accPedal = math.max(0, self.spec_drivable.axisForward)
		spec.HydrostatPedal = math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
		-- if self:getIsEntered() and spec.isVarioTM and not isPKWLKW then
		if spec.isVarioTM and not isPKWLKW then
			if self.CVTaddon == nil then
				self.CVTaddon = true
				if self.spec_motorized ~= nil then
					if self.spec_motorized.motor ~= nil then
						-- print("CVT_Addon: Motorized eingestiegen")
					end;
				end;
			end;
			
	-- ACCELERATION RAMPS - BESCHLEUNIGUNGSRAMPEN
			if self:getIsMotorStarted() then
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
				-- g_currentMission:addExtraPrintText(tostring(self.spec_motorized.motor.accelerationLimit))
	-- BRAKE RAMPS - BREMSRAMPEN
				if spec.vThree == 1 and spec.isVarioTM then
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp5")) -- #hud 4
					self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00500 -- 17 kmh
					spec.BR_genText = tostring(g_i18n:getText("txt_bRamp5"))
				end
				if spec.vThree == 2 and spec.isVarioTM then
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp1")) -- #hud off
					self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00027777777777778 -- 1-2 kmh
					spec.BR_genText = tostring(g_i18n:getText("txt_bRamp1"))
				end
				if spec.vThree == 3 and spec.isVarioTM then
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp2")) -- #hud 1
					self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00150 -- ca 4 kmh
					spec.BR_genText = tostring(g_i18n:getText("txt_bRamp2"))
				end
				if spec.vThree == 4 and spec.isVarioTM then
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp3")) -- #hud 2
					self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00250 -- ca 8 kmh
					spec.BR_genText = tostring(g_i18n:getText("txt_bRamp3"))
				end
				if spec.vThree == 5 and spec.isVarioTM then
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp4")) -- #hud 3
					self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00427 -- 15 km/h
					spec.BR_genText = tostring(g_i18n:getText("txt_bRamp4"))
				end
				
				local spiceLoad = tonumber(string.format("%.2f", math.min(math.abs(self.spec_motorized.motor.smoothedLoadPercentage)/5, 0.04)))
				local spiceRPM = self.spec_motorized.motor.lastMotorRpm
				local spiceMaxSpd = self.spec_motorized.motor.maxForwardSpeed
				
	-- NEUTRAL
				if spec.vFour == 0 then
					self.spec_motorized.motor.currentDirection = 0
					self.spec_motorized.motor.minForwardGearRatio = 0
					self.spec_motorized.motor.maxForwardGearRatio = 0
					self.spec_motorized.motor.minBackwardGearRatio = 0
					self.spec_motorized.motor.maxBackwardGearRatio = 0
					self.spec_motorized.motor.manualClutchValue = 1
					self.spec_motorized.motor.lowBrakeForceScale = 0.03
					self.spec_motorized.motor.accelerationLimit = 0
					self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0 -- 0
					self.spec_motorized.motor.maxBackwardSpeed = 0
					self.spec_motorized.motor.maxForwardSpeed = 0
					-- need to unlock AccelerationPedal when direction is 0 as neutral
					--done
					local loadsetXP
					-- local accPedal = math.max(0, self.spec_drivable.axisForward)
					local loadDrive = 0
					loadDrive = math.max(0, math.max(0, self.spec_drivable.axisForward))
					if (self.spec_motorized.motor.lastMotorRpm / self.spec_motorized.motor.maxRpm) < loadDrive and spiceRPM > self.spec_motorized.motor.minRpm+25 then
						loadsetXP = 1;
					else
						loadsetXP = 0;
					end;
					self.spec_motorized.motor.rawLoadPercentage = math.max(self.spec_motorized.motor.rawLoadPercentage, loadsetXP)*1.8
					self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm + math.max(0, self.spec_drivable.axisForward) *66*math.pi, self.spec_motorized.motor.maxRpm)
					self.spec_motorized.motor.currentDirection = 0
				end
						-- need to read inputValue's of directionChanger toggle, fw, bw
				if spec.vFour == 1 then
					self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin
					self.spec_motorized.motor.maxForwardGearRatio = self.spec_motorized.motor.maxForwardGearRatioOrigin
					self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minBackwardGearRatioOrigin
					self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.minBackwardGearRatioOrigin
					self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin
					self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin
					self.spec_motorized.motor.manualClutchValue = 0
					loadsetXP = 0;
				end
				
				
	-- MOTORDREHZAHL (Handgas-digital)    min
				local maxRpm = self.spec_motorized.motor.maxRpm
				local minRpm = self.spec_motorized.motor.minRpm
				local lastMotorRpm = self.spec_motorized.motor.lastMotorRpm
				spec.lastPTORot = self.spec_motorized.motor.lastPtoRpm
				spec.accPedal = math.max(0, self.spec_drivable.axisForward)
				local brkPedal = math.min(0, self.spec_drivable.axisForward)
				if self.spec_motorized.motor.lastPtoRpm == nil then
					self.spec_motorized.motor.lastPtoRpm = 0
				end
				if spec.vFive == 1 and spec.vFive ~= nil then
					self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 1
				end
				if spec.vFive == 2 and spec.vFive ~= nil then
					-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/1.99), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
				end
				if spec.vFive == 3 and spec.vFive ~= nil then
					-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/2.97), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
				end
				if spec.vFive == 4 and spec.vFive ~= nil then
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
					-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/3.95), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
				end
				if spec.vFive == 5 and spec.vFive ~= nil then
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
					-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/4.92), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
				end
				if spec.vFive == 6 and spec.vFive ~= nil then
					-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/5.88), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
				end
				if spec.vFive == 7 and spec.vFive ~= nil then
					-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/6.85), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
				end
				if spec.vFive == 8 and spec.vFive ~= nil then
					-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/7.82), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
				end
				if spec.vFive == 9 and spec.vFive ~= nil then
					-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/8.78), self.spec_motorized.motor.maxRpm-1), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
				end
				if spec.vFive == 10 and spec.vFive ~= nil then
					-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min((self.spec_motorized.motor.lastMotorRpm) * (spec.vFive/9.72), self.spec_motorized.motor.maxRpm), self.spec_motorized.motor.lastPtoRpm+(spec.vFive*10))
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(self.spec_motorized.motor.maxRpm-51, self.spec_motorized.motor.lastPtoRpm*0.75)), self.spec_motorized.motor.maxRpm)
				end
				
				if self.spec_motorized.motor.currentDirection == -1 then
					self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage * 1.8
				end
				
		-- -- FAHRSTUFE I. 
				-- if spec.vOne ~= 1 and spec.vOne ~= nil and spec.isVarioTM then
				if spec.vOne == 2 and spec.vOne ~= nil and spec.isVarioTM then
					spec.isHydroState = false
					spec.spiceDFWspeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 4.49), 6.94)
					spec.spiceDBWspeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 3.21), 6.36)
					
					self.spec_motorized.motor.maxForwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 4.49), 6.94)
					self.spec_motorized.motor.maxBackwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 3.21), 6.36)
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_VarioOne")) -- #l10n
					self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 0.99 + (self.spec_motorized.motor.rawLoadPercentage*9)
					-- self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 1.1
					self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin * 1.6
					self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.maxForwardGearRatioOrigin + 1
					self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin * 2
					self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage * 0.5
					if spiceRPM > self.spec_motorized.motor.minRpm + 300 then
						if self.spec_motorized.motor.smoothedLoadPercentage < 0.3 then
							-- Gaspedal and Variator
							spec.smoother = spec.smoother + dt;
							if spec.smoother ~= nil and spec.smoother > 150 then
								spec.smoother = 0;
								if self:getLastSpeed() > 3 then
									self.spec_motorized.motor.lastMotorRpm = math.max(math.max(math.min((self:getLastSpeed() * math.abs(math.max(self.spec_motorized.motor.rawLoadPercentage, 0.52)))*44, self.spec_motorized.motor.maxRpm*0.98), self.spec_motorized.motor.minRpm+203), self.spec_motorized.motor.lastPtoRpm*0.7)
									if self:getLastSpeed() > (self.spec_motorized.motor.maxForwardSpeed*3.14)-2 then
										self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage *0.9
										self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm + self:getLastSpeed()
									end
									if math.max(0, self.spec_drivable.axisForward) < 0.2 then
										self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm + self:getLastSpeed() * 10, self.spec_motorized.motor.maxRpm)
									end
									if math.max(0, self.spec_drivable.axisForward) > 0.5 and math.max(0, self.spec_drivable.axisForward) <= 0.9 and self.spec_motorized.motor.rawLoadPercentage < 0.5 then
										self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 0.8
									end
									
									-- self.spec_motorized.motor.lastPtoRpm = self.spec_motorized.motor.lastPtoRpm*0.7
								end
							end
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.3 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.5 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.97), self.spec_motorized.motor.lastPtoRpm*0.7)+(math.abs(self.spec_motorized.motor.lastAcceleratorPedal)*25), self.spec_motorized.motor.maxRpm)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.5 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.65 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.975), self.spec_motorized.motor.lastPtoRpm*0.7)+(math.abs(self.spec_motorized.motor.lastAcceleratorPedal)*45), self.spec_motorized.motor.maxRpm)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.65 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.7 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.98), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.7 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.75 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.99), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.75 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.995), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.8 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.85 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 1.00), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.85 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.9 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 1.001), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm - self.spec_motorized.motor.smoothedLoadPercentage*99)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.9 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 1.002), self.spec_motorized.motor.lastPtoRpm*0.6), self.spec_motorized.motor.maxRpm - self.spec_motorized.motor.smoothedLoadPercentage*99)
							self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 3 + (self.spec_motorized.motor.rawLoadPercentage*19)
							self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatio + self.spec_motorized.motor.smoothedLoadPercentage*15
							-- self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatio * 1.6
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						-- if self.spec_motorized.motor.smoothedLoadPercentage > 0.95 then
							-- -- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * 0.92
							-- self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * math.min(0.97+spiceLoad, 1)), self.spec_motorized.motor.lastPtoRpm*0.5), self.spec_motorized.motor.maxRpm)
							-- self.spec_motorized.motor.gearRatio = 250
							-- -- self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 1.8 + (self.spec_motorized.motor.rawLoadPercentage*19)
							-- self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatio +  - self.spec_motorized.motor.smoothedLoadPercentage*9
						-- end
					end
				end
	
	
	-- HYDROSTAT
				if spec.vOne ~= 1 and spec.vOne ~= nil and spec.isVarioTM and self.spec_motorized.motor.maxForwardSpeedOrigin <= 6.68 and not isTractor and isWoodWorker then
					spec.isHydroState = true
					-- spec.HydrostatPedal = math.abs(self.spec_motorized.motor.lastAcceleratorPedal) -- nach oben verschoben z.719
					local spiceDFWspeedHs = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 2.8), 3.16)
					local spiceDBWspeedHs = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 2.8), 3.16)
					local spiceDFWspeedH = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 2.8), 3.16) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
					local spiceDBWspeedH = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 2.8), 3.16) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
					self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.maxForwardGearRatio
					self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minForwardGearRatio
					
					if math.abs(self.spec_motorized.motor.lastAcceleratorPedal) >= 0.2 then
						self.spec_motorized.motor.maxForwardSpeed = spiceDFWspeedH
						self.spec_motorized.motor.maxBackwardSpeed = spiceDBWspeedH
						g_currentMission:addExtraPrintText("Hydrostat Antrieb")
					end
					if math.abs(self.spec_motorized.motor.lastAcceleratorPedal) < 0.2 then
						self.spec_motorized.motor.maxForwardSpeed = spiceDFWspeedHs
						self.spec_motorized.motor.maxBackwardSpeed = spiceDBWspeedHs
						g_currentMission:addExtraPrintText("Hydrostat byPass")
					end
					
					self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 2.1
					if spiceRPM > self.spec_motorized.motor.minRpm + 150 then
						if self.spec_motorized.motor.smoothedLoadPercentage < 0.3 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.98), self.spec_motorized.motor.lastPtoRpm)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage > 0.4 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.99), self.spec_motorized.motor.lastPtoRpm)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage > 0.8 then
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * 0.92
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * math.min(0.97+spiceLoad, 1)), self.spec_motorized.motor.lastPtoRpm)
						end
					end
				end
				
				
	-- -- FAHRSTUFE II. (Street/light weight transport or work) inputbinding
				if spec.vOne == 1 and spec.vOne ~= nil and spec.isVarioTM then
					spec.isHydroState = false
					self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 0.96 + (self.spec_motorized.motor.rawLoadPercentage*9)
					self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin
					self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minBackwardGearRatioOrigin
					self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.maxBackwardGearRatioOrigin
					
					if spiceRPM > self.spec_motorized.motor.minRpm + 300 then
						if self.spec_motorized.motor.smoothedLoadPercentage < 0.3 then
							-- Gaspedal and Variator
							spec.smoother = spec.smoother + dt;
							if spec.smoother ~= nil and spec.smoother > 150 then
								spec.smoother = 0;
								if self:getLastSpeed() > 3 then
									self.spec_motorized.motor.lastMotorRpm = math.max(math.max(math.min((self:getLastSpeed() * math.abs(math.max(self.spec_motorized.motor.rawLoadPercentage, 0.55)))*44, self.spec_motorized.motor.maxRpm*0.99), self.spec_motorized.motor.minRpm+203), self.spec_motorized.motor.lastPtoRpm*0.7)
									if self:getLastSpeed() > (self.spec_motorized.motor.maxForwardSpeed*3.14)-2 then
										self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage *0.9
										self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm - self:getLastSpeed()
									end
									if math.max(0, self.spec_drivable.axisForward) < 0.2 then
										self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm + self:getLastSpeed() * 10, self.spec_motorized.motor.maxRpm)
									end
									if math.max(0, self.spec_drivable.axisForward) > 0.5 and self.spec_motorized.motor.rawLoadPercentage < 0.5 then
										self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 0.8
									end
									
									-- self.spec_motorized.motor.lastPtoRpm = self.spec_motorized.motor.lastPtoRpm*0.7
								end
							end
						end
							
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.3 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.5 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.97), self.spec_motorized.motor.lastPtoRpm*0.7)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.5 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.65 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.98), self.spec_motorized.motor.lastPtoRpm*0.7)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.65 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.7 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.975), self.spec_motorized.motor.lastPtoRpm*0.7)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.7 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.75 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.98), self.spec_motorized.motor.lastPtoRpm*0.7)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.75 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.985), self.spec_motorized.motor.lastPtoRpm*0.7)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.8 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.85 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.98), self.spec_motorized.motor.lastPtoRpm*0.7)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.85 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.9 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.985), self.spec_motorized.motor.lastPtoRpm*0.7)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.9 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.95 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.99), self.spec_motorized.motor.lastPtoRpm*0.7)
							self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 1.1 + (self.spec_motorized.motor.rawLoadPercentage*9)
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * (math.min(0.92+spec.spiceLoad, 1)))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage > 0.95 then
							-- self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * 0.92
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * math.min(0.97+spiceLoad, 1)), self.spec_motorized.motor.lastPtoRpm*0.8)
							self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 1.1 + (self.spec_motorized.motor.rawLoadPercentage*9)
						end
					end
				end
			end                 -- pto rpm muss weiter runter
			-- g_currentMission:addExtraPrintText("StI: " .. tostring(StI))
			-- g_currentMission:addExtraPrintText("vOne: " .. tostring(spec.vOne))
			-- g_currentMission:addExtraPrintText("isVarioTM: " .. tostring(spec.isVarioTM))
			-- g_currentMission:addExtraPrintText("isTractor: " .. tostring(isTractor))
			-- g_currentMission:addExtraPrintText("gearRatio: " .. tostring(self.spec_motorized.motor.gearRatio))
			-- g_currentMission:addExtraPrintText("maxGearRatio: " .. tostring(self.spec_motorized.motor.maxGearRatio))
			-- g_currentMission:addExtraPrintText("minGearRatio: " .. tostring(self.spec_motorized.motor.minGearRatio))
			-- g_currentMission:addExtraPrintText("requiredMotorRpm: " .. tostring(self.spec_motorized.motor.requiredMotorRpm))
			-- g_currentMission:addExtraPrintText("minForwardGearRatio: " .. tostring(self.spec_motorized.motor.minForwardGearRatio))
			-- g_currentMission:addExtraPrintText("maxForwardGearRatio: " .. tostring(self.spec_motorized.motor.maxForwardGearRatio))
		end
		-- print("CLIENT vOne: " .. tostring(spec.vOne))
		-- print("CLIENT vTwo: " .. tostring(spec.vTwo))
		-- print("CLIENT vThree: " .. tostring(spec.vThree))
		-- print("CLIENT vFour: " .. tostring(spec.vFour))
		-- print("CLIENT vFive: " .. tostring(spec.vFive))
		-- print("CLIENT smoother: " .. tostring(spec.smoother))
		-- print("CLIENT isHydroState: " .. tostring(spec.isHydroState))
		-- print("CLIENT currentDirection: " .. tostring(self.spec_motorized.motor.currentDirection))
		-- print("CLIENT lastDirection: " .. tostring(spec.lastDirection))
		-- print("CLIENT spiceDFWspeed: " .. tostring(spec.spiceDFWspeed))
		-- print("CLIENT gearRatio: " .. tostring(self.spec_motorized.motor.gearRatio))
		-- print("CLIENT maxForwardSpeed: " .. tostring(self.spec_motorized.motor.maxForwardSpeed))
		-- print("CLIENT lastMotorRpm: " .. tostring(self.spec_motorized.motor.lastMotorRpm))
		-- print("CLIENT equalizedMotorRpm: " .. tostring(self.spec_motorized.motor.equalizedMotorRpm))
		-- print("CLIENT lastRealMotorRpm: " .. tostring(self.spec_motorized.motor.lastRealMotorRpm))
		-- print("CLIENT lastPtoRpm: " .. tostring(self.spec_motorized.motor.lastPtoRpm))
	end   -- g_client
	-- g_currentMission:addExtraPrintText("Entered: " .. tostring(self:getIsEntered()))
	-- g_currentMission:addExtraPrintText("Started: " .. tostring(self:getIsMotorStarted()))
	
	-- if self:getIsDashboardGroupActive() == "isMotorStarting" then
	-- print("ssm.Motor startet: " .. getMotorIgnitionState())
	-- end
	-- if self.spec_motorized.motor.lastMotorRpm < self.spec_motorized.motor.minRpm - 5 and self.spec_motorized.motor.lastMotorRpm > 0 then
		-- startetATM = true
	-- else
		-- startetATM = false
	-- end
	-- if startetATM then
		-- g_currentMission:addExtraPrintText("ACHTUNG: Motor started !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		-- changeFlag = true
	-- end
	
	if g_server ~= nil then
		-- local spec = self.spec_CVTaddon
		-- print("SERVER vOne: " .. tostring(spec.vOne))
		-- print("SERVER vTwo: " .. tostring(spec.vTwo))
		-- print("SERVER vThree: " .. tostring(spec.vThree))
		-- print("SERVER vFour: " .. tostring(spec.vFour))
		-- print("SERVER vFive: " .. tostring(spec.vFive))
		-- print("SERVER smoother: " .. tostring(spec.smoother))
		-- print("SERVER isHydroState: " .. tostring(spec.isHydroState))
		-- print("SERVER currentDirection: " .. tostring(self.spec_motorized.motor.currentDirection))
		-- print("SERVER lastDirection: " .. tostring(spec.lastDirection))
		-- print("SERVER spiceDFWspeed: " .. tostring(spec.spiceDFWspeed))
		-- print("SERVER gearRatio: " .. tostring(self.spec_motorized.motor.gearRatio))
		-- print("SERVER maxForwardSpeed: " .. tostring(self.spec_motorized.motor.maxForwardSpeed))
		-- print("SERVER lastMotorRpm: " .. tostring(self.spec_motorized.motor.lastMotorRpm))
		-- print("SERVER equalizedMotorRpm: " .. tostring(self.spec_motorized.motor.equalizedMotorRpm))
		-- print("SERVER lastRealMotorRpm: " .. tostring(self.spec_motorized.motor.lastRealMotorRpm))
		-- print("SERVER lastPtoRpm: " .. tostring(self.spec_motorized.motor.lastPtoRpm))
	end
	
	--local isMotorStarting = (self.spec_motorized.isMotorStarted and (self.spec_motorized.motorStartTime > g_currentMission.time and 1 or 2) or 0)
	--if self:getIsEntered() then
	--	if spec.check == false then
			self:raiseDirtyFlags(spec.dirtyFlag)
			
			--spec.check = true
			
			--print("BITTE SCHREIB MIR OB DER PRINT NUR 1x BEIM EINSTEIGEN KOMMT ODER DAUERND BEIM STARTEN")
			----------------------------------
				-- events (sync client server)
			----------------------------------
			
			if g_server ~= nil then
				g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.isVarioTM), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.isVarioTM))
			end
		--end
	--else
		--spec.check = false
	--end
	-- print("vOne ALL: " .. tostring(spec.vOne))
end -- onUpdate

function CVTaddon.SyncClientServer(vehicle, vOne, vTwo, vThree, vFour, vFive)
	local spec = vehicle.spec_CVTaddon	
	-- local spec = self.spec_CVTaddon  -- need too?
	
	spec.vOne = vOne
    spec.vTwo = vTwo
    spec.vThree = vThree
    spec.vFour = vFour
    spec.vFive = vFive
	spec.isVarioTM = isVarioTM
    -- spec.check = check						  
end

----------------------------------------------------------------------------------------------------------------------	
----------------------------------------------------------------------------------------------------------------------			
------------- Should be external in CVT_Addon_HUD.lua, but I can't sync spec between 2 lua's -------------------------			
function CVTaddon:onDraw(vehicle, dt)
	local spec = self.spec_CVTaddon
	
	
	
	if g_client ~= nil then
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
		-- g_currentMission:addExtraPrintText("spec.lastPTORot: " .. tostring(spec.lastPTORot))

			-- calculate position and size
			local uiScale = g_gameSettings.uiScale;
			-- render BG
			-- h -
			-- + nach 
			-- local D_posX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1.3) -0.018
			local posX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1) - (0.035*g_gameSettings.uiScale)
			
			-- v |   + hoch
			local posY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY
			local BGcvt = 1
			local overlayP = 1
			-- local overlay.overlay = 1
			local Transparancy = 0.6
			-- local CVTaddon.overlayP = overlayP
			-- if CVTaddon.overlay[overlay] == nil then

			local size = 0.014 * g_gameSettings.uiScale
			
			-- local drawHgStep = ""
			-- for i=1, spec.vFive-1 do
				-- drawHgStep = drawHgStep .."["
				
			-- end
			-- spec.HgScaleX = 0.04 / 9 * (spec.vFive-1)
			-- -- if spec.vOne == 3.2 then
			-- if spec.vOne == 2 then
				-- spec.D_insTextV = "txt_VarioOne"  -- ToDo make graphic instead of Text Dots to comp with 4k
				
			-- end
			-- -- if spec.vOne == 1 then
			-- if spec.vOne == 1 then
				-- spec.D_insTextV = "txt_VarioTwo"  -- ToDo make graphic instead of Text Dots to comp with 4k
			-- end
			-- if spec.vFour == 0 then
				-- spec.N_insTextV = "txt_VarioN"
			-- elseif spec.vFour == 1 then
				-- if self.spec_motorized.motor.currentDirection == 1 then
					-- spec.N_insTextV = "txt_VarioD"
				-- elseif self.spec_motorized.motor.currentDirection == -1 then
					-- spec.N_insTextV = "txt_VarioR"
				-- end
			-- end
			-- add current driving level to table
			-- spec.D_genText = tostring(g_i18n:getText(spec.D_insTextV))
			-- spec.N_genText = tostring(g_i18n:getText(spec.N_insTextV))
			
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
			-----------------------------------------------------------------------------------------------------------------
			if not isPKWLKW then
				local isPTO = false
				-- spec.CVTIconPTO = spec.CVTIconHg5
				if spec.lastPTORot ~= nil then
					if spec.lastPTORot > self.spec_motorized.motor.minRpm then
						isPTO = true
					end
				end
				local PTOColour = { 0.8, 0.6, 0, math.max(math.min(spec.transparendSpdT, 0.8), 0.5) }
				local HgColour = { 0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1) }
				if spec.vFive < 9 then
					local HgColour = { 1, 0, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1) }
				elseif spec.vFive >= 9 then
				end
				local HgRColour = { 1, 0, 0, 1 }
				spec.CVTIconBg:setColor(0.01, 0.01, 0.01, math.max(math.min(spec.transparendSpd, 0.6), 0.2))
				spec.CVTIconFb:setColor(0, 0, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))
				spec.CVTIconFs1:setColor(0, 0.9, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))
				spec.CVTIconFs2:setColor(0, 0.9, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))

				spec.CVTIconHg2:setColor(unpack(HgColour))
				spec.CVTIconHg3:setColor(unpack(HgColour))
				spec.CVTIconHg4:setColor(unpack(HgColour))
				spec.CVTIconHg5:setColor(unpack(HgColour))
				spec.CVTIconPTO:setColor(unpack(PTOColour))
				spec.CVTIconHg6:setColor(unpack(HgColour))
				spec.CVTIconHg7:setColor(unpack(HgColour))
				spec.CVTIconHg8:setColor(unpack(HgColour))
				spec.CVTIconHg9:setColor(unpack(HgColour))
				if spec.vFive <= 8 then
					spec.CVTIconHg10:setColor(unpack(HgColour))
				elseif spec.vFive >= 9 then
					spec.CVTIconHg10:setColor(unpack(HgRColour))
				end
				
				spec.CVTIconAr1:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1)) 
				spec.CVTIconAr2:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				spec.CVTIconAr3:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				spec.CVTIconAr4:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				
				spec.CVTIconBr1:setColor(0.6, 0.1, 0.1, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1)) 
				spec.CVTIconBr2:setColor(0.6, 0.1, 0.1, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				spec.CVTIconBr3:setColor(0.6, 0.1, 0.1, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				spec.CVTIconBr4:setColor(0.6, 0.1, 0.1, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				
				spec.CVTIconHydro:setColor(0, 0.5, 0.5, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				spec.CVTIconN:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				spec.CVTIconN2:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				
				spec.CVTIconV:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				spec.CVTIconR:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				--
				spec.CVTIconBg:setPosition(posX-0.01, posY)
				spec.CVTIconFb:setPosition(posX-0.01, posY)
				spec.CVTIconFs1:setPosition(posX-0.01, posY)
				spec.CVTIconFs2:setPosition(posX-0.01, posY)
				
				spec.CVTIconHg2:setPosition(posX-0.01, posY)
				spec.CVTIconHg3:setPosition(posX-0.01, posY)
				spec.CVTIconHg4:setPosition(posX-0.01, posY)
				spec.CVTIconHg5:setPosition(posX-0.01, posY)
				spec.CVTIconPTO:setPosition(posX-0.01, posY)
				spec.CVTIconHg6:setPosition(posX-0.01, posY)
				spec.CVTIconHg7:setPosition(posX-0.01, posY)
				spec.CVTIconHg8:setPosition(posX-0.01, posY)
				spec.CVTIconHg9:setPosition(posX-0.01, posY)
				spec.CVTIconHg10:setPosition(posX-0.01, posY)
				
				spec.CVTIconAr1:setPosition(posX-0.01, posY)
				spec.CVTIconAr2:setPosition(posX-0.01, posY)
				spec.CVTIconAr3:setPosition(posX-0.01, posY)
				spec.CVTIconAr4:setPosition(posX-0.01, posY)
				
				spec.CVTIconBr1:setPosition(posX-0.01, posY)
				spec.CVTIconBr2:setPosition(posX-0.01, posY)
				spec.CVTIconBr3:setPosition(posX-0.01, posY)
				spec.CVTIconBr4:setPosition(posX-0.01, posY)
				
				spec.CVTIconHydro:setPosition(posX-0.01, posY)
				spec.CVTIconN:setPosition(posX-0.01, posY)
				spec.CVTIconN2:setPosition(posX-0.01, posY)
				
				spec.CVTIconV:setPosition(posX-0.01, posY)
				spec.CVTIconR:setPosition(posX-0.01, posY)
				--
				spec.CVTIconBg:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconFb:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconFs1:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconFs2:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				
				spec.CVTIconHg2:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconHg3:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconHg4:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconHg5:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconPTO:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconHg6:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconHg7:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconHg8:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconHg9:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconHg10:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				
				spec.CVTIconAr1:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconAr2:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconAr3:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconAr4:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				
				spec.CVTIconBr1:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconBr2:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconBr3:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconBr4:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				
				spec.CVTIconHydro:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconN:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconN2:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				
				spec.CVTIconV:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconR:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)

				-- :setAlignment(self.alignmentVertical, self.alignmentHorizontal)
				
				spec.CVTIconBg:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconFb:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconFs1:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconFs2:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				
				-- spec.CVTIconHg:setScale(spec.HgScaleX*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale) -- spec.HgScaleX*
				spec.CVTIconHg2:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconHg3:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconHg4:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconHg5:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconPTO:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconHg6:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconHg7:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconHg8:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconHg9:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconHg10:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				
				spec.CVTIconAr1:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconAr2:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconAr3:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconAr4:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				
				spec.CVTIconBr1:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconBr2:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconBr3:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconBr4:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				
				spec.CVTIconHydro:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconN:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconN2:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				
				spec.CVTIconV:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconR:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)

			 -- local HGuvs = {x,y,  x ,y,  x ,y, x,y}
			 -- local HGuvs = { s 1s   s 2e   e 3s  e4e}
				local hgUVs = {0,0, 0.5,1}
				-- local hgUVs = {0.2,0, 0.2,1, 0.5,0, 1,1} -- verschiebt nur und cropped nicht oder falsche Werte?
				-- Array of UV coordinates as {x, y, width, height}
				-- local HGuvs  = getNormalizedUVs{0, 0, 108, 512}
				-- CVTaddon.CVTIconHg:setUVs(GuiUtils.getUVs(hgUVs))
				-- u1, v1, u2, v2, u3, v3, u4, v4
				 -- -- start x, start y
				-- u1 = (u3-u1)*p1 + u1
				-- v1 = (v2-v1)*p2 + v1

				-- -- start x, end y
				-- u2 = (u3-u1)*p1 + u1
				-- v2 = (v4-v3)*p4 + v3

				-- -- end x, start y
				-- u3 = (u3-u1)*p3 + u1
				-- v3 = (v2-v1)*p2 + v1

				-- -- end x, end y
				-- u4 = (u4-u2)*p3 + u2
				-- v4 = (v4-v3)*p4 + v3

				-- CVTaddon.CVTIcon:setDimension(0.4, 0.8)
				
				spec.CVTIconBg:render()
				spec.CVTIconFb:render()
				if self:getIsMotorStarted() then
				
					if spec.vOne == 2 then
						spec.CVTIconFs1:render()
					elseif spec.vOne == 1 then
						spec.CVTIconFs2:render()
					end
					
					if isPTO then
						spec.CVTIconPTO:render()
					end
					if spec.vFive ~= 1 and spec.vFive ~= nil then
						if spec.vFive == 2 then
							spec.CVTIconHg2:render()
						elseif spec.vFive == 3 then
							spec.CVTIconHg3:render()
						elseif spec.vFive == 4 then
							spec.CVTIconHg4:render()
						elseif spec.vFive == 5 then
							spec.CVTIconHg5:render()
						elseif spec.vFive == 6 then
							spec.CVTIconHg6:render()
						elseif spec.vFive == 7 then
							spec.CVTIconHg7:render()
						elseif spec.vFive == 8 then
							spec.CVTIconHg8:render()
						elseif spec.vFive == 9 then
							spec.CVTIconHg9:render()
						elseif spec.vFive == 10 then
							spec.CVTIconHg10:render()
						end
					end
										
					if spec.vTwo == 1 then
					spec.CVTIconAr4:render()
					elseif spec.vTwo == 2 then
						spec.CVTIconAr1:render()
					elseif spec.vTwo == 3 then
						spec.CVTIconAr2:render()
					elseif spec.vTwo == 4 then
						spec.CVTIconAr3:render()
					end
					
					if spec.vThree ~= 2 then
						if spec.vThree == 3 then
							spec.CVTIconBr1:render()
							local showBrake = 0
							if self:getLastSpeed() >= 2 and self:getLastSpeed() <= 4 and math.abs(self.spec_motorized.motor.lastAcceleratorPedal) < 0.01 then
								for showBrake=1, 2 do
									spec.CVTIconBr1:render()
									spec.CVTIconBr2:render()
									spec.CVTIconBr3:render()
									spec.CVTIconBr4:render()
									showBrake = showBrake +1;
								end
							end
						-- end
						elseif spec.vThree == 4 then
							spec.CVTIconBr2:render()
							local showBrake = 0
							if self:getLastSpeed() >= 2 and self:getLastSpeed() <= 8 and math.abs(self.spec_motorized.motor.lastAcceleratorPedal) < 0.01 then
								for showBrake=1, 2 do
									spec.CVTIconBr1:render()
									spec.CVTIconBr2:render()
									spec.CVTIconBr3:render()
									spec.CVTIconBr4:render()
									showBrake = showBrake +1;
								end
							end
						-- end
						elseif spec.vThree == 5 then
							spec.CVTIconBr3:render()
							local showBrake = 0
							if self:getLastSpeed() >= 2 and self:getLastSpeed() <= 15 and math.abs(self.spec_motorized.motor.lastAcceleratorPedal) < 0.01 then
								for showBrake=1, 2 do
									spec.CVTIconBr1:render()
									spec.CVTIconBr2:render()
									spec.CVTIconBr3:render()
									spec.CVTIconBr4:render()
									showBrake = showBrake +1;
								end
							end
						-- end
						elseif spec.vThree == 1 then
							spec.CVTIconBr4:render()
							if self:getLastSpeed() >= 2 and self:getLastSpeed() <= 17 and math.abs(self.spec_motorized.motor.lastAcceleratorPedal) < 0.01 then
								local showBrake = 0
								for showBrake=1, 2 do
									spec.CVTIconBr1:render()
									spec.CVTIconBr2:render()
									spec.CVTIconBr3:render()
									spec.CVTIconBr4:render()
									showBrake = showBrake +1;
								end
							end
						end
					end
					
					if spec.vFour == 0 then
						spec.CVTIconN2:render()
					end
					if self.spec_motorized.motor.currentDirection == 1 then
						spec.CVTIconV:render()
					elseif self.spec_motorized.motor.currentDirection == -1 then
						spec.CVTIconR:render()
					end
					
					if spec.isHydroState then
						
						spec.CVTIconHydro:render()
					end

					-- setTextBold(true)
					-- renderText(posX, D_posY+0.03, size+0.025, spec.D_genText)
					-- renderText(posX-0.01, posY+0.024, size, spec.N_genText)
					-- setTextBold(false)
					-- renderText(posX, posY, size, spec.AR_genText)
					-- renderText(posX, posY-0.02, size, spec.BR_genText)
					-- setTextAlignment(RenderText.ALIGN_RIGHT)
					-- renderText(posX+0.010, posY+0.026, size-0.005, drawHgStep)
				end
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
end
----------------------------------------------------------------------------------------------------------------------
-- HUD draw	end		
----------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------------------------			
-- ----------------   Server Sync   --------------------------------

function CVTaddon:onReadStream(streamId, connection)
	local spec = self.spec_CVTaddon
	local motorized = self.spec_motorized ~= nil
	-- if motorized then
		
		spec.vOne = streamReadInt32(streamId)  -- state driving level
		spec.vTwo = streamReadInt32(streamId) -- state accelerationRamp
		spec.vThree = streamReadInt32(streamId) -- state brakeRamp
		spec.vFour = streamReadInt32(streamId) -- state neutral
		spec.vFive = streamReadInt32(streamId) -- state Handgas

		spec.isVarioTM = streamReadBool(streamId)
		-- spec.check = streamReadBool(streamId)
	-- end -- motorized
end

function CVTaddon:onWriteStream(streamId, connection)
	local spec = self.spec_CVTaddon
	local motorized = self.spec_motorized ~= nil
	-- sync was stucking @99% thanks Glowin for fixing this
	-- if motorized then
		streamWriteInt32(streamId, spec.vOne)
		streamWriteInt32(streamId, spec.vTwo)
		streamWriteInt32(streamId, spec.vThree)
		streamWriteInt32(streamId, spec.vFour)
		streamWriteInt32(streamId, spec.vFive)
		
		streamWriteBool(streamId, spec.isVarioTM)
		-- streamWriteBool(streamId, spec.check)	   
	-- end -- motorized
end

function CVTaddon:onReadUpdateStream(streamId, timestamp, connection)
-- local spec = self.spec_CVTaddon
	if not connection:getIsServer() then
		local spec = self.spec_CVTaddon
		
		if streamReadBool(streamId) then
			if spec ~= nil then
				
				spec.vOne = streamReadInt32(streamId)
				spec.vTwo = streamReadInt32(streamId)
				spec.vThree = streamReadInt32(streamId)
				spec.vFour = streamReadInt32(streamId)
				spec.vFive = streamReadInt32(streamId)
				
				spec.isVarioTM = streamReadBool(streamId)
				-- spec.check = streamReadBool(streamId)
			end
		end
	end
end

function CVTaddon:onWriteUpdateStream(streamId, connection, dirtyMask)
-- local spec = self.spec_CVTaddon
	if connection:getIsServer() then
		local spec = self.spec_CVTaddon
		if spec ~= nil then
			if spec.dirtyFlag ~= nil then
				if streamWriteBool(streamId, bitAND(dirtyMask, spec.dirtyFlag) ~= 0) then

					streamWriteInt32(streamId, spec.vOne)
					if spec.vTwo ~= nil then -- test
						streamWriteInt32(streamId, spec.vTwo) -- nil
					end
					if spec.vThree ~= nil then
						streamWriteInt32(streamId, spec.vThree) -- nil
					end
					if spec.vFour ~= nil then
						streamWriteInt32(streamId, spec.vFour) -- nil
					end
					if spec.vFive ~= nil then
						streamWriteInt32(streamId, spec.vFive) -- nil
					end

					streamWriteBool(streamId, spec.isVarioTM)
					-- streamWriteBool(streamId, spec.check)
				end
			else 
				streamWriteBool(streamId, false)
			end
		end
	end
end

-- Drivable = true
-- addModEventListener(CVTaddon)
-- Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, CVTaddon.registerActionEvents)
-- Drivable.onUpdate  = Utils.appendedFunction(Drivable.onUpdate, CVTaddon.onUpdate);