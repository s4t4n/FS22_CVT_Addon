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
local scrversion = "0.3.0.18";
local modversion = "0.9.9.14"; -- moddesc
-- last update	10.08.23
-- last change	-- disable VCA static enginebrake if vca is active
				-- added vehicles as hydrostatic driveable
				-- "FRONTLOADERVEHICLES" "WHEELLOADERVEHICLES" "WOODHARVESTING" "FORKLIFTS"
				-- automaticly enable & disable awd and diffs c.o. speed and steerangle
				
-- known issue	Neutral does'n sync lastDirection mp



CVTaddon = {};
CVTaddon.modDirectory = g_currentModDirectory;
source(CVTaddon.modDirectory.."events/SyncClientServerEvent.lua")
-- source(g_currentModDirectory .. "CVT_Addon_HUD.lua")  -- need to sync 'spec' between CVT_Addon.lua and CVT_Addon_HUD.lua

-- local sbshDebugOn = true;
-- local changeFlag = false;
local startetATM = false;
local vcaAWDon = false
local vcaInfoUnread = true
-- local sbshFlyDebugOn = true;

function CVTaddon.prerequisitesPresent(specializations) 
	-- return SpecializationUtil.hasSpecialization(WorkArea, specializations)
    return true
end 

function CVTaddon.registerEventListeners(vehicleType) 
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", CVTaddon) 
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", CVTaddon)
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", CVTaddon)
	SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", CVTaddon)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", CVTaddon)
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
		spec.calcBrakeForce = string.format("%.2f", self.spec_motorized.motor.maxForwardSpeedOrigin/(self.spec_motorized.motor.maxForwardSpeedOrigin*math.pi)+10)
		spec.maxRpmOrigin = tostring(self.spec_motorized.motor.maxRpm)
		
		if self.getIsEntered ~= nil and self:getIsEntered() then
			CVTaddon.actionEventsV1 = {}
			CVTaddon.actionEventsV2 = {}
			CVTaddon.actionEventsV3 = {}
			CVTaddon.actionEventsV4 = {}
			CVTaddon.actionEventsV5 = {}
			CVTaddon.actionEventsV6 = {}
			CVTaddon.actionEventsV7 = {}
			CVTaddon.actionEventsV8 = {}
			CVTaddon.actionEventsV9 = {}
			CVTaddon.actionEventsV10 = {}
			local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName) -- debug
			if sbshDebugOn then
				print("storeItem.categoryName: " .. tostring(storeItem.categoryName)) -- debug
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
			-- Tasten Bindings
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
			_, CVTaddon.eventIdV8 = self:addActionEvent(CVTaddon.actionEventsV8, 'SETPEDALTMS', self, CVTaddon.VarioPedalRes, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV8, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV8, false)
			
			-- autoDiffs
			_, CVTaddon.eventIdV9 = self:addActionEvent(CVTaddon.actionEventsV9, 'SETVARIOADIFFS', self, CVTaddon.VarioADiffs, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV9, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV9, false)
	
			-- rpmDmax
			_, CVTaddon.eventIdV10 = self:addActionEvent(CVTaddon.actionEventsV10, 'SETVARIORPMDMAX', self, CVTaddon.VarioRpmDmax, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV10, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV10, CVTaddon.eventActiveV10)

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
	
	-- HUD Grafiken laden
	spec.CVTIconBg = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDbg.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconFb = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDfb.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconFs1 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDfs1.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconFs2 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDfs2.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconPtms = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDptms.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	
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
	-- spec.CVTIconN = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDn.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconN2 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDn2.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	
	spec.CVTIconR = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDr.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconV = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDv.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	
	spec.BG1width, spec.BG1height = 0.005, 0.09;
	spec.currBGcolor = { 0.02, 0.02, 0.02, 0.7 }
	if self.spec_motorized.motor.currentDirection == nil then
		spec.lastDirection = 1
	end
	-- defaults if allother nil
	spec.smoother = 0
	spec.vOne = 1
	spec.vTwo = 4
	spec.vThree = 2
	spec.vFour = 1
	spec.vFive = 1
	spec.autoDiffs = 0
	spec.lastDirection = 1
	spec.isTMSpedal = 0
	spec.PedalResolution = 0
	spec.impIsLowered = false
	spec.rpmrange = 1
	-- spec.rpmDmin
	spec.rpmDmax = self.spec_motorized.motor.maxRpm
	spec.BlinkTimer = 0
	spec.NumberBlinkTimer = 0
	spec.Counter = 0
	spec.AN = false
	
	-- to make it easier read with dashbord-live
	spec.forDBL_drivinglevel = ""
	spec.forDBL_accramp = ""
	spec.forDBL_brakeramp = ""
	spec.forDBL_neutral = ""
	spec.forDBL_tmspedal = ""
	spec.forDBL_pedalpercent = ""
	spec.forDBL_digitalhandgasstep = ""
	spec.forDBL_rpmrange = ""
	spec.forDBL_rpmDmin = ""
	spec.forDBL_rpmDmax = ""
	-- spec.forDBL_
	
	CVTaddon.eventActiveV1 = true
	CVTaddon.eventActiveV2 = true
	CVTaddon.eventActiveV3 = true
	CVTaddon.eventActiveV4 = true
	CVTaddon.eventActiveV5 = true
	CVTaddon.eventActiveV6 = true
	CVTaddon.eventActiveV7 = true
	CVTaddon.eventActiveV8 = true
	CVTaddon.eventActiveV9 = true
	CVTaddon.eventActiveV10 = true
	CVTaddon.eventIdV1 = nil
	CVTaddon.eventIdV2 = nil
	CVTaddon.eventIdV3 = nil
	CVTaddon.eventIdV4 = nil
	CVTaddon.eventIdV5 = nil
	CVTaddon.eventIdV6 = nil
	CVTaddon.eventIdV7 = nil
	CVTaddon.eventIdV8 = nil
	CVTaddon.eventIdV9 = nil
	CVTaddon.eventIdV10 = nil
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
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV9")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV10")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#vOne")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#vTwo")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#vThree")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#vFour")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#vFive")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#lastDirection")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#PedalResolution")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#rpmDmax")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#autoDiffs")
	print("CVT_Addon: init....... ")
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
				CVTaddon.eventActiveV9 = xmlFile:getValue(key.."#eventActiveV9", CVTaddon.eventActiveV9)
				CVTaddon.eventActiveV10 = xmlFile:getValue(key.."#eventActiveV10", CVTaddon.eventActiveV10)
				spec.vOne = xmlFile:getValue(key.."#vOne", spec.vOne)
				spec.vTwo = xmlFile:getValue(key.."#vTwo", spec.vTwo)
				spec.vThree = xmlFile:getValue(key.."#vThree", spec.vThree)
				spec.vFour = xmlFile:getValue(key.."#vFour", spec.vFour)
				spec.vFive = xmlFile:getValue(key.."#vFive", spec.vFive)
				spec.autoDiffs = xmlFile:getValue(key.."#autoDiffs", spec.autoDiffs)
				spec.lastDirection = xmlFile:getValue(key.."#lastDirection", spec.lastDirection)
				spec.PedalResolution = xmlFile:getValue(key.."#PedalResolution", spec.PedalResolution)
				-- spec.rpmDmin = xmlFile:getValue(key.."#rpmDmin", spec.rpmDmin)
				spec.rpmDmax = xmlFile:getValue(key.."#rpmDmax", spec.rpmDmax)
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
			xmlFile:setValue(key.."#eventActiveV9", CVTaddon.eventActiveV9)
			xmlFile:setValue(key.."#eventActiveV10", CVTaddon.eventActiveV10)
			xmlFile:setValue(key.."#vOne", spec.vOne)
			xmlFile:setValue(key.."#vTwo", spec.vTwo)
			xmlFile:setValue(key.."#vThree", spec.vThree)
			xmlFile:setValue(key.."#vFour", spec.vFour)
			xmlFile:setValue(key.."#vFive", spec.vFive)
			xmlFile:setValue(key.."#autoDiffs", spec.autoDiffs)
			xmlFile:setValue(key.."#lastDirection", spec.lastDirection)
			xmlFile:setValue(key.."#PedalResolution", spec.PedalResolution)
			-- xmlFile:setValue(key.."#rpmDmin", spec.rpmDmin)
			xmlFile:setValue(key.."#rpmDmax", spec.rpmDmax)
		end

		print("CVT_Addon: saved personal adjustments for "..self:getName())
		print("CVT_Addon: Save Driving Level id: "..tostring(spec.vOne))
		print("CVT_Addon: Save Acceleration Ramp id: "..tostring(spec.vTwo))
		print("CVT_Addon: Save Brake Ramp id: "..tostring(spec.vThree))
	end
end
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

function CVTaddon:VarioRpmDmax() -- RPM range max
	local spec = self.spec_CVTaddon
	-- spec.maxRpmOrigin = self.spec_motorized.motor.maxRpm
	if g_client ~= nil then
		
		if sbshDebugOn then
			print("VarioRpmDmax rpmrange: "..tostring(spec.rpmrange))
			print("VarioRpmDmax Taste gedrückt: "..tostring(spec.rpmDmax))
			print("maxRpmOrigin: "..tostring(spec.maxRpmOrigin))
		end
		if self.CVTaddon == nil then 
			return
		end
		if not CVTaddon.eventActiveV10 then
			return
		end
		if (spec.rpmrange == 1) then -- full
			self.spec_motorized.motor.maxRpm = spec.maxRpmOrigin
			if sbshDebugOn then
				print("VarioRpmDmax rpmrange 1: "..tostring(spec.rpmrange))
				print("VarioRpmDmax Taste gedrückt 1: "..tostring(spec.rpmDmax))
				print("maxRpmOrigin 1: "..tostring(spec.maxRpmOrigin))
			end
		end
		if (spec.rpmrange == 2) then -- reduce 2
			self.spec_motorized.motor.maxRpm = ( self.spec_motorized.motor.maxRpm - 300 )
			if sbshDebugOn then
				print("VarioRpmDmax rpmrange 2: "..tostring(spec.rpmrange))
				print("VarioRpmDmax Taste gedrückt 2: "..tostring(spec.rpmDmax))
				print("maxRpmOrigin 2: "..tostring(spec.maxRpmOrigin))
			end
		end
		if (spec.rpmrange == 3) then -- reduce 3
			self.spec_motorized.motor.maxRpm = ( self.spec_motorized.motor.maxRpm - 550 )
			if sbshDebugOn then
				print("VarioRpmDmax rpmrange 3: "..tostring(spec.rpmrange))
				print("VarioRpmDmax Taste gedrückt 3: "..tostring(spec.rpmDmax))
				print("maxRpmOrigin 3: "..tostring(spec.maxRpmOrigin))
			end
		end
		if (spec.rpmrange == 4) then -- reduce 4
			self.spec_motorized.motor.maxRpm = ( self.spec_motorized.motor.maxRpm - 725 )
			if sbshDebugOn then
				print("VarioRpmDmax rpmrange 4: "..tostring(spec.rpmrange))
				print("VarioRpmDmax Taste gedrückt 4: "..tostring(spec.rpmDmax))
				print("maxRpmOrigin 4: "..tostring(spec.maxRpmOrigin))
			end
		end
		if spec.rpmrange == 4 then
			spec.rpmrange = 1
		else
			spec.rpmrange = spec.rpmrange + 1
		end
		if sbshDebugOn then
			print("VarioRpmDmax rpmrange E: "..tostring(spec.rpmrange))
			print("VarioRpmDmax Taste gedrückt E: "..tostring(spec.rpmDmax))
			print("maxRpmOrigin E: "..tostring(spec.maxRpmOrigin))
		end
		spec.forDBL_rpmDmax = tostring(spec.rpmDmax)
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax))
		end				 
	end -- g_client
end -- rpmDmin


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

function CVTaddon:BrakeRamps() -- BREMSRAMPEN - Ab kmh X wird die Betriebsbremse automatisch aktiv
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		-- local spec = self.spec_CVTaddon
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
			spec.forDBL_brakeramp = tostring(0) -- off / 1-2 km/h vanilla lowBrakeForceSpeedLimit: 0.00027777777777778
			if sbshDebugOn then
				print("BrRamp 1 vThree: "..tostring(spec.vThree))
				print("BrRamp 1 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
			end
		end
		if (spec.vThree == 2) then -- BRamp 2
			spec.forDBL_brakeramp = tostring(4) -- km/h
			if sbshDebugOn then
				print("BrRamp 2 vThree: "..tostring(spec.vThree))
				print("BrRamp 2 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
			end
		end
		if (spec.vThree == 3) then -- BRamp 3
			spec.forDBL_brakeramp = tostring(8) -- km/h
			if sbshDebugOn then
				print("BrRamp 3 vThree: "..tostring(spec.vThree))
				print("BrRamp 3 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
			end
		end
		if (spec.vThree == 4) then -- BRamp 4
			spec.forDBL_brakeramp = tostring(15) -- km/h
			if sbshDebugOn then
				print("BrRamp 4 vThree: "..tostring(spec.vThree))
				print("BrRamp 4 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
			end
		end
		if (spec.vThree == 5) then -- BRamp 5
			spec.forDBL_brakeramp = tostring(17) -- km/h
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
		-- to make it easier read with dashbord-live
		if sbshDebugOn then
			print("BrRamp Taste losgelassen vThree: "..tostring(spec.vThree))
			print("BrRamp Taste losgelassen lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
		end
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax))
		end																																				  
	end --g_client
end -- BrakeRamps

function CVTaddon:AccRamps() -- BESCHLEUNIGUNGSRAMPEN - Motorbremswirkung wird kontinuirlich berechnet @update
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
		if (spec.vTwo == 1) then -- Ramp 1 +1
			self.spec_motorized.motor.accelerationLimit = 0.50
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce-0.10))
			if sbshDebugOn then
				print("AccRamp 1 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 1 acc0.5: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 2) then -- Ramp 2 +1
			self.spec_motorized.motor.accelerationLimit = 1.00
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce))
			
			if sbshDebugOn then
				print("AccRamp 2 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 2 acc1.0: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 3) then -- Ramp 3 +1
			self.spec_motorized.motor.accelerationLimit = 1.50
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.03))
			if sbshDebugOn then
				print("AccRamp 3 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 3 acc1.5: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 4) then -- Ramp 4 +1
			self.spec_motorized.motor.accelerationLimit = 2.00 -- Standard
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.08))
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
		-- DBL convert
		if spec.vTwo == 1 then
			spec.forDBL_accramp = tostring(4)
		elseif spec.vTwo == 2 then
			spec.forDBL_accramp = tostring(1)
		elseif spec.vTwo == 3 then
			spec.forDBL_accramp = tostring(2)
		elseif spec.vTwo == 4 then
			spec.forDBL_accramp = tostring(3)
		end
		
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax))
		end			 
	end -- g_client
end -- AccRamps

function CVTaddon:VarioRpmPlus() -- Handgas hoch
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		-- local spec = self.spec_CVTaddon
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
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax))
		end																																						  
	end -- g_client
	-- DBL convert
	spec.forDBL_digitalhandgasstep = tostring(spec.vFive)
end

function CVTaddon:VarioRpmMinus() -- Handgas runter
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		-- local spec = self.spec_CVTaddon
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
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax))
		end	
	end -- g_client
	-- DBL convert
	spec.forDBL_digitalhandgasstep = tostring(spec.vFive)
end

function CVTaddon:VarioOne() -- FAHRSTUFE 1 field
	-- changeFlag = true -- tryout
	local spec = self.spec_CVTaddon
	spec.BlinkTimer = -1
	spec.Counter = 0
	-- spec.AsLongBlink = g_currentMission.environment.dayTime
	-- spec.NumberBlinkTimer = g_currentMission.environment.dayTime
	if g_client ~= nil then
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
		
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax))
		end		 
	end -- g_client
	-- DBL convert
	if spec.vOne == 1 then
		spec.forDBL_drivinglevel = tostring(2)
	elseif spec.vOne == 2 then
		spec.forDBL_drivinglevel = tostring(1)
	end
end -- VarioOne

function CVTaddon:VarioTwo() -- FAHRSTUFE 2 street
	-- changeFlag = true -- tryout
	local spec = self.spec_CVTaddon
	spec.BlinkTimer = -1
	spec.Counter = 0
	-- spec.AsLongBlink = g_currentMission.environment.dayTime
	if g_client ~= nil then
		-- local spec = self.spec_CVTaddon
		-- if spec.vOne == nil then
			-- spec.vOne = 2
		-- end
		spec.autoDiffs = 0
		self:vcaSetState("diffLockFront", false)
		self:vcaSetState("diffLockBack", false)
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
		
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax))
		end		 
	end
	-- DBL convert
	if spec.vOne == 1 then
		spec.forDBL_drivinglevel = tostring(2)
	elseif spec.vOne == 2 then
		spec.forDBL_drivinglevel = tostring(1)
	end
end -- VarioTwo

function CVTaddon:VarioN() -- neutral
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		
		-- local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
		
		if sbshDebugOn then
			print("VarioN Taste gedrückt vFour: "..spec.vFour)
			print("VarioN : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
			print("VarioN : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxBwSpd))
		end
		if self:getIsEntered() and self:getIsMotorStarted() then
			if (spec.vFour == 0) then
				if self.spec_motorized.motor.currentDirection ~= spec.lastDirection then
					-- self.spec_motorized.motor.currentDirection = spec.lastDirection
					-- spec.vFour = 1 -- keeps N on
					if sbshFlyDebugOn then
						print("Erster cD")
					end
				end
				CVTaddon.eventActiveV5 = true
				if sbshFlyDebugOn then
					print("Neutral inaktiv") -- debug
				end
				
				if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm+250 then
					self:addDamageAmount(math.min(0.00005*(self:getOperatingTime()/1000000)+(self.spec_motorized.motor.lastMotorRpm/10000), 1))
				end
				self.spec_motorized.motor.currentDirection = spec.lastDirection -- Vorherige Fahrtrichtung wiederherstellen (funktioniert im mp nicht korrekt)
				-- spec.lastDirection = self.spec_motorized.motor.currentDirection
				self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin
				self.spec_motorized.motor.maxForwardGearRatio = self.spec_motorized.motor.maxForwardGearRatioOrigin
				self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minBackwardGearRatioOrigin
				self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.minBackwardGearRatioOrigin
				self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin
				self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin
				self.spec_motorized.motor.manualClutchValue = 0
				
				
				-- print("currDir0: "..self.spec_motorized.motor.currentDirection)
				-- print("lastDir0: "..spec.lastDirection)
			end
			if (spec.vFour == 1) then
				CVTaddon.eventActiveV5 = true
				if sbshFlyDebugOn then
					print("Neutral aktiv") -- debug
				end
				if self:getLastSpeed() > 5 then
					self:addDamageAmount(math.min(0.00015*(self:getOperatingTime()/1000000)+(self.spec_motorized.motor.lastMotorRpm/10000)+(self:getLastSpeed()/100), 1))
				end

				if self.spec_motorized.motor.currentDirection ~= spec.lastDirection then
					spec.lastDirection = self.spec_motorized.motor.currentDirection -- backup vorherige Fahrtrichtung
					self.spec_motorized.motor.currentDirection = 0
					self.spec_motorized.motor.minForwardGearRatio = 0
					self.spec_motorized.motor.maxForwardGearRatio = 0
					self.spec_motorized.motor.minBackwardGearRatio = 0
					self.spec_motorized.motor.maxBackwardGearRatio = 0
					self.spec_motorized.motor.maxBackwardSpeed = 0
					self.spec_motorized.motor.maxForwardSpeed = 0
					self.spec_motorized.motor.manualClutchValue = 1
					-- self.spec_motorized.motor.currentDirection = spec.lastDirection
					if sbshFlyDebugOn then
						print("Zweiter cD")
					end
				end
				-- print("currDir1: "..self.spec_motorized.motor.currentDirection)
				-- print("lastDir1: "..spec.lastDirection)
			end
			if spec.vFour == 1 then
				spec.vFour = 0
			else
				spec.vFour = 1
			end
			self:raiseDirtyFlags(spec.dirtyFlag) 
			if g_server ~= nil then
				g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.autoDiffs, spec.vFive, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax))
			end	
		end
	end
	-- DBL convert
	if spec.vFour == 0 then
		spec.forDBL_neutral = tostring(1)
	elseif spec.vFour == 1 then
		spec.forDBL_neutral = tostring(0)
	end
end -- VarioN

function CVTaddon:VarioADiffs() -- autoDiffs
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		
		-- local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
		
		if sbshDebugOn then
			-- print("VarioN Taste gedrückt vFour: "..spec.vFour)
			-- print("VarioN : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
			-- print("VarioN : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxBwSpd))
		end
		if self:getIsEntered() and self:getIsMotorStarted() then
			if (spec.autoDiffs == 0) then
				CVTaddon.eventActiveV9 = true
				if sbshFlyDebugOn then
					print("Auto Diffs inaktiv") -- debug
				end
			end
			if (spec.autoDiffs == 1) then
				CVTaddon.eventActiveV9 = true
				if sbshFlyDebugOn then
					print("Auto Diffs aktiv") -- debug
				end
			end
			if spec.autoDiffs == 1 then
				spec.autoDiffs = 0
				self:vcaSetState("diffLockFront", false)
				self:vcaSetState("diffLockBack", false)
			else
				spec.autoDiffs = 1
			end
			self:raiseDirtyFlags(spec.dirtyFlag) 
			if g_server ~= nil then
				g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax))
			end	
		end
	end
end -- Automatic Diffs

function CVTaddon:VarioPedalRes() -- Pedal Resolution TMS like
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		-- local spec = self.spec_CVTaddon
		-- local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
		
		if sbshDebugOn then
			print("VarioN Taste gedrückt isTMSpedal: "..spec.isTMSpedal)
		end
		if self:getIsEntered() and self:getIsMotorStarted() then
			if (spec.isTMSpedal == 0) then
				if sbshFlyDebugOn then
					print("Erster cD")
				end
				
				CVTaddon.eventActiveV8 = true
				if sbshFlyDebugOn then
					print("TMS Pedal AN") -- debug
				end
			end
			if (spec.isTMSpedal == 1) then
				CVTaddon.eventActiveV8 = true
				if sbshFlyDebugOn then
					print("TMS Pedal AUS") -- debug
				end
			end
			if spec.isTMSpedal == 1 then
				spec.isTMSpedal = 0
			else
				spec.isTMSpedal = 1
			end
			self:raiseDirtyFlags(spec.dirtyFlag) 
			if g_server ~= nil then
				g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax))
			end		  
		end
	end
	-- DBL convert
	if spec.isTMSpedal == 0 then
		spec.forDBL_tmspedal = tostring(0)
	elseif spec.isTMSpedal == 1 then
		spec.forDBL_tmspedal = tostring(1)
	end
end

function CVTaddon:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected, vehicle)
	local spec = self.spec_CVTaddon
	-- SpecializationUtil.raiseEvent(self, "onStartWorkAreaProcessing", dt, spec.workAreas)
	local changeFlag = false
	local motor = nil

	-- Anbaugeräte ermitteln und prüfen ob abgesenkt Front/Back
	for attachedImplement = 1, #self.spec_attacherJoints.attachedImplements do
		local object = self.spec_attacherJoints.attachedImplements[attachedImplement].object;
		local object_specAttachable = object.spec_attachable

		if object_specAttachable.attacherVehicle ~= nil then
			local attacherJointVehicleSpec = object_specAttachable.attacherVehicle.spec_attacherJoints;
			local implementIndex = object_specAttachable.attacherVehicle:getImplementIndexByObject(object);
			local implement = attacherJointVehicleSpec.attachedImplements[implementIndex];
			local jointDescIndex = implement.jointDescIndex;
			local jointDesc = attacherJointVehicleSpec.attacherJoints[jointDescIndex];

			if jointDesc.bottomArm ~= nil then
				if jointDesc.bottomArm.zScale == 1 then
					moveDownFront = object:getIsImplementChainLowered();
				elseif jointDesc.bottomArm.zScale == -1 then
					moveDownBack = object:getIsImplementChainLowered();
				end
			end
		end
	end
	if moveDownBack == true or moveDownFront == true then
		spec.impIsLowered = true
	else
		spec.impIsLowered = false
	end

	-- if g_server ~= nil then
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
		spec.HydrostatPedal = math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
		if spec.isVarioTM and not isPKWLKW then
			if self.CVTaddon == nil then
				self.CVTaddon = true
				if self.spec_motorized ~= nil then
					if self.spec_motorized.motor ~= nil then
						-- print("CVT_Addon: Motorized eingestiegen")
					end;
				end;
			end;
			
			if self.spec_vca ~= nil and self.spec_motorized.motor.lowBrakeForceScale ~= nil then
				if self.spec_vca.brakeForce ~= 1 or self.spec_vca.idleThrottle == true then
					-- Check for wrong vca settings to use CVT addon
					
					-- g_currentMission:showBlinkingWarning(g_i18n:getText("txt_vcaInfo"), 1024)
					if vcaInfoUnread then
						g_gui:showInfoDialog({
						titel = "titel",
						text = g_i18n:getText("txt_vcaInfo", "vcaInfo"),
						})
						vcaInfoUnread = false
					end
				end
				
				-- enable & disable VCA AWD and difflocks automaticly by speed and steering angle
					-- awd
					if spec.vOne == 2 and spec.autoDiffs == 1 then
						if self:getLastSpeed() > 19 then
							self:vcaSetState("diffLockAWD", false)
						elseif self:getLastSpeed() < 16 then
							self:vcaSetState("diffLockAWD", true)
						end
						-- diff front
						if self:vcaGetState("diffLockFront") == true and math.abs(self.rotatedTime) > 0.29 then
							self:vcaSetState("diffLockFront", false)
						elseif math.abs(self.rotatedTime) < 0.15 then
							self:vcaSetState("diffLockFront", true)
						end
						-- diff rear
						if self:vcaGetState("diffLockBack") == true and math.abs(self.rotatedTime) > 0.18 then
							self:vcaSetState("diffLockBack", false)
						elseif math.abs(self.rotatedTime) < 0.11 then
							self:vcaSetState("diffLockBack", true)
						end
					end
				-- print("CVTa: rotatedTime ".. tostring(self.rotatedTime))
			end
			
			-- print("CVTa: availablePower: ".. tostring(self.spec_motorized.motor.availablePower))
			-- print("CVTa: peakMotorPower: ".. tostring(self.spec_motorized.motor.peakMotorPower))
			
	-- ACCELERATION RAMPS - BESCHLEUNIGUNGSRAMPEN
			if self:getIsMotorStarted() then
				-- print("CVT_Addon: Motor AN")
			
				if spec.vFour ~= 0 then
					if spec.vTwo == 1 and spec.isVarioTM then
						if self:getLastSpeed() <= (self.spec_motorized.motor.maxForwardSpeed*math.pi)/(2.3) then -- Beschleunigung wird ab kmh X full
							self.spec_motorized.motor.accelerationLimit = 2.00 -- Standard
						else
							self.spec_motorized.motor.accelerationLimit = 2.00 -- Standard
						end

						-- Motor-Bremswirkung verändert sich, wenn das Gewicht steigt - Damit die Betriebsbremse auch zum Einsatz kommen muß wie RL
						if (self:getTotalMass() - self:getTotalMass(true)) ~= 0 then -- 35 100
							-- anstatt das Gewicht hinten dran zusätzlich bremst wie vanilla, schiebt das zusätzliche Gewicht nun, vorallem bergab.
							--													z.B. big plough		(                   3.7t              / 100 = 0.037  )*(	45 kmh	 = 0.35				)  =  {(3.7/100)*(0.8-0.45=0.35 ~ 0.013)}
							self.spec_motorized.motor.lowBrakeForceScale = math.max(math.min((0.5-((self:getTotalMass() - self:getTotalMass(true)) /100 ))*(0.8-(self:getLastSpeed()/100)), 0.35*( 1-(self:getTotalMass() - self:getTotalMass(true))/100 ) ), 0.01)
							-- self.spec_motorized.motor.lowBrakeForceScale = math.min((0.5-((self:getTotalMass() - self:getTotalMass(true)) /200 ))*(1-(self:getLastSpeed()/100)), 0.35*( 1-(self:getTotalMass() - self:getTotalMass(true))/100 ) )
						else
							-- bei Schlepper Leermasse
							self.spec_motorized.motor.lowBrakeForceScale = math.max(math.min((1-(self.spec_motorized.motor.lastMotorRpm/((self.spec_motorized.motor.minRpm/2)*10))-(self:getLastSpeed()/100)),0.35),0.01)
						end
						-- Sprit-Verbrauch anpassen
						-- print("Usage: 4 " .. self.spec_motorized.lastFuelUsage)
						self.spec_motorized.lastFuelUsage = self.spec_motorized.lastFuelUsage * 1.001
					end
					
					if spec.vTwo == 2 and spec.isVarioTM then
						if self:getLastSpeed() <= (self.spec_motorized.motor.maxForwardSpeed*math.pi)/(2.3) then
							self.spec_motorized.motor.accelerationLimit = 0.50
						end
						if (self:getTotalMass() - self:getTotalMass(true)) ~= 0 then -- 20 97
							self.spec_motorized.motor.lowBrakeForceScale = math.max(math.min((0.5-((self:getTotalMass() - self:getTotalMass(true)) /97 ))*(0.8-(self:getLastSpeed()/100)), 0.2*( 1-(self:getTotalMass() - self:getTotalMass(true))/100 ) ), 0.01)
						else
							self.spec_motorized.motor.lowBrakeForceScale = math.max(math.min((1-(self.spec_motorized.motor.lastMotorRpm/((self.spec_motorized.motor.minRpm/2.03)*10))-(self:getLastSpeed()/100)),0.2),0.01)
						end
						-- Sprit-Verbrauch anpassen
						-- print("Usage: 1 " .. self.spec_motorized.lastFuelUsage)
						self.spec_motorized.lastFuelUsage = self.spec_motorized.lastFuelUsage * 0.97
					end
					
					if spec.vTwo == 3 and spec.isVarioTM then
						if self:getLastSpeed() <= (self.spec_motorized.motor.maxForwardSpeed*math.pi)/(2.3) then
							self.spec_motorized.motor.accelerationLimit = 1.00
						end
						if (self:getTotalMass() - self:getTotalMass(true)) ~= 0 then -- 25 98
							self.spec_motorized.motor.lowBrakeForceScale = math.max(math.min((0.5-((self:getTotalMass() - self:getTotalMass(true)) /98 ))*(0.8-(self:getLastSpeed()/100)), 0.25*( 1-(self:getTotalMass() - self:getTotalMass(true))/100 ) ), 0.01)
						else
							self.spec_motorized.motor.lowBrakeForceScale = math.max(math.min((1-(self.spec_motorized.motor.lastMotorRpm/((self.spec_motorized.motor.minRpm/2.02)*10))-(self:getLastSpeed()/100)),0.25),0.01)
						end
						-- Sprit-Verbrauch anpassen
						-- print("Usage: 2 " .. self.spec_motorized.lastFuelUsage)
						self.spec_motorized.lastFuelUsage = self.spec_motorized.lastFuelUsage * 0.98
					end
					
					if spec.vTwo == 4 and spec.isVarioTM then
						if self:getLastSpeed() <= (self.spec_motorized.motor.maxForwardSpeed*math.pi)/(2.3) then
							self.spec_motorized.motor.accelerationLimit = 1.50
						end
						if (self:getTotalMass() - self:getTotalMass(true)) ~= 0 then -- 30 99
							self.spec_motorized.motor.lowBrakeForceScale = math.max(math.min((0.5-((self:getTotalMass() - self:getTotalMass(true)) /99 ))*(0.8-(self:getLastSpeed()/100)), 0.30*( 1-(self:getTotalMass() - self:getTotalMass(true))/100 ) ), 0.01)
						else
							self.spec_motorized.motor.lowBrakeForceScale = math.max(math.min((1-(self.spec_motorized.motor.lastMotorRpm/((self.spec_motorized.motor.minRpm/2.01)*10))-(self:getLastSpeed()/100)),0.3),0.01)
						end
						-- Sprit-Verbrauch anpassen
						-- print("Usage: 3 " .. self.spec_motorized.lastFuelUsage)
						self.spec_motorized.lastFuelUsage = self.spec_motorized.lastFuelUsage * 0.99
					end
					-- print("MBF: " .. tostring(self.spec_motorized.motor.lowBrakeForceScale))
					-- print("TWO: " .. tostring(spec.vTwo))
					-- print("Mass Difference Ges./1.Fhzg.: " .. (self:getTotalMass() - self:getTotalMass(true)) )
				end
				-- g_currentMission:addExtraPrintText(tostring(self.spec_motorized.motor.accelerationLimit))
				
	-- BRAKE RAMPS - BREMSRAMPEN
				if spec.vThree == 1 and spec.isVarioTM then
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp5")) -- #hud 4
					self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00500 -- 17 kmh
					-- spec.BR_genText = tostring(g_i18n:getText("txt_bRamp5"))
				end
				if spec.vThree == 2 and spec.isVarioTM then
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp1")) -- #hud off
					self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00027777777777778 -- 1-2 kmh
					-- spec.BR_genText = tostring(g_i18n:getText("txt_bRamp1"))
				end
				if spec.vThree == 3 and spec.isVarioTM then
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp2")) -- #hud 1
					self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00150 -- ca 4 kmh
					-- spec.BR_genText = tostring(g_i18n:getText("txt_bRamp2"))
				end
				if spec.vThree == 4 and spec.isVarioTM then
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp3")) -- #hud 2
					self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00250 -- ca 8 kmh
					-- spec.BR_genText = tostring(g_i18n:getText("txt_bRamp3"))
				end
				if spec.vThree == 5 and spec.isVarioTM then
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp4")) -- #hud 3
					self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00427 -- 15 km/h
					-- spec.BR_genText = tostring(g_i18n:getText("txt_bRamp4"))
				end
				
				local spiceLoad = (tonumber(string.format("%.2f", math.min(math.abs(self.spec_motorized.motor.smoothedLoadPercentage)/5, 0.17))))
				-- local spiceRPM = self.spec_motorized.motor.lastMotorRpm
				-- local spiceMaxSpd = self.spec_motorized.motor.maxForwardSpeed
				local Nonce = 0
				
	-- NEUTRAL
				if spec.vFour == 0 then
					Nonce = 1
					self.spec_motorized.motor.currentDirection = 0
					-- self.spec_motorized.motor.minForwardGearRatio = 0
					-- self.spec_motorized.motor.maxForwardGearRatio = 0
					-- self.spec_motorized.motor.minBackwardGearRatio = 0
					-- self.spec_motorized.motor.maxBackwardGearRatio = 0
					-- self.spec_motorized.motor.maxBackwardSpeed = 0
					-- self.spec_motorized.motor.maxForwardSpeed = 0
					-- self.spec_motorized.motor.manualClutchValue = 1
					
					-- self.spec_motorized.motor.lowBrakeForceScale = 0.03
					-- self.spec_motorized.motor.accelerationLimit = 0
					-- self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0 -- 0
					-- need to unlock AccelerationPedal when direction is 0 as neutral
						--done
					local loadsetXP
					-- local accPedal = math.max(0, self.spec_drivable.axisForward)
					local loadDrive = 0
					loadDrive = math.max(0, math.max(0, self.spec_drivable.axisForward))
					if (self.spec_motorized.motor.lastMotorRpm / self.spec_motorized.motor.maxRpm) < loadDrive and self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm+25 then
						loadsetXP = 1;
					else
						loadsetXP = 0;
					end;
					self.spec_motorized.motor.rawLoadPercentage = math.max(self.spec_motorized.motor.rawLoadPercentage, loadsetXP)*1.8
					self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm + math.max(0, self.spec_drivable.axisForward) *66*math.pi, self.spec_motorized.motor.maxRpm)
					-- self.spec_motorized.motor.currentDirection = 0
					self.spec_motorized.motor.lastTurboScale = math.min(math.abs(self.spec_motorized.motor.rawLoadPercentage), 1)
					self.spec_motorized.motor.blowOffValveState = math.min(self.spec_motorized.motor.blowOffValveState + (self.spec_motorized.motor.lastMotorRpm / 1000 ), 1)
				end
						-- need to read inputValue's of directionChanger toggle, fw, bw
				-- if spec.vFour == 1 and Nonce == 1 then
				if spec.vFour == 1 then
					-- self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin
					-- self.spec_motorized.motor.maxForwardGearRatio = self.spec_motorized.motor.maxForwardGearRatioOrigin
					-- self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minBackwardGearRatioOrigin
					-- self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.minBackwardGearRatioOrigin
					-- self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin
					-- self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin
					-- self.spec_motorized.motor.manualClutchValue = 0
					
					-- self.spec_motorized.motor.accelerationLimit = 1
					-- self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00027777777777778
					loadsetXP = 0;
					
					-- self.spec_motorized.motor.currentDirection = spec.lastDirection
					Nonce = 0
				end
				
				
	-- MOTORDREHZAHL (Handgas-digital)
				local maxRpm = self.spec_motorized.motor.maxRpm
				local minRpm = self.spec_motorized.motor.minRpm
				spec.lastPTORot = self.spec_motorized.motor.lastPtoRpm
				if self.spec_motorized.motor.lastPtoRpm == nil then
					self.spec_motorized.motor.lastPtoRpm = 0
				end
				-- Handgas Stufen
				if spec.vFive == 1 then
					self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 1
				end
				if spec.vFive == 2 then
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (self.spec_motorized.motor.lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
				end
				if spec.vFive == 3 then
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (self.spec_motorized.motor.lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
				end
				if spec.vFive == 4 then
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (self.spec_motorized.motor.lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
				end
				if spec.vFive == 5 then
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (self.spec_motorized.motor.lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
				end
				if spec.vFive == 6 then
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (self.spec_motorized.motor.lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
				end
				if spec.vFive == 7 then
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (self.spec_motorized.motor.lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
				end
				if spec.vFive == 8 then
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (self.spec_motorized.motor.lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
				end
				if spec.vFive == 9 then
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (self.spec_motorized.motor.lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
				end
				if spec.vFive == 10 then
					self.spec_motorized.motor.lastMotorRpm = math.min((math.max(self.spec_motorized.motor.maxRpm-51, self.spec_motorized.motor.lastPtoRpm*0.75)), self.spec_motorized.motor.maxRpm)
				end
				-- Rückwärts retarder Last
				if self.spec_motorized.motor.currentDirection == -1 then
					self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage * 1.2
				end
				
		-- -- FAHRSTUFE I. 
				if spec.vOne == 2 and spec.vOne ~= nil and spec.isVarioTM then
					-- Planetengetriebe / Hydromotor Übersetzung
					spec.isHydroState = false
					spec.spiceDFWspeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 4.49), 6.94)
					spec.spiceDBWspeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 3.21), 6.36)
					
					self.spec_motorized.motor.maxForwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 4.49), 6.94)
					self.spec_motorized.motor.maxBackwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 3.21), 6.36)
					-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_VarioOne")) -- #l10n
					self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 1.81 + (self.spec_motorized.motor.rawLoadPercentage*9)
					self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin * 1.6
					self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.maxForwardGearRatioOrigin + 1
					self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin * 2
					self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage * 0.83
					self.spec_motorized.motor.differentialRotSpeed = self.spec_motorized.motor.differentialRotSpeed * 0.8
					
 					-- TMS like
					-- wenn Tempomat aus, wird die Tempomatgescwindigkeit als Steps der maxSpeed benutzt
					if spec.isTMSpedal == 1 and self:getCruiseControlState() == 0 and math.abs(self.spec_motorized.motor.lastAcceleratorPedal) >= 0.1 then
						self.spec_motorized.motor.maxBackwardSpeed = (math.min(self:getCruiseControlSpeed(), math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 3.21), 6.36) )) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
						self.spec_motorized.motor.maxForwardSpeed = (math.min(self:getCruiseControlSpeed(), math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 4.49), 6.94) )) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
					else
						self.spec_motorized.motor.maxForwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 4.49), 6.94)
						self.spec_motorized.motor.maxBackwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 3.21), 6.36)
					end
					
					if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm + 160 then
						if self.spec_motorized.motor.smoothedLoadPercentage < 0.3 then
							-- Gaspedal and Variator
							-- smooth = 1 + dt / 1400 for 60 fps range
							spec.smoother = spec.smoother + dt;
							if spec.smoother ~= nil and spec.smoother > 75 then
								spec.smoother = 0;
								if self:getLastSpeed() > 3 then
									self.spec_motorized.motor.lastMotorRpm = math.max(math.max(math.min((self:getLastSpeed() * math.abs(math.max(self.spec_motorized.motor.rawLoadPercentage, 0.52)))*44, self.spec_motorized.motor.maxRpm*0.98), self.spec_motorized.motor.minRpm+203), self.spec_motorized.motor.lastPtoRpm*0.7)
									if self:getLastSpeed() > (self.spec_motorized.motor.maxForwardSpeed*3.14)-2 then
										self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage *0.97
										self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm + self:getLastSpeed()
									end
									if math.max(0, self.spec_drivable.axisForward) < 0.2 then
										self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm + (self:getLastSpeed() * 15), self.spec_motorized.motor.maxRpm)
										self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage - (self:getLastSpeed() / 50)
										self.spec_motorized.motor.blowOffValveState = math.min(self.spec_motorized.motor.blowOffValveState + (self.spec_motorized.motor.lastMotorRpm / 1000 ), 1)
									end
									if math.max(0, self.spec_drivable.axisForward) > 0.5 and math.max(0, self.spec_drivable.axisForward) <= 0.9 and self.spec_motorized.motor.rawLoadPercentage < 0.5 then
										self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 0.8
										self.spec_motorized.motor.lastTurboScale = math.min(math.abs(self.spec_motorized.motor.rawLoadPercentage), 1)
										self.spec_motorized.motor.blowOffValveState = 0
									end
									
									-- self.spec_motorized.motor.lastPtoRpm = self.spec_motorized.motor.lastPtoRpm*0.7
								end
								-- print("smooth: " .. spec.smoother)
							end -- smooth
						end
						-- Nm kurven für unterschiedliche Lasten, Berücksichtigung pto
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.3 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.5 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.985), self.spec_motorized.motor.lastPtoRpm*0.7)+(math.abs(self.spec_motorized.motor.lastAcceleratorPedal)*25), self.spec_motorized.motor.maxRpm)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.5 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.65 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.97), self.spec_motorized.motor.lastPtoRpm*0.7)+(math.abs(self.spec_motorized.motor.lastAcceleratorPedal)*45), self.spec_motorized.motor.maxRpm)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.65 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.7 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.975), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.7 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.75 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.980), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.75 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.985), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.8 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.85 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.990), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.85 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.9 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.995), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm - (self.spec_motorized.motor.smoothedLoadPercentage*99))
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.9 then
							self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 1.00), self.spec_motorized.motor.lastPtoRpm*0.6), self.spec_motorized.motor.maxRpm - (self.spec_motorized.motor.smoothedLoadPercentage*99))
							self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 3 + (self.spec_motorized.motor.rawLoadPercentage*19)
							self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatio + self.spec_motorized.motor.smoothedLoadPercentage*15
						end

						-- Wenn ein Anbaugerät zu schwere Last erzeugt, schafft es die 4. Beschleunigungsrampe nicht oder nimmt Schaden
						if self.spec_motorized.motor.smoothedLoadPercentage > 0.96 and (self:getTotalMass() - self:getTotalMass(true)) >= (self:getTotalMass(true)) and spec.vTwo == 1 and spec.impIsLowered == true then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.95), self.spec_motorized.motor.lastPtoRpm*0.2)
							self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 3.1 + (self.spec_motorized.motor.rawLoadPercentage*9)
							self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
							self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
							-- Getriebeschaden erzeugen
							if self.spec_motorized.motor.rawLoadPercentage > 0.98 then
								g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 2048)
								self:addDamageAmount(self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 ) )
							end
						end
					end
				end
	
	
	-- HYDROSTAT  für evtl. Radlader und Holzernter    ToDo: need separate
				local hydrostaticVehicles = isLoader or isWoodWorker or isFFF
				if spec.vOne ~= 1 and spec.vOne ~= nil and spec.isVarioTM and self.spec_motorized.motor.maxForwardSpeedOrigin <= 6.68 and not isTractor and isWoodWorker then
					spec.isHydroState = true
					-- spec.HydrostatPedal = math.abs(self.spec_motorized.motor.lastAcceleratorPedal) -- nach oben verschoben z.719
					
					-- Hydrostatisches Fahrpedal
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
					self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 2.5
					if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm + 150 then
						if self.spec_motorized.motor.smoothedLoadPercentage < 0.3 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.98), self.spec_motorized.motor.lastPtoRpm)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage > 0.4 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.6 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 1.02), self.spec_motorized.motor.lastPtoRpm)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage > 0.6 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 1.05), self.spec_motorized.motor.lastPtoRpm)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage > 0.8 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * math.min(0.95+(tonumber(string.format("%.2f", math.min(math.abs(self.spec_motorized.motor.smoothedLoadPercentage)/5, 0.17)))), 1)), self.spec_motorized.motor.lastPtoRpm)
						end
					end
				end
				
				local i = 0
	-- -- FAHRSTUFE II. (Street/light weight transport or work) inputbinding ===================================================
				-- work()
				if spec.vOne == 1 and spec.vOne ~= nil and spec.isVarioTM then
					-- Planetengetriebe / Hydromotor Übersetzung
					spec.isHydroState = false
					self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 0.95 + (self.spec_motorized.motor.rawLoadPercentage*9)
					self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin
					self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minBackwardGearRatioOrigin
					self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.maxBackwardGearRatioOrigin
					
  					-- TMS like
					-- wenn Tempomat aus, wird die Tempomatgescwindigkeit als Steps der maxSpeed benutzt
					if spec.isTMSpedal == 1 and self:getCruiseControlState() == 0 and math.abs(self.spec_motorized.motor.lastAcceleratorPedal) >= 0.1 then
						self.spec_motorized.motor.maxBackwardSpeed = (math.min(self:getCruiseControlSpeed(), (self.spec_motorized.motor.maxBackwardSpeedOrigin * math.abs(self.spec_motorized.motor.lastAcceleratorPedal))))
						self.spec_motorized.motor.maxForwardSpeed = (math.min(self:getCruiseControlSpeed(), (self.spec_motorized.motor.maxForwardSpeedOrigin * math.abs(self.spec_motorized.motor.lastAcceleratorPedal))))
					else
						self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin
						self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin
					end
					-- smoothing nicht im Leerlauf
					if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm + 150 then
						if self.spec_motorized.motor.smoothedLoadPercentage < 0.3 then
							-- Gaspedal and Variator
							spec.smoother = spec.smoother + dt;
							if spec.smoother ~= nil and spec.smoother > 50 then -- Drehzahl zucken eliminieren
								spec.smoother = 0;
								if self:getLastSpeed() > 3 then 
									self.spec_motorized.motor.lastMotorRpm = math.max(math.max(math.min((self:getLastSpeed() * math.abs(math.max(self.spec_motorized.motor.rawLoadPercentage, 0.55)))*42, self.spec_motorized.motor.maxRpm*0.99), self.spec_motorized.motor.minRpm+203), self.spec_motorized.motor.lastPtoRpm*0.7)

									-- Drehzahl Erhöhung angleichen zur Motorbremswirkung, wenn Pedal losgelassen wird
									if math.max(0, self.spec_drivable.axisForward) < 0.2 then
										self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm + (self:getLastSpeed() * 12), self.spec_motorized.motor.maxRpm)
										self.spec_motorized.motor.blowOffValveState = math.min(self.spec_motorized.motor.blowOffValveState + (self.spec_motorized.motor.lastMotorRpm / 1000 ), 1)
										-- self.spec_motorized.motor.lastTurboScale = math.min(self.spec_motorized.motor.lastTurboScale + (self.spec_motorized.motor.lastMotorRpm / 1000 ), 1)
										-- self.spec_motorized.motor.constantRpmCharge = 1
									end
									-- TryOut TurboCharge und BlowOffValue reactive for sound xml (it works but sounds terr.)
									if math.max(0, self.spec_drivable.axisForward) > 0.5 and self.spec_motorized.motor.rawLoadPercentage < 0.5 then
										-- self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 0.9
										self.spec_motorized.motor.lastTurboScale = math.min(math.abs(self.spec_motorized.motor.rawLoadPercentage), 1)
										self.spec_motorized.motor.blowOffValveState = 0
									end
								end
							end -- smooth
						end
						
						-- Nm kurven für unterschiedliche Lasten, Berücksichtigung pto
						if self.spec_motorized.motor.smoothedLoadPercentage < 0.3 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.98), self.spec_motorized.motor.lastPtoRpm*0.8)
							self.spec_motorized.motorTemperature.heatingPerMS = 0.0015
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.3 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.5 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.99), self.spec_motorized.motor.lastPtoRpm*0.7)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.5 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.65 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.975), self.spec_motorized.motor.lastPtoRpm*0.7)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.65 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.7 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.98), self.spec_motorized.motor.lastPtoRpm*0.7)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.7 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.75 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.985), self.spec_motorized.motor.lastPtoRpm*0.7)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.75 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.99), self.spec_motorized.motor.lastPtoRpm*0.7)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.8 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.85 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.98), self.spec_motorized.motor.lastPtoRpm*0.7)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.85 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.9 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.985), self.spec_motorized.motor.lastPtoRpm*0.7)
						end
						if self.spec_motorized.motor.smoothedLoadPercentage >= 0.9 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.999), self.spec_motorized.motor.lastPtoRpm*0.7)
							self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 1.1 + (self.spec_motorized.motor.rawLoadPercentage*9)
							self.spec_motorized.motor.lastPtoRpm = self.spec_motorized.motor.lastPtoRpm * 0.9
							self.spec_motorized.motorTemperature.heatingPerMS = 0.0030 * self.spec_motorized.motor.rawLoadPercentage
							-- ändert bei sehr hoher Last die Übersetzung
						end
						
						-- Wenn ein Anbaugerät zu schwere Last erzeugt, schafft es die 2. Fahrstufe nicht
						if self.spec_motorized.motor.smoothedLoadPercentage > 0.93 and spec.impIsLowered == true then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.98), self.spec_motorized.motor.lastPtoRpm*0.4)
							self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 3.1 + (self.spec_motorized.motor.rawLoadPercentage*9)
							self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 1
							self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 1
							self.spec_motorized.motorTemperature.heatingPerMS = 0.0050 * self.spec_motorized.motor.rawLoadPercentage
						end
						-- Wenn ein Anbaugerät zu schwere Last erzeugt, schafft es die 2. Fahrstufe nicht oder nimmt Schaden
						if self.spec_motorized.motor.smoothedLoadPercentage > 0.96 and (self:getTotalMass() - self:getTotalMass(true)) >= (self:getTotalMass(true)) and spec.vTwo == 1 then
							self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.95), self.spec_motorized.motor.lastPtoRpm*0.8)
							self.spec_motorized.motor.lastPtoRpm = self.spec_motorized.motor.lastPtoRpm * 0.6
							self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 3.1 + (self.spec_motorized.motor.rawLoadPercentage*9)
							self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 1
							self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 1
							self.spec_motorized.motorTemperature.heatingPerMS = 0.0060 * self.spec_motorized.motor.rawLoadPercentage
							local massDiff = (self:getTotalMass() - self:getTotalMass(true)) / 100
							
							-- Getriebeschaden erzeugen
							if self.spec_motorized.motor.rawLoadPercentage > 0.98 then
								g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 2048)
								if spec.impIsLowered == false then
									self.spec_motorized.motorTemperature.heatingPerMS = 0.0080 * self.spec_motorized.motor.rawLoadPercentage
									if self.spec_motorized.motor.lastMotorRpm < self.spec_motorized.motor.minRpm + 150 then
										self:addDamageAmount((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4)
									end
								end
								-- print("addDamage: "  .. (self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4)
								-- print("is over weight: "  .. (self:getTotalMass() - self:getTotalMass(true)) .." >= " .. (self:getTotalMass(true)) )
								if spec.impIsLowered == true then
									self.spec_motorized.motorTemperature.heatingPerMS = 0.0150 * self.spec_motorized.motor.rawLoadPercentage
									self:addDamageAmount((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.7)
									-- print("addDamage lowered: "  .. self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 ))
								end
							end
							-- print("Mass Diff Local: " .. tostring(massDiff))
							-- todo addDamage
						end
						-- 			kmh 		> 				max kmh								-						max kmh                     :14
						--          47							16.87 * 3.141592654 (53) 		    -                 "   (53)/14= 3.786    47-3.786= 43.214 kmh
						if self:getLastSpeed() > ((self.spec_motorized.motor.maxForwardSpeed*math.pi)-(self.spec_motorized.motor.maxForwardSpeed*math.pi/14)) then
							-- Ändert die Drehzahl wenn man sich der vMax nähert
							self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm + (self:getLastSpeed()/9 ), self.spec_motorized.motor.maxRpm-18)
						end
					end
				end
			end
			
			-- modern deactivate diffs and 4wd
			-- spec.isVCAfrontDiff = self.vcaSetState("diffLockFront")
			-- spec.isVCAbackDiff = self.vcaSetState("diffLockBack")
			-- print("Diff Front: " .. tostring(self.vcaSetState("diffLockFront")))
			-- print("Diff Back: " .. tostring(self.vcaSetState("diffLockBack")))
			-- print("Diff Front: " .. tostring(spec.isVCAfrontDiff))
			-- print("motorTemperature.value: " .. tostring(self.spec_motorized.motorTemperature.value))
			-- print("motorTemperature.heatingPerMS: " .. tostring(self.spec_motorized.motorTemperature.heatingPerMS))
			-- print("motorFan.enabled: " .. tostring(self.spec_motorized.motorFan.enabled))
			-- print("Diff Back: " .. tostring(spec.isVCAbackDiff))
			-- print("Steering: " .. tostring(self.spec_drivable.lastSteeringAngle)) -- wheel.lastSteeringAngle steeringAxleAngle
			-- print("steeringAxleAngle: " .. tostring(self.spec_drivable.steeringAxleAngle)) -- wheel.lastSteeringAngle steeringAxleAngle
			self.spec_motorized.motor.equalizedMotorRpm = self.spec_motorized.motor.lastMotorRpm -- to compare in VehicleDebug and usable in realismAddon_AnimSpeed
			
			-- DBL convert Pedalposition and/or PedalVmax
			spec.forDBL_pedalpercent = string.format("%.0f", ( self.spec_drivable.axisForward ))
			spec.forDBL_tmspedalVmax = string.format("%.1f", (( self:getCruiseControlSpeed()*math.pi)+1 ))
			spec.forDBL_tmspedalVmaxActual = string.format("%.1f", (( self:getCruiseControlSpeed()*math.pi)+1 )*self.spec_drivable.axisForward)
			
			
			
			-- Brainstorm for later:
				-- DebugUtil.printTableRecursively()
				-- self.spec_motorized.consumersByFillType[FillType.DEF]
				-- 40 = 950; 50 = 1250; 60 = 1450;
			
			
			-- g_currentMission:addExtraPrintText("isVarioTM: " .. tostring(spec.isVarioTM))
			-- g_currentMission:addExtraPrintText("isTractor: " .. tostring(isTractor))
			-- g_currentMission:addExtraPrintText("gearRatio: " .. tostring(self.spec_motorized.motor.gearRatio))
			-- g_currentMission:addExtraPrintText("maxGearRatio: " .. tostring(self.spec_motorized.motor.maxGearRatio))
			-- g_currentMission:addExtraPrintText("minGearRatio: " .. tostring(self.spec_motorized.motor.minGearRatio))
			-- g_currentMission:addExtraPrintText("requiredMotorRpm: " .. tostring(self.spec_motorized.motor.requiredMotorRpm))
			-- g_currentMission:addExtraPrintText("minForwardGearRatio: " .. tostring(self.spec_motorized.motor.minForwardGearRatio))
			-- g_currentMission:addExtraPrintText("blowOffValveState: " .. tostring(self.spec_motorized.motor.blowOffValveState))
			-- g_currentMission:addExtraPrintText("lastTurboScale: " .. tostring(self.spec_motorized.motor.lastTurboScale))
			-- g_currentMission:addExtraPrintText("constantRpmCharge: " .. tostring(self.spec_motorized.motor.constantRpmCharge))
			-- g_currentMission:addExtraPrintText("constantAccelerationCharge: " .. tostring(self.spec_motorized.motor.constantAccelerationCharge))
			-- g_currentMission:addExtraPrintText("loadPercentageChangeCharge: " .. tostring(self.spec_motorized.motor.loadPercentageChangeCharge))
			-- Drivable.CRUISECONTROL_STATE_ACTIVE
			-- self.spec_motorized.motor.constantRpmCharge = 1
		end
		-- print("CLIENT spec.impIsLowered: " .. tostring(spec.impIsLowered))
		-- print("CLIENT vOne: " .. tostring(spec.vOne))
		-- print("CLIENT lastDirection: " .. tostring(spec.lastDirection))
		-- print("CLIENT vTwo: " .. tostring(spec.vTwo))
		-- print("CLIENT vThree: " .. tostring(spec.vThree))
		-- print("CLIENT vFour: " .. tostring(spec.vFour)) -- neutral
		-- print("CLIENT vFive: " .. tostring(spec.vFive)) -- handgas
		-- print("CLIENT smoother: " .. tostring(spec.smoother))
		-- print("CLIENT isHydroState: " .. tostring(spec.isHydroState))
		-- print("CLIENT currentDirection: " .. tostring(self.spec_motorized.motor.currentDirection))
		-- print("CLIENT spiceDFWspeed: " .. tostring(spec.spiceDFWspeed))
		-- print("CLIENT gearRatio: " .. tostring(self.spec_motorized.motor.gearRatio))
		-- print("CLIENT maxForwardSpeed: " .. tostring(self.spec_motorized.motor.maxForwardSpeed))
		-- print("CLIENT lastMotorRpm: " .. tostring(self.spec_motorized.motor.lastMotorRpm))
		-- print("CLIENT equalizedMotorRpm: " .. tostring(self.spec_motorized.motor.equalizedMotorRpm))
		-- print("CLIENT lastRealMotorRpm: " .. tostring(self.spec_motorized.motor.lastRealMotorRpm))
		-- print("CLIENT lastPtoRpm: " .. tostring(self.spec_motorized.motor.lastPtoRpm))
		-- print("CLIENT motorRotAcceleration: " .. tostring(self.spec_motorized.motor.motorRotAcceleration))
		-- print("CLIENT motorRotAccelerationSmoothed: " .. tostring(self.spec_motorized.motor.motorRotAccelerationSmoothed))
		-- print("CLIENT motorRotSpeed: " .. tostring(self.spec_motorized.motor.motorRotSpeed))
		-- print("CLIENT peakMotorTorque: " .. tostring(self.spec_motorized.motor.peakMotorTorque))
		-- print("CLIENT dampingRateFullThrottle: " .. tostring(self.spec_motorized.motor.dampingRateFullThrottle))
		-- print("CLIENT motorAvailableTorque: " .. tostring(self.spec_motorized.motor.motorAvailableTorque))
		-- print("CLIENT lastMotorAvailableTorque: " .. tostring(self.spec_motorized.motor.lastMotorAvailableTorque))
		-- print("CLIENT motorAppliedTorque: " .. tostring(self.spec_motorized.motor.motorAppliedTorque))
		-- print("CLIENT lastMotorAppliedTorque: " .. tostring(self.spec_motorized.motor.lastMotorAppliedTorque))
		-- print("CLIENT motorExternalTorque: " .. tostring(self.spec_motorized.motor.motorExternalTorque))
		-- print("CLIENT lastMotorExternalTorque: " .. tostring(self.spec_motorized.motor.lastMotorExternalTorque))
		-- print("CLIENT differentialRotSpeed: " .. tostring(self.spec_motorized.motor.differentialRotSpeed))
		-- print("CLIENT differentialRotAcceleration: " .. tostring(self.spec_motorized.motor.differentialRotAcceleration))
		-- print("CLIENT differentialRotAccelerationSmoothed: " .. tostring(self.spec_motorized.motor.differentialRotAccelerationSmoothed))
		-- print("CLIENT lastDifference: " .. tostring(self.spec_motorized.motor.lastDifference))
		-- print("CLIENT peakMotorPower: " .. tostring(self.spec_motorized.motor.peakMotorPower))
		-- print("CLIENT peakMotorPowerRotSpeed: " .. tostring(self.spec_motorized.motor.peakMotorPowerRotSpeed))
		-- print("CLIENT speedLimit: " .. tostring(self.spec_motorized.motor.speedLimit))
		-- print("CLIENT speedLimitAcc: " .. tostring(self.spec_motorized.motor.speedLimitAcc))
		-- print("CLIENT motorRotationAccelerationLimit: " .. tostring(self.spec_motorized.motor.motorRotationAccelerationLimit))
		-- print("CLIENT equalizedMotorRpm: " .. tostring(self.spec_motorized.motor.equalizedMotorRpm))
		-- print("CLIENT requiredMotorPower: " .. tostring(self.spec_motorized.motor.requiredMotorPower))
		-- print("CLIENT motorRotationAccelerationLimit: " .. tostring(self.spec_motorized.motor.motorRotationAccelerationLimit))
		-- print("CLIENT Vehicle:getIsLowered(defaultIsLowered): " .. tostring( Vehicle:getIsLowered(defaultIsLowered) ))
		-- print("CLIENT g_currentMission.accessHandler:canFarmAccessLand(activeFarm, x0, z0): " .. tostring(g_currentMission.accessHandler:canFarmAccessLand(activeFarm, x0, z0)))
	-- end   -- g_client
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
		-- print("SERVER lastDirection: " .. tostring(spec.lastDirection))
		-- print("SERVER vTwo: " .. tostring(spec.vTwo))
		-- print("SERVER vThree: " .. tostring(spec.vThree))
		-- print("SERVER vFour: " .. tostring(spec.vFour)) -- neutral
		-- print("SERVER vFive: " .. tostring(spec.vFive)) -- handgas
		-- print("SERVER smoother: " .. tostring(spec.smoother))
		-- print("SERVER isHydroState: " .. tostring(spec.isHydroState))
		-- print("SERVER currentDirection: " .. tostring(self.spec_motorized.motor.currentDirection))
		-- print("SERVER spiceDFWspeed: " .. tostring(spec.spiceDFWspeed))
		-- print("SERVER gearRatio: " .. tostring(self.spec_motorized.motor.gearRatio))
		-- print("SERVER maxForwardSpeed: " .. tostring(self.spec_motorized.motor.maxForwardSpeed))
		-- print("SERVER lastMotorRpm: " .. tostring(self.spec_motorized.motor.lastMotorRpm))
		-- print("SERVER equalizedMotorRpm: " .. tostring(self.spec_motorized.motor.equalizedMotorRpm))
		-- print("SERVER lastRealMotorRpm: " .. tostring(self.spec_motorized.motor.lastRealMotorRpm))
		-- print("SERVER lastPtoRpm: " .. tostring(self.spec_motorized.motor.lastPtoRpm))
	end
	-- print("spec.forDBL_drivinglevel: " .. spec.forDBL_drivinglevel)
	-- print("spec.forDBL_accramp: " .. spec.forDBL_accramp)
	-- print("spec.forDBL_brakeramp: " .. spec.forDBL_brakeramp)
	-- print("spec.forDBL_neutral: " .. spec.forDBL_neutral)
	-- print("spec.forDBL_tmspedal: " .. tostring(spec.forDBL_tmspedal))
	-- print("spec.forDBL_tmspedalVmax: " .. spec.forDBL_tmspedalVmax)
	-- print("spec.forDBL_pedalpercent: " .. spec.forDBL_pedalpercent)
	-- print("spec.forDBL_tmspedalVmaxActual: " .. spec.forDBL_tmspedalVmaxActual)
	-- print("spec.forDBL_digitalhandgasstep: " .. spec.forDBL_digitalhandgasstep)
	-- print("spec.forDBL_rpmrange: " .. spec.forDBL_rpmrange)
	-- print("spec.forDBL_rpmDmin: " .. spec.forDBL_rpmDmin)
	-- print("spec.forDBL_rpmDmax: " .. spec.forDBL_rpmDmax)
end -- onUpdate

----------------------------------------------------------------------------------------------------------------------	
----------------------------------------------------------------------------------------------------------------------			
------------- Should be external in CVT_Addon_HUD.lua, but I can't sync spec between 2 lua's -------------------------			
function CVTaddon:onDraw(dt)
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
			-- calculate position and size
			local uiScale = g_gameSettings.uiScale;
			local posX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1) - (0.035*g_gameSettings.uiScale)
			local ptmsX, ptmsY = g_currentMission.inGameMenu.hud.speedMeter.cruiseControlElement:getPosition()
			-- v |   + hoch
			local posY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY
			local BGcvt = 1
			local overlayP = 1
			local Transparancy = 0.6
			local size = 0.014 * g_gameSettings.uiScale
			
			-- vca diff locks
			local VCAposX   = g_currentMission.inGameMenu.hud.speedMeter.gearBg.overlay.x
			local VCAposY   = g_currentMission.inGameMenu.hud.speedMeter.gearBg.overlay.y
			local VCAwidth  = g_currentMission.inGameMenu.hud.speedMeter.gearBg.overlay.width 
			local VCAheight = g_currentMission.inGameMenu.hud.speedMeter.gearBg.overlay.height
			local VCAl = g_currentMission.inGameMenu.hud.speedMeter.gearTextSize
			
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
			setTextColor(0, 0.95, 0, 0.8)
			setTextAlignment(RenderText.ALIGN_LEFT)
			setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
			setTextBold(false)
			
			-- add background overlay box -
			if not isPKWLKW then  -- nil in mp at lkw 1661 dHG
				local isPTO = false
				if spec.lastPTORot ~= nil then
					if spec.lastPTORot > self.spec_motorized.motor.minRpm then
						isPTO = true
					end
				end
				local PTOColour = { 0.8, 0.6, 0, math.max(math.min(spec.transparendSpdT, 0.8), 0.5) }
				local HgColour = { 0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1) }
				if spec.vFive == nil then -- fix for mp nil at first HG use/unuse
					spec.vFive = 1
				end
				if spec.vFive ~= nil and spec.vFive < 9 then -- safty for no nil
					local HgColour = { 1, 0, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1) }
				elseif spec.vFive ~= nil and spec.vFive >= 9 then
				end
				local HgRColour = { 1, 0, 0, 1 }
				spec.CVTIconBg:setColor(0.01, 0.01, 0.01, math.max(math.min(spec.transparendSpd, 0.6), 0.2))
				spec.CVTIconFb:setColor(0, 0, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))
				spec.CVTIconFs1:setColor(0, 0.9, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))
				spec.CVTIconFs2:setColor(0, 0.9, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))
				spec.CVTIconPtms:setColor(0, 0.9, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))

				spec.CVTIconHg2:setColor(unpack(HgColour))
				spec.CVTIconHg3:setColor(unpack(HgColour))
				spec.CVTIconHg4:setColor(unpack(HgColour))
				spec.CVTIconHg5:setColor(unpack(HgColour))
				spec.CVTIconPTO:setColor(unpack(PTOColour))
				spec.CVTIconHg6:setColor(unpack(HgColour))
				spec.CVTIconHg7:setColor(unpack(HgColour))
				spec.CVTIconHg8:setColor(unpack(HgColour))
				spec.CVTIconHg9:setColor(unpack(HgColour))
				if spec.vFive ~= nil and spec.vFive <= 8 then
					spec.CVTIconHg10:setColor(unpack(HgColour))
				elseif spec.vFive ~= nil and spec.vFive >= 9 then
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
				-- spec.CVTIconN:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				spec.CVTIconN2:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				
				spec.CVTIconV:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				spec.CVTIconR:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				--
				spec.CVTIconBg:setPosition(posX-0.01, posY)
				spec.CVTIconFb:setPosition(posX-0.01, posY)
				spec.CVTIconFs1:setPosition(posX-0.01, posY)
				spec.CVTIconFs2:setPosition(posX-0.01, posY)
				spec.CVTIconPtms:setPosition(posX-0.01, posY)
				
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
				-- spec.CVTIconN:setPosition(posX-0.01, posY)
				spec.CVTIconN2:setPosition(posX-0.01, posY)
				
				spec.CVTIconV:setPosition(posX-0.01, posY)
				spec.CVTIconR:setPosition(posX-0.01, posY)
				--
				spec.CVTIconBg:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconFb:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconFs1:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconFs2:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconPtms:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				
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
				-- spec.CVTIconN:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconN2:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				
				spec.CVTIconV:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				spec.CVTIconR:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)

				-- :setAlignment(self.alignmentVertical, self.alignmentHorizontal)
				
				spec.CVTIconBg:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconFb:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconFs1:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconFs2:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconPtms:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)

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
				-- spec.CVTIconN:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconN2:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				
				spec.CVTIconV:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				spec.CVTIconR:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)

				local hgUVs = {0,0, 0.5,1}

				spec.CVTIconBg:render()
				spec.CVTIconFb:render()
				
				-- spec.BlinkTimer = spec.BlinkTimer - g_currentDt
				-- spec.NumberBlinkTimer = math.min(-spec.BlinkTimer / 2000, 0.5)
				-- spec.AsLongBlink
				
				if spec.AN then 
					spec.CVTIconFs2:render()
				end
				if self:getIsMotorStarted() then
					-- local AN = false --> onLoad
					-- local Counter = 0
					if spec.vOne == 2 then
						spec.CVTIconFs1:render()
						-- if spec.Counter < 10 and spec.NumberBlinkTimer == 0.5 then
							-- spec.AN = not spec.AN
							-- spec.Counter = spec.Counter + 1
						-- end
					elseif spec.vOne == 1 then
						spec.CVTIconFs2:render()
					end
					if spec.isTMSpedal == 1 then
					local tmsSpeed = string.format("%.1f", math.min((self:getCruiseControlSpeed() ) * math.pi, self.spec_motorized.motor.maxForwardSpeed * math.pi) +0.7)
						spec.CVTIconPtms:render()
						if self:getCruiseControlState() == 0 then
							renderText(ptmsX+0.006, ptmsY-0.002, size, tmsSpeed)
						end
					end
					-- VCA DiffLocks AutoDiffsAWD
					if spec.autoDiffs == 1 then
						renderText( 0.5 * ( VCAposX + VCAwidth + 1 ), VCAposY + 0.3 * VCAheight, VCAl + 0.005, "A" )
						
						-- renderText( 0.5 * ( posX + width + 1 ), posY + 0.5 * height, l, ">99%" )
					end
					
					-- print("AN: ".. tostring(AN))
					-- print("Number: ".. tostring(spec.NumberBlinkTimer))
					-- print("Counter: ".. tostring(Counter))
					-- print("timeUpdateTime: "..tostring(g_currentMission.environment.timeUpdateTime))
					-- print("dayTime: "..tostring(g_currentMission.environment.dayTime))
					-- print("NumberBlinkTimer: "..tostring(spec.NumberBlinkTimer))
					-- print("BlinkTimer: "..tostring(spec.BlinkTimer))
					-- print("AsLongBlink: "..tostring(spec.AsLongBlink))
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
						end -- rle
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
				end
			end

			-- 1337 Back to roots, wer hat das erfunden ?
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

function CVTaddon.SyncClientServer(vehicle, vOne, vTwo, vThree, vFour, vFive, autoDiffs, lastDirection, isVarioTM, isTMSpedal, PedalResolution, rpmDmax)
	local spec = vehicle.spec_CVTaddon
	
	spec.vOne = vOne
	spec.vTwo = vTwo
	spec.vThree = vThree
	spec.vFour = vFour
	spec.vFive = vFive
	spec.autoDiffs = autoDiffs
	spec.lastDirection = lastDirection
	spec.isVarioTM = isVarioTM
	spec.isTMSpedal = isTMSpedal
	spec.PedalResolution = PedalResolution
	spec.rpmDmax = rpmDmax
end								   
function CVTaddon:onReadStream(streamId, connection)
	local spec = self.spec_CVTaddon
	spec.vOne = streamReadInt32(streamId)  -- state driving level
	spec.vTwo = streamReadInt32(streamId) -- state accelerationRamp
	spec.vThree = streamReadInt32(streamId) -- state brakeRamp
	spec.vFour = streamReadInt32(streamId) -- state neutral
	spec.vFive = streamReadInt32(streamId) -- state Handgas
	spec.autoDiffs = streamReadInt32(streamId) -- state autoDiffs n awd
	spec.lastDirection = streamReadInt32(streamId) -- backup for neutral
	spec.isVarioTM = streamReadBool(streamId) -- checks if cvt
	spec.isTMSpedal = streamReadInt32(streamId) -- checks if pedalresolution is in use
	spec.PedalResolution = streamReadInt32(streamId) -- tms pedalmodus in %
	spec.rpmDmax = streamReadInt32(streamId) -- rpm range for max rpm
end

function CVTaddon:onWriteStream(streamId, connection)
	local spec = self.spec_CVTaddon
	streamWriteInt32(streamId, spec.vOne)
	streamWriteInt32(streamId, spec.vTwo)
	streamWriteInt32(streamId, spec.vThree)
	streamWriteInt32(streamId, spec.vFour)
	streamWriteInt32(streamId, spec.vFive)	
	streamWriteInt32(streamId, spec.autoDiffs)	
	streamWriteInt32(streamId, spec.lastDirection)	
	streamWriteBool(streamId, spec.isVarioTM)
	streamWriteInt32(streamId, spec.isTMSpedal)
	streamWriteInt32(streamId, spec.PedalResolution)
	streamWriteInt32(streamId, spec.rpmDmax)
end

function CVTaddon:onReadUpdateStream(streamId, timestamp, connection)
	if not connection:getIsServer() then
		local spec = self.spec_CVTaddon
		if streamReadBool(streamId) then			
			spec.vOne = streamReadInt32(streamId)
			spec.vTwo = streamReadInt32(streamId)
			spec.vThree = streamReadInt32(streamId)
			spec.vFour = streamReadInt32(streamId)
			spec.vFive = streamReadInt32(streamId)
			spec.autoDiffs = streamReadInt32(streamId)
			spec.lastDirection = streamReadInt32(streamId)
			spec.isVarioTM = streamReadBool(streamId)
			spec.isTMSpedal = streamReadInt32(streamId)
			spec.PedalResolution = streamReadInt32(streamId)
			spec.rpmDmax = streamReadInt32(streamId)
		end
	end
end

function CVTaddon:onWriteUpdateStream(streamId, connection, dirtyMask)
-- local spec = self.spec_CVTaddon
	if connection:getIsServer() then
		local spec = self.spec_CVTaddon
		if streamWriteBool(streamId, bitAND(dirtyMask, spec.dirtyFlag) ~= 0) then
			streamWriteInt32(streamId, spec.vOne)
			streamWriteInt32(streamId, spec.vTwo)
			streamWriteInt32(streamId, spec.vThree)
			streamWriteInt32(streamId, spec.vFour)
			streamWriteInt32(streamId, spec.vFive)
			streamWriteInt32(streamId, spec.autoDiffs)
			streamWriteInt32(streamId, spec.lastDirection)
			streamWriteBool(streamId, spec.isVarioTM)
			streamWriteInt32(streamId, spec.isTMSpedal)
			streamWriteInt32(streamId, spec.PedalResolution)
			streamWriteInt32(streamId, spec.rpmDmax)
			-- streamWriteBool(streamId, spec.check)
		end
	end
end

-- Drivable = true
-- addModEventListener(CVTaddon)
-- Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, CVTaddon.registerActionEvents)
-- Drivable.onUpdate  = Utils.appendedFunction(Drivable.onUpdate, CVTaddon.onUpdate);