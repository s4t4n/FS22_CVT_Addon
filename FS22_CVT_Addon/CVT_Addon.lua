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

-- last change	-- AXIS_CLUTCH_VEHICLE
				-- 
				
-- known issue	Neutral does'n sync lastDirection mp, you have to press a forward or reward directionbutton, not change direction
-- shop configuration produced call stacks


CVTaddon = {};
CVTaddon.modDirectory = g_currentModDirectory;
local modDesc = loadXMLFile("modDesc", g_currentModDirectory .. "modDesc.xml");
CVTaddon.modversion = getXMLString(modDesc, "modDesc.version");
CVTaddon.author = getXMLString(modDesc, "modDesc.author");
CVTaddon.contributor = getXMLString(modDesc, "modDesc.contributor");
source(CVTaddon.modDirectory.."events/SyncClientServerEvent.lua")

local scrversion = "0.3.4.0";
local modversion = CVTaddon.modversion; -- moddesc
local lastupdate = "20.04.24";

-- _______________________
cvtaDebugCVTon = false	 -- \
debug_for_DBL = false	  --  \ 
cvtaDebugCVTxOn = false	  --   } Debug change via console commands
cvtaDebugCVTheatOn = false --  / 
cvtaDebugCVTuOn = false	  -- /
cvtaDebugCVTu2on = false --/
-- ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
debugTable = false
sbshDebugWT = false
cvtaDebugCVTcanStartOn = false

printLMBF = false
VcvtaResetWear = false

local startetATM = false;
local vcaAWDon = false
local vcaInfoUnread = true
peakMotorTorqueOrigin = 0
-- local changeFlag = false;

function CVTaddon.prerequisitesPresent(specializations) 
    return true
end 

function CVTaddon.registerEventListeners(vehicleType) 
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", CVTaddon) 
	-- SpecializationUtil.registerEventListener(vehicleType, "onMissionLoaded", CVTaddon)
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", CVTaddon)
	SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", CVTaddon)
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", CVTaddon)
	SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", CVTaddon)
	
    SpecializationUtil.registerEventListener(vehicleType, "onLeaveVehicle", CVTaddon)
    SpecializationUtil.registerEventListener(vehicleType, "onCVTaHUDposChanged", CVTaddon)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", CVTaddon)
    SpecializationUtil.registerEventListener(vehicleType, "onDraw", CVTaddon)
    -- SpecializationUtil.registerEventListener(vehicleType, "addNewStoreConfig", CVTaddon)
	
	SpecializationUtil.registerEventListener(vehicleType, "onReadStream", CVTaddon);
	SpecializationUtil.registerEventListener(vehicleType, "onWriteStream", CVTaddon);
	SpecializationUtil.registerEventListener(vehicleType, "onReadUpdateStream", CVTaddon);
    SpecializationUtil.registerEventListener(vehicleType, "onWriteUpdateStream", CVTaddon);
	
	addModEventListener(CVTaddon)
end 
function CVTaddon.registerOverwrittenFunctions(vehicleType)
	SpecializationUtil.registerOverwrittenFunction(vehicleType, "getCanMotorRun", CVTaddon.getCanMotorRun)
	-- SpecializationUtil.registerOverwrittenFunction(vehicleType, "getTorqueCurveValue", CVTaddon.getTorqueCurveValue_new)
	-- SpecializationUtil.registerOverwrittenFunction(vehicleType, "getLastModulatedMotorRpm", CVTaddon.getLastModulatedMotorRpm_new)
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
			CVTaddon.actionEventsVt = {}
			CVTaddon.actionEventsV3 = {}
			CVTaddon.actionEventsV3toggle = {}
			CVTaddon.actionEventsV3set1 = {}
			CVTaddon.actionEventsV3set2 = {}
			CVTaddon.actionEventsV3set3 = {}
			CVTaddon.actionEventsV3set4 = {}
			CVTaddon.actionEventsV3d = {}
			CVTaddon.actionEventsV4 = {}
			CVTaddon.actionEventsV5 = {}
			CVTaddon.actionEventsV6 = {}
			CVTaddon.actionEventsV7 = {}
			CVTaddon.actionEventsV12 = {}
			CVTaddon.actionEventsV13 = {}
			CVTaddon.actionEventsV8 = {}
			CVTaddon.actionEventsV9 = {}
			CVTaddon.actionEventsV10 = {}
			local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName)
			if cvtaDebugCVTon then
				print("storeItem.categoryName: " .. tostring(storeItem.categoryName)) -- debug
			end
			spec.currSpdCheck = self:getLastSpeed()
			if cvtaDebugCVTon then
				print("CVTaddon: onRegisterActionEvents vOne: ".. tostring(spec.vOne))
				print("CVTaddon: onRegisterActionEvents vTwo: ".. tostring(spec.vTwo))
				print("CVTaddon: onRegisterActionEvents vThree: ".. tostring(spec.vThree))
				print("CVTaddon: onRegisterActionEvents eventActiveV1: ".. tostring(CVTaddon.eventActiveV1))
				print("CVTaddon: onRegisterActionEvents eventActiveV2: ".. tostring(CVTaddon.eventActiveV2))
				print("CVTaddon: onRegisterActionEvents eventActiveV3: ".. tostring(CVTaddon.eventActiveV3))
				print("CVTaddon: onRegisterActionEvents eventActiveV3toggle: ".. tostring(CVTaddon.eventActiveV3toggle))
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
			
			-- D toggle
			_, CVTaddon.eventIdVt = self:addActionEvent(CVTaddon.actionEventsVt, 'SETVARIOTOGGLE', self, CVTaddon.VarioToggle, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdVt, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdVt, false)
			
			-- AR
			_, CVTaddon.eventIdV3 = self:addActionEvent(CVTaddon.actionEventsV3, 'LMBF_TOGGLE_RAMP', self, CVTaddon.AccRamps, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV3, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV3, false)
			-- AR down
			_, CVTaddon.eventIdV3d = self:addActionEvent(CVTaddon.actionEventsV3d, 'LMBF_TOGGLE_RAMPD', self, CVTaddon.AccRampsD, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV3d, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV3d, false)
			-- AR toggle
			_, CVTaddon.eventIdV3toggle = self:addActionEvent(CVTaddon.actionEventsV3toggle, 'LMBF_TOGGLE_RAMPT', self, CVTaddon.AccRampsToggle, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV3toggle, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV3toggle, false)
			-- AR 1
			_, CVTaddon.eventIdV3set1 = self:addActionEvent(CVTaddon.actionEventsV3set1, 'LMBF_TOGGLE_RAMPS1', self, CVTaddon.AccRampsSet1, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV3set1, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV3set1, false)
			-- AR 2
			_, CVTaddon.eventIdV3set2 = self:addActionEvent(CVTaddon.actionEventsV3set2, 'LMBF_TOGGLE_RAMPS2', self, CVTaddon.AccRampsSet2, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV3set2, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV3set2, false)
			-- AR 3
			_, CVTaddon.eventIdV3set3 = self:addActionEvent(CVTaddon.actionEventsV3set3, 'LMBF_TOGGLE_RAMPS3', self, CVTaddon.AccRampsSet3, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV3set3, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV3set3, false)
			-- AR 4
			_, CVTaddon.eventIdV3set4 = self:addActionEvent(CVTaddon.actionEventsV3set4, 'LMBF_TOGGLE_RAMPS4', self, CVTaddon.AccRampsSet4, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV3set4, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV3set4, false)
			
			-- BR
			_, CVTaddon.eventIdV4 = self:addActionEvent(CVTaddon.actionEventsV4, 'LMBF_TOGGLE_BRAMP', self, CVTaddon.BrakeRamps, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV4, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV4, false)
			
			-- neutral 
			-- _, CVTaddon.eventIdV5 = self:addActionEvent(CVTaddon.actionEventsV5, 'SETVARION', self, CVTaddon.VarioN, false, true, false, true)
			-- g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV5, GS_PRIO_NORMAL)
			-- g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV5, false)
			
			-- -- rpmUP
			-- _, CVTaddon.eventIdV6 = self:addActionEvent(CVTaddon.actionEventsV6, 'SETVARIORPMP', self, CVTaddon.VarioRpmPlus, false, true, false, true)
			-- g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV6, GS_PRIO_NORMAL)
			-- g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV6, CVTaddon.eventActiveV6)
			-- -- rpmDn
			-- _, CVTaddon.eventIdV7 = self:addActionEvent(CVTaddon.actionEventsV7, 'SETVARIORPMM', self, CVTaddon.VarioRpmMinus, false, true, false, true)
			-- g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV7, GS_PRIO_NORMAL)
			-- g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV7, CVTaddon.eventActiveV7)
			
			-- rpm axis
			_, CVTaddon.eventIdV12 = self:addActionEvent(CVTaddon.actionEventsV12, 'SETVARIORPM_AXIS', self, CVTaddon.VarioRpmAxis, false, false, true, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV12, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV12, false)
			
			-- clutch axis
			if spec.isVarioTM == true then 
			-- _, CVTaddon.eventIdV13 = self:addActionEvent(CVTaddon.actionEventsV13, 'SETVARIOCLUTCH_AXIS', self, CVTaddon.VarioClutchAxis, false, false, true, true)
			_, CVTaddon.eventIdV13 = self:addActionEvent(CVTaddon.actionEventsV13, 'AXIS_CLUTCH_VEHICLE', self, CVTaddon.VarioClutchAxis, false, false, true, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV13, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV13, false)
			end
			
			-- Fahrpedalauflösung -- needed?   oder ändern in RPM aka gearbox
			_, CVTaddon.eventIdV8 = self:addActionEvent(CVTaddon.actionEventsV8, 'SETPEDALTMS', self, CVTaddon.VarioPedalRes, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV8, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV8, false)
			
			-- autoDiffs
			_, CVTaddon.eventIdV9 = self:addActionEvent(CVTaddon.actionEventsV9, 'SETVARIOADIFFS', self, CVTaddon.VarioADiffs, false, true, false, true)
			g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV9, GS_PRIO_NORMAL)
			g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV9, false)
	
			-- rpmDmax
			-- _, CVTaddon.eventIdV10 = self:addActionEvent(CVTaddon.actionEventsV10, 'SETVARIORPMDMAX', self, CVTaddon.VarioRpmDmax, false, true, false, true)
			-- g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV10, GS_PRIO_NORMAL)
			-- g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV10, CVTaddon.eventActiveV10)

		end
		if cvtaDebugCVTon then
			print("CVTaddon: onRegisterActionEvents a vOne: ".. tostring(spec.vOne))
			print("CVTaddon: onRegisterActionEvents a vTwo: ".. tostring(spec.vTwo))
			print("CVTaddon: onRegisterActionEvents a vThree: ".. tostring(spec.vThree))
			-- print("CVTaddon: onRegisterActionEvents a CVTCanStart: ".. tostring(spec.CVTCanStart))
			print("CVTaddon: onRegisterActionEvents a eventActiveV1: ".. tostring(CVTaddon.eventActiveV1))
			print("CVTaddon: onRegisterActionEvents a eventActiveV2: ".. tostring(CVTaddon.eventActiveV2))
			print("CVTaddon: onRegisterActionEvents a eventActiveV3: ".. tostring(CVTaddon.eventActiveV3))
			print("CVTaddon: onRegisterActionEvents a eventActiveV3toggle: ".. tostring(CVTaddon.eventActiveV3toggle))
			print("CVTaddon: onRegisterActionEvents a eventActiveV4: ".. tostring(CVTaddon.eventActiveV4))
		end
	end -- g_client
end -- onRegisterActionEvents

-- function CVTaddon.registerSoundXMLPaths(schema, baseKey)
    -- SoundManager.registerSampleXMLPaths(schema, baseKey, "motorFAN")
-- end

function CVTaddon:onLoad()
	-- if g_client ~= nil then
	self.spec_CVTaddon = {}
	local spec = self.spec_CVTaddon
	local pcspec = self.spec_powerConsumer
	
	if self.spec_RealisticDamageSystemEngineDied == nil then
		self.spec_RealisticDamageSystemEngineDied = {}
		self.spec_RealisticDamageSystemEngineDied.EngineDied = false
	end
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
	
	spec.CVTIconHEAT = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDpto.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconDmg = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDpto.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconMScold = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDmsCOLD.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconMSok = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDmsOK.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconMSwarn = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDmsWARN.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconMScrit = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDmsCRIT.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	
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
	-- spec.CVTIconN2 = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDn2.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	
	spec.CVTIconR = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDr.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	spec.CVTIconV = Overlay.new(Utils.getFilename("hud/CVTaddon_HUDv.dds", CVTaddon.modDirectory), 0, 0, 1, 1);
	
	spec.BG1width, spec.BG1height = 0.005, 0.09;
	spec.currBGcolor = { 0.02, 0.02, 0.02, 0.7 }
	-- if self.spec_motorized.motor.currentDirection == nil then
		-- spec.lastDirection = 1
	-- end
	-- defaults if allother nil
	spec.smoother = 0
	spec.DTadd = 0
	spec.vOne = 1
	spec.vTwo = 4
	spec.vThree = 2
	spec.CVTCanStart = false
	spec.vFive = 0
	spec.HandgasPercent = 0
	spec.ClutchInputValue = 0
	spec.autoDiffs = 0
	-- spec.lastDirection = 1
	spec.isTMSpedal = 0
	-- spec.moveRpmL = 0
	spec.impIsLowered = false
	spec.rpmrange = 1
	-- spec.rpmDmin
	spec.rpmDmax = self.spec_motorized.motor.maxRpm
	spec.BlinkTimer = 0
	spec.NumberBlinkTimer = 0
	spec.Counter = 0
	spec.AN = false
	spec.CVTconfig = 0
	spec.CVTcfgExists = false
	spec.CVTdamage = 0.000
	-- spec.RpmInputValue = 0
	-- spec.mcRPMvar = 1
	-- spec.CVTCanStart = false
	
 -- to make it easier read with dashbord-live
	spec.forDBL_pedalpercent = tostring(self.spec_motorized.motor.lastAcceleratorPedal*100)
	spec.forDBL_rpmrange = tostring(spec.rpmDmax .. " - " .. self.spec_motorized.motor.minRpm)
	spec.forDBL_rpmdmin = tostring(0)
	spec.forDBL_autodiffs = tostring(0)
	spec.forDBL_preautodiffs = tostring(0)
	spec.forDBL_ipmactive = tostring(0)
	spec.forDBL_brakeramp = tostring(0)
	
	spec.forDBL_warnheat = 0
	spec.forDBL_warndamage = 0
	spec.forDBL_critheat = 0
	spec.forDBL_critdamage = 0
	spec.forDBL_cvtwear = 0.000
	
	-- #GLOWIN-TEMP-SYNC
	spec.SyncMotorTemperature = 0
	spec.SyncFanEnabled = false
	spec.fanEnabledLast = false
		
	if spec.isTMSpedal ~= nil then
		if spec.isTMSpedal == 0 then
			spec.forDBL_tmspedal = 0
		elseif spec.isTMSpedal == 1 then
			spec.forDBL_tmspedal = 1
		end
	end
	-- if spec.CVTCanStart ~= nil then
		-- if spec.CVTCanStart == 0 then
			-- spec.forDBL_neutral = 1
		-- elseif spec.CVTCanStart == 1 then
			-- spec.forDBL_neutral = 0
		-- end
	-- end
	if spec.vOne ~= nil then
		if spec.vOne == 1 then
			spec.forDBL_drivinglevel = tostring(2)
		elseif spec.vOne == 2 then
			spec.forDBL_drivinglevel = tostring(1)
		end
	end
	spec.forDBL_digitalhandgasstep = tostring(spec.vFive)
	if spec.vTwo ~= nil then
		if spec.vTwo == 4 then
			spec.forDBL_accramp = tostring(4)
		elseif spec.vTwo == 1 then
			spec.forDBL_accramp = tostring(1)
		elseif spec.vTwo == 2 then
			spec.forDBL_accramp = tostring(2)
		elseif spec.vTwo == 3 then
			spec.forDBL_accramp = tostring(3)
		end
	end
	spec.forDBL_rpmdmax = tostring(spec.rpmDmax)
	if spec.vThree ~= nil then
		if (spec.vThree == 1) then -- BRamp 1
			spec.forDBL_brakeramp = tostring(17) -- off
		end
		if (spec.vThree == 2) then -- BRamp 2
			spec.forDBL_brakeramp = tostring(0) -- km/h
		end
		if (spec.vThree == 3) then -- BRamp 3
			spec.forDBL_brakeramp = tostring(4) -- km/h
		end
		if (spec.vThree == 4) then -- BRamp 4
			spec.forDBL_brakeramp = tostring(8) -- km/h
		end
		if (spec.vThree == 5) then -- BRamp 5
			spec.forDBL_brakeramp = tostring(15) -- km/h
		end
	end
	spec.forDBL_motorcanstart = 0
	-- spec.forDBL_
	
	CVTaddon.eventActiveV1 = true
	CVTaddon.eventActiveV2 = true
	CVTaddon.eventActiveVt = true
	CVTaddon.eventActiveV3toggle = true
	CVTaddon.eventActiveV3set1 = true
	CVTaddon.eventActiveV3set2 = true
	CVTaddon.eventActiveV3set3 = true
	CVTaddon.eventActiveV3set4 = true
	CVTaddon.eventActiveV3 = true
	CVTaddon.eventActiveV3d = true
	CVTaddon.eventActiveV4 = true
	CVTaddon.eventActiveV5 = true
	CVTaddon.eventActiveV6 = true
	CVTaddon.eventActiveV7 = true
	CVTaddon.eventActiveV12 = true
	CVTaddon.eventActiveV13 = true
	CVTaddon.eventActiveV8 = true
	CVTaddon.eventActiveV9 = true
	CVTaddon.eventActiveV10 = true
	CVTaddon.eventIdV1 = nil
	CVTaddon.eventIdV2 = nil
	CVTaddon.eventIdVt = nil
	CVTaddon.eventIdV3 = nil
	CVTaddon.eventIdV3toggle = nil
	CVTaddon.eventIdV3set1 = nil
	CVTaddon.eventIdV3set2 = nil
	CVTaddon.eventIdV3set3 = nil
	CVTaddon.eventIdV3set4 = nil
	CVTaddon.eventIdV3d = nil
	CVTaddon.eventIdV4 = nil
	CVTaddon.eventIdV5 = nil
	CVTaddon.eventIdV6 = nil
	CVTaddon.eventIdV7 = nil
	CVTaddon.eventIdV12 = nil
	CVTaddon.eventIdV13 = nil
	CVTaddon.eventIdV8 = nil
	CVTaddon.eventIdV9 = nil
	CVTaddon.eventIdV10 = nil
	spec.BackupMaxFwSpd = ""
	if spec.calcBrakeForce == nil then
		spec.calcBrakeForce = "0.5"
	end
	spec.dirtyFlag = self:getNextDirtyFlag() -- needed?
	spec.check = false
end  -- onLoad

-----------------------------------------------------------------------------------------------
function CVTaddon.initSpecialization()
	local schemaSavegame = Vehicle.xmlSchemaSavegame
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV1")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV2")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveVt")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV3toggle")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV3set1")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV3set2")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV3set3")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV3set4")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV3")
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#eventActiveV3d")
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
    schemaSavegame:register(XMLValueType.BOOL, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#CVTCanStart")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#vFive")
    -- schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#lastDirection")
    -- schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#PedalResolution")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#rpmDmax")
    schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#autoDiffs")
	schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#CvtConfigId")
	schemaSavegame:register(XMLValueType.FLOAT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#CVTdamage")
	print("CVT_Addon: initialized...... ")
	print("CVT_Addon: by " .. CVTaddon.author .. " and awsome contributors " .. CVTaddon.contributor)
	print("CVT_Addon: Script-Version...: " .. scrversion)
	print("CVT_Addon: Mod-Version......: " .. modversion)
	print("CVT-Addon: Date.............: " .. lastupdate)
end -- initSpecialization

function CVTaddon:onPreLoad(savegame)
	local spec = self.spec_CVTaddon
    local CvtConfigId = Utils.getNoNil(self.configurations["CVTaddon"], 0)
	-- print("CVTa: onPreLoad CvtConfigId noNIL " .. CvtConfigId)
    if savegame ~= nil then
        if CvtConfigId > 0 then
            CvtConfigId = savegame.xmlFile:getValue(savegame.key .. ".FS22_CVT_Addon.CVTaddon#CvtConfigId", CvtConfigId)
            -- if CvtConfigId < 1 or CvtConfigId > 8 then
                -- CvtConfigId = 1
            -- end
            self.configurations["CVTaddon"] = CvtConfigId
			-- spec.CVTconfig = self.configurations["CVTaddon"] -- spec nil
			-- print("CVTa: onPreLoad CvtConfigId " .. CvtConfigId)
			
        end
		-- print("CVTa: onPreLoad CvtConfigId out " .. CvtConfigId)
    end
end

function initNewStoreConfig()
	print("CVTaREG: initNewStoreConfig")
    g_configurationManager:addConfigurationType("CVTaddon", g_i18n:getText("text_CVT_title"), nil, nil, nil, nil, ConfigurationUtil.SELECTOR_MULTIOPTION)
	StoreItemUtil.getConfigurationsFromXML = Utils.overwrittenFunction(StoreItemUtil.getConfigurationsFromXML, addNewStoreConfig)
end

function addNewStoreConfig(xmlFile, superFunc, baseXMLName, baseDir, customEnvironment, isMod, storeItem)
	local configurations = superFunc(xmlFile, baseXMLName, baseDir, customEnvironment, isMod, storeItem)
    -- local spec = self.spec_CVTaddon
    local StI = ""
    if storeItem == nil then
		--
    elseif configurations == nil then
		--
    elseif configurations["CVTaddon"] ~= nil then
		--
    else
        -- StI = string.sub(storeItem.categoryName, 1, 8)
        StI = storeItem.categoryName
    end
	local modNamez = getXMLString(xmlFile.handle, "vehicle.storeData.name")
	-- local indCatName = "catoff"
	-- if getXMLString(xmlFile.handle, "vehicle.storeData.indCatCVT") ~= nil then
		-- indCatName = getXMLString(xmlFile.handle, "vehicle.storeData.indCatCVT")
	-- end
	if modNamez == nil then
		modNamez = getXMLString(xmlFile.handle, "vehicle.storeData.name.en")
	end
	local exVehicles = string.find(tostring(modNamez), "wheelbarrow") or string.find(tostring(modNamez), "Schubkarre") or string.find(tostring(modNamez), "Taczka") 
					   or string.find(tostring(modNamez), "Göweil") or string.find(tostring(modNamez), "boat") or string.find(tostring(modNamez), "boot") or string.find(tostring(modNamez), "fahrrad")
					   or string.find(tostring(modNamez), "bike") or string.find(tostring(modNamez), "bicycle") or string.find(tostring(modNamez), "roller")
	local addXtraCats = string.find(tostring(StI), "sdf") or string.find(tostring(StI), "SDF") or string.find(tostring(StI), "LSFM") or string.find(tostring(StI), "CLAAS")
						or string.find(tostring(StI), "JOHN") or string.find(tostring(StI), "DEUTZ") or string.find(tostring(StI), "JD") or string.find(tostring(StI), "PACK")
    local int2ndVehicles = StI == "GRAPEVEHICLES" or StI == "OLIVEVEHICLES" or StI == "FORAGEHARVESTERCUTTERS" or StI == "MOWERVEHICLES" or StI == "SLURRYVEHICLES"
    local intVehicles = addXtraCats or StI == "TRACTORSS" or StI == "TRACTORSM" or StI == "TRACTORSL" or StI == "HARVESTERS" or StI == "FORAGEHARVESTERS" or StI == "POTATOVEHICLES" or StI == "BEETVEHICLES" or StI == "SUGARCANEVEHICLES" or StI == "COTTONVEHICLES" or StI == "MISCVEHICLES" or StI == "FRONTLOADERVEHICLES" or StI == "TELELOADERVEHICLES" or StI == "SKIDSTEERVEHICLES" or StI == "WHEELLOADERVEHICLES" or StI == "WOODHARVESTING" or StI == "FORKLIFTS" or StI == "ANIMALSVEHICLES"
	-- print("CVTa ShopCat: " .. tostring(StI))
    if intVehicles or int2ndVehicles then
		local isVario = true -- ToDo: find a way to check if one of a motorconfig has cvt, when the first one is a manual shift
        local xmlFile = XMLFile.load("vehicle", storeItem.xmlFilename, Vehicle.xmlSchema)
        local manualShift = getXMLString(xmlFile.handle, "vehicle.motorized.motorConfigurations.motorConfiguration(?).transmission(?)#name")
        -- local XMLCVTaddon = getXMLString(xmlFile.handle, "vehicle.motorized.motorConfigurations.motorConfiguration(?).CVTaddon")
        -- local XMLCVTaddonNDL = getXMLString(xmlFile.handle, "vehicle.motorized.motorConfigurations.motorConfiguration(?).CVTaddon.NumDrivingLevels")
        local XMLCVTaddonNDLv = getXMLString(xmlFile.handle, "vehicle.motorized.motorConfigurations.motorConfiguration(?).CVTaddon.NumDrivingLevels#dlvalue")
		-- local XMLCVTaddonFCN = getXMLString(xmlFile.handle, "vehicle.motorized.motorConfigurations.motorConfiguration(?).CVTaddon.ForceConfigNumber")
        local XMLCVTaddonFCNv = getXMLString(xmlFile.handle, "vehicle.motorized.motorConfigurations.motorConfiguration(?).CVTaddon.ForceConfigNumber#fcnvalue")

		if string.find(tostring(manualShift), "cvt") or string.find(tostring(manualShift), "cvx") or string.find(tostring(manualShift), "vario") or string.find(tostring(manualShift), "stufenlos") or string.find(tostring(manualShift), "auto") then
			isVario = true
		end

        local integrateConfig = true
        if storeItem.isMod == false then
            if StI == "TRUCKS" then
                integrateConfig = false
            end
        else
            if StI == "TRUCKS" then
                local modName = getXMLString(xmlFile.handle, "vehicle.storeData.name")
                if modName == nil then
                    modName = getXMLString(xmlFile.handle, "vehicle.storeData.name.en")
                end
                if modName == nil then
                    integrateConfig = false
                elseif string.find(string.upper(modName), "UNIMOG") == nil then
                    integrateConfig = false
                end
                if modName == "$l10n_storeData_name_1axis" then  -- Unimog U5023
                    integrateConfig = true
                end
				if modName == "E - Locomotive" or modName == "locomotive" or modName == "horse" then
                    integrateConfig = false
                end
				-- print("CVTa modName: " .. tostring(modName))
            end
			
        end
		-- print("CVTa indCatName: " .. tostring(indCatName))
		-- if indCatName ~= "catoff" then
			-- integrateConfig = true
		-- end
		delete(xmlFile.handle)
        if isVario == true and integrateConfig == true and not exVehicles then
            local name1 = g_i18n:getText("text_CVTclas_installed_short")
            local name2 = g_i18n:getText("text_CVTclasB1_installed_short")
            local name3 = g_i18n:getText("text_CVTclasB2_installed_short")
            local name4 = g_i18n:getText("text_CVTmod_installed_short")
            local name5 = g_i18n:getText("text_CVTmodB1_installed_short")
            local name6 = g_i18n:getText("text_CVTmodB2_installed_short")
            local name7 = g_i18n:getText("text_HST_installed_short")
            local name8 = g_i18n:getText("text_CVT_notInstalled_short")
            local name9 = g_i18n:getText("text_CVT_manuInstalled_short")
            local name10 = g_i18n:getText("text_CVT_ElektroInstalled_short")
            local name11 = g_i18n:getText("text_CVT_HarvesterInstalled_short")
            -- local name9 = "manuell"
            configurations["CVTaddon"] = {
                {name = name1, index = 1, isDefault = false, price = 0, dailyUpkeep = 0, isSelectable = true},
                {name = name2, index = 2, isDefault = false, price = 750, dailyUpkeep = 0, isSelectable = true},
                {name = name3, index = 3, isDefault = false, price = 1000, dailyUpkeep = 0, isSelectable = true},
                {name = name4, index = 4, isDefault = false, price = 0, dailyUpkeep = 0, isSelectable = true},
                {name = name5, index = 5, isDefault = false, price = 750, dailyUpkeep = 0, isSelectable = true},
                {name = name6, index = 6, isDefault = false, price = 1000, dailyUpkeep = 0, isSelectable = true},
                {name = name7, index = 7, isDefault = false, price = 0, dailyUpkeep = 5, isSelectable = true},
				{name = name8, index = 8, isDefault = false, price = 1, dailyUpkeep = 0, isSelectable = true},
				{name = name9, index = 9, isDefault = false, price = 0, dailyUpkeep = 0, isSelectable = true},
				{name = name10, index = 10, isDefault = false, price = 3016, dailyUpkeep = 3, isSelectable = true},
				{name = name11, index = 11, isDefault = false, price = 0, dailyUpkeep = 2, isSelectable = true}
            }
        end
    end
    return configurations
end
if g_configurationManager.configurations["CVTaddon"] == nil then
    initNewStoreConfig()
	print("CVTa: init store config")
end

function CVTaddon:onPostLoad(savegame, mission, node, state)
-- load hud settings
	if g_currentMission:getIsServer() then
        if g_currentMission.missionInfo.savegameDirectory ~= nil and fileExists(g_currentMission.missionInfo.savegameDirectory .. "/CVTaddonHUD.xml") then
            local xmlFile4HUD = XMLFile.load("CVTaddon", g_currentMission.missionInfo.savegameDirectory .. "/CVTaddonHUD.xml")
            if xmlFile4HUD ~= nil then
                CVTaddon.HUDpos = xmlFile4HUD:getInt("CVTaddon.nvHUDpos", CVTaddon.HUDpos)
                CVTaddon.HUDsize = xmlFile4HUD:getInt("CVTaddon.nvHUDsize", CVTaddon.HUDsize)
                xmlFile4HUD:delete()
				CVTaddon.XMLloaded = 1
				state = CVTaddon.HUDpos
				if state == 1 then
					CVTaddon.PoH = 1
				elseif state == 2 then
					CVTaddon.PoH = 2
				elseif state == 3 then
					CVTaddon.PoH = 3
				end
				print("CVTa: CVTaddonHUD.xml data loaded")
			else
				CVTaddon.XMLloaded = 2
				CVTaddon.HUDpos = 1
				CVTaddon.PoH = 1
				print("CVTa: CVTaddonHUD.xml data not found - use default")
            end
		end
	end
-- load vehicle setting
	local spec = self.spec_CVTaddon
	local CvtConfigId = Utils.getNoNil(self.configurations["CVTaddon"], 0)
	if g_client ~= nil then
		if self.spec_motorized ~= nil then
			if spec == nil then return end
			spec.CVTcfgExists = self.configurations["CVTaddon"] ~= nil and self.configurations["CVTaddon"] ~= 0
			
			if savegame ~= nil then
				local xmlFile = savegame.xmlFile
				local key = savegame.key .. ".FS22_CVT_Addon.CVTaddon"
				spec.vOne = xmlFile:getValue(key.."#vOne", spec.vOne)
				spec.vTwo = xmlFile:getValue(key.."#vTwo", spec.vTwo)
				spec.vThree = xmlFile:getValue(key.."#vThree", spec.vThree)
				spec.CVTCanStart = xmlFile:getValue(key.."#CVTCanStart", spec.CVTCanStart)
				spec.vFive = xmlFile:getValue(key.."#vFive", spec.vFive)
				spec.autoDiffs = xmlFile:getValue(key.."#autoDiffs", spec.autoDiffs)
				-- spec.lastDirection = xmlFile:getValue(key.."#lastDirection", spec.lastDirection)
				-- spec.PedalResolution = xmlFile:getValue(key.."#PedalResolution", spec.PedalResolution)
				-- spec.rpmDmax = xmlFile:getValue(key.."#rpmDmax", spec.rpmDmax)
				spec.CVTconfig = xmlFile:getValue(key.."#CvtConfigId", spec.CVTconfig)
				spec.CVTdamage = xmlFile:getValue(key.."#CVTdamage", spec.CVTdamage)
				
				print("CVT_Addon: personal adjustments loaded for "..self:getName())
				print("CVT_Addon: Load Driving Level id: "..tostring(spec.vOne))
				print("CVT_Addon: Load Acceleration Ramp id: "..tostring(spec.vTwo))
				print("CVT_Addon: Load Brake Ramp id: "..tostring(spec.vThree))
			end
		end
	end -- g_client

	-- self.configurations["CVTaddon"] = spec.CVTcfgExists and 7 or 6 or 5 or 4 or 3 or 2 or 1
	-- self.configurations["CVTaddon"] = spec.CVTconfig and 1 or 2 or 3 or 4 or 5 or 6 or 7 or 8
	if spec.CVTcfgExists then
		-- self.configurations["CVTaddonConfigs"] = spec.CVTconfig
		if CvtConfigId > 0 then
			spec.CVTconfig = CvtConfigId
		end
		-- print("CVTa: if spec.CVTcfgExists then : " .. tostring(spec.CVTcfgExists))
		-- print("CVTa: CvtConfigId: " .. CvtConfigId)
		-- print("CVTa: CVTconfig: " .. tostring(spec.CVTconfig))
		-- print("CVTa: isVarioTM PL: " .. tostring(spec.isVarioTM))
	end
	
	gU_targetSelf = self
	
	-- local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName)
	-- local MODxmlFile = XMLFile.load("vehicle", storeItem.xmlFilename, Vehicle.xmlSchema)
	-- local XMLCVTaddonNDLv = getXMLString(MODxmlFile.handle, "vehicle.motorized.motorConfigurations.motorConfiguration(?).CVTaddon.NumDrivingLevels#dlvalue")
	-- local XMLCVTaddonFCNv = getXMLString(MODxmlFile.handle, "vehicle.motorized.motorConfigurations.motorConfiguration(?).CVTaddon.ForceConfigNumber#fcnvalue")

	-- print("CVTa Shop XMLCVTaddonNDLv: " .. tostring(XMLCVTaddonNDLv))
	-- print("CVTa Shop XMLCVTaddonFCNv: " .. tostring(XMLCVTaddonFCNv))
	print("CVTa: CvtConfigId spec.CVTconfig " .. spec.CVTconfig)
	
	-- if XMLCVTaddonFCNv ~= nil then
		-- spec.CVTconfig = XMLCVTaddonFCNv
	-- end

	
	-- print("CVTa:2 CvtConfigId spec.CVTconfig " .. spec.CVTconfig)
	-- if spec.CVTconfig == nil or 0 then
		-- spec.CVTconfig = CvtConfigId
	-- end
	
 -- to make it easier read with dashbord-live
	spec.forDBL_pedalpercent = tostring(self.spec_motorized.motor.lastAcceleratorPedal*100)
	spec.forDBL_rpmrange = 1
	spec.forDBL_rpmdmin = tostring(0)
	spec.forDBL_autodiffs = tostring(0)
	spec.forDBL_preautodiffs = tostring(0)
	spec.forDBL_ipmactive = tostring(0)
	spec.forDBL_brakeramp = tostring(0)
	spec.forDBL_warnheat = 0
	spec.forDBL_warndamage = 0
	spec.forDBL_critheat = 0
	spec.forDBL_critdamage = 0
	if spec.CVTdamage ~= nil then
		spec.forDBL_cvtwear = spec.CVTdamage
	else
		spec.forDBL_cvtwear = 0.00
		spec.CVTdamage = 0.000
	end
	
	-- if spec.CVTCanStart ~= nil then
	if spec.isTMSpedal ~= nil then
		if spec.isTMSpedal == 0 then
			spec.forDBL_tmspedal = 0
		elseif spec.isTMSpedal == 1 then
			spec.forDBL_tmspedal = 1
		end
	end
	-- if spec.CVTCanStart ~= nil then
		-- if spec.CVTCanStart == 0 then
			-- spec.forDBL_neutral = 1
		-- elseif spec.CVTCanStart == 1 then
			-- spec.forDBL_neutral = 0
		-- end
	-- end
	if spec.vOne ~= nil then
		if spec.vOne == 1 then
			spec.forDBL_drivinglevel = tostring(2)
		elseif spec.vOne == 2 then
			spec.forDBL_drivinglevel = tostring(1)
		end
	end
	spec.forDBL_digitalhandgasstep = tostring(spec.vFive)
	if spec.vTwo ~= nil then
		if spec.vTwo == 4 then
			spec.forDBL_accramp = tostring(4)
		elseif spec.vTwo == 1 then
			spec.forDBL_accramp = tostring(1)
		elseif spec.vTwo == 2 then
			spec.forDBL_accramp = tostring(2)
		elseif spec.vTwo == 3 then
			spec.forDBL_accramp = tostring(3)
		end
	end
	-- spec.forDBL_rpmdmax = tostring(spec.rpmDmax)
	if spec.vThree ~= nil then
		if (spec.vThree == 1) then -- BRamp 1
			spec.forDBL_brakeramp = tostring(17) -- off
		end
		if (spec.vThree == 2) then -- BRamp 2
			spec.forDBL_brakeramp = tostring(0) -- km/h
		end
		if (spec.vThree == 3) then -- BRamp 3
			spec.forDBL_brakeramp = tostring(4) -- km/h
		end
		if (spec.vThree == 4) then -- BRamp 4
			spec.forDBL_brakeramp = tostring(8) -- km/h
		end
		if (spec.vThree == 5) then -- BRamp 5
			spec.forDBL_brakeramp = tostring(15) -- km/h
		end
	end
	-- spec.forDBL_
	
	-- if self.spec_motorized.motor:getRotInertia() < 0.003 then
		-- local setRIorigin = self.spec_motorized.motor.peakMotorTorque / 600
		-- self.spec_motorized.motor:setRotInertia(setRIorigin)
		-- -- print("setRIorigin: ".. tostring(setRIorigin))
	-- end
end -- onPostLoad
if CVTaddon.ModName == nil then 
	CVTaddon.ModName = g_currentModName
end
CVTaddon.PoH = 1; -- Position of HUD
CVTaddon.HUDpos = 1;
CVTaddon.XMLloaded = 0;
CVTaddon.HUDposChanged = {}
CVTaddon.HUDposChanged[1] = g_i18n.modEnvironments[CVTaddon.ModName]:getText("selection_CVTaddonHUDpos_1")
CVTaddon.HUDposChanged[2] = g_i18n.modEnvironments[CVTaddon.ModName]:getText("selection_CVTaddonHUDpos_2")
CVTaddon.HUDposChanged[3] = g_i18n.modEnvironments[CVTaddon.ModName]:getText("selection_CVTaddonHUDpos_3")
-- Mission00.loadMission00Finished = Utils.appendedFunction(Mission00.loadMission00Finished, CVTaddon.loadedMission);

function init()
	InGameMenuGameSettingsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuGameSettingsFrame.onFrameOpen, CVTaddon.installGUI)
    InGameMenuGameSettingsFrame.updateGameSettings = Utils.appendedFunction(InGameMenuGameSettingsFrame.updateGameSettings, CVTaddon.updateHUDposGui)
end
function CVTaddon:installGUI()
	if not self.initLRBGuiDone then 
		
		local title = TextElement.new()
		title:applyProfile("settingsMenuSubtitle", true)
		title:setText(g_i18n:getText("title_PosOfHUD"))
		self.boxLayout:addElement(title)
		self.CVTaHUDpos = self.checkDirt:clone()
		self.CVTaHUDpos.target = CVTaddon 
		self.CVTaHUDpos.id = "CVTaHUDpos"
		self.CVTaHUDpos:setCallback("onClickCallback", "onCVTaHUDposChanged")
		self.CVTaHUDpos.elements[4]:setText(g_i18n:getText("setting_PosOf_HUD"))
		self.CVTaHUDpos.elements[6]:setText(g_i18n:getText("explanation_PosOf_HUD"))
		self.CVTaHUDpos:setTexts({g_i18n:getText("selection_CVTaddonHUDpos_1"), g_i18n:getText("selection_CVTaddonHUDpos_2"), g_i18n:getText("selection_CVTaddonHUDpos_3")})
		self.boxLayout:addElement(self.CVTaHUDpos)
		self.initLRBGuiDone = true
		self.CVTaHUDpos:setState(CVTaddon.HUDpos)
	end
end
function CVTaddon.updateHUDposGui(self)
	if self.initLRBGuiDone and self.CVTaHUDpos ~= nil then
        self.CVTaHUDpos:setState(CVTaddon.HUDpos)
    end
end
function CVTaddon:onCVTaHUDposChanged(state)
	CVTaddon.HUDpos = state;
	local changedTextValue
	if state == 1 then
		CVTaddon.PoH = 1
		changedTextValue = "SettingNorm"
	elseif state == 2 then
		CVTaddon.PoH = 2
		changedTextValue = "SettingTop"
	elseif state == 3 then
		CVTaddon.PoH = 3
		changedTextValue = "SettingOff"
	end
	g_currentMission:addGameNotification(g_i18n.modEnvironments[CVTaddon.ModName]:getText("SettingChanged_title"), g_i18n.modEnvironments[CVTaddon.ModName]:getText("SettingChanged").." "..g_i18n.modEnvironments[CVTaddon.ModName]:getText(changedTextValue), "", 2048)
end
init()
-- make localizations available
local i18nTable = getfenv(0).g_i18n
for l18nId,l18nText in pairs(g_i18n.texts) do
  i18nTable:setText(l18nId, l18nText)
end

function CVTaddon:saveToXMLFile(xmlFile, key, usedModNames)
	
	if g_currentMission.missionInfo.isValid then
        local xmlFile4HUD = XMLFile.create("CVTaddon", g_currentMission.missionInfo.savegameDirectory .. "/CVTaddonHUD.xml", "CVTaddon")
        if xmlFile4HUD ~= nil then
            xmlFile4HUD:setInt("CVTaddon.nvHUDpos", CVTaddon.HUDpos)
            xmlFile4HUD:save()
            xmlFile4HUD:delete()
			print("CVTa: CVTaddonHUD.xml data saved")
        end
    end
	
	if self.spec_motorized ~= nil then
		local spec = self.spec_CVTaddon
		-- if spec.CVTconfig ~= nil or spec.CVTconfig ~= 0
		spec.CVTconfig = self.configurations["CVTaddon"] or 1
		-- #configPart
		-- spec.cvtexists = self.configurations["CVTaddon"] == 2
		-- spec.actionsLength = table.getn(spec.actions)
		if spec.isVarioTM then
			xmlFile:setValue(key.."#vOne", spec.vOne)
			xmlFile:setValue(key.."#vTwo", spec.vTwo)
			xmlFile:setValue(key.."#vThree", spec.vThree)
			xmlFile:setValue(key.."#CVTCanStart", spec.CVTCanStart)
			xmlFile:setValue(key.."#vFive", spec.vFive)
			xmlFile:setValue(key.."#autoDiffs", spec.autoDiffs)
			-- xmlFile:setValue(key.."#lastDirection", spec.lastDirection)
			-- xmlFile:setValue(key.."#PedalResolution", spec.PedalResolution)
			-- xmlFile:setValue(key.."#rpmDmin", spec.rpmDmin)
			-- xmlFile:setValue(key.."#rpmDmax", spec.rpmDmax)
			xmlFile:setValue(key.."#CVTdamage", spec.CVTdamage)
		end
		xmlFile:setValue(key.."#CvtConfigId", spec.CVTconfig)

		print("CVT_Addon: saved.")
		-- print("CVT_Addon: saved personal adjustments for "..self:getName())
		-- print("CVT_Addon: Save Driving Level id: "..tostring(spec.vOne))
		-- print("CVT_Addon: Save Acceleration Ramp id: "..tostring(spec.vTwo))
		-- print("CVT_Addon: Save Brake Ramp id: "..tostring(spec.vThree))
		-- print("CVT_Addon: Save CfgID: "..tostring(spec.CVTconfig))
	end
end
-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

function CVTaddon:BrakeRamps() -- BREMSRAMPEN - Ab kmh X wird die Betriebsbremse automatisch aktiv
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		-- local spec = self.spec_CVTaddon
		if cvtaDebugCVTon then
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
			if cvtaDebugCVTon then
				print("BrRamp 1 vThree: "..tostring(spec.vThree))
				print("BrRamp 1 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
			end
		end
		if (spec.vThree == 2) then -- BRamp 2
			spec.forDBL_brakeramp = tostring(4) -- km/h
			if cvtaDebugCVTon then
				print("BrRamp 2 vThree: "..tostring(spec.vThree))
				print("BrRamp 2 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
			end
		end
		if (spec.vThree == 3) then -- BRamp 3
			spec.forDBL_brakeramp = tostring(8) -- km/h
			if cvtaDebugCVTon then
				print("BrRamp 3 vThree: "..tostring(spec.vThree))
				print("BrRamp 3 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
			end
		end
		if (spec.vThree == 4) then -- BRamp 4
			spec.forDBL_brakeramp = tostring(15) -- km/h
			if cvtaDebugCVTon then
				print("BrRamp 4 vThree: "..tostring(spec.vThree))
				print("BrRamp 4 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
			end
		end
		if (spec.vThree == 5) then -- BRamp 5
			spec.forDBL_brakeramp = tostring(17) -- km/h
			if cvtaDebugCVTon then
				print("BrRamp 5 vThree: "..tostring(spec.vThree))
				print("BrRamp 5 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
			end
		end
		if spec.vThree == 5 or spec.vThree == nil then
			spec.vThree = 1
		else
			spec.vThree = spec.vThree + 1
		end
		-- to make it easier read with dashbord-live
		if cvtaDebugCVTon then
			print("BrRamp Taste losgelassen vThree: "..tostring(spec.vThree))
			print("BrRamp Taste losgelassen lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
		end
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
		end
		if debug_for_DBL then
			print("CVTa BR event: " .. spec.vThree)		
			print("CVTa BR 4_dbl: " .. spec.forDBL_brakeramp)		
		end
	end --g_client
end -- BrakeRamps

function CVTaddon:AccRampsToggle() -- BESCHLEUNIGUNGSRAMPEN
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		if cvtaDebugCVTon then
			print("AccRamp Taste gedrückt vTwo: "..tostring(spec.vTwo))
			print("AccRamp Taste gedrückt acc: "..self.spec_motorized.motor.accelerationLimit)
		end
		if self.CVTaddon == nil then 
			return
		end
		if not CVTaddon.eventActiveV3toggle then
			return
		end
		if spec.vTwo == 4 or spec.vTwo == nil then
			spec.vTwo = 1
		else
			spec.vTwo = spec.vTwo + 1
		end
		-- DBL convert
		if spec.vTwo == 4 then
			spec.forDBL_accramp = tostring(4)
		elseif spec.vTwo == 1 then
			spec.forDBL_accramp = tostring(1)
		elseif spec.vTwo == 2 then
			spec.forDBL_accramp = tostring(2)
		elseif spec.vTwo == 3 then
			spec.forDBL_accramp = tostring(3)
		end
		
		if (spec.vTwo == 1) then -- Ramp 1 +1
			self.spec_motorized.motor.accelerationLimit = 0.35
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce-0.10))
			if cvtaDebugCVTon then
				print("AccRamp 1 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 1 acc0.5: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 2) then -- Ramp 2 +1
			self.spec_motorized.motor.accelerationLimit = 0.80
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce))
			
			if cvtaDebugCVTon then
				print("AccRamp 2 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 2 acc1.0: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 3) then -- Ramp 3 +1
			self.spec_motorized.motor.accelerationLimit = 1.20
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.03))
			if cvtaDebugCVTon then
				print("AccRamp 3 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 3 acc1.5: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 4) then -- Ramp 4 +1
			self.spec_motorized.motor.accelerationLimit = 1.70 -- Standard
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.08))
			-- self.spec_motorized.motor.peakMotorTorque = self.spec_motorized.motor.peakMotorTorque * 0.5
			if cvtaDebugCVTon then
				print("AccRamp 4 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 4 acc2.0: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		
		if cvtaDebugCVTon then
			print("AccRamp Taste losgelassen vTwo: "..tostring(spec.vTwo))
			print("AccRamp Taste losgelassen acc: "..self.spec_motorized.motor.accelerationLimit)
		end
		
		
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
		end
	end -- g_client
end -- AccRamps Toggle

function CVTaddon:AccRampsSet1() -- BESCHLEUNIGUNGSRAMPEN I
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		if self.CVTaddon == nil then 
			return
		end
		if not CVTaddon.eventActiveV3set1 then
			return
		end
		spec.vTwo = 1
		-- DBL convert
		spec.forDBL_accramp = tostring(1)

-- Ramp 1 +1
		self.spec_motorized.motor.accelerationLimit = 0.35
		self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce-0.10))
		if cvtaDebugCVTon then
			print("AccRamp1 Taste gedrückt vTwo: "..tostring(spec.vTwo))
			print("AccRamp1 Taste gedrückt acc: "..self.spec_motorized.motor.accelerationLimit)
		end
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
		end
	end -- g_client
end -- AccRamps set1

function CVTaddon:AccRampsSet2() -- BESCHLEUNIGUNGSRAMPEN II
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		if self.CVTaddon == nil then 
			return
		end
		if not CVTaddon.eventActiveV3set2 then
			return
		end
		spec.vTwo = 2
		-- DBL convert
		spec.forDBL_accramp = tostring(2)

		self.spec_motorized.motor.accelerationLimit = 0.80
		self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce))
		if cvtaDebugCVTon then
			print("AccRamp2 Taste gedrückt vTwo: "..tostring(spec.vTwo))
			print("AccRamp2 Taste gedrückt acc: "..self.spec_motorized.motor.accelerationLimit)
		end
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
		end
	end -- g_client
end -- AccRamps set2

function CVTaddon:AccRampsSet3() -- BESCHLEUNIGUNGSRAMPEN III
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		if self.CVTaddon == nil then 
			return
		end
		if not CVTaddon.eventActiveV3set3 then
			return
		end
		spec.vTwo = 3
		-- DBL convert
		spec.forDBL_accramp = tostring(3)

		self.spec_motorized.motor.accelerationLimit = 1.20
		self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.03))
		if cvtaDebugCVTon then
			print("AccRamp3 Taste gedrückt vTwo: "..tostring(spec.vTwo))
			print("AccRamp3 Taste gedrückt acc: "..self.spec_motorized.motor.accelerationLimit)
		end
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
		end
	end -- g_client
end -- AccRamps set3

function CVTaddon:AccRampsSet4() -- BESCHLEUNIGUNGSRAMPEN IV
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		if self.CVTaddon == nil then 
			return
		end
		if not CVTaddon.eventActiveV3set4 then
			return
		end
		spec.vTwo = 4
		-- DBL convert
		spec.forDBL_accramp = tostring(4)

		self.spec_motorized.motor.accelerationLimit = 1.70 -- Standard
		self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.08))
		if cvtaDebugCVTon then
			print("AccRamp4 Taste gedrückt vTwo: "..tostring(spec.vTwo))
			print("AccRamp4 Taste gedrückt acc: "..self.spec_motorized.motor.accelerationLimit)
		end
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
		end
	end -- g_client
end -- AccRamps set4

function CVTaddon:AccRamps() -- BESCHLEUNIGUNGSRAMPEN - Motorbremswirkung wird kontinuirlich berechnet @update
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		if cvtaDebugCVTon then
			print("AccRamp Taste gedrückt vTwo: "..tostring(spec.vTwo))
			print("AccRamp Taste gedrückt acc: "..self.spec_motorized.motor.accelerationLimit)
		end
		if self.CVTaddon == nil then 
			return
		end
		if not CVTaddon.eventActiveV3 then
			return
		end
		
		if spec.vTwo < 4 then
			spec.vTwo = spec.vTwo + 1
			-- CVTaddon.eventActiveV3 = true
		else
			spec.vTwo = 4
			-- CVTaddon.eventActiveV3 = false
		end
		if cvtaDebugCVTon then
			print("AccRamp Taste losgelassen vTwo: "..tostring(spec.vTwo))
			print("AccRamp Taste losgelassen acc: "..self.spec_motorized.motor.accelerationLimit)
		end
		-- DBL convert
		if spec.vTwo == 4 then
			spec.forDBL_accramp = tostring(4)
		elseif spec.vTwo == 1 then
			spec.forDBL_accramp = tostring(1)
		elseif spec.vTwo == 2 then
			spec.forDBL_accramp = tostring(2)
		elseif spec.vTwo == 3 then
			spec.forDBL_accramp = tostring(3)
		end
		
		if (spec.vTwo == 1) then -- Ramp 1 +1
			self.spec_motorized.motor.accelerationLimit = 0.35
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce-0.10))
			if cvtaDebugCVTon then
				print("AccRamp 1 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 1 acc0.5: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 2) then -- Ramp 2 +1
			self.spec_motorized.motor.accelerationLimit = 0.80
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce))
			
			if cvtaDebugCVTon then
				print("AccRamp 2 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 2 acc1.0: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 3) then -- Ramp 3 +1
			self.spec_motorized.motor.accelerationLimit = 1.20
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.03))
			if cvtaDebugCVTon then
				print("AccRamp 3 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 3 acc1.5: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 4) then -- Ramp 4 +1
			self.spec_motorized.motor.accelerationLimit = 1.70 -- Standard
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.08))
			-- self.spec_motorized.motor.peakMotorTorque = self.spec_motorized.motor.peakMotorTorque * 0.5
			if cvtaDebugCVTon then
				print("AccRamp 4 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 4 acc2.0: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		
		
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
		end
	end -- g_client
end -- AccRamps
function CVTaddon:AccRampsD()
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		if cvtaDebugCVTon then
			print("AccRamp Taste gedrückt vTwo: "..tostring(spec.vTwo))
			print("AccRamp Taste gedrückt acc: "..self.spec_motorized.motor.accelerationLimit)
		end
		if self.CVTaddon == nil then 
			return
		end
		if not CVTaddon.eventActiveV3d then
			return
		end
		
		if spec.vTwo > 1 then
			spec.vTwo = spec.vTwo - 1
			-- CVTaddon.eventActiveV3d = true
		else
			spec.vTwo = 1
			-- CVTaddon.eventActiveV3d = false
		end
		if cvtaDebugCVTon then
			print("AccRamp Taste losgelassen vTwo: "..tostring(spec.vTwo))
			print("AccRamp Taste losgelassen acc: "..self.spec_motorized.motor.accelerationLimit)
		end
		-- DBL convert
		if spec.vTwo == 4 then
			spec.forDBL_accramp = tostring(4)
		elseif spec.vTwo == 1 then
			spec.forDBL_accramp = tostring(1)
		elseif spec.vTwo == 2 then
			spec.forDBL_accramp = tostring(2)
		elseif spec.vTwo == 3 then
			spec.forDBL_accramp = tostring(3)
		end
		
		if (spec.vTwo == 1) then -- Ramp 1 +1
			self.spec_motorized.motor.accelerationLimit = 0.35
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce-0.10))
			if cvtaDebugCVTon then
				print("AccRamp 1 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 1 acc0.5: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 2) then -- Ramp 2 +1
			self.spec_motorized.motor.accelerationLimit = 0.80
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce))
			
			if cvtaDebugCVTon then
				print("AccRamp 2 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 2 acc1.0: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 3) then -- Ramp 3 +1
			self.spec_motorized.motor.accelerationLimit = 1.20
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.03))
			if cvtaDebugCVTon then
				print("AccRamp 3 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 3 acc1.5: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
		if (spec.vTwo == 4) then -- Ramp 4 +1
			self.spec_motorized.motor.accelerationLimit = 1.70 -- Standard
			self.spec_motorized.motor.lowBrakeForceScale = (math.abs(spec.calcBrakeForce+0.08))
			-- self.spec_motorized.motor.peakMotorTorque = self.spec_motorized.motor.peakMotorTorque * 0.5
			if cvtaDebugCVTon then
				print("AccRamp 4 vTwo: "..tostring(spec.vTwo))
				print("AccRamp 4 acc2.0: "..self.spec_motorized.motor.accelerationLimit)
			end
		end
				
		self:raiseDirtyFlags(spec.dirtyFlag) 
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
		end
	end -- g_client
end -- AccRamps Down



function CVTaddon:VarioRpmAxis(actionName, inputValue)	
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		if inputValue ~= nil then
			spec.HandgasPercent = (math.floor(tonumber(inputValue) * 100)/100)
		end
		spec.forDBL_digitalhandgasstep = spec.vFive
		-- print("CVTa HandgasPercent: " .. tostring(spec.HandgasPercent))
		self:raiseDirtyFlags(spec.dirtyFlag)
		-- if g_server ~= nil then
			-- g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
		-- else
			-- g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
		-- end
	end
end
function CVTaddon:VarioClutchAxis(actionName, inputValue)	
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		spec.ClutchInputValue = tonumber(inputValue)
		spec.ClutchInputValue = (math.floor(spec.ClutchInputValue * 10)/10)
		self:raiseDirtyFlags(spec.dirtyFlag)
		if g_server ~= nil then
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
		end
	end
end

function CVTaddon:VarioOne() -- FAHRSTUFE 1 field
	-- changeFlag = true -- tryout
	local spec = self.spec_CVTaddon
	spec.BlinkTimer = -1
	spec.Counter = 0
	-- spec.AsLongBlink = g_currentMission.environment.dayTime
	-- spec.NumberBlinkTimer = g_currentMission.environment.dayTime
	-- not able to use when modern config
	if spec.CVTconfig ~= 4 or spec.CVTconfig ~= 5 or spec.CVTconfig ~= 6 or spec.CVTconfig ~= 8 then
		if g_client ~= nil then
			if cvtaDebugCVTon then
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
				if self:getLastSpeed() >= 11 and spec.CVTconfig ~= 10 and spec.CVTconfig ~= 11 then
					if g_client ~= nil and isActiveForInputIgnoreSelection then
						g_currentMission:showBlinkingWarning(g_i18n:getText("txt_warn_tofastDn"), 3072)
					end
					spec.CVTdamage = math.min(spec.CVTdamage + math.floor((29*( self:getLastSpeed() / math.pi * self.spec_motorized.motor.maxForwardSpeed )^2 ), 100))
					-- if self.spec_RealisticDamageSystem == nil then
						-- self:addDamageAmount(math.min(0.0002*(self:getOperatingTime()/1000000)+(self:getLastSpeed()/100), 1))
					-- end
					
					spec.forDBL_critdamage = 1
					spec.forDBL_warndamage = 0
					if cvtaDebugCVTxOn then
						print("Damage: ".. (math.min(0.0002*(self:getOperatingTime()/1000000)+(self:getLastSpeed()/100), 1))  ) -- debug
					end
					CVTaddon.eventActiveV1 = true
					CVTaddon.eventActiveV2 = false
				end

				if spec.vOne == 1 then
					if self:getLastSpeed() <=10 and spec.CVTconfig ~= 10 and spec.CVTconfig ~= 11 then
						if self:getLastSpeed() > 1 then
							spec.CVTdamage = math.min(spec.CVTdamage + math.floor((29*( self:getLastSpeed() / math.pi * self.spec_motorized.motor.maxForwardSpeed )^2 ), 100))
							-- if self.spec_RealisticDamageSystem == nil then
								-- self:addDamageAmount(math.min(0.00008*(self:getOperatingTime()/1000000)+(self.spec_motorized.motor.lastMotorRpm/10000)+(self:getLastSpeed()/100), 1))
							-- end
							spec.forDBL_critdamage = 1
							spec.forDBL_warndamage = 0
							if cvtaDebugCVTxOn then
								print("Damage: ".. (math.min(0.00008*(self:getOperatingTime()/1000000)+(self.spec_motorized.motor.lastMotorRpm/10000)+(self:getLastSpeed()/100), 1))  ) -- debug
							end
						end
						spec.vOne = 2
						-- local SpeedScale = spec.moveRpmL
						CVTaddon.eventActiveV1 = true
						CVTaddon.eventActiveV2 = true
						if cvtaDebugCVTon then
							print("VarioOne vOne: ".. tostring(spec.vOne))
							print("VarioOne : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
						end
					end
				end
			end
			
			if cvtaDebugCVTon then
				print("VarioOne Taste losgelassen vOne: ".. tostring(spec.vOne))
				print("VarioOne : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
			end
			
			self:raiseDirtyFlags(spec.dirtyFlag) 
			if g_server ~= nil then
				g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
			end
		end -- g_client
		
	end
	-- DBL convert
	if spec.vOne == 1 then
		spec.forDBL_drivinglevel = tostring(2)
	elseif spec.vOne == 2 then
		spec.forDBL_drivinglevel = tostring(1)
	end
end -- VarioOne

function CVTaddon:VarioToggle() -- FAHRSTUFEN WECHSELN
	-- changeFlag = true -- tryout
	local spec = self.spec_CVTaddon
	spec.BlinkTimer = -1
	spec.Counter = 0
	if spec.CVTconfig ~= 4 or spec.CVTconfig ~= 5 or spec.CVTconfig ~= 6 or spec.CVTconfig ~= 8 or spec.CVTconfig ~= 9 then
		if g_client ~= nil then
			if cvtaDebugCVTon then
				print("VarioOne Taste gedrückt vOne: ".. tostring(spec.vOne))
				print("Entered: " .. tostring(self:getIsEntered()))
				print("Started: " .. tostring(self:getIsMotorStarted()))
				print("VarioOne : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
			end
			if self.CVTaddon == nil then 
				return
			end
			if not CVTaddon.eventActiveV1 or not CVTaddon.eventActiveV2 then
				return
			end

			if self:getIsEntered() and self:getIsMotorStarted() then
				if spec.vOne == 1 then
					if self:getLastSpeed() <=10 then
						if self:getLastSpeed() > 1 and spec.CVTconfig ~= 10 and spec.CVTconfig ~= 11 then
							spec.CVTdamage = math.min(spec.CVTdamage + math.min(0.00008*(self:getOperatingTime()/1000000)+(self.spec_motorized.motor.lastMotorRpm/10000)+(self:getLastSpeed()/100), 1))
							-- if self.spec_RealisticDamageSystem == nil then
								-- self:addDamageAmount(math.min(0.00008*(self:getOperatingTime()/1000000)+(self.spec_motorized.motor.lastMotorRpm/10000)+(self:getLastSpeed()/100), 1))
							-- end
							spec.forDBL_critdamage = 1
							spec.forDBL_warndamage = 0
							if cvtaDebugCVTxOn then
								print("Damage: ".. (math.min(0.00008*(self:getOperatingTime()/1000000)+(self.spec_motorized.motor.lastMotorRpm/10000)+(self:getLastSpeed()/100), 1))  ) -- debug
							end
						end
						spec.vOne = 2
						-- local SpeedScale = spec.moveRpmL
						CVTaddon.eventActiveV1 = true
						CVTaddon.eventActiveV2 = true
						if cvtaDebugCVTon then
							print("VarioOne vOne: ".. tostring(spec.vOne))
							print("VarioOne : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
						end
					end
					self.spec_motorized.motor.maxForwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 4.49), 6.94)
					self.spec_motorized.motor.maxBackwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 3.21), 6.36)
				elseif spec.vOne == 2 then
					if self:getLastSpeed() > 10 and spec.CVTconfig ~= 10 and spec.CVTconfig ~= 11 then
						if g_client ~= nil and isActiveForInputIgnoreSelection then
							g_currentMission:showBlinkingWarning(g_i18n:getText("txt_warn_tofastUp"), 3072)
						end
						spec.CVTdamage = math.min(spec.CVTdamage + math.floor((29*( self:getLastSpeed() / math.pi * self.spec_motorized.motor.maxForwardSpeed )^2 ), 100))
						-- if self.spec_RealisticDamageSystem == nil then
							-- self:addDamageAmount(math.min(0.00015*(self:getOperatingTime()/1000000), 1)) -- 3.6
						-- end
						spec.forDBL_critdamage = 1
						spec.forDBL_warndamage = 0
					end
					
					
					spec.vOne = 1
					-- local SpeedScale = spec.moveRpmL
					self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin
					self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin
					
					spec.autoDiffs = 0
					if self.spec_vca ~= nil then
						self:vcaSetState("diffLockFront", false)
						self:vcaSetState("diffLockBack", false)
					end

					CVTaddon.eventActiveV1 = true
					CVTaddon.eventActiveV2 = true
					if cvtaDebugCVTon then
						print("VarioTwo vOne: "..tostring(spec.vOne))
						print("VarioTwo : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
						print("VarioTwo : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxBwSpd))
					end
				end
			end
			
			if cvtaDebugCVTon then
				print("VarioOne Taste losgelassen vOne: ".. tostring(spec.vOne))
				print("VarioOne : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
			end
			
			self:raiseDirtyFlags(spec.dirtyFlag) 
			if g_server ~= nil then
				g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
			end
		end -- g_client
	end
	-- DBL convert
	if spec.vOne == 1 then
		spec.forDBL_drivinglevel = tostring(2)
	elseif spec.vOne == 2 then
		spec.forDBL_drivinglevel = tostring(1)
	end
end -- VarioToggle

function CVTaddon:VarioTwo() -- FAHRSTUFE 2 street
	-- changeFlag = true -- tryout
	local spec = self.spec_CVTaddon
	spec.BlinkTimer = -1
	spec.Counter = 0
	-- spec.AsLongBlink = g_currentMission.environment.dayTime
	-- not able to use when modern config
	if spec.CVTconfig ~= 4 or spec.CVTconfig ~= 5 or spec.CVTconfig ~= 6 or spec.CVTconfig ~= 8 or spec.CVTconfig ~= 9 then
		if g_client ~= nil then
			-- local spec = self.spec_CVTaddon
			-- if spec.vOne == nil then
				-- spec.vOne = 2
			-- end
			spec.autoDiffs = 0
			if self.spec_vca ~= nil then
				self:vcaSetState("diffLockFront", false)
				self:vcaSetState("diffLockBack", false)
			end
			if cvtaDebugCVTon then
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
				if self:getLastSpeed() > 10 and spec.CVTconfig ~= 10 and spec.CVTconfig ~= 11 then
					if g_client ~= nil and isActiveForInputIgnoreSelection then
						g_currentMission:showBlinkingWarning(g_i18n:getText("txt_warn_tofastUp"), 3072)
					end
					spec.forDBL_critdamage = 1
					spec.forDBL_warndamage = 0
					spec.CVTdamage = math.min(spec.CVTdamage + math.floor((29*( self:getLastSpeed() / math.pi * self.spec_motorized.motor.maxForwardSpeed )^2 ), 100))
					-- if self.spec_RealisticDamageSystem == nil then
						-- self:addDamageAmount(math.min(0.00015*(self:getOperatingTime()/1000000), 1)) -- 3.6
					-- end
				end
				if spec.vOne == 2 then
					spec.vOne = 1
					-- local SpeedScale = spec.moveRpmL
					self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin
					self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin

					CVTaddon.eventActiveV1 = true
					CVTaddon.eventActiveV2 = true
					if cvtaDebugCVTon then
						print("VarioTwo vOne: "..tostring(spec.vOne))
						print("VarioTwo : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
						print("VarioTwo : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxBwSpd))
					end
				end
			end
			if cvtaDebugCVTon then
				print("VarioTwo Taste losgelassen vOne: "..tostring(spec.vOne))
				print("VarioTwo : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
				print("VarioTwo : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxFwSpd))
			end
			
			self:raiseDirtyFlags(spec.dirtyFlag) 
			if g_server ~= nil then
				g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
			end
		end
	end
	-- DBL convert
	if spec.vOne == 1 then
		spec.forDBL_drivinglevel = tostring(2)
	elseif spec.vOne == 2 then
		spec.forDBL_drivinglevel = tostring(1)
	end
end -- VarioTwo


function CVTaddon:VarioADiffs() -- autoDiffs
	local spec = self.spec_CVTaddon
	if g_client ~= nil then
		
		-- local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
		
		if cvtaDebugCVTon then
			-- print("VarioN Taste gedrückt CVTCanStart: "..spec.CVTCanStart)
			-- print("VarioN : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..spec.calcBrakeForce)
			-- print("VarioN : BMFwSpd/BMBwSpd:"..tostring(spec.BackupMaxFwSpd).."/"..tostring(spec.BackupMaxBwSpd))
		end
		if self:getIsEntered() and self:getIsMotorStarted() then
			if (spec.autoDiffs == 0) then
				CVTaddon.eventActiveV9 = true
				if cvtaDebugCVTxOn then
					print("Auto Diffs aktiv") -- debug
				end
			end
			if (spec.autoDiffs == 1) then
				CVTaddon.eventActiveV9 = true
				if cvtaDebugCVTxOn then
					print("Auto Diffs inaktiv") -- debug
				end
			end
			if spec.autoDiffs == 1 and spec.CVTconfig ~= 8 then
				spec.autoDiffs = 0
				if self.spec_vca ~= nil then
					self:vcaSetState("diffLockFront", false)
					self:vcaSetState("diffLockBack", false)
				elseif FS22_EnhancedVehicle ~= nil and FS22_EnhancedVehicle.FS22_EnhancedVehicle ~= nil and FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall ~= nil then
					if self.vData.is[1] and self.vData.is[2] then
						FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_FD", 1, nil, nil, nil)
						FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_RD", 1, nil, nil, nil)
					end
				end
			else
				spec.autoDiffs = 1
			end
			self:raiseDirtyFlags(spec.dirtyFlag) 
			if g_server ~= nil then
				g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
			end
		end
	end
end -- Automatic Diffs

function CVTaddon:VarioPedalRes() -- Pedal Resolution TMS like
	local spec = self.spec_CVTaddon
	if g_client ~= nil and spec.CVTconfig ~= 8 then
		-- local spec = self.spec_CVTaddon
		-- local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
		
		if cvtaDebugCVTon then
			print("VarioN Taste gedrückt isTMSpedal: "..spec.isTMSpedal)
		end
		if self:getIsEntered() and self:getIsMotorStarted() then
			if (spec.isTMSpedal == 0) then
				if cvtaDebugCVTxOn then
					print("Erster cD")
				end
				
				CVTaddon.eventActiveV8 = true
				if cvtaDebugCVTxOn then
					print("TMS Pedal AN") -- debug
				end
			end
			if (spec.isTMSpedal == 1) then
				CVTaddon.eventActiveV8 = true
				if cvtaDebugCVTxOn then
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
				g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.isVarioTM, spec.isTMSpedal, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
			end
		end
	end
	-- DBL convert
	if spec.isTMSpedal == 0 then
		spec.forDBL_tmspedal = 0
	elseif spec.isTMSpedal == 1 then
		spec.forDBL_tmspedal = 1
	end
end

function CVTaddon:onLeaveVehicle(wasEntered)
	local spec = self.spec_CVTaddon
	if spec.CVTconfig ~= 8 then
		-- self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm
		if self.spec_vca ~= nil then
			if spec.CVTconfig == 4 or spec.CVTconfig == 5 or spec.CVTconfig == 6 then
				self.spec_vca.handbrake = true
				-- self:raiseDirtyFlags(spec.dirtyFlag)
			end
		end
	end
	-- if g_server ~= nil then
		-- g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, spec.isTMSpedal, spec.moveRpmL, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue), nil, nil, self)
	-- else
		-- g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.CVTCanStart, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, spec.isTMSpedal, spec.moveRpmL, spec.CVTconfig, spec.forDBL_warnheat, spec.forDBL_critheat, spec.forDBL_warndamage, spec.forDBL_critdamage, spec.CVTdamage, spec.HandgasPercent, spec.ClutchInputValue))
	-- end
end

function CVTaddon:getCanMotorRun(superFunc)
	if self.spec_CVTaddon ~= nil then
		local spec = self.spec_CVTaddon
		-- glow
		if spec.isVarioTM == true then
			if spec.CVTCanStart == true then
			  return superFunc(self)
			else
				return false
			end
		elseif spec.isVarioTM == false then
			return superFunc(self)
		end
	end
end

--function CVTaddon:getTorqueCurveValue_new(superFunc)
	-- if self.spec_CVTaddon ~= nil then
		-- local spec = self.spec_CVTaddon
		
		-- if spec.isVarioTM == true then
			-- local setIPMpwr = 1
			-- if spec.forDBL_ipmactive == 1 then
				-- print("ipm new")
			-- end
			-- local damage = 1 - (self.vehicle:getVehicleDamage() * (VehicleMotor.DAMAGE_TORQUE_REDUCTION*4))
			-- return self:getTorqueCurve():get(self.spec_motorized.motor:getLastModulatedMotorRpm()) * damage
			
		-- elseif spec.isVarioTM == false then
			-- return superFunc(self)
		-- end
	-- end
-- end
-- functionCVTaddon:getLastModulatedMotorRpm_new(self, superFunc)
    -- return self.lastMotorRpm
-- end
-- VehicleMotor.getLastModulatedMotorRpm = Utils.overwrittenFunction(VehicleMotor.getLastModulatedMotorRpm, realismAddon_gearbox_overrides.newGetLastModulatedMotorRpm)
-- function CVTaddon:getLastModulatedMotorRpm_new(superFunc)
	-- local spec = self.spec_CVTaddon
    -- local modulationIntensity = MathUtil.clamp((self.smoothedLoadPercentage - MODULATION_RPM_MIN_REF_LOAD) / (MODULATION_RPM_MAX_REF_LOAD - MODULATION_RPM_MIN_REF_LOAD), MODULATION_RPM_MIN_INTENSITY, 1)
    -- local modulationOffset = self.lastModulationPercentage * (MODULATION_RPM_MAX_OFFSET * modulationIntensity) * self.constantRpmCharge
	-- -- SbSh: no need rpm ducking
	-- print("test")
	-- if spec.isVarioTM == true then
		
		-- -- apply only if clutch is released since with slipping clutch the rpm is already decreased
		-- local loadChangeChargeDrop = 0
		-- if self:getClutchPedal() < 0.1 and self.minGearRatio > 0 then
			-- local rpmRange = self.maxRpm - self.minRpm
			-- local dropScale = (self.lastMotorRpm - self.minRpm) / rpmRange * 0.5
			-- loadChangeChargeDrop = self.loadPercentageChangeCharge * rpmRange * dropScale
			-- print("dropScale: "..tostring(dropScale))
		-- else
			-- self.loadPercentageChangeCharge = 
			-- print("loadChangeChargeDrop: "..tostring(loadChangeChargeDrop))
		-- end

		-- return self.lastMotorRpm + modulationOffset - loadChangeChargeDrop
	-- else
		-- return superFunc(self)
	-- end
-- end
-- VehicleMotor.getLastModulatedMotorRpm = Utils.overwrittenFunction(VehicleMotor.getLastModulatedMotorRpm, CVTaddon.getLastModulatedMotorRpm_new)


function CVTaddon:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected, vehicle)
	local spec = self.spec_CVTaddon
	local specMF = self.spec_motorized
	
	
	local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName)
	local StI = storeItem.categoryName
	-- print("CVTa ShopCat: " .. tostring(StI))
	local isTractor = StI == "TRACTORSS" or StI == "TRACTORSM" or StI == "TRACTORSL"
	local isErnter = storeItem.categoryName == "HARVESTERS" or StI == "FORAGEHARVESTERS" or StI == "POTATOVEHICLES" or StI == "BEETVEHICLES" or StI == "SUGARCANEVEHICLES" or StI == "COTTONVEHICLES" or StI == "MISCVEHICLES"
	local isLoader = storeItem.categoryName == "FRONTLOADERVEHICLES" or StI == "TELELOADERVEHICLES" or StI == "SKIDSTEERVEHICLES" or StI == "WHEELLOADERVEHICLES"
	local isPKWLKW = StI == "CARS" or StI == "TRUCKS"
	local isWoodWorker = storeItem.categoryName == "WOODHARVESTING"
	local isFFF = storeItem.categoryName == "FORKLIFTS"
	local samples = specMF.samples
	-- local currentDayTemp = self.environment.weather:getCurrentTemperatureTrend()
	-- local currentDayTemp = self:getCurrentWeatherType()
	-- local currentDayTemp = g_currentMission.environment:getCurrentWeatherType()
	-- print("motor.isMotorStarted: " .. tostring(self.spec_motorized.isMotorStarted))
	-- print("motor.getIsMotorStarted: " .. tostring(self:getIsMotorStarted()))
	spec.isVarioTM = self.spec_motorized.motor.lastManualShifterActive == false and self.spec_motorized.motor.groupType == 1 and self.spec_motorized.motor.gearType == 1 and self.spec_motorized.motor.forwardGears == nil
	if cvtaDebugCVTuOn == true then
		print("CVTa Config spec: " .. tostring(spec.CVTconfig))
		print("CVTa ############ isVarioTM: " .. tostring(spec.isVarioTM))
	end
	-- print("CVTa DayTemp: " .. tostring(currentDayTemp))
	if spec.CVTconfig == 8 or spec.CVTconfig == 0 or spec.CVTconfig == 9 or spec.CVTconfig == 10 or spec.CVTconfig == 11 then
		spec.CVTCanStart = true
	end
	
	-- #GLOWIN-TEMP-SYNC
	-- Data Sync's that will not sync by default  (base code by glowin)
	if FS22_DashboardLive ~= nil and self.spec_DashboardLive ~= nil then
		--
	else
		spec.DTadd = spec.DTadd + dt
		if self.isServer and self.getIsMotorStarted ~= nil and self:getIsMotorStarted() then
			spec.SyncMotorTemperature = specMF.motorTemperature.value
			spec.SyncFanEnabled = specMF.motorFan.enabled
			
			if spec.DTadd >= 1000 and spec.SyncMotorTemperature ~= self.spec_motorized.motorTemperature.valueSend then
				self:raiseDirtyFlags(spec.dirtyFlag)
				print("Sync: DirtyFlag")
			end
			
			if spec.SyncFanEnabled ~= spec.fanEnabledLast then
				spec.fanEnabledLast = spec.SyncFanEnabled
				self:raiseDirtyFlags(spec.dirtyFlag)
			end
		end
		if self.isClient and not self.isServer and self.getIsMotorStarted ~= nil and self:getIsMotorStarted() then
			specMF.motorTemperature.value = spec.SyncMotorTemperature
			specMF.motorFan.enabled = spec.SyncFanEnabled
		end
	end
	
	
	if spec.CVTconfig ~= 8 and spec.CVTconfig ~= 0 then
		-- print("rotInertia: ".. tostring(self.spec_motorized.motor:getRotInertia() ))
		
		-- if self.spec_motorized.motor:getRotInertia() < 0.003 then
			-- local setRIorigin = self.spec_motorized.motor.peakMotorTorque / 600
			-- self.spec_motorized.motor:setRotInertia(setRIorigin)
			-- -- print("setRIorigin: ".. tostring(setRIorigin))
		-- end
		
		-- if not self.spec_RealisticDamageSystem.EngineDied then
		-- -- Secure starting engine
		if self.getIsEntered ~= nil and self:getIsEntered() and spec.CVTconfig ~= 8 and spec.CVTconfig ~= 0 and spec.CVTconfig ~= 9 and spec.CVTconfig ~= 10 and spec.CVTconfig ~= 11 then
			if cvtaDebugCVTcanStartOn then print("CVTa CanStart: " .. tostring(spec.CVTCanStart)) end
			if self.spec_cpAIWorker ~= nil then -- CP
				if self.rootVehicle:getIsCpActive() == false then
					if not self:getIsMotorStarted() then
						if spec.isVarioTM == true then
							if spec.CVTconfig ~= 7 and spec.CVTconfig ~= 8 then
								if spec.ClutchInputValue < 0.6 or spec.HandgasPercent > 0.05 then
								
									if spec.ClutchInputValue < 0.6 then
										spec.CVTCanStart = false
										if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
											if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
												g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needClutch2start"), 2048)
											end
										end
										if cvtaDebugCVTcanStartOn then print("CVTa Clutch/Config [A]: " .. tostring(spec.ClutchInputValue .."/" .. spec.CVTconfig)) end
									end
									
									if spec.HandgasPercent > 0.05 then
										spec.CVTCanStart = false
										if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
											if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
												g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needNoHG2start"), 4096)
											end
										end
										if cvtaDebugCVTcanStartOn then print("CVTa Hgas [E]: " .. tostring(spec.HandgasPercent)) end
									end
									
								elseif spec.ClutchInputValue >= 0.6 or spec.HandgasPercent <= 0.05 then
									if spec.ClutchInputValue >= 0.6 then
										spec.CVTCanStart = true
										if cvtaDebugCVTcanStartOn then print("CVTa Clutch [B]: " .. tostring(spec.ClutchInputValue)) end
									end
									if spec.HandgasPercent <= 0.05 then
										spec.CVTCanStart = true
										if cvtaDebugCVTcanStartOn then print("CVTa Hgas [F]: " .. tostring(spec.HandgasPercent)) end
									else
										spec.CVTCanStart = false
									end
								end
							elseif spec.CVTconfig == 7 then
								-- if self.spec_motorized.motor.vehicle.wheelsUtilSmoothedBrakePedal == 1 or self.spec_motorized.motor.vehicle.wheelsUtilSmoothedBrakePedal <= 0.1 then
								if self.spec_vca ~= nil and self.spec_vca.handbrake ~= nil then
									if self.spec_vca.handbrake == false or spec.HandgasPercent > 0.05 then
										if self.spec_vca.handbrake == false then
											spec.CVTCanStart = false
											if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
												if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
													g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needBrake2start"), 3072)
												end
											end
											if cvtaDebugCVTcanStartOn then print("CVTa HB [C]: " .. tostring(self.spec_vca.handbrake)) end
										end
										if spec.HandgasPercent > 0.05 then
											spec.CVTCanStart = false
											if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
												if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
													g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needNoHG2start"), 4096)
												end
											end
											if cvtaDebugCVTcanStartOn then print("CVTa Hgas [E]: " .. tostring(spec.HandgasPercent)) end
										end
										
									elseif self.spec_vca.handbrake == true or spec.HandgasPercent <= 0.05 then
										if self.spec_vca.handbrake == true then
											spec.CVTCanStart = true
										end
										if cvtaDebugCVTcanStartOn then print("CVTa HB [D]: " .. tostring(self.spec_vca.handbrake)) end
										
										if spec.HandgasPercent <= 0.05 then
											spec.CVTCanStart = true
											if cvtaDebugCVTcanStartOn then print("CVTa Hgas [F]: " .. tostring(spec.HandgasPercent)) end
										else
											spec.CVTCanStart = false
										end
									end
								end
							end
						end
					end
				elseif self.rootVehicle:getIsCpActive() == true then
					-- print("CVTa: CP aktiv")
					spec.CVTCanStart = true
				end
			elseif not self.spec_cpAIWorker and not FS22_AutoDrive then
				if not self:getIsMotorStarted() then
					if spec.isVarioTM == true then
						if spec.CVTconfig ~= 7 and spec.CVTconfig ~= 8 then
							if spec.ClutchInputValue < 0.6 or spec.HandgasPercent > 0.05 then
							
								if spec.ClutchInputValue < 0.6 then
									spec.CVTCanStart = false
									if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
										if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
											g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needClutch2start"), 2048)
										end
									end
									if cvtaDebugCVTcanStartOn then print("CVTa Clutch/Config [A]: " .. tostring(spec.ClutchInputValue .."/" .. spec.CVTconfig)) end
								end
								
								if spec.HandgasPercent > 0.05 then
									spec.CVTCanStart = false
									if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
										if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
											g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needNoHG2start"), 4096)
										end
									end
									if cvtaDebugCVTcanStartOn then print("CVTa Hgas [E]: " .. tostring(spec.HandgasPercent)) end
								end
								
							elseif spec.ClutchInputValue >= 0.6 or spec.HandgasPercent <= 0.05 then
								if spec.ClutchInputValue >= 0.6 then
									spec.CVTCanStart = true
									if cvtaDebugCVTcanStartOn then print("CVTa Clutch [B]: " .. tostring(spec.ClutchInputValue)) end
								end
								if spec.HandgasPercent <= 0.05 then
									spec.CVTCanStart = true
									if cvtaDebugCVTcanStartOn then print("CVTa Hgas [F]: " .. tostring(spec.HandgasPercent)) end
								else
									spec.CVTCanStart = false
								end
							end
						elseif spec.CVTconfig == 7 then
							-- if self.spec_motorized.motor.vehicle.wheelsUtilSmoothedBrakePedal == 1 or self.spec_motorized.motor.vehicle.wheelsUtilSmoothedBrakePedal <= 0.1 then
							if self.spec_vca ~= nil and self.spec_vca.handbrake ~= nil then
								if self.spec_vca.handbrake == false or spec.HandgasPercent > 0.05 then
									if self.spec_vca.handbrake == false then
										spec.CVTCanStart = false
										if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
											if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
												g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needBrake2start"), 3072)
											end
										end
										if cvtaDebugCVTcanStartOn then print("CVTa HB [C]: " .. tostring(self.spec_vca.handbrake)) end
									end
									if spec.HandgasPercent > 0.05 then
										spec.CVTCanStart = false
										if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
											if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
												g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needNoHG2start"), 4096)
											end
										end
										if cvtaDebugCVTcanStartOn then print("CVTa Hgas [E]: " .. tostring(spec.HandgasPercent)) end
									end
									
								elseif self.spec_vca.handbrake == true or spec.HandgasPercent <= 0.05 then
									if self.spec_vca.handbrake == true then
										spec.CVTCanStart = true
									end
									if cvtaDebugCVTcanStartOn then print("CVTa HB [D]: " .. tostring(self.spec_vca.handbrake)) end
									
									if spec.HandgasPercent <= 0.05 then
										spec.CVTCanStart = true
										if cvtaDebugCVTcanStartOn then print("CVTa Hgas [F]: " .. tostring(spec.HandgasPercent)) end
									else
										spec.CVTCanStart = false
									end
								end
							end
						end
					end
				end
			end -- cp
				
			if FS22_AutoDrive ~= nil and FS22_AutoDrive.AutoDrive ~= nil then -- AD
				if self.ad.stateModule:isActive() == false and not self.spec_cpAIWorker then
					if not self:getIsMotorStarted() then
						if spec.isVarioTM == true then
							if spec.CVTconfig ~= 7 and spec.CVTconfig ~= 8 then
								if spec.ClutchInputValue < 0.6 or spec.HandgasPercent > 0.05 then
								
									if spec.ClutchInputValue < 0.6 then
										spec.CVTCanStart = false
										if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
											if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
												g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needClutch2start"), 2048)
											end
										end
										if cvtaDebugCVTcanStartOn then print("CVTa Clutch/Config [A]: " .. tostring(spec.ClutchInputValue .."/" .. spec.CVTconfig)) end
									end
									
									if spec.HandgasPercent > 0.05 then
										spec.CVTCanStart = false
										if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
											if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
												g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needNoHG2start"), 4096)
											end
										end
										if cvtaDebugCVTcanStartOn then print("CVTa Hgas [E]: " .. tostring(spec.HandgasPercent)) end
									end
									
								elseif spec.ClutchInputValue >= 0.6 or spec.HandgasPercent <= 0.05 then
									if spec.ClutchInputValue >= 0.6 then
										spec.CVTCanStart = true
										if cvtaDebugCVTcanStartOn then print("CVTa Clutch [B]: " .. tostring(spec.ClutchInputValue)) end
									end
									if spec.HandgasPercent <= 0.05 then
										spec.CVTCanStart = true
										if cvtaDebugCVTcanStartOn then print("CVTa Hgas [F]: " .. tostring(spec.HandgasPercent)) end
									else
										spec.CVTCanStart = false
									end
								end
							elseif spec.CVTconfig == 7 then
								-- if self.spec_motorized.motor.vehicle.wheelsUtilSmoothedBrakePedal == 1 or self.spec_motorized.motor.vehicle.wheelsUtilSmoothedBrakePedal <= 0.1 then
								if self.spec_vca ~= nil and self.spec_vca.handbrake ~= nil then
									if self.spec_vca.handbrake == false or spec.HandgasPercent > 0.05 then
										if self.spec_vca.handbrake == false then
											spec.CVTCanStart = false
											if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
												if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
													g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needBrake2start"), 3072)
												end
											end
											if cvtaDebugCVTcanStartOn then print("CVTa HB [C]: " .. tostring(self.spec_vca.handbrake)) end
										end
										if spec.HandgasPercent > 0.05 then
											spec.CVTCanStart = false
											if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
												if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
													g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needNoHG2start"), 4096)
												end
											end
											if cvtaDebugCVTcanStartOn then print("CVTa Hgas [E]: " .. tostring(spec.HandgasPercent)) end
										end
										
									elseif self.spec_vca.handbrake == true or spec.HandgasPercent <= 0.05 then
										if self.spec_vca.handbrake == true then
											spec.CVTCanStart = true
										end
										if cvtaDebugCVTcanStartOn then print("CVTa HB [D]: " .. tostring(self.spec_vca.handbrake)) end
										
										if spec.HandgasPercent <= 0.05 then
											spec.CVTCanStart = true
											if cvtaDebugCVTcanStartOn then print("CVTa Hgas [F]: " .. tostring(spec.HandgasPercent)) end
										else
											spec.CVTCanStart = false
										end
									end
								end
							end
						end
					end
				elseif self.ad.stateModule:isActive() == true then
					-- print("CVTa: AD active")
					spec.CVTCanStart = true
				end
			elseif not self.spec_cpAIWorker then -- ad
				if not self:getIsMotorStarted() then
					if spec.isVarioTM == true then
						if spec.CVTconfig ~= 7 and spec.CVTconfig ~= 8 then
							if spec.ClutchInputValue < 0.6 or spec.HandgasPercent > 0.05 then
							
								if spec.ClutchInputValue < 0.6 then
									spec.CVTCanStart = false
									if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
										if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
											g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needClutch2start"), 2048)
										end
									end
									if cvtaDebugCVTcanStartOn then print("CVTa Clutch/Config [A]: " .. tostring(spec.ClutchInputValue .."/" .. spec.CVTconfig)) end
								end
								
								if spec.HandgasPercent > 0.05 then
									spec.CVTCanStart = false
									if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
										if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
											g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needNoHG2start"), 4096)
										end
									end
									if cvtaDebugCVTcanStartOn then print("CVTa Hgas [E]: " .. tostring(spec.HandgasPercent)) end
								end
								
							elseif spec.ClutchInputValue >= 0.6 or spec.HandgasPercent <= 0.05 then
								if spec.ClutchInputValue >= 0.6 then
									spec.CVTCanStart = true
									if cvtaDebugCVTcanStartOn then print("CVTa Clutch [B]: " .. tostring(spec.ClutchInputValue)) end
								end
								if spec.HandgasPercent <= 0.05 then
									spec.CVTCanStart = true
									if cvtaDebugCVTcanStartOn then print("CVTa Hgas [F]: " .. tostring(spec.HandgasPercent)) end
								else
									spec.CVTCanStart = false
								end
							end
						elseif spec.CVTconfig == 7 then
							-- if self.spec_motorized.motor.vehicle.wheelsUtilSmoothedBrakePedal == 1 or self.spec_motorized.motor.vehicle.wheelsUtilSmoothedBrakePedal <= 0.1 then
							if self.spec_vca ~= nil and self.spec_vca.handbrake ~= nil then
								if self.spec_vca.handbrake == false or spec.HandgasPercent > 0.05 then
									if self.spec_vca.handbrake == false then
										spec.CVTCanStart = false
										if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
											if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
												g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needBrake2start"), 3072)
											end
										end
										if cvtaDebugCVTcanStartOn then print("CVTa HB [C]: " .. tostring(self.spec_vca.handbrake)) end
									end
									if spec.HandgasPercent > 0.05 then
										spec.CVTCanStart = false
										if g_client ~= nil and isActiveForInputIgnoreSelection and self:getCanMotorRun() == false then
											if not self.spec_RealisticDamageSystemEngineDied.EngineDied then
												g_currentMission:showBlinkingWarning(g_i18n:getText("txt_needNoHG2start"), 4096)
											end
										end
										if cvtaDebugCVTcanStartOn then print("CVTa Hgas [E]: " .. tostring(spec.HandgasPercent)) end
									end
									
								elseif self.spec_vca.handbrake == true or spec.HandgasPercent <= 0.05 then
									if self.spec_vca.handbrake == true then
										spec.CVTCanStart = true
									end
									if cvtaDebugCVTcanStartOn then print("CVTa HB [D]: " .. tostring(self.spec_vca.handbrake)) end
									
									if spec.HandgasPercent <= 0.05 then
										spec.CVTCanStart = true
										if cvtaDebugCVTcanStartOn then print("CVTa Hgas [F]: " .. tostring(spec.HandgasPercent)) end
									else
										spec.CVTCanStart = false
									end
								end
							end
						end
					end
				end
			end -- secure AD
		end
		
		local changeFlag = false
		local motor = nil
		-- local lowerfind = Vehicle:getIsLowered(defaultIsLowered)
		-- print("CVTa:started " .. tostring(self.spec_motorized.isMotorStarted))
		-- print("CVTa:motorStartTime " .. tostring(self.spec_motorized.motorStartTime))
		-- print("CVTa:isMotorRunning " .. tostring(self.spec_motorized.isMotorRunning))
		-- print("CVTa:SmoothedBrakePedal " .. tostring(self.spec_motorized.motor.vehicle.wheelsUtilSmoothedBrakePedal))
		-- print("CVTa:axisBrake " .. tostring(self.spec_drivable.lastInputValues.axisBrake))
		-- print("CVTa:lastAcceleratorPedal " .. tostring(self.spec_motorized.motor.lastAcceleratorPedal))
		
		
		-- Anbaugeräte ermitteln und prüfen ob abgesenkt Front/Back
		local moveDownFront = false
		local moveDownBack = false
		local object;
		if #self.spec_attacherJoints.attachedImplements ~= nil then
			for attachedImplement = 1, #self.spec_attacherJoints.attachedImplements do
				if self.spec_attacherJoints.attachedImplements[attachedImplement].object ~= nil then
					object = self.spec_attacherJoints.attachedImplements[attachedImplement].object;
				end
				local object_specAttachable = object.spec_attachable
				if object_specAttachable.attacherVehicle ~= nil then
					local attacherJointVehicleSpec = object_specAttachable.attacherVehicle.spec_attacherJoints;
					local implementIndex = object_specAttachable.attacherVehicle:getImplementIndexByObject(object);
					local implement = attacherJointVehicleSpec.attachedImplements[implementIndex];
					local jointDescIndex = implement.jointDescIndex;
					local jointDesc = attacherJointVehicleSpec.attacherJoints[jointDescIndex];
					
					if jointDesc.bottomArm ~= nil then
						-- if math.abs(jointDesc.bottomArm.zScale) == 1 then
							-- spec.impIsLowered = object:getIsImplementChainLowered();
						-- end
						if jointDesc.bottomArm.zScale == 1 then
							moveDownFront = object:getIsImplementChainLowered();
						elseif jointDesc.bottomArm.zScale == -1 then
							moveDownBack = object:getIsImplementChainLowered();
						end
					end
					if moveDownBack == true or moveDownFront == true then
						spec.impIsLowered = true
					else
						spec.impIsLowered = false
					end
				else
					spec.impIsLowered = false
				end
			end
		else
			spec.impIsLowered = false
		end
		if self:getTotalMass() - self:getTotalMass(true) == 0 then
			spec.impIsLowered = false
		end
		-- ### war vorher an dieser Stelle ###
		
		
		-- local moveRpmL = 0
		
		-- FRONTLADER HYDRAULIK RPM - make wheelloader hydraulic assign to rpm
		-- if spec.CVTconfig == 7 or isLoader or isWoodWorker or isTractor then
			local i = 0
			local RPMforHydraulics = 1
			if spec.CVTconfig == 10 then
				RPMforHydraulics = math.min( math.max(spec.HandgasPercent, 0.05), 0.8)
			else
				RPMforHydraulics = math.min( math.max((self.spec_motorized.motor:getLastModulatedMotorRpm()/self.spec_motorized.motor:getMaxRpm())*0.7, 0.05), 0.8)
			end
			-- local KGforHydraulics = math.min( math.max((self.spec_motorized.motor:getLastModulatedMotorRpm()/self.spec_motorized.motor:getMaxRpm())*0.7, 0.05), 0.8)
			if self:getTotalMass() - self:getTotalMass(true) > 1.2 then
				RPMforHydraulics = RPMforHydraulics * 0.5
				-- RPMforHydraulics = RPMforHydraulics * (  1-(self:getTotalMass() - self:getTotalMass(true))/self:getTotalMass(true)  )
			end
			-- local RPMforHydraulics = self.spec_motorized.motor.lastRealMotorRpm/self.spec_motorized.motor:getMaxRpm()
			-- print("CVTa self.spec_motorized.motor:getLastModulatedMotorRpm(): " .. self.spec_motorized.motor:getLastModulatedMotorRpm())
			-- print("CVTa self.spec_motorized.motor:getMaxRpm(): " .. self.spec_motorized.motor:getMaxRpm())
			-- print("CVTa self.spec_motorized.motor.lastMotorRpm: " .. self.spec_motorized.motor.lastMotorRpm)
			-- print("CVTa self.spec_motorized.motor.equalizedMotorRpm: " .. self.spec_motorized.motor.equalizedMotorRpm)
			-- print("CVTa Lowered: " .. tostring(spec.impIsLowered))
			if spec.CVTconfig ~= 10 and spec.CVTconfig ~= 8 then
			
				for i=1, #self.spec_cylindered.movingTools do
					local tool = self.spec_cylindered.movingTools[i]
					local isSelectedGroup = tool.controlGroupIndex == 0 or tool.controlGroupIndex == self.spec_cylindered.currentControlGroupIndex
					local easyArmControlActive = false
					if self.spec_cylindered.easyArmControl ~= nil then
						easyArmControlActive = self.spec_cylindered.easyArmControl.state
					end
					local canBeControlled = (easyArmControlActive and tool.easyArmControlActive) or (not easyArmControlActive and not tool.isEasyControlTarget)
					local tool = self.spec_cylindered.movingTools[i]
					local rotSpeed = 0
					local transSpeed = 0
					local animSpeed = 0
					local move = self:getMovingToolMoveValue(tool)
					-- self:getTotalMass() - self:getTotalMass(true)
					-- print("self:getTotalMass(): " .. self:getTotalMass() )
					-- print("att: " .. self:getTotalMass() - self:getTotalMass(true) )
					-- print("self:getTotalMass(true): " .. self:getTotalMass(true) )
					-- spec.moveRpmL = 0
					if math.abs(move) > 0 then
						if move < 0 then
							move = move * 0.8
						end
						
						if move < -0.5 then
							self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm - (math.abs(move)*10)
							self.spec_motorized.motor.smoothedLoadPercentage = math.min(self.spec_motorized.motor.smoothedLoadPercentage + (math.abs(move)), .9)
							if self.spec_motorized.motor.lastMotorRpm < self.spec_motorized.motor.minRpm * 0.89 and self.spec_motorized.motor.smoothedLoadPercentage > 0.8 and self.spec_motorized.motorTemperature.value < 50 then
								move = 0
								RPMforHydraulics = 0
								-- Motor abwürgen
								self:stopMotor();
								-- break;
								move = 0
								self:startMotor(true)
								if self.spec_vca ~= nil and self.spec_vca.handbrake ~= nil then
									self.spec_vca.handbrake = true
									-- self.spec_vca.handbrake = false
								end
								-- self:stopMotor()
								-- tool.rotSpeed = movingBU
							end
						elseif move < 0  and move >= -0.5 then
							self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm - (math.abs(move)*10)
							self.spec_motorized.motor.smoothedLoadPercentage = math.min(self.spec_motorized.motor.smoothedLoadPercentage + (math.abs(move)), .9)
						elseif move > 0 then
							self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm - (math.abs(move)*5)
							self.spec_motorized.motor.smoothedLoadPercentage = math.min(self.spec_motorized.motor.smoothedLoadPercentage + (math.abs(move)), .4)
						end
						
						
						-- print("move: " .. move) -- 0 - 1
						tool.externalMove = 0
						-- spec.moveRpmL = 1

						if tool.rotSpeed ~= nil then
							-- rotSpeed = move*tool.rotSpeed * (MathUtil.clamp(RPMforHydraulics, 0.01, 0.7))
							rotSpeed = move*tool.rotSpeed * RPMforHydraulics
							-- rotSpeed = move*tool.rotSpeed * (math.max(spec.HandgasPercent, 0.1))
							if tool.rotAcceleration ~= nil and math.abs(rotSpeed - tool.lastRotSpeed) >= tool.rotAcceleration*dt then
								if rotSpeed > tool.lastRotSpeed then
									rotSpeed = (tool.lastRotSpeed*0.8 ) + tool.rotAcceleration*dt
								else
									rotSpeed = (tool.lastRotSpeed ) - tool.rotAcceleration*dt
								end
							end
						end
						if tool.transSpeed ~= nil then
							-- transSpeed = move*tool.transSpeed * (MathUtil.clamp(RPMforHydraulics, 0.01, 0.7))
							transSpeed = move*tool.transSpeed * RPMforHydraulics
							if tool.transAcceleration ~= nil and math.abs(transSpeed - tool.lastTransSpeed) >= tool.transAcceleration*dt then
								if transSpeed > tool.lastTransSpeed then
									transSpeed = (tool.lastTransSpeed*0.8 ) + tool.transAcceleration*dt
								else
									transSpeed = (tool.lastTransSpeed ) - tool.transAcceleration*dt
								end
							end
						end
						if tool.animSpeed ~= nil then
							-- animSpeed = move*tool.animSpeed * (MathUtil.clamp(RPMforHydraulics, 0.01, 0.7))
							animSpeed = move*tool.animSpeed * RPMforHydraulics
							if tool.animAcceleration ~= nil and math.abs(animSpeed - tool.lastAnimSpeed) >= tool.animAcceleration*dt then
								if animSpeed > tool.lastAnimSpeed then
									animSpeed = (tool.lastAnimSpeed*0.8 ) + tool.animAcceleration*dt
								else
									animSpeed = (tool.lastAnimSpeed) - tool.animAcceleration*dt
								end
							end
						end
						-- set rpm here
						
						-- spec.moveRpmL = 1
					else
						if tool.rotAcceleration ~= nil then
							if tool.lastRotSpeed < 0 then
								rotSpeed = math.min(tool.lastRotSpeed + tool.rotAcceleration*dt, 0)
							else
								rotSpeed = math.max(tool.lastRotSpeed - tool.rotAcceleration*dt, 0)
							end
						end
						if tool.transAcceleration ~= nil then
							if tool.lastTransSpeed < 0 then
								transSpeed = math.min(tool.lastTransSpeed + tool.transAcceleration*dt, 0)
							else
								transSpeed = math.max(tool.lastTransSpeed - tool.transAcceleration*dt, 0)
							end
						end
						if tool.animAcceleration ~= nil then
							if tool.lastAnimSpeed < 0 then
								animSpeed = math.min(tool.lastAnimSpeed + tool.animAcceleration*dt, 0)
							else
								animSpeed = math.max(tool.lastAnimSpeed - tool.animAcceleration*dt, 0)
							end
						end
					end
					
					
					
					local changed = false
					if rotSpeed ~= nil and rotSpeed ~= 0 then
						changed = changed or Cylindered.setToolRotation(self, tool, rotSpeed, dt)
					else
						tool.lastRotSpeed = 0
					end
					if transSpeed ~= nil and transSpeed ~= 0 then
						changed = changed or Cylindered.setToolTranslation(self, tool, transSpeed, dt)
					else
						tool.lastTransSpeed = 0
					end
					if animSpeed ~= nil and animSpeed ~= 0 then
						changed = changed or Cylindered.setToolAnimation(self, tool, animSpeed, dt)
					else
						tool.lastAnimSpeed = 0
					end
					for _, dependentTool in pairs(tool.dependentMovingTools) do
						if dependentTool.speedScale ~= nil then
							local isAllowed = true
							if dependentTool.requiresMovement then
								if not changed then
									isAllowed = false
								end
							end

							if isAllowed then
								dependentTool.movingTool.externalMove = dependentTool.speedScale * tool.move
							end
						end
						Cylindered.updateRotationBasedLimits(self, tool, dependentTool)
						self:updateDependentToolLimits(tool, dependentTool)
					end
				end 
			end
		-- end -- FRONTLADER HYDRAULIK RPM END
		
		
		
		-- BEGIN OF THE MAIN SCRIPT	
			-- spec.isVarioTM = self.spec_motorized.motor.lastManualShifterActive == false and self.spec_motorized.motor.groupType == 1 and self.spec_motorized.motor.gearType == 1 and self.spec_motorized.motor.forwardGears == nil
			-- print("CVTa Kat: " .. StI)
			-- local currentSpeedDrv = tonumber(string.format("%.2f", self:getLastSpeed()))
			-- spec.HydrostatPedal = math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
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
						-- self.spec_vca.brakeForce = 1
						-- self.spec_vca.idleThrottle = false
						-- g_currentMission:showBlinkingWarning(g_i18n:getText("txt_vcaInfo"), 1024)
						if vcaInfoUnread and g_currentMission.isMissionStarted and self:getIsEntered() then
							g_gui:showInfoDialog({
							titel = "titel",
							text = g_i18n:getText("txt_vcaInfo", "vcaInfo"),
							})
							vcaInfoUnread = false
						end
					end

				-- AUTO-DIFFS: enable & disable VCA AWD and difflocks automaticly by speed and steering angle
					-- Vehicle Control Addon
					if spec.autoDiffs == 1 and self.spec_vca ~= nil then
						self:vcaSetState("diffManual", true)
					end
					if spec.vOne == 2 and spec.autoDiffs == 1 then
						-- classic
						if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 or spec.CVTconfig == 7 or spec.CVTconfig == 11 then
							if self.spec_vca ~= nil then
								-- awd
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
						end
					end
					if spec.vOne >= 1 then
						-- modern
						if spec.CVTconfig == 4 or spec.CVTconfig == 5 or spec.CVTconfig == 6 then
							if self.spec_vca ~= nil then
								-- awd
								if self:getLastSpeed() >= 16 then
									self:vcaSetState("diffLockAWD", false)
								elseif self:getLastSpeed() <= 14 then
									self:vcaSetState("diffLockAWD", true)
								end
								if self:getLastSpeed() < 12 and spec.autoDiffs == 1 then
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
								elseif self:getLastSpeed() > 12 then
									self:vcaSetState("diffLockFront", false)
									self:vcaSetState("diffLockBack", false)
								end
							end
						end
					end
				end
				
				-- Enhanced Vehicle 
				if FS22_EnhancedVehicle ~= nil and FS22_EnhancedVehicle.FS22_EnhancedVehicle ~= nil and FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall ~= nil then 
					-- print("CVTa: EV found")
					if spec.vOne == 2 and spec.autoDiffs == 1 then
						-- classic
						if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 then
							if FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall ~= nil then
								-- awd
								if self:getLastSpeed() > 19 and self.vData.is[3] == 1 then
									FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_DM", 1, nil, nil, nil)
								elseif self:getLastSpeed() < 16 and self.vData.is[3] == 0 then
									FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_DM", 1, nil, nil, nil)
								end
								-- diff front
								if self.vData.is[1] and math.abs(self.rotatedTime) > 0.29 then
									FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_FD", 1, nil, nil, nil)
								elseif not self.vData.is[1] and math.abs(self.rotatedTime) < 0.15 then
									FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_FD", 1, nil, nil, nil)
								end
								-- diff rear
								if self.vData.is[2] and math.abs(self.rotatedTime) > 0.18 then
									FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_RD", 1, nil, nil, nil)
								elseif not self.vData.is[2] and math.abs(self.rotatedTime) < 0.11 then
									FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_RD", 1, nil, nil, nil)
									-- self.vData.is[2] = true
								end
							end
						end
					end
					if spec.vOne >= 1 then
						-- modern
						if spec.CVTconfig == 4 or spec.CVTconfig == 5 or spec.CVTconfig == 6 then
							if FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall ~= nil then
								-- awd
								if self:getLastSpeed() >= 16 and self.vData.is[3] == 1 then
									FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_DM", 1, nil, nil, nil)
								elseif self:getLastSpeed() <= 14 and self.vData.is[3] == 0 then
									FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_DM", 1, nil, nil, nil)
								end
								if self:getLastSpeed() < 12 and spec.autoDiffs == 1 then
									-- diff front
									if self.vData.is[1] and math.abs(self.rotatedTime) > 0.29 then
										FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_FD", 1, nil, nil, nil)
									elseif not self.vData.is[1] and math.abs(self.rotatedTime) < 0.15 then
										FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_FD", 1, nil, nil, nil)
									end
									-- diff rear
									if self.vData.is[2] and math.abs(self.rotatedTime) > 0.18 then
										FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_RD", 1, nil, nil, nil)
									elseif not self.vData.is[2] and math.abs(self.rotatedTime) < 0.11 then
										FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_RD", 1, nil, nil, nil)
									end
								elseif self:getLastSpeed() >= 12 and self.vData.is[1] and self.vData.is[2] then
									FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_FD", 1, nil, nil, nil)
									FS22_EnhancedVehicle.FS22_EnhancedVehicle.onActionCall(self, "FS22_EnhancedVehicle_RD", 1, nil, nil, nil)
								end
							end
						end
					end
				end
				if FS22_LessMotorBrakeForce ~= nil then 
					if printLMBF == false then
						print("CVT-Addon: FS22_LessMotorBrakeForce found, please uninstall the FS22_LessMotorBrakeForce mod !")
						printLMBF = true
					end
				end

				-- get maxForce sum of all tools attached
				local maxForce = 0
				--local vehicles = self:getChildVehicles()
				--[[for _, vehicle in ipairs(vehicles) do
					if vehicle ~= self then
						if vehicle.spec_powerConsumer ~= nil then
							if vehicle.spec_powerConsumer.maxForce ~= nil then
								local multiplier = vehicle:getPowerMultiplier()
								if multiplier ~= 0 then
									maxForce = maxForce + vehicle.spec_powerConsumer.maxForce
									-- maxForce2 = self.spec_powerConsumer.getTotalConsumedPtoTorque(self.vehicle, nil, nil, true)
									-- print("CVTa maxForce: " .. maxForce )
									-- print("CVTa getTotalConsumedPtoTorque: " .. maxForce2 )
									-- print("CVTa vehicle:getPowerMultiplier(): " .. vehicle:getPowerMultiplier() )
									-- print("CVTa multiplier: " .. multiplier )
									-- print("CVTa vehicle.spec_powerConsumer.maxForce: " .. vehicle.spec_powerConsumer.maxForce )
									-- print("CVTa vehicle.spec_powerConsumer.neededPtoTorque: " .. vehicle.spec_powerConsumer.neededPtoTorque )
									-- self.spec_motorized.motor.requiredMotorPower
								end
							end
						end
					end
				end]]
				
				
		-- Boost function e.g. IPM		The exact multiplier number Giants uses is 0.00414, (rounded) =1hp. So target hp x 0.00414 = torque scale value #.
				if (self.spec_motorized.motor.motorExternalTorque * self.spec_motorized.motor.lastMotorRpm * math.pi / 30) == 0 or self:getLastSpeed() < 15 then
					peakMotorTorqueOrigin = self.spec_motorized.motor.peakMotorTorque
				end
				if spec.CVTconfig == 2 or spec.CVTconfig == 3 or spec.CVTconfig == 5 or spec.CVTconfig == 6 then
																		-- 1800 * 0.43 * pi / 30   = 81.053
																		-- 81.053 / pi * 30 * 1800 = 0.42999
					if (self.spec_motorized.motor.motorExternalTorque * self.spec_motorized.motor.lastMotorRpm * math.pi / 30) ~= 0 or self:getLastSpeed() >= 14 then
						-- self.spec_motorized.motor.peakMotorPower = self.spec_motorized.motor.peakMotorPower + 14.7  -- * 1.1337 (110kw) 	-- 14.7 kw = 20 ps
						-- self.spec_motorized.motor.ptoMotorRpmRatio = self.spec_motorized.motor.ptoMotorRpmRatio * 0.5
						
						-- self.spec_motorized.motor.peakMotorPower = self.spec_motorized.motor.peakMotorPower * 100
						-- print("CVTa: IPM: " .. (25 / math.pi * 30 / self.spec_motorized.motor.lastMotorRpm))
						-- self:setPtoMotorRpmRatio(2)
						-- self.spec_motorized.motor.ptoMotorRpmRatio = 6
						if spec.CVTconfig == 2 then
							if cvtaDebugCVTxOn then print("CVTa: IPM c15") end
							self.spec_motorized.motor.motorRotationAccelerationLimit = math.max(self.spec_motorized.motor.motorRotationAccelerationLimit *1.25 , 2)
							self.spec_motorized.motor.smoothedLoadPercentage = self.spec_motorized.motor.smoothedLoadPercentage * 0.85
							self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 0.85
							spec.forDBL_ipmactive = 1
						elseif spec.CVTconfig == 3 then
							if cvtaDebugCVTxOn then print("CVTa: IPM c25") end
							self.spec_motorized.motor.motorRotationAccelerationLimit = math.max(self.spec_motorized.motor.motorRotationAccelerationLimit *1.25 , 2)
							self.spec_motorized.motor.smoothedLoadPercentage = self.spec_motorized.motor.smoothedLoadPercentage * 0.75
							self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 0.75
							spec.forDBL_ipmactive = 1
						elseif spec.CVTconfig == 5 then
							if cvtaDebugCVTxOn then print("CVTa: IPM m15") end
							self.spec_motorized.motor.motorRotationAccelerationLimit = math.max(self.spec_motorized.motor.motorRotationAccelerationLimit *1.25 , 2)
							self.spec_motorized.motor.smoothedLoadPercentage = self.spec_motorized.motor.smoothedLoadPercentage * 0.83
							self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 0.83
							spec.forDBL_ipmactive = 1
						elseif spec.CVTconfig == 6 then
							if cvtaDebugCVTxOn then print("CVTa: IPM m27") end
							self.spec_motorized.motor.motorRotationAccelerationLimit = math.max(self.spec_motorized.motor.motorRotationAccelerationLimit *1.25 , 2)
							self.spec_motorized.motor.smoothedLoadPercentage = self.spec_motorized.motor.smoothedLoadPercentage * 0.73
							self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 0.83
							spec.forDBL_ipmactive = 1
							-- self.spec_motorized.motor.externalTorqueVirtualMultiplicator = self.spec_motorized.motor.externalTorqueVirtualMultiplicator * 4
							-- self.spec_motorized.motor.motorExternalTorque = self.spec_motorized.motor.motorExternalTorque * 0.27
							-- self.spec_motorized.motor.lastMotorAppliedTorque = self.spec_motorized.motor.lastMotorAppliedTorque * 1.27
							-- self.spec_motorized.motor.differentialRotSpeed = self.spec_motorized.motor.differentialRotSpeed * 1.27
							-- self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 0.27
							-- self.spec_motorized.motor.lastMotorAvailableTorque = self.spec_motorized.motor.lastMotorAvailableTorque * 0.27
							-- self.spec_motorized.motor.smoothedLoadPercentage = self.spec_motorized.motor.smoothedLoadPercentage * 0.73
							-- self.spec_motorized.motor.motorAvailableTorque = self.spec_motorized.motor.motorAvailableTorque * 1.27
							-- self.spec_motorized.motor.differentialRotAcceleration = self.spec_motorized.motor.differentialRotAcceleration * 1.73
							-- self.spec_motorized.motor.peakMotorTorque = peakMotorTorqueOrigin + 0.4
							-- self.rotatedTime = 0.7
							-- self:updateMotorProperties()
						end
					else
						-- self.spec_motorized.motor.ptoMotorRpmRatio = 4
						-- self.spec_motorized.motor.peakMotorTorque = peakMotorTorqueOrigin
						spec.forDBL_ipmactive = 0
					end
				end

		-- ODB V
		-- self.spec_RealisticDamageSystem.CVTRepairActive
		-- self.spec_DashboardLive
				if cvtaDebugCVTon then
					-- print("getCanMotorRun(): " .. tostring(self:getCanMotorRun()))
				end
				if not self:getIsMotorStarted() then
					if self.getIsEntered ~= nil and self:getIsEntered() then
					-- Verschleiß Info
						if spec.CVTdamage > 50 and self:getDamageAmount() >= 0.4 then
							if g_client ~= nil and isActiveForInputIgnoreSelection then -- Bitte reparieren, der Verschleiß des Triebsatzes liegt bei über 
								g_currentMission:showBlinkingWarning(g_i18n:getText("damageWT").. math.floor(math.min(spec.CVTdamage,95)) .." %", 2048)
							end
						elseif spec.CVTdamage > 0 and self:getDamageAmount() == 0 then
							if self.spec_RealisticDamageSystem == nil then
								spec.CVTdamage = 0
							end
						end
						spec.CVTdamage = math.min(spec.CVTdamage,100)
						if sbshDebugWT then
							print("CVTa Verschleiß : ".. spec.CVTdamage)
							print("Fahrzeug Schaden: ".. self:getDamageAmount() )
						end
						-- self.spec_frontloaderAttacher.attacherJoint.allowsLowering = true
						if self:getDamageAmount() <= 0.6 and self:getLastSpeed() < 3 and self.spec_motorized.motor.lastMotorRpm < (self.spec_motorized.motor.minRpm + 20) then
							-- Kritische CVT Schaden-Kontrolllampe geht erst aus, wenn repariert und sich das Fahrzeug im Standgas und Stillstand befindet.
							if self.spec_motorized.motorTemperature.value < 88 then
								spec.forDBL_critdamage = 0
								spec.forDBL_warndamage = 0
							end
						end
					end
					if self.spec_motorized.motorTemperature ~= nil then
						if not self.getIsEntered ~= nil and not self:getIsEntered() then
							if self.spec_motorized.motorTemperature.value < 50 then
								self.spec_motorized.motorTemperature.heatingPerMS = 3 / 1000
								self.spec_motorized.motorFan.enabled = false
							elseif self.spec_motorized.motorTemperature.value >= 50 and self.spec_motorized.motorTemperature.value < 100 then
								self.spec_motorized.motorTemperature.heatingPerMS = 1.5 / 1000
								if self.spec_motorized.motorTemperature.value > 93 then
									self.spec_motorized.motorFan.enabled = true
								end
								if self.spec_motorized.motorTemperature.value < 87 then
									self.spec_motorized.motorFan.enabled = false
								end
							elseif self.spec_motorized.motorTemperature.value >= 100 then
								self.spec_motorized.motorTemperature.heatingPerMS = 0.018
								self.spec_motorized.motorTemperature.coolingPerMS = 4.0 / 1000
								self.spec_motorized.motorTemperature.coolingByWindPerMS = 2.00 / 1000
								self.spec_motorized.motorFan.enabled = true
							end
						end
					end
				end
				
		-- ACCELERATION RAMPS - BESCHLEUNIGUNGSRAMPEN
				if self:getIsMotorStarted() then
					spec.CVTdamage = math.min(spec.CVTdamage,100)
					if spec.CVTconfig ~= 7 then
						if spec.vTwo == 4 and spec.isVarioTM then
							if self:getLastSpeed() <= (self.spec_motorized.motor.maxForwardSpeed*math.pi)/(2.6) then -- Beschleunigung wird ab kmh X full
								self.spec_motorized.motor.accelerationLimit = 1.7 -- Standard IV
							else
								self.spec_motorized.motor.accelerationLimit = 1.8 -- Standard
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
							self.spec_motorized.lastFuelUsage = self.spec_motorized.lastFuelUsage * 1.01
						end
						
						if spec.vTwo == 1 and spec.isVarioTM then
							if self:getLastSpeed() <= (self.spec_motorized.motor.maxForwardSpeed*math.pi)/(2.6) then
								self.spec_motorized.motor.accelerationLimit = 0.35 -- I
							else
								self.spec_motorized.motor.accelerationLimit = 0.7 -- Standard
							end
							if (self:getTotalMass() - self:getTotalMass(true)) ~= 0 then -- 20 97
								self.spec_motorized.motor.lowBrakeForceScale = math.max(math.min((0.5-((self:getTotalMass() - self:getTotalMass(true)) /97 ))*(0.8-(self:getLastSpeed()/100)), 0.2*( 1-(self:getTotalMass() - self:getTotalMass(true))/100 ) ), 0.01)
							else
								self.spec_motorized.motor.lowBrakeForceScale = math.max(math.min((1-(self.spec_motorized.motor.lastMotorRpm/((self.spec_motorized.motor.minRpm/2.03)*10))-(self:getLastSpeed()/100)),0.2),0.01)
							end
							-- Sprit-Verbrauch anpassen
							-- print("Usage: 1 " .. self.spec_motorized.lastFuelUsage)
							self.spec_motorized.lastFuelUsage = self.spec_motorized.lastFuelUsage * 0.94
						end
						
						if spec.vTwo == 2 and spec.isVarioTM then
							if self:getLastSpeed() <= (self.spec_motorized.motor.maxForwardSpeed*math.pi)/(2.6) then
								self.spec_motorized.motor.accelerationLimit = 0.80 -- II
							else
								self.spec_motorized.motor.accelerationLimit = 1.2 -- Standard
							end
							if (self:getTotalMass() - self:getTotalMass(true)) ~= 0 then -- 25 98
								self.spec_motorized.motor.lowBrakeForceScale = math.max(math.min((0.5-((self:getTotalMass() - self:getTotalMass(true)) /98 ))*(0.8-(self:getLastSpeed()/100)), 0.25*( 1-(self:getTotalMass() - self:getTotalMass(true))/100 ) ), 0.01)
							else
								self.spec_motorized.motor.lowBrakeForceScale = math.max(math.min((1-(self.spec_motorized.motor.lastMotorRpm/((self.spec_motorized.motor.minRpm/2.02)*10))-(self:getLastSpeed()/100)),0.25),0.01)
							end
							-- Sprit-Verbrauch anpassen
							-- print("Usage: 2 " .. self.spec_motorized.lastFuelUsage)
							self.spec_motorized.lastFuelUsage = self.spec_motorized.lastFuelUsage * 0.96
						end
						
						if spec.vTwo == 3 and spec.isVarioTM then
							if self:getLastSpeed() <= (self.spec_motorized.motor.maxForwardSpeed*math.pi)/(2.6) then
								self.spec_motorized.motor.accelerationLimit = 1.20 -- III
							else
								self.spec_motorized.motor.accelerationLimit = 1.5 -- Standard
							end
							if (self:getTotalMass() - self:getTotalMass(true)) ~= 0 then -- 30 99
								self.spec_motorized.motor.lowBrakeForceScale = math.max(math.min((0.5-((self:getTotalMass() - self:getTotalMass(true)) /99 ))*(0.8-(self:getLastSpeed()/100)), 0.30*( 1-(self:getTotalMass() - self:getTotalMass(true))/100 ) ), 0.01)
							else
								self.spec_motorized.motor.lowBrakeForceScale = math.max(math.min((1-(self.spec_motorized.motor.lastMotorRpm/((self.spec_motorized.motor.minRpm/2.01)*10))-(self:getLastSpeed()/100)),0.3),0.01)
							end
							-- Sprit-Verbrauch anpassen
							-- print("Usage: 3 " .. self.spec_motorized.lastFuelUsage)
							self.spec_motorized.lastFuelUsage = self.spec_motorized.lastFuelUsage * 0.98
						end
						-- print("MBF: " .. tostring(self.spec_motorized.motor.lowBrakeForceScale))
						-- print("TWO: " .. tostring(spec.vTwo))
						-- print("Mass Difference Ges./1.Fhzg.: " .. (self:getTotalMass() - self:getTotalMass(true)) )
					end
					-- g_currentMission:addExtraPrintText(tostring(self.spec_motorized.motor.maxForwardSpeed))
					
		-- BRAKE RAMPS - BREMSRAMPEN
					if spec.vThree == 1 and spec.isVarioTM then
						-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp5")) -- #hud 4
						self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00500 -- 17 kmh
					end
					if spec.vThree == 2 and spec.isVarioTM then
						self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00027777777777778 -- 1-2 kmh
						-- self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.0000000001 -- 1-2 kmh -- Fließkomme Fehler nach einer Weile
					end
					if spec.vThree == 3 and spec.isVarioTM then
						self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00150 -- ca 4 kmh
					end
					if spec.vThree == 4 and spec.isVarioTM then
						self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00250 -- ca 8 kmh
					end
					if spec.vThree == 5 and spec.isVarioTM then
						self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00427 -- 15 km/h
					end
					
					local spiceLoad = (tonumber(string.format("%.2f", math.min(math.abs(self.spec_motorized.motor.smoothedLoadPercentage)/5, 0.17))))
					-- local spiceRPM = self.spec_motorized.motor.lastMotorRpm
					-- local spiceMaxSpd = self.spec_motorized.motor.maxForwardSpeed
					local Nonce = 0
					
		-- NEUTRAL
					-- print("CVTa targetGear : " .. tostring(self.spec_motorized.motor.targetGear))
					-- print("CVTa currentDirection : " .. tostring(self.spec_motorized.motor.currentDirection))
					-- print("CVTa movingDirection2 : " .. tostring(self.spec_motorized.motor.vehicle.movingDirection))
										
	
					-- Rückwärts retarder Last
					-- if self.spec_motorized.motor.currentDirection == -1 then
						-- self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage * 1.2
					-- end
					
					if math.abs(self.spec_motorized.motor.lastAcceleratorPedal) <= 0.01 then
						self.spec_motorized.motor.motorAppliedTorque = 0
					end
					
					-- automatic drivinglevel for modern cvt, CVTconfig: 4,5,6
					--                                                     
					
					-- Adjust the params when CP or/and AD is active
					if self.spec_cpAIWorker ~= nil then
						if (self.rootVehicle:getIsCpActive() ~= nil ) then
							if (self.rootVehicle:getIsCpActive() == true ) then
								if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 then
									spec.vOne = 2
								end
								if spec.CVTconfig ~= 7 then
									if self.spec_motorized.motor.smoothedLoadPercentage >= 0.95 then
										spec.vTwo = 1
									elseif self.spec_motorized.motor.smoothedLoadPercentage < 0.9 and self.spec_motorized.motor.smoothedLoadPercentage >= 0.7 then
										spec.vTwo = 2
									elseif self.spec_motorized.motor.smoothedLoadPercentage < 0.6 then
										spec.vTwo = 3
									end
								end
							end
						end
					end
					if FS22_AutoDrive ~= nil and FS22_AutoDrive.AutoDrive ~= nil then
						if (self.ad.stateModule:isActive() ~= nil ) then
							if (self.ad.stateModule:isActive() == true ) then
								if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 then
									spec.vOne = 1
								end
								if spec.CVTconfig ~= 7 then
									if self.spec_motorized.motor.smoothedLoadPercentage >= 0.95 then
										spec.vTwo = 1
									elseif self.spec_motorized.motor.smoothedLoadPercentage < 0.9 and self.spec_motorized.motor.smoothedLoadPercentage >= 0.7 then
										spec.vTwo = 2
									elseif self.spec_motorized.motor.smoothedLoadPercentage < 0.6 then
										spec.vTwo = 3
									elseif self.spec_motorized.motor.smoothedLoadPercentage <= 0.5 and (self:getTotalMass() - self:getTotalMass(true)) <= 800 then
										spec.vTwo = 4
									end
								end
							end
						end
					end
					
					-- print("CVTa vOne: " .. spec.vOne)
					
					-- different classic and modern @server or @local
					local mcRPMvar = 1
					-- if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 then -- classic
					
					if g_server and g_client and not g_currentMission.connectedToDedicatedServer then 	-- das ist Local und server host local
						-- spec.mcRPMvar = 1.0009*0.97 	-- c.local
						mcRPMvar = 1.025*0.97 	-- c.local
					else																				-- das ist (dedi)server
						-- spec.mcRPMvar = 1.0009	-- c.server
						mcRPMvar = 0.99	-- c.server
					end
					if cvtaDebugCVTuOn == true then
						print("CVTa mcRPMvar: " .. tostring(mcRPMvar))
					end
					
	-- -- FAHRSTUFE I. classic
					if spec.vOne == 2 and spec.isVarioTM and spec.CVTconfig ~= 7 and ( spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 ) then
						-- Planetengetriebe / Hydromotor Übersetzung
						spec.isHydroState = false
						if spec.CVTdamage > 60 and spec.forDBL_critdamage == 1 and spec.isTMSpedal ~= 1 then -- Notlauf
							self.spec_motorized.motor.maxForwardSpeed = (math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 4.49), 6.94*(1-spec.ClutchInputValue)))/2
							self.spec_motorized.motor.maxBackwardSpeed = (math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 3.21), 6.36*(1-spec.ClutchInputValue)))/2
							-- self.spec_motorized.motor.accelerationLimit = 0.3
							self.spec_motorized.motor.lowBrakeForceScale = math.max(self.spec_motorized.motor.lowBrakeForceScale * (1-spec.ClutchInputValue),0.04)
							self.spec_motorized.motor.accelerationLimit = math.min(self.spec_motorized.motor.accelerationLimit * (1-spec.ClutchInputValue),0.3)
						elseif spec.forDBL_critdamage == 0 and spec.isTMSpedal == 0 then -- Normalbetrieb
							self.spec_motorized.motor.maxForwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 4.49), 6.94*(1))
							self.spec_motorized.motor.maxBackwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 3.21), 6.36*(1))
							self.spec_motorized.motor.lowBrakeForceScale = math.max(self.spec_motorized.motor.lowBrakeForceScale * (1-spec.ClutchInputValue),0.04)
							self.spec_motorized.motor.accelerationLimit = self.spec_motorized.motor.accelerationLimit * (1-spec.ClutchInputValue)
						elseif spec.isTMSpedal == 1 and self:getCruiseControlState() == 0 and math.abs(self.spec_motorized.motor.lastAcceleratorPedal) >= 0.03 then -- PedalTMS
						-- TMS like
						-- wenn Tempomat aus, wird die Tempomatgescwindigkeit als Steps der maxSpeed benutzt
							self.spec_motorized.motor.maxBackwardSpeed = (math.min(self:getCruiseControlSpeed(), math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 3.21), 6.36*(1-spec.ClutchInputValue) ) )) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
							self.spec_motorized.motor.maxForwardSpeed = (math.min(self:getCruiseControlSpeed(), math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 4.49), 6.94*(1-spec.ClutchInputValue) ) )) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
							self.spec_motorized.motor.motorAppliedTorque = math.max(self.spec_motorized.motor.motorAppliedTorque, 0.5)
						end
						-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_VarioOne")) -- #l10n
						self.spec_motorized.motor.gearRatio = math.max(self.spec_motorized.motor.gearRatio, 100) * 1.81 + (self.spec_motorized.motor.rawLoadPercentage*9)
						self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin * 1.6
						-- self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.maxForwardGearRatioOrigin + 1
						-- self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin * 2
						self.spec_motorized.motor.rawLoadPercentage = (self.spec_motorized.motor.rawLoadPercentage * 0.94)
						-- self.spec_motorized.motor.differentialRotSpeed = self.spec_motorized.motor.differentialRotSpeed * 0.8

						if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm + 60 then
							if self.spec_motorized.motor.smoothedLoadPercentage < 0.2 then
								-- Gaspedal and Variator
								-- smooth = 1 + dt / 1400 for 60 fps range
								spec.smoother = 1 + dt / 1400
								-- if spec.smoother ~= nil and spec.smoother > 10 then
									-- spec.smoother = 0;
									-- if cvtaDebugCVTuOn then
										-- print("DT smooth: " .. spec.smoother)
									-- end
									
									-- 
									if self:getLastSpeed() > 1 then
										self.spec_motorized.motor.lastMotorRpm = math.max(math.max(math.max(math.min((self:getLastSpeed() * math.abs(math.max(self.spec_motorized.motor.rawLoadPercentage, 0.52)))*44, self.spec_motorized.motor.maxRpm*0.98), self.spec_motorized.motor.minRpm+203), self.spec_motorized.motor.lastPtoRpm*0), self.spec_motorized.motor.maxRpm*spec.HandgasPercent)
										if self:getLastSpeed() > (self.spec_motorized.motor.maxForwardSpeed*math.pi)-1 then
											self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage *0.97
											self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm + self:getLastSpeed()
										end
										if math.max(0, self.spec_drivable.axisForward) < 0.2 then
										-- if self.isClient and not self.isServer
											self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm * mcRPMvar + (self:getLastSpeed() * 16), self.spec_motorized.motor.maxRpm)
											if self.spec_motorized.motor.rawLoadPercentage < 0 then
												-- self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * ( math.max(math.abs(self.spec_motorized.motor.rawLoadPercentage)*1.7, 1) )
												self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm + (math.abs(self:getLastSpeed()) * 14), self.spec_motorized.motor.maxRpm)
											end
										end
										-- 
										if math.max(0, self.spec_drivable.axisForward) > 0.5 and math.max(0, self.spec_drivable.axisForward) <= 0.9 and self.spec_motorized.motor.rawLoadPercentage < 0.5 then
											self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 0.8 * mcRPMvar
										end
									end
									-- print("smooth: " .. spec.smoother)
								-- end -- smooth
							end
							
														
							-- Nm kurven für unterschiedliche Lasten, Berücksichtigung pto
							if self.spec_motorized.motor.smoothedLoadPercentage >= 0.1 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.3 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.982 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0)+(math.abs(self.spec_motorized.motor.lastAcceleratorPedal)*25), self.spec_motorized.motor.maxRpm)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.3 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.5 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.98 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0)+(math.abs(self.spec_motorized.motor.lastAcceleratorPedal)*25), self.spec_motorized.motor.maxRpm)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.5 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.65 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.975 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0)+(math.abs(self.spec_motorized.motor.lastAcceleratorPedal)*45), self.spec_motorized.motor.maxRpm)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.65 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.7 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.98 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0), self.spec_motorized.motor.maxRpm)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.7 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.75 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.985 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0), self.spec_motorized.motor.maxRpm)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.75 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.99 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0), self.spec_motorized.motor.maxRpm)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.8 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.85 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.994 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0), self.spec_motorized.motor.maxRpm)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.85 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.9 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.997 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0), self.spec_motorized.motor.maxRpm)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.9 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 1.00 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0), self.spec_motorized.motor.maxRpm)
								self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 3 + (self.spec_motorized.motor.rawLoadPercentage*19)
								self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatio + self.spec_motorized.motor.smoothedLoadPercentage*15
							end
							
							-- Drehzahl Erhöhung sobald Pedal aktiviert wird zur Fahrt
							if math.max(0, self.spec_drivable.axisForward) >= 0.01 and self:getLastSpeed() <= 4 then 
								self.spec_motorized.motor.lastMotorRpm = math.max(math.max(math.min(self.spec_motorized.motor.lastMotorRpm * 1.01, self.spec_motorized.motor.maxRpm*0.99), self.spec_motorized.motor.minRpm+323), self.spec_motorized.motor.lastPtoRpm*0)
								if cvtaDebugCVTon == true then
									print("## Drehzahl Erhöhung sobald Pedal aktiviert wird zur Fahrt: " .. math.max(math.max(math.min(self.spec_motorized.motor.lastMotorRpm * 1.01, self.spec_motorized.motor.maxRpm*0.99), self.spec_motorized.motor.minRpm+323), self.spec_motorized.motor.lastPtoRpm*0))
									print("## self:getDamageAmount(): " .. self:getDamageAmount())
								end
							end

							-- Wenn ein Anbaugerät zu schwere Last erzeugt, schafft es die 4. Beschleunigungsrampe nicht oder nimmt Schaden
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.95 and (self:getTotalMass() - self:getTotalMass(true)) >= (self:getTotalMass(true)/2.26) and spec.vTwo == 4 and spec.impIsLowered == true then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.94 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.0)
								self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 3.1 + (self.spec_motorized.motor.rawLoadPercentage*9)
								self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 1
								self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 1
								self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm - 10
								if self.spec_motorized.motorTemperature ~= nil then
									self.spec_motorized.motorTemperature.heatingPerMS = 0.022 * self.spec_motorized.motor.rawLoadPercentage
								end
								if spec.forDBL_critheat == 1 and spec.forDBL_critdamage == 1 then
									spec.CVTdamage = math.min(spec.CVTdamage + ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4), 100)
									if self.spec_RealisticDamageSystem == nil then
										-- self:addDamageAmount((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4)
									end
								end
								if self.spec_motorized.motorTemperature.value > 94 and self.spec_motorized.motorTemperature.value <= 105 and spec.forDBL_critheat ~= 1 then
									spec.forDBL_warnheat = 1
								elseif self.spec_motorized.motorTemperature.value > 105 then
									spec.forDBL_critheat = 1
									spec.forDBL_warnheat = 0
									if spec.forDBL_critdamage ~= 1 then
										spec.forDBL_warndamage = 1
									end
									if spec.CVTdamage > 60 then
										spec.forDBL_critdamage = 1
										spec.forDBL_warndamage = 0
									end
								end
								if cvtaDebugCVTheatOn then
									print("warnHeat: " .. spec.forDBL_warnheat)
									print("critHeat: " .. spec.forDBL_critheat)
									print("warnDamage: " .. spec.forDBL_warndamage)
									print("critDamage: " .. spec.forDBL_critdamage)
									print("Temp: " .. self.spec_motorized.motorTemperature.value .. "°C")
								end
								local FFeffekt = math.max(self.spec_motorized.motor.rawLoadPercentage * 0.75, 0.2)
								if cvtaDebugCVTxOn == true then
									print("CVTa: > 95 % - Lowered, AR4, vTwo=" .. spec.vTwo)
									print("CVTa: > 95 % - Lowered, AR4, Damage=" .. ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4))
									print("CVTa Mass:" .. (self:getTotalMass() - self:getTotalMass(true)) ..">=".. (self:getTotalMass(true)/2.26))
								end
								-- Getriebeschaden erzeugen bzw. Verschleiß
								if self.spec_motorized.motor.rawLoadPercentage > 0.98 then
									if g_client ~= nil and isActiveForInputIgnoreSelection then
										g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 2048)
									end
									if spec.forDBL_critheat == 1 and spec.forDBL_critdamage == 1 then
										spec.CVTdamage = math.min(spec.CVTdamage + (self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 ) ),100)
										if self.spec_RealisticDamageSystem == nil then
											-- self:addDamageAmount(self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 ) )
										end
									end
									self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm -100
									if self.spec_motorized.motorTemperature ~= nil then
										self.spec_motorized.motorTemperature.heatingPerMS = 0.0035 * self.spec_motorized.motor.rawLoadPercentage
									end
									if self.spec_motorized.motorTemperature.value > 94 and self.spec_motorized.motorTemperature.value <= 105 and spec.forDBL_critheat ~= 1 then
										spec.forDBL_warnheat = 1
									elseif self.spec_motorized.motorTemperature.value > 105 then
										spec.forDBL_critheat = 1
										spec.forDBL_warnheat = 0
										if spec.forDBL_critdamage ~= 1 then
											spec.forDBL_warndamage = 1
										end
										if spec.CVTdamage > 60 then
											spec.forDBL_critdamage = 1
											spec.forDBL_warndamage = 0
										end
									end
									if cvtaDebugCVTheatOn then
										print("warnHeat: " .. spec.forDBL_warnheat)
										print("critHeat: " .. spec.forDBL_critheat)
										print("warnDamage: " .. spec.forDBL_warndamage)
										print("critDamage: " .. spec.forDBL_critdamage)
										print("Temp: " .. self.spec_motorized.motorTemperature.value .. "°C")
									end
									if cvtaDebugCVTxOn == true then
										print("CVTa: > 98 % - Lowered, AR4, vTwo=" .. spec.vTwo)
										print("CVTa: > 98 % - Lowered, AR4, Damage=" .. self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 ))
										print("CVTa Mass:" .. (self:getTotalMass() - self:getTotalMass(true)) ..">=".. (self:getTotalMass(true)/2.26))
									end
									if self.spec_motorized.motor.rawLoadPercentage > 0.99 then
										self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
										self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
										self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 0.5 * mcRPMvar
										if self.spec_motorized.motorTemperature ~= nil then
											self.spec_motorized.motorTemperature.heatingPerMS = 0.040 * self.spec_motorized.motor.rawLoadPercentage
										end
										if spec.forDBL_critheat == 1 and spec.forDBL_critdamage == 1 then
											spec.CVTdamage = math.min(spec.CVTdamage + ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.5),100)
											if self.spec_RealisticDamageSystem == nil then
												-- self:addDamageAmount((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.5)
											end
										end
										if self.spec_motorized.motorTemperature.value > 94 and self.spec_motorized.motorTemperature.value <= 105 and spec.forDBL_critheat ~= 1 then
											spec.forDBL_warnheat = 1
										elseif self.spec_motorized.motorTemperature.value > 105 then
											spec.forDBL_critheat = 1
											spec.forDBL_warnheat = 0
											if spec.forDBL_critdamage ~= 1 then
												spec.forDBL_warndamage = 1
											end
										end
										if cvtaDebugCVTheatOn then
											print("warnHeat: " .. spec.forDBL_warnheat)
											print("critHeat: " .. spec.forDBL_critheat)
											print("warnDamage: " .. spec.forDBL_warndamage)
											print("critDamage: " .. spec.forDBL_critdamage)
											print("Temp: " .. self.spec_motorized.motorTemperature.value .. "°C")
										end
										local FFeffekt = math.max(self.spec_motorized.motor.rawLoadPercentage, 0.5)
										if cvtaDebugCVTxOn == true then
											print("CVTa: > 99 % - Lowered, AR4, vTwo=" .. spec.vTwo)
											print("CVTa: > 99 % - Lowered, AR4, Damage=" .. (self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.7)
											print("CVTa Mass:" .. (self:getTotalMass() - self:getTotalMass(true)) ..">=".. (self:getTotalMass(true)/2.26))
										end
									end
								end
							end
							-- Wenn ein Anbaugerät zu schwere Last erzeugt, schafft es die 4. Beschleunigungsrampe nicht oder nimmt Schaden
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.96 and (self:getTotalMass() - self:getTotalMass(true)) >= (self:getTotalMass(true)/1.69) and spec.vTwo == 4 and spec.impIsLowered == true then
								if g_client ~= nil and isActiveForInputIgnoreSelection then
									g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 2048)
								end
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.96 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0)
								self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 3.1 + (self.spec_motorized.motor.rawLoadPercentage*9)
								-- self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 1
								-- self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 1
								self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm - 50
								local FFeffekt = math.max(self.spec_motorized.motor.rawLoadPercentage * 0.75, 0.2)
								if cvtaDebugCVTxOn == true then
									print("CVTa: > 97 % - Lowered, AR3, vTwo=" .. spec.vTwo)
									print("CVTa Mass:" .. (self:getTotalMass() - self:getTotalMass(true)) ..">=".. (self:getTotalMass(true)/2.26))
								end
								-- Getriebeschaden erzeugen
								if self.spec_motorized.motor.smoothedLoadPercentage > 0.98 then
									if g_client ~= nil and isActiveForInputIgnoreSelection then
										g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 2048)
									end
									if spec.forDBL_critheat == 1 and spec.forDBL_critdamage == 1 then
										spec.CVTdamage = math.min(spec.CVTdamage + (self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 ) ),100)
										if self.spec_RealisticDamageSystem == nil then
											-- self:addDamageAmount(self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 ) )
										end
									end
									local FFeffekt = math.max(self.spec_motorized.motor.rawLoadPercentage * 0.95, 0.5)
									self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm -100
									if self.spec_motorized.motorTemperature ~= nil then
										self.spec_motorized.motorTemperature.heatingPerMS = 0.0030 * self.spec_motorized.motor.rawLoadPercentage
									end
									if self.spec_motorized.motorTemperature.value > 94 and self.spec_motorized.motorTemperature.value <= 105 and spec.forDBL_critheat ~= 1 then
										spec.forDBL_warnheat = 1
									elseif self.spec_motorized.motorTemperature.value > 105 then
										spec.forDBL_critheat = 1
										spec.forDBL_warnheat = 0
										if spec.forDBL_critdamage ~= 1 then
											spec.forDBL_warndamage = 1
										end
										if spec.CVTdamage > 60 then
											spec.forDBL_critdamage = 1
											spec.forDBL_warndamage = 0
										end
									end
									if cvtaDebugCVTheatOn then
										print("warnHeat: " .. spec.forDBL_warnheat)
										print("critHeat: " .. spec.forDBL_critheat)
										print("warnDamage: " .. spec.forDBL_warndamage)
										print("critDamage: " .. spec.forDBL_critdamage)
										print("Temp: " .. self.spec_motorized.motorTemperature.value .. "°C")
									end
									if cvtaDebugCVTxOn == true then
										print("CVTa: > 98 % - Lowered, AR3, vTwo=" .. spec.vTwo)
										print("CVTa: > 98 % - Lowered, AR3, Damage=" .. self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 ))
										print("CVTa Mass:" .. (self:getTotalMass() - self:getTotalMass(true)) ..">=".. (self:getTotalMass(true)/2.26))
									end
									if self.spec_motorized.motor.smoothedLoadPercentage > 0.99 then
										-- g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 2048)
										self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
										self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
										self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 0.6 * mcRPMvar
										if self.spec_motorized.motorTemperature ~= nil then
											self.spec_motorized.motorTemperature.heatingPerMS = 0.0035 * self.spec_motorized.motor.rawLoadPercentage
										end
										if self.spec_motorized.motorTemperature.value > 94 and self.spec_motorized.motorTemperature.value <= 105 and spec.forDBL_critheat ~= 1 then
											spec.forDBL_warnheat = 1
										elseif self.spec_motorized.motorTemperature.value > 105 then
											spec.forDBL_critheat = 1
											spec.forDBL_warnheat = 0
											if spec.forDBL_critdamage ~= 1 then
												-- spec.forDBL_warndamage = 1
											end
											if spec.CVTdamage > 60 then
												-- spec.forDBL_critdamage = 1
												-- spec.forDBL_warndamage = 0
											end
										end
										if cvtaDebugCVTheatOn then
											print("warnHeat: " .. spec.forDBL_warnheat)
											print("critHeat: " .. spec.forDBL_critheat)
											print("warnDamage: " .. spec.forDBL_warndamage)
											print("critDamage: " .. spec.forDBL_critdamage)
											print("Temp: " .. self.spec_motorized.motorTemperature.value .. "°C")
										end
										if cvtaDebugCVTxOn == true then
											print("CVTa: > 99 % - Lowered, AR3, vTwo=" .. spec.vTwo)
											print("CVTa Mass:" .. (self:getTotalMass() - self:getTotalMass(true)) ..">=".. (self:getTotalMass(true)/2.26))
										end
									end
								end
							end
						end
					end --FS I

		-- HYDROSTAT HST
					if spec.vOne ~= nil and spec.CVTconfig == 7 then
						-- local mtspec = self.spec_motorized.motor
						spec.isHydroState = true
						-- spec.HydrostatPedal = math.abs(self.spec_motorized.motor.lastAcceleratorPedal) -- nach oben verschoben z.719
						
						-- Hydrostatisches Fahrpedal
						self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.maxForwardGearRatio
						self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minForwardGearRatio
						if spec.vOne == 2 then -- FS I.
							if math.abs(self.spec_motorized.motor.lastAcceleratorPedal) >= 0.0005 then
								self.spec_motorized.motor.maxForwardSpeed  = (self.spec_motorized.motor.maxForwardSpeedOrigin / 4 * spec.vTwo) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal * (self.spec_motorized.motor.lastMotorRpm/self.spec_motorized.motor.maxRpm))
								self.spec_motorized.motor.maxBackwardSpeed = (self.spec_motorized.motor.maxForwardSpeedOrigin / 4 * spec.vTwo) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal * (self.spec_motorized.motor.lastMotorRpm/self.spec_motorized.motor.maxRpm))
									
								if self.spec_vca ~= nil then
									if self.spec_vca.handThrottle > 0 then
										self.spec_motorized.motor.lastMotorRpm = math.max(self.spec_motorized.motor.minRpm*0.99, self.spec_motorized.motor.maxRpm* (math.min(self.spec_vca.handThrottle,0.999)) )
									else
										if spec.HandgasPercent > 0 then
											self.spec_motorized.motor.lastMotorRpm = math.max(self.spec_motorized.motor.minRpm*0.95, self.spec_motorized.motor.maxRpm*spec.HandgasPercent)
											self.spec_motorized.motor.smoothedLoadPercentage = self.spec_motorized.motor.smoothedLoadPercentage * 0.9
										else
											self.spec_motorized.motor.lastMotorRpm = math.max(self.spec_motorized.motor.minRpm * 0.95, self.spec_motorized.motor.maxRpm * spec.HandgasPercent)
										end
									end
								else
									if spec.HandgasPercent > 0 then
										self.spec_motorized.motor.lastMotorRpm = math.max(self.spec_motorized.motor.minRpm*0.95, self.spec_motorized.motor.maxRpm*spec.HandgasPercent)
										self.spec_motorized.motor.smoothedLoadPercentage = self.spec_motorized.motor.smoothedLoadPercentage * 0.9
									else
										self.spec_motorized.motor.lastMotorRpm = math.max(self.spec_motorized.motor.minRpm * 0.95, self.spec_motorized.motor.maxRpm * spec.HandgasPercent)
									end
								end
								if self.spec_vca ~= nil then
									self.spec_motorized.motor.accelerationLimit = 1 + ( 3 * (math.min(self.spec_vca.handThrottle,0.999)))
								else
									self.spec_motorized.motor.accelerationLimit = 1 + ( 3 * spec.HandgasPercent)
								end
							end
						elseif spec.vOne == 1 then -- FS II.
							if math.abs(self.spec_motorized.motor.lastAcceleratorPedal) >= 0.005 then
								self.spec_motorized.motor.maxForwardSpeed  = (self.spec_motorized.motor.maxForwardSpeedOrigin / 4 * spec.vTwo) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
								self.spec_motorized.motor.maxBackwardSpeed = (self.spec_motorized.motor.maxForwardSpeedOrigin / 4 * spec.vTwo) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
								self.spec_motorized.motor.lastMotorRpm = math.max(math.max(math.max(self.spec_motorized.motor.lastMotorRpm, self.spec_motorized.motor.minRpm + (self.spec_motorized.motor.minRpm/1.4 * self.spec_motorized.motor.smoothedLoadPercentage), (self.spec_motorized.motor.maxRpm*0.6) * self.spec_motorized.motor.smoothedLoadPercentage*0.5 ), self.spec_motorized.motor.minRpm), self.spec_motorized.motor.maxRpm * math.max(self.spec_motorized.motor.smoothedLoadPercentage, .5))
								self.spec_motorized.motor.accelerationLimit = 2
							else
								self.spec_motorized.motor.lastMotorRpm = math.max(self.spec_motorized.motor.lastMotorRpm, math.min(self.spec_motorized.motor.maxRpm * self.spec_motorized.motor.smoothedLoadPercentage*0.8, self.spec_motorized.motor.maxRpm * 0.7 )  )
								-- self.spec_motorized.motor.lastMotorRpm = math.max(math.min(self.spec_motorized.motor.minRpm * self.spec_motorized.motor.smoothedLoadPercentage, self.spec_motorized.motor.maxRpm*0.4 * self.spec_motorized.motor.smoothedLoadPercentage*0.5 ), self.spec_motorized.motor.minRpm)
							end
						end
						if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm + 2 then
							if self.spec_motorized.motor.smoothedLoadPercentage >= 0.99 then
								self.spec_motorized.motor.lastMotorRpm = (self.spec_motorized.motor.lastMotorRpm * .8 * mcRPMvar)
								if self.spec_motorized.motorTemperature ~= nil then
									self.spec_motorized.motorTemperature.heatingPerMS = 0.0016
								end
								if self.spec_motorized.motorTemperature.value > 104 then 
									spec.CVTdamage = math.min(spec.CVTdamage + (self.spec_motorized.motorTemperature.value/1250),100)
									if self.spec_RealisticDamageSystem == nil then
										-- self:addDamageAmount(self.spec_motorized.motorTemperature.value/1250)
									end
								end
								if self.spec_motorized.motorTemperature.value > 94 and spec.forDBL_critheat ~= 1 then
									spec.forDBL_warnheat = 1
									spec.forDBL_warndamage = 1
								elseif self.spec_motorized.motorTemperature.value > 105 then
									spec.forDBL_critheat = 1
									spec.forDBL_warnheat = 0
									if spec.forDBL_critdamage ~= 1 then
										spec.forDBL_warndamage = 1
									end
									if spec.CVTdamage > 60 then
										spec.forDBL_critdamage = 1
										spec.forDBL_warndamage = 0
									end
								end
							end
						end
					end -- HST
					
					if debugTable == true then
						if firstTimeRun == nil then 
							-- DebugUtil.printTableRecursively(self.spec_frontloaderAttacher, "flA- " , 0, 5)
							-- DebugUtil.printTableRecursively(self.spec_cylindered, "cyl- " , 0, 5)
							-- DebugUtil.printTableRecursively(self.spec_cylindered.movingTools, "mT- " , 0, 3)
							-- DebugUtil.printTableRecursively(self.spec_motorized.actionEvents[InputAction.TOGGLE_MOTOR_STATE], "mStart- " , 0, 5)
							-- DebugUtil.printTableRecursively(self.spec_motorized.actionEvents[InputAction.TOGGLE_MOTOR_STATE].1, "mStart- " , 0, 5)
							-- DebugUtil.printTableRecursively(self.spec_motorized.motor, "motor- " , 0, 4)
							-- DebugUtil.printTableRecursively(self.spec_powerConsumer, "pC- " , 0, 3) -- wth
							firstTimeRun = true
						end;
					end
					
					
				-- ODB V
													-- self.spec_RealisticDamageSystem.CVTRepairActive 
					if spec.CVTconfig ~= 10 then -- nicht für Elektrofahrzeuge (cfg)
						if self.spec_motorized.motor.smoothedLoadPercentage <= 0.7 and math.abs(self.spec_motorized.motor.lastAcceleratorPedal) <= 0.9 then
							if self.spec_motorized.motorTemperature ~= nil then
								self.spec_motorized.motorTemperature.heatingPerMS = 0.0015
							end
							if self.spec_motorized.motorTemperature.value > 92 then
								self.spec_motorized.motorFan.enabled = true
							elseif self.spec_motorized.motorTemperature.value < 85 then
								self.spec_motorized.motorFan.enabled = false
							end
							if self.spec_motorized.motorTemperature.value < 95 then
								-- Reset der Warn-Kontrolllampen erst, wenn alles abgekühlt ist
								spec.forDBL_warnheat = 0
								if spec.forDBL_critdamage ~= 1 then
									spec.forDBL_warndamage = 0
								end
									-- Kritische CVT Schaden-Kontrolllampe geht erst aus, wenn repariert und sich das Fahrzeug Stillstand und Motor AUS->EIN befindet.
							elseif self.spec_motorized.motorTemperature.value < 104 and self.spec_motorized.motorTemperature.value > 94 then
								spec.forDBL_critheat = 0
								spec.forDBL_warnheat = 1
							end
						end
						if self.spec_motorized.motor.smoothedLoadPercentage <= 0.4 and self:getLastSpeed() < 3 then
							local sspMOT = self.spec_motorized.motor
							if self.spec_motorized.motorTemperature ~= nil then
								self.spec_motorized.motorTemperature.heatingPerMS = 0.0015
							end
							if self.spec_motorized.motorTemperature.value > 92 then
								self.spec_motorized.motorFan.enabled = true
							elseif self.spec_motorized.motorTemperature.value < 85 then
								self.spec_motorized.motorFan.enabled = false
							end
							if self.spec_motorized.motorTemperature.value < 95 then
								-- Reset der Warn-Kontrolllampen erst, wenn alles abgekühlt ist
								spec.forDBL_warnheat = 0
								if spec.forDBL_critdamage == 1 then
									-- spec.forDBL_warndamage = 1
								elseif spec.forDBL_critdamage ~= 1 then
									spec.forDBL_warndamage = 0
								end
													-- Kritische CVT Schaden-Kontrolllampe geht erst aus, wenn repariert und sich das Fahrzeug Stillstand und Motor AUS->EIN befindet.
							elseif self.spec_motorized.motorTemperature.value < 104 and self.spec_motorized.motorTemperature.value > 94 then
								spec.forDBL_critheat = 0
								spec.forDBL_warnheat = 1
							end
							if cvtaDebugCVTheatOn then
								-- print("Cooling Phase")
								-- print("warnHeat: " .. spec.forDBL_warnheat)
								-- print("critHeat: " .. spec.forDBL_critheat)
								-- print("warnDamage: " .. spec.forDBL_warndamage)
								-- print("critDamage: " .. spec.forDBL_critdamage)
								-- print("Temp: " .. self.spec_motorized.motorTemperature.value .. "°C")
							end
							-- Bei etwas mehr Drehzahl, fördert die WaPu mehr Wasser und die Kühlleistung nimmt zu. Zuviel Drehzahl hat keinen Mehrwert.
							if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm and self.spec_motorized.motor.lastMotorRpm < self.spec_motorized.motor.maxRpm / 1.5 then
								self.spec_motorized.motorTemperature.coolingPerMS = math.max( math.min( ((sspMOT.maxRpm/100000)*(sspMOT.lastMotorRpm/10000)), 0.0036 ), 0.001)
							else
								self.spec_motorized.motorTemperature.coolingPerMS = 1.00 / 1000
							end
						end
						if self.spec_motorized.motor.smoothedLoadPercentage <= 0.6 and math.abs(self.spec_motorized.motor.lastAcceleratorPedal) <= 0.5 then
							if self.spec_motorized.motorTemperature ~= nil then
								if self.spec_motorized.motorTemperature.value > 90 and self.spec_motorized.motorTemperature.value < 105 then
									if spec.forDBL_critheat == 1 then
										spec.forDBL_warnheat = 1
										spec.forDBL_critheat = 0
									end
								end
								if self.spec_motorized.motorTemperature.value < 90 then
									if spec.forDBL_critheat ~= 1 then
										spec.forDBL_warnheat = 0
									end
								end
								if self.spec_motorized.motorTemperature.value < 83 then
									self.spec_motorized.motorTemperature.coolingPerMS = 0.75 / 1000
									self.spec_motorized.motorTemperature.heatingPerMS = 1.65 / 1000
								end
							end
						end
						if self.spec_motorized.motorTemperature.value < 45 and self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.maxRpm /1.52 then
							spec.forDBL_warndamage = 1
						elseif self.spec_motorized.motorTemperature.value < 45 and self.spec_motorized.motor.lastMotorRpm <= self.spec_motorized.motor.maxRpm /1.52 then
							spec.forDBL_warndamage = 0
						end
						if self.spec_motorized.motorTemperature.value < 45 and self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.maxRpm /1.5  then
							if spec.forDBL_critdamage == 0 then
								if self.getIsEntered ~= nil and self:getIsEntered() then
									spec.CVTdamage = math.min(spec.CVTdamage + (self.spec_motorized.motorTemperature.value/1250),100)
									if self.spec_RealisticDamageSystem == nil then
										-- self:addDamageAmount(self.spec_motorized.motorTemperature.value/1250)
									end
								end
							end
							spec.forDBL_critdamage = 1
						elseif self.spec_motorized.motorTemperature.value < 45 and self.spec_motorized.motor.lastMotorRpm <= self.spec_motorized.motor.maxRpm /1.5 then
							spec.forDBL_critdamage = 0
						end
						if self.spec_motorized.motorTemperature.value < 45 then
							spec.forDBL_motorcoldlamp = 1
							self:raiseActive()
						else
							spec.forDBL_motorcoldlamp = 0
						end
					end
				-- ODB END
				
	-- -- FAHRSTUFE II. classic (Street/light weight transport or work) inputbinding =====================================
					if spec.vOne == 1 and spec.vOne ~= nil and spec.isVarioTM and spec.CVTconfig ~= 7 and ( spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 ) then
					-- if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 then
						-- Planetengetriebe / Hydromotor Übersetzung
						spec.isHydroState = false
						-- self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 0.95 + (self.spec_motorized.motor.rawLoadPercentage*9)
						self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin
						self.spec_motorized.motor.maxForwardGearRatio = self.spec_motorized.motor.maxForwardGearRatioOrigin
						self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minBackwardGearRatioOrigin
						self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.maxBackwardGearRatioOrigin
						
						-- TMS like
						-- wenn Tempomat aus, wird die Tempomatgescwindigkeit als Steps der maxSpeed benutzt
						if spec.isTMSpedal == 1 and self:getCruiseControlState() == 0 and math.abs(self.spec_motorized.motor.lastAcceleratorPedal) > 0.02 then -- PedalTMS
							self.spec_motorized.motor.maxBackwardSpeed = (math.min(self:getCruiseControlSpeed(), (self.spec_motorized.motor.maxBackwardSpeedOrigin * math.abs(self.spec_motorized.motor.lastAcceleratorPedal))))
							self.spec_motorized.motor.maxForwardSpeed = (math.min(self:getCruiseControlSpeed(), (self.spec_motorized.motor.maxForwardSpeedOrigin * math.abs(self.spec_motorized.motor.lastAcceleratorPedal))))
							self.spec_motorized.motor.motorAppliedTorque = math.max(self.spec_motorized.motor.motorAppliedTorque, 0.5)
						-- Utils.getNoNil(self:getDamageAmount(), 0)
						elseif spec.isTMSpedal == 0 then
							if self.spec_motorized.motor ~= nil then
								-- if self:getDamageAmount() > 0.7 and spec.forDBL_critdamage == 1 and spec.forDBL_critheat == 1 then
								if spec.forDBL_critdamage == 1 and spec.forDBL_critheat == 1 then -- Notlauf
									self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin*(1-spec.ClutchInputValue) / 2
									self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin*(1-spec.ClutchInputValue) / 2
									-- self.spec_motorized.motor.accelerationLimit = 0.25
									self.spec_motorized.motor.lowBrakeForceScale = math.max(self.spec_motorized.motor.lowBrakeForceScale * (1-spec.ClutchInputValue),0.04)
									self.spec_motorized.motor.accelerationLimit = math.min(self.spec_motorized.motor.accelerationLimit * (1-spec.ClutchInputValue),0.25)
								elseif spec.forDBL_critdamage == 0 then -- Normalbetrieb
									self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin*(1)
									self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin*(1)
									self.spec_motorized.motor.lowBrakeForceScale = math.max(self.spec_motorized.motor.lowBrakeForceScale * (1-spec.ClutchInputValue),0.04)
									self.spec_motorized.motor.accelerationLimit = self.spec_motorized.motor.accelerationLimit * (1-spec.ClutchInputValue)
								else -- 
									self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin*(1-spec.ClutchInputValue)
									self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin*(1-spec.ClutchInputValue)
								end
							end
						end
						
						
						-- smoothing nicht im Leerlauf
						if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm + 20 then
							if self.spec_motorized.motor.smoothedLoadPercentage < 0.2 then
							-- if self:getLastSpeed() >= 1 then
								-- Gaspedal and Variator
								-- spec.smoother = spec.smoother + dt;
								-- if spec.smoother ~= nil and spec.smoother > 10 then -- Drehzahl zucken eliminieren
									-- spec.smoother = 0;
									if self:getLastSpeed() > 0.5 then 
										self.spec_motorized.motor.lastMotorRpm = math.max(math.max(math.max(math.min((self:getLastSpeed() * math.abs(math.max(self.spec_motorized.motor.rawLoadPercentage, 0.55)))*42, self.spec_motorized.motor.maxRpm*0.99), self.spec_motorized.motor.minRpm+203), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm*spec.HandgasPercent)
										if cvtaDebugCVTxOn == true then
											-- print("0: " .. tostring(self:getLastSpeed()))
										end
										-- Drehzahl Erhöhung angleichen zur Motorbremswirkung, wenn Pedal losgelassen wird FS2
										if math.max(0, self.spec_drivable.axisForward) < 0.1 and spec.ClutchInputValue ~= 1 then
											-- self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm * mcRPMvar + (self:getLastSpeed() * 14), self.spec_motorized.motor.maxRpm)
											self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm + (math.abs(self:getLastSpeed()) * 14), self.spec_motorized.motor.maxRpm)
											-- self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage - (self:getLastSpeed() / 50)
											if cvtaDebugCVTon == true then
												print("## Angleichen zur Motorbremswirkung,  Pedal losgelassen: " .. math.min(self.spec_motorized.motor.lastMotorRpm * mcRPMvar + (self:getLastSpeed() * 14), self.spec_motorized.motor.maxRpm))
											end
										end
									end
								-- end -- smooth
							end
														
							-- Nm kurven für unterschiedliche Lasten, Berücksichtigung pto FS2
							if self.spec_motorized.motor.smoothedLoadPercentage < 0.4 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.984 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.88)
								if self.spec_motorized.motorTemperature ~= nil then
									self.spec_motorized.motorTemperature.heatingPerMS = 0.0015
								end
							end
							if self.spec_motorized.motor.smoothedLoadPercentage >= 0.4 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.5 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.985 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.88)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.5 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.65 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.9875 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.88)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.65 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.7 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.989 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.7 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.75 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.992 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.75 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.994 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.8 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.85 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.996 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.85 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.9 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.998 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
							end
							
							-- Drehzahl Erhöhung sobald Pedal aktiviert wird zur Fahrt FS2
							if math.max(0, self.spec_drivable.axisForward) >= 0.02 and self:getLastSpeed() <= 7 then 
								self.spec_motorized.motor.lastMotorRpm = math.max(math.max(math.min(self.spec_motorized.motor.lastMotorRpm * 1.01, self.spec_motorized.motor.maxRpm*0.99), self.spec_motorized.motor.minRpm+323), self.spec_motorized.motor.lastPtoRpm*0.7)
								if cvtaDebugCVTon == true then
									print("## Drehzahl Erhöhung sobald Pedal aktiviert wird zur Fahrt: " .. math.max(math.max(math.min(self.spec_motorized.motor.lastMotorRpm * 1.01, self.spec_motorized.motor.maxRpm*0.99), self.spec_motorized.motor.minRpm+323), self.spec_motorized.motor.lastPtoRpm*0.7))
									print("## self:getDamageAmount(): " .. self:getDamageAmount())
								end
							end
							
							if (
							 self.spec_motorized.motor.smoothedLoadPercentage > (1.15 - (spec.vTwo/12))
							 )
							 and (self:getTotalMass() - self:getTotalMass(true)) >= (self:getTotalMass(true)/(spec.vTwo/10.3))
							  then
								self.spec_motorized.motor.lastMotorRpm = math.max(self.spec_motorized.motor.lastMotorRpm * 0.993 * mcRPMvar, self.spec_motorized.motor.lastPtoRpm*0.6)
								if self.spec_motorized.motorTemperature ~= nil then
									self.spec_motorized.motorTemperature.heatingPerMS = 0.0023 * self.spec_motorized.motor.rawLoadPercentage
								end
								if self.spec_motorized.motorTemperature.value > 94 and spec.forDBL_critheat ~= 1 then
									spec.forDBL_warnheat = 1
								elseif self.spec_motorized.motorTemperature.value > 105 then
									spec.forDBL_critheat = 1
									spec.forDBL_warnheat = 0
									if spec.forDBL_critdamage ~= 1 then
										-- spec.forDBL_warndamage = 1
									end
									if self:getDamageAmount() ~= nil then
										if self:getDamageAmount() > 0.6 then
											-- spec.forDBL_critdamage = 1
											-- spec.forDBL_warndamage = 0
										end
									end
								elseif self.spec_motorized.motorTemperature.value <= 95 then
									spec.forDBL_warnheat = 0
									spec.forDBL_critheat = 0
								end
								if cvtaDebugCVTheatOn then
									print("##1 load > 0.9")
									print("##1 warnHeat: " .. spec.forDBL_warnheat)
									print("##1 critHeat: " .. spec.forDBL_critheat)
									print("##1 warnDamage: " .. spec.forDBL_warndamage)
									print("##1 critDamage: " .. spec.forDBL_critdamage)
									print("##1 Temp: " .. self.spec_motorized.motorTemperature.value .. "°C")
									print("##1 heatingPerMS: " .. 0.0018 * self.spec_motorized.motor.rawLoadPercentage)
								end
								if cvtaDebugCVTxOn == true then
									print("##1 CVTa: II. > ".. (1.15 - (spec.vTwo/12) )*100 .." %r - Weighted, vTwo=" .. spec.vTwo)
									print("##1 addDamage: ".. ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4))
								end
							end

							-- Wenn ein abgesenktes Anbaugerät zu schwere Last erzeugt und abgesenkt ist, schafft es die 2. Fahrstufe nicht II.
							if self.spec_motorized.motor.smoothedLoadPercentage > (1.05 - (spec.vTwo/21) ) and spec.impIsLowered == true then
								if g_client ~= nil and isActiveForInputIgnoreSelection then
									g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 1024)
								end
								self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 1
								self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 1
								if self.spec_motorized.motorTemperature ~= nil then
									self.spec_motorized.motorTemperature.heatingPerMS = 0.0035 * self.spec_motorized.motor.rawLoadPercentage / (1.5-spec.vTwo/10)
									self.spec_motorized.motorTemperature.coolingPerMS = 0.70 / 1000
								end
								if spec.forDBL_critheat == 1 and spec.forDBL_critdamage == 1 then
									spec.CVTdamage = math.min(spec.CVTdamage + ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4),100)
									if self.spec_RealisticDamageSystem == nil then
										if spec.CVTdamage >= 80 then
											-- self:addDamageAmount((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4)
										end
									end
								end
								if self.spec_motorized.motorTemperature.value > 95 and self.spec_motorized.motorTemperature.value <= 105 and spec.forDBL_critheat ~= 1 then
									spec.forDBL_warnheat = 1
								elseif self.spec_motorized.motorTemperature.value > 105 then
									spec.forDBL_critheat = 1
									spec.forDBL_warnheat = 0
									if spec.forDBL_critdamage ~= 1 then
										spec.forDBL_warndamage = 1
									end
									if spec.CVTdamage > 70 then
										if spec.forDBL_critdamage == 1 then
											-- Motor abwürgen
											-- self:stopMotor()
											print("##2 Motor abgewürgt")
											-- self:stopMotor(false)
										end
										spec.forDBL_critdamage = 1
										spec.forDBL_warndamage = 0
									end
								end
								if cvtaDebugCVTheatOn then
									print("##2 load > ".. (1.05 - (spec.vTwo/13) ) .."r   lowered")
									print("##2 warnHeat: " .. spec.forDBL_warnheat)
									print("##2 critHeat: " .. spec.forDBL_critheat)
									print("##2 warnDamage: " .. spec.forDBL_warndamage)
									print("##2 critDamage: " .. spec.forDBL_critdamage)
									print("##2 Temp: " .. self.spec_motorized.motorTemperature.value .. "°C")
									print("##2 heatingPerMS: " .. 0.0090 * self.spec_motorized.motor.rawLoadPercentage)
								end
								if cvtaDebugCVTxOn == true then
									print("##2 CVTa: II. > ".. (1.05 - (spec.vTwo/10) )*100 .." %r - Lowered, vTwo=" .. spec.vTwo)
									print("##2 addDamage: ".. ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4))
									-- print("mass() - mass(true)>=mass(true)" .. (self:getTotalMass() - self:getTotalMass(true)) .. " >= " .. (self:getTotalMass(true)))
								end
							end
							-- Wenn ein Anbaugerät zu schwere Last erzeugt, schafft es die 2. Fahrstufe nicht oder nimmt Schaden II.
							if self.spec_motorized.motor.smoothedLoadPercentage > (1.222 - (spec.vTwo/9) ) and (self:getTotalMass() - self:getTotalMass(true)) >= (self:getTotalMass(true)) and spec.vTwo > 3 then
								-- g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 2048)
								-- self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.95 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.8)
								self.spec_motorized.motor.lastPtoRpm = math.max(self.spec_motorized.motor.lastPtoRpm * 0.6, 0)
								self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 3.1 + (self.spec_motorized.motor.rawLoadPercentage*9)
								self.spec_motorized.motor.maxForwardSpeed = ( (self:getLastSpeed()-0.5) / math.pi )
								self.spec_motorized.motor.maxBackwardSpeed = ( (self:getLastSpeed()-0.5) / math.pi )
								if self.spec_motorized.motorTemperature ~= nil then
									self.spec_motorized.motorTemperature.heatingPerMS = (0.0024 + (spec.vTwo^2/10000))
									self.spec_motorized.motorTemperature.coolingPerMS = 1.2 / 1000
								end
								if spec.forDBL_critheat == 1 and spec.forDBL_warndamage == 1 or spec.forDBL_critheat == 1 and spec.forDBL_critdamage == 1 then
									spec.CVTdamage = math.min(spec.CVTdamage + ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4), 100)
									if self.spec_RealisticDamageSystem == nil then
										if spec.CVTdamage >= 50 then
											-- self:addDamageAmount((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4)
										end
									end
									if cvtaDebugCVTheatOn then
										print("##3 addDamage: " .. ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *2.4) )
									end
								end
								if self.spec_motorized.motorTemperature.value > 95 and self.spec_motorized.motorTemperature.value <= 105 and spec.forDBL_critheat ~= 1 then
									spec.forDBL_warnheat = 1
								elseif self.spec_motorized.motorTemperature.value > 105 then
									spec.forDBL_critheat = 1
									spec.forDBL_warnheat = 0
									if spec.forDBL_critdamage ~= 1 then
										spec.forDBL_warndamage = 1
									end
									-- if self:getDamageAmount() ~= nil then
									if spec.CVTdamage > 80 then
										spec.forDBL_critdamage = 1
										spec.forDBL_warndamage = 0
									end
									-- end
								end
								if cvtaDebugCVTheatOn then
									print("##3 load > " .. (1.222 - (spec.vTwo/9) .. " mass AR4"))
									print("##3 warnHeat: " .. spec.forDBL_warnheat)
									print("##3 critHeat: " .. spec.forDBL_critheat)
									print("##3 warnDamage: " .. spec.forDBL_warndamage)
									print("##3 critDamage: " .. spec.forDBL_critdamage)
									print("##3 Temp: " .. self.spec_motorized.motorTemperature.value .. "°C")
									print("##3 heatingPerMS = " .. self.spec_motorized.motorTemperature.heatingPerMS)
									print("##3 coolingPerMS = " .. self.spec_motorized.motorTemperature.coolingPerMS)
									print("##3 coolingByWindPerMS = " .. self.spec_motorized.motorTemperature.coolingByWindPerMS)
								end
								self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm +10
								local massDiff = (self:getTotalMass() - self:getTotalMass(true)) / 100
								if cvtaDebugCVTxOn == true then
									print("##3 CVTa: II. > " .. (1.222 - (spec.vTwo/9))*100 .. " %r - Mass, AR4, vTwo=" .. spec.vTwo)
									print("##3 CVTa: II. > " .. (1.222 - (spec.vTwo/9))*100 .. " %r - Mass, AR4, forDBL_warnHeat=" .. spec.forDBL_warnheat)
									print("##3 mass("..self:getTotalMass()..") - mass(true)>=mass(true)" .. (self:getTotalMass() - self:getTotalMass(true)) .. " >= " .. (self:getTotalMass(true)))
								end
								
								-- Getriebeschaden erzeugen nur klassisch  II.
								if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 then
									if self.spec_motorized.motor.smoothedLoadPercentage > 0.98  then
										if g_client ~= nil and isActiveForInputIgnoreSelection then
											g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 1024)
										end
										if self.spec_motorized.motorTemperature ~= nil then
											self.spec_motorized.motorTemperature.heatingPerMS = 0.0022 * self.spec_motorized.motor.rawLoadPercentage
										end
										-- self.spec_motorized.motorTemperature.coolingPerMS = 0.65 / 1000
										if self.spec_motorized.motorTemperature.value > 95 and spec.forDBL_critheat ~= 1 then
											spec.forDBL_warnheat = 1
										elseif self.spec_motorized.motorTemperature.value > 105 then
											spec.forDBL_critheat = 1
											spec.forDBL_warnheat = 0
											if spec.forDBL_critdamage ~= 1 then
												-- spec.forDBL_warndamage = 1
											end
											if self:getDamageAmount() ~= nil then
												if self:getDamageAmount() > 0.6 then
													-- spec.forDBL_critdamage = 1
													-- spec.forDBL_warndamage = 0
												end
											end
										end
										if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm + 150 then
											if spec.forDBL_critheat == 1 and spec.forDBL_critdamage == 1 then
												spec.CVTdamage = math.min(spec.CVTdamage + ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4),100)
												if self.spec_RealisticDamageSystem == nil then
													if spec.CVTdamage >= 80 then
														-- self:addDamageAmount((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4)
													end
												end
												if cvtaDebugCVTheatOn then
													print("##4 addDamage: " .. ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4) )
												end
											end
											if self.spec_motorized.motorTemperature.value > 95 and spec.forDBL_critheat ~= 1 then
												spec.forDBL_warnheat = 1
											elseif self.spec_motorized.motorTemperature.value > 105 then
												spec.forDBL_critheat = 1
												spec.forDBL_warnheat = 0
												if spec.forDBL_critdamage ~= 1 then
													spec.forDBL_warndamage = 1
												end
												if spec.CVTdamage > 80 then
													spec.forDBL_critdamage = 1
													spec.forDBL_warndamage = 0
												end
											end
											if cvtaDebugCVTheatOn then
												print("##4 rpm > min+150 classic")
												print("##4 warnHeat: " .. spec.forDBL_warnheat)
												print("##4 critHeat: " .. spec.forDBL_critheat)
												print("##4 warnDamage: " .. spec.forDBL_warndamage)
												print("##4 critDamage: " .. spec.forDBL_critdamage)
												print("##4 Temp: " .. self.spec_motorized.motorTemperature.value .. "°C")
												print("##4 heatingPerMS: " .. 0.0110 * self.spec_motorized.motor.rawLoadPercentage)
												print("##4 CVTa: II. > 98 % - Mass, AR3, Damage=" .. ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4))
											end
											-- self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
											-- self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
											self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 1.12 * mcRPMvar
											if cvtaDebugCVTxOn == true then
												print("##4 CVTa: II. > 98 % - Mass, AR3, vTwo=" .. spec.vTwo .. " damage: " .. ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4) )
												print("##4 CVTa: II. > 98 % - Mass, AR3, forDBL_critHeat=" .. spec.forDBL_critheat)
												print("##4 CVTa: II. > 98 % - Mass, AR3, forDBL_warnDamage=" .. spec.forDBL_warndamage)
											end
										end
									end
									if spec.impIsLowered == true and self.spec_motorized.motor.rawLoadPercentage > 0.97 then
										if g_client ~= nil and isActiveForInputIgnoreSelection then
											g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 1024)
										end
										if self.spec_motorized.motorTemperature ~= nil then
											self.spec_motorized.motorTemperature.heatingPerMS = 0.0045 * self.spec_motorized.motor.rawLoadPercentage
										end
										if spec.forDBL_critheat == 1 and spec.forDBL_critdamage == 1 then
											spec.CVTdamage = math.min(spec.CVTdamage + ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.5),100)
											if self.spec_RealisticDamageSystem == nil then
												if spec.CVTdamage >= 80 then
													-- self:addDamageAmount((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.5)
												end
											end
										end
										if self.spec_motorized.motorTemperature.value > 95 and spec.forDBL_critheat ~= 1 then
											spec.forDBL_warnheat = 1
										elseif self.spec_motorized.motorTemperature.value > 105 then
											spec.forDBL_critheat = 1
											spec.forDBL_warnheat = 0
											if spec.forDBL_critdamage ~= 1 then
												spec.forDBL_warndamage = 1
											end
											if spec.CVTdamage > 80 then
												if spec.forDBL_critdamage == 1 then
													-- Motor abwürgen
													-- self:stopMotor()
													-- self:stopMotor(false)
													print("##5 Motor abgewürgt")
												end
												spec.forDBL_critdamage = 1
												spec.forDBL_warndamage = 0
											end
										end
										if cvtaDebugCVTheatOn then
											print("##5 load > 0.97 lowered classic")
											print("##5 warnHeat: " .. spec.forDBL_warnheat)
											print("##5 critHeat: " .. spec.forDBL_critheat)
											print("##5 warnDamage: " .. spec.forDBL_warndamage)
											print("##5 critDamage: " .. spec.forDBL_critdamage)
											print("##5 Temp: " .. self.spec_motorized.motorTemperature.value .. "°C")
											print("##5 heatingPerMS: " .. 0.080 * self.spec_motorized.motor.rawLoadPercentage)
											print("##5 addDamage lowered: "  .. (self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 ))*0.7)
										end
										self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
										self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
										self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 1.5 * mcRPMvar
										if cvtaDebugCVTxOn == true then
											print("##5 CVTa: II. > 97 % - Mass, AR3, vTwo=" .. spec.vTwo)
										end
									end
								end
							end
							-- HydroPumpe abschwenken auf nur mechanischen Antrieb bei vMax FS2
							-- ToDo: assign with vca.keepspeed
							-- 			kmh 		> 				max kmh								-						max kmh                     :14
							--          47							16.87 * 3.141592654 (53) 		    -                 "   (53)/14= 3.786    53-3.786= 49.214 kmh
							if self:getLastSpeed() > ((self.spec_motorized.motor.maxForwardSpeed*math.pi) - 0.5) then
						
						-- Ändert die Drehzahl wenn man sich der vMax nähert  ##here  II. FS2
								self.spec_motorized.motor.lastMotorRpm = math.min((self.spec_motorized.motor.lastMotorRpm*1.01) + (self:getLastSpeed()/(8*mcRPMvar) ), self.spec_motorized.motor.maxRpm-18)
								-- self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 
								-- self.spec_motorized.motor.smoothedLoadPercentage = self.spec_motorized.motor.smoothedLoadPercentage * 1.06
								if cvtaDebugCVTon == true then
									print("## Ändert die Drehzahl wenn man sich der vMax nähert: ")
								end
							end
						end
					end -- FSII.
					
	-- MODERN CURVES =====================================
					if spec.isVarioTM and spec.CVTconfig ~= 7 and ( spec.CVTconfig == 4 or spec.CVTconfig == 5 or spec.CVTconfig == 6 ) then
					
						if self.spec_vca ~= nil then
							if math.abs(self.spec_drivable.axisForward) > 0.75 and self.spec_vca.handbrake == true and self:getLastSpeed() < 1 then
								self.spec_vca.handbrake = false
							else
								--
							end
						end

						-- Planetengetriebe / Hydromotor Übersetzung
						spec.isHydroState = false
						-- self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 0.95 + (self.spec_motorized.motor.rawLoadPercentage*9)
						self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin
						self.spec_motorized.motor.maxForwardGearRatio = self.spec_motorized.motor.maxForwardGearRatioOrigin
						self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minBackwardGearRatioOrigin
						self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.maxBackwardGearRatioOrigin
						
						-- TMS like
						-- wenn Tempomat aus, wird die Tempomatgescwindigkeit als Steps der maxSpeed benutzt
						if spec.isTMSpedal == 1 and self:getCruiseControlState() == 0 and math.abs(self.spec_motorized.motor.lastAcceleratorPedal) > 0.02 then
							self.spec_motorized.motor.maxBackwardSpeed = (math.min(self:getCruiseControlSpeed(), (self.spec_motorized.motor.maxBackwardSpeedOrigin * math.abs(self.spec_motorized.motor.lastAcceleratorPedal))))
							self.spec_motorized.motor.maxForwardSpeed = (math.min(self:getCruiseControlSpeed(), (self.spec_motorized.motor.maxForwardSpeedOrigin * math.abs(self.spec_motorized.motor.lastAcceleratorPedal))))
							self.spec_motorized.motor.motorAppliedTorque = math.max(self.spec_motorized.motor.motorAppliedTorque, 0.5)
						-- Utils.getNoNil(self:getDamageAmount(), 0)
						elseif spec.isTMSpedal == 0 then
							if self.spec_motorized.motor ~= nil then
								-- if self:getDamageAmount() > 0.7 and spec.forDBL_critdamage == 1 and spec.forDBL_critheat == 1 then
								if spec.forDBL_critdamage == 1 and spec.forDBL_critheat == 1 then -- Notlauf
									self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin*(1) / 2
									self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin*(1) / 2
									-- self.spec_motorized.motor.accelerationLimit = 0.25
									self.spec_motorized.motor.lowBrakeForceScale = math.max(self.spec_motorized.motor.lowBrakeForceScale * (1-spec.ClutchInputValue),0.04)
									self.spec_motorized.motor.accelerationLimit = math.min(self.spec_motorized.motor.accelerationLimit * (1-spec.ClutchInputValue),0.25)
								elseif spec.forDBL_critdamage == 0 then -- Normalbetrieb
									self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin*(1)
									self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin*(1)
									self.spec_motorized.motor.lowBrakeForceScale = math.max(self.spec_motorized.motor.lowBrakeForceScale * (1-spec.ClutchInputValue),0.04)
									self.spec_motorized.motor.accelerationLimit = self.spec_motorized.motor.accelerationLimit * (1-spec.ClutchInputValue)
								else
									self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin*(1-spec.ClutchInputValue)
									self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin*(1-spec.ClutchInputValue)
								end
							end
						end
						
						
						-- smoothing nicht im Leerlauf
						if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm + 20 then
							if self.spec_motorized.motor.smoothedLoadPercentage < 0.2 then
							-- if self:getLastSpeed() >= 1 then
								-- Gaspedal and Variator
								-- spec.smoother = spec.smoother + dt;
								-- if spec.smoother ~= nil and spec.smoother > 10 then -- Drehzahl zucken eliminieren
									-- spec.smoother = 0;
									if self:getLastSpeed() > 0.5 then 
										self.spec_motorized.motor.lastMotorRpm = math.max(math.max(math.max(math.min((self:getLastSpeed() * math.abs(math.max(self.spec_motorized.motor.rawLoadPercentage, 0.55)))*42, self.spec_motorized.motor.maxRpm*0.99), self.spec_motorized.motor.minRpm+203), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm*spec.HandgasPercent)
										if cvtaDebugCVTxOn == true then
											-- print("0: " .. tostring(self:getLastSpeed()))
										end
										-- Drehzahl Erhöhung angleichen zur Motorbremswirkung, wenn Pedal losgelassen wird MODERN
										if math.max(0, self.spec_drivable.axisForward) < 0.1 then
											-- self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm * mcRPMvar + (self:getLastSpeed() * 14), self.spec_motorized.motor.maxRpm)
											self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm + (math.abs(self:getLastSpeed()) * 14), self.spec_motorized.motor.maxRpm)
											-- self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage - (self:getLastSpeed() / 50)
											if cvtaDebugCVTon == true then
												print("## Angleichen zur Motorbremswirkung, Pedal losgelassen: " .. math.min(self.spec_motorized.motor.lastMotorRpm * mcRPMvar + (self:getLastSpeed() * 14), self.spec_motorized.motor.maxRpm))
											end
										end
									end
								-- end -- smooth
							end
							
																					
							-- Nm kurven für unterschiedliche Lasten, Berücksichtigung pto MODERN
							if self.spec_motorized.motor.smoothedLoadPercentage < 0.4 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.983 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.88)
								if self.spec_motorized.motorTemperature ~= nil then
									self.spec_motorized.motorTemperature.heatingPerMS = 0.0015
									-- self.spec_motorized.motorTemperature.coolingPerMS = 0.002
									
								end
							end
							if self.spec_motorized.motor.smoothedLoadPercentage >= 0.4 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.5 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.9825 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.88)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.5 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.65 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.984 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.88)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.65 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.7 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.9865 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.7 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.75 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.9885 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.75 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.99 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.8 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.85 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.9925 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
								-- self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * ((self.spec_motorized.motor.smoothedLoadPercentage/9.95)+0.908) * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.85 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.9 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.995 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
								-- self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * ((self.spec_motorized.motor.smoothedLoadPercentage/9.95)+0.905) * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.9 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.99 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.9975 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
								-- self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * ((self.spec_motorized.motor.smoothedLoadPercentage/9.95)+0.90) * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
							end
							
							-- Drehzahl Erhöhung sobald Pedal aktiviert wird zur Fahrt MODERN
							if math.max(0, self.spec_drivable.axisForward) >= 0.02 and self:getLastSpeed() <= 7 then 
								self.spec_motorized.motor.lastMotorRpm = math.max(math.max(math.min(self.spec_motorized.motor.lastMotorRpm * 1.01, self.spec_motorized.motor.maxRpm*0.99), self.spec_motorized.motor.minRpm+323), self.spec_motorized.motor.lastPtoRpm*0.7)
								if cvtaDebugCVTon == true then
									print("### Drehzahl Erhöhung sobald Pedal aktiviert wird zur Fahrt: " .. math.max(math.max(math.min(self.spec_motorized.motor.lastMotorRpm * 1.01, self.spec_motorized.motor.maxRpm*0.99), self.spec_motorized.motor.minRpm+323), self.spec_motorized.motor.lastPtoRpm*0.7))
									print("### self:getDamageAmount(): " .. self:getDamageAmount())
								end
							end
							
							-- Fahrzeug nicht leer
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.95 and spec.vTwo > 3 and (self:getTotalMass() - self:getTotalMass(true)) >= (self:getTotalMass(true)) then
								self.spec_motorized.motor.lastMotorRpm = math.max(self.spec_motorized.motor.lastMotorRpm * 0.993 * mcRPMvar, self.spec_motorized.motor.lastPtoRpm*0.6)
								if self.spec_motorized.motorTemperature ~= nil then
									self.spec_motorized.motorTemperature.heatingPerMS = (0.0011 + (spec.vTwo^2/10000))
								end
								self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - (spec.vTwo/2)
								spec.CVTdamage = math.min(spec.CVTdamage + ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.5),100)
								if self.spec_RealisticDamageSystem == nil then
									if spec.CVTdamage >= 80 then
										-- self:addDamageAmount((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.5)
									end
								end
								
								-- print("###0 TEST: " ..((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4) )
																
								if self.spec_motorized.motorTemperature.value > 96 and spec.forDBL_critheat ~= 1 then
									spec.forDBL_warnheat = 1
								elseif self.spec_motorized.motorTemperature.value > 105 then
									spec.forDBL_critheat = 1
									spec.forDBL_warnheat = 0
									if spec.forDBL_critdamage ~= 1 then
										spec.forDBL_warndamage = 1
									end
									if self:getDamageAmount() ~= nil then
										if self:getDamageAmount() > 0.6 then
											-- spec.forDBL_critdamage = 1
											-- spec.forDBL_warndamage = 0
										end
									end
								elseif self.spec_motorized.motorTemperature.value <= 96 then
									spec.forDBL_warnheat = 0
									spec.forDBL_critheat = 0
								end
								
								if cvtaDebugCVTheatOn then
									print("###1 load > 0.9")
									print("###1 warnHeat: " .. spec.forDBL_warnheat)
									print("###1 critHeat: " .. spec.forDBL_critheat)
									print("###1 warnDamage: " .. spec.forDBL_warndamage)
									print("###1 critDamage: " .. spec.forDBL_critdamage)
									print("###1 Temp: " .. self.spec_motorized.motorTemperature.value .. "°C")
									print("###1 heatingPerMS: " .. self.spec_motorized.motorTemperature.heatingPerMS)
								end
								if cvtaDebugCVTxOn == true then
									print("###1 CVTa: M. > ".. (1.05 - (spec.vTwo/10) )*100 .." %r, vTwo=" .. spec.vTwo)
									print("###1 addDamage: ".. ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4))
									print("###1 heatingPerMS.: " .. self.spec_motorized.motorTemperature.heatingPerMS)
								end
							end

							
							-- Wenn ein Anbaugerät zu schwere Last erzeugt, steigt der Druck je nach Beschleunigungsrampe.
							if self.spec_motorized.motor.smoothedLoadPercentage > (1.20 - (spec.vTwo/10) ) and (self:getTotalMass() - self:getTotalMass(true)) >= (self:getTotalMass(true)) and spec.vTwo >= 3 and spec.impIsLowered == true then
								if self.spec_motorized.motorTemperature ~= nil then
									self.spec_motorized.motorTemperature.heatingPerMS = 0.0031 * self.spec_motorized.motor.rawLoadPercentage   / (1.8-spec.vTwo/10)
									-- self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - spec.vTwo
									spec.CVTdamage = math.min(spec.CVTdamage + ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.5),100)
									if self.spec_RealisticDamageSystem == nil then
										if spec.CVTdamage >= 80 then
											-- self:addDamageAmount((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.5)
										end
									end
									
									if self.spec_motorized.motorTemperature.value > 96 and spec.forDBL_critheat ~= 1 then
										spec.forDBL_warnheat = 1
									elseif self.spec_motorized.motorTemperature.value > 105 then
										spec.forDBL_critheat = 1
										spec.forDBL_warnheat = 0
										if spec.forDBL_critdamage ~= 1 then
											spec.forDBL_warndamage = 1
										end
										if self:getDamageAmount() ~= nil then
											if self:getDamageAmount() > 0.6 then
												spec.forDBL_critdamage = 1
												spec.forDBL_warndamage = 0
											end
										end
									elseif self.spec_motorized.motorTemperature.value <= 96 then
										spec.forDBL_warnheat = 0
										spec.forDBL_critheat = 0
									end
									
									if cvtaDebugCVTheatOn then
										print("###2 load > ".. (1.222 - (spec.vTwo/9) ))
										print("###2 warnHeat: " .. spec.forDBL_warnheat)
										print("###2 critHeat: " .. spec.forDBL_critheat)
										print("###2 warnDamage: " .. spec.forDBL_warndamage)
										print("###2 critDamage: " .. spec.forDBL_critdamage)
										print("###2 Temp: " .. self.spec_motorized.motorTemperature.value .. "°C")
										print("###2 heatingPerMS: " .. self.spec_motorized.motorTemperature.heatingPerMS)
									end
									if cvtaDebugCVTxOn == true then
									print("###2 CVTa: M. > ".. (1.05 - (spec.vTwo/10) )*100 .." %r, vTwo=" .. spec.vTwo)
									print("###2 addDamage: ".. ((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4))
									print("###2 heatingPerMS.: " .. self.spec_motorized.motorTemperature.heatingPerMS)
								end
								end
							end
							
							-- Ändert die Drehzahl wenn man sich der vMax nähert  ##here  II. MODERN
							-- HydroPumpe abschwenken auf nur mechanischen Antrieb bei vMax
							-- ToDo: assign with vca.keepspeed
							-- 			kmh 		> 				max kmh								-						max kmh                     :14
							--          47							16.87 * 3.141592654 (53) 		    -                 "   (53)/14= 3.786    53-3.786= 49.214 kmh
							if self:getLastSpeed() > ((self.spec_motorized.motor.maxForwardSpeed*math.pi) - 1) then
								-- if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 then
									-- self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm + (self:getLastSpeed()/(11*mcRPMvar) ), self.spec_motorized.motor.maxRpm-18)
									-- self.spec_motorized.motor.smoothedLoadPercentage = math.max(self.spec_motorized.motor.smoothedLoadPercentage, 0.61)
								-- elseif spec.CVTconfig == 4 or spec.CVTconfig == 5 or spec.CVTconfig == 6 then
								self.spec_motorized.motor.lastMotorRpm = math.min((self.spec_motorized.motor.lastMotorRpm*0.99) + (self:getLastSpeed()/14 ), self.spec_motorized.motor.maxRpm-21)
								-- end
								if cvtaDebugCVTon == true then
									print("### Ändert die Drehzahl wenn man sich der vMax nähert: ")
								end
							end
						end
					end -- Modern Curves.
					
					
	-- MOTORDREHZAHL (Handgas-digital)
					local maxRpm = self.spec_motorized.motor.maxRpm
					local minRpm = self.spec_motorized.motor.minRpm

					if spec.vFive == nil then
						spec.vFive = 0
					end
					if spec.HandgasPercent ~= nil then					-- HG per axis
						spec.vFive = math.max(math.floor(10*spec.HandgasPercent), 0)
						-- print(tostring(spec.moveRpmL))
						if spec.HandgasPercent > 0 then
							if self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
								self.spec_motorized.motor.lastMotorRpm = math.max(self.spec_motorized.motor.lastMotorRpm, math.max(self.spec_motorized.motor.minRpm+(self.spec_motorized.motor.maxRpm-self.spec_motorized.motor.minRpm) * spec.HandgasPercent, self.spec_motorized.motor.minRpm) )
							elseif self.spec_motorized.motor.smoothedLoadPercentage > 0.8 then
								self.spec_motorized.motor.lastMotorRpm = math.max(self.spec_motorized.motor.lastMotorRpm, math.max((self.spec_motorized.motor.minRpm+(self.spec_motorized.motor.maxRpm-self.spec_motorized.motor.minRpm) * spec.HandgasPercent) * math.min(math.max(spec.HandgasPercent*1.5, 0.8),1), self.spec_motorized.motor.minRpm) )
								-- self.spec_motorized.motor.lastMotorRpm = math.max(self.spec_motorized.motor.lastMotorRpm, math.max(self.spec_motorized.motor.minRpm+(self.spec_motorized.motor.maxRpm-self.spec_motorized.motor.minRpm) * (math.max(math.min(spec.HandgasPercent*(1.8*self.spec_motorized.motor.smoothedLoadPercentage), 1), 0.6)), self.spec_motorized.motor.minRpm) )  -- push it higher
							end
						end
					else
						spec.HandgasPercent = 0
						spec.vFive = 0
					end -- Handgas
					
					
				-- Elektro Stapler
					if spec.CVTconfig == 10 then
						self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin / spec.vOne * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
						self.spec_motorized.motor.maxBackwardSpeed =self.spec_motorized.motor.maxBackwardSpeedOrigin/ spec.vOne * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
						self.spec_motorized.motor.accelerationLimit = self.spec_motorized.motor.accelerationLimit / 4 * spec.vTwo
						self.spec_motorized.lastFuelUsage = self.spec_motorized.lastFuelUsage / 2.9 * spec.vTwo
						-- self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 1.05 * self.spec_motorized.motor.lastAcceleratorPedal
					end
					
				-- HARVESTER config
					if spec.isVarioTM and spec.CVTconfig == 11 then

						-- Planetengetriebe / Hydromotor Übersetzung
						spec.isHydroState = false
						-- self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 0.95 + (self.spec_motorized.motor.rawLoadPercentage*9)
						-- self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin
						-- self.spec_motorized.motor.maxForwardGearRatio = self.spec_motorized.motor.maxForwardGearRatioOrigin
						-- self.spec_motorized.motor.minBackwardGearRatio=self.spec_motorized.motor.minBackwardGearRatioOrigin
						-- self.spec_motorized.motor.maxBackwardGearRatio=self.spec_motorized.motor.maxBackwardGearRatioOrigin
						
						-- TMS like
						-- wenn Tempomat aus, wird die Tempomatgescwindigkeit als Steps der maxSpeed benutzt
						if spec.isTMSpedal == 0 or 1 then
							if self.spec_motorized.motor ~= nil and self.spec_motorized.motor.lastAcceleratorPedal > 0.03 then
								-- if self:getDamageAmount() > 0.7 and spec.forDBL_critdamage == 1 and spec.forDBL_critheat == 1 then
								if spec.forDBL_critdamage == 1 and spec.forDBL_critheat == 1 then -- Notlauf
									self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin / 2 * self.spec_motorized.motor.lastAcceleratorPedal
									self.spec_motorized.motor.maxBackwardSpeed=self.spec_motorized.motor.maxBackwardSpeedOrigin / 1.2 * self.spec_motorized.motor.lastAcceleratorPedal
									-- self.spec_motorized.motor.accelerationLimit = 0.25
									self.spec_motorized.motor.lowBrakeForceScale=math.max(self.spec_motorized.motor.lowBrakeForceScale * (1 - spec.ClutchInputValue),0.04)
									self.spec_motorized.motor.accelerationLimit = math.min(self.spec_motorized.motor.accelerationLimit * (1 - spec.ClutchInputValue),0.25)
								elseif spec.forDBL_critdamage == 0 then -- Normalbetrieb
									if spec.vOne == 2 then
										if self.spec_motorized.motor.lastAcceleratorPedal >= 0.9 then
											self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin / 1.5 	/ 4 * spec.vTwo
											self.spec_motorized.motor.maxBackwardSpeed= self.spec_motorized.motor.maxBackwardSpeedOrigin
											-- self.spec_motorized.motor.maxBackwardSpeed= self.spec_motorized.motor.maxBackwardSpeedOrigin 		/ 4 * spec.vTwo
										else
											-- self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin / 1.5 	/ 4 * spec.vTwo * math.abs(self.spec_drivable.axisForward)
											-- self.spec_motorized.motor.maxBackwardSpeed= self.spec_motorized.motor.maxForwardSpeedOrigin / 1.5 	/ 4 * spec.vTwo * math.abs(self.spec_drivable.axisForward)
											self.spec_motorized.motor.maxForwardSpeed  = (self.spec_motorized.motor.maxForwardSpeedOrigin / 1.5	/ 4 * spec.vTwo) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
											self.spec_motorized.motor.maxBackwardSpeed = (self.spec_motorized.motor.maxBackwardSpeedOrigin)
											-- self.spec_motorized.motor.maxBackwardSpeed = (self.spec_motorized.motor.maxBackwardSpeedOrigin)						 * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
										end
										
										-- Clutchpedal as Inching -pedal
										self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeed * (1.6 - spec.ClutchInputValue)
										self.spec_motorized.motor.maxBackwardSpeed=self.spec_motorized.motor.maxBackwardSpeed * (1.8 - spec.ClutchInputValue)
										
									elseif spec.vOne == 1 then
										self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin / 4 * spec.vTwo
										self.spec_motorized.motor.maxBackwardSpeed=self.spec_motorized.motor.maxBackwardSpeedOrigin / 4 * spec.vTwo
									end
									self.spec_motorized.motor.lowBrakeForceScale = math.max(self.spec_motorized.motor.lowBrakeForceScale * (1 - spec.ClutchInputValue),0.04)
									self.spec_motorized.motor.accelerationLimit = 			self.spec_motorized.motor.accelerationLimit  * (1 - spec.ClutchInputValue)
									
									
								else
									self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin * (1 - spec.ClutchInputValue)
									self.spec_motorized.motor.maxBackwardSpeed=self.spec_motorized.motor.maxBackwardSpeedOrigin * (1 - spec.ClutchInputValue)
								end
							end
						end
						
						
						-- smoothing nicht im Leerlauf
						if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm + 20 then
							if self.spec_motorized.motor.smoothedLoadPercentage < 0.2 then
							-- if self:getLastSpeed() >= 1 then
								-- Gaspedal and Variator
								-- spec.smoother = spec.smoother + dt;
								-- if spec.smoother ~= nil and spec.smoother > 10 then -- Drehzahl zucken eliminieren
									-- spec.smoother = 0;
								if self:getLastSpeed() > 0.5 then 
									self.spec_motorized.motor.lastMotorRpm = math.max(math.max(math.max(math.min((self:getLastSpeed() * math.abs(math.max(self.spec_motorized.motor.rawLoadPercentage, 0.55)))*42, self.spec_motorized.motor.maxRpm*0.99), self.spec_motorized.motor.minRpm+203), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm*spec.HandgasPercent)
									if cvtaDebugCVTxOn == true then
										-- print("0: " .. tostring(self:getLastSpeed()))
									end
									-- Drehzahl Erhöhung angleichen zur Motorbremswirkung, wenn Pedal losgelassen wird MODERN
									if math.max(0, self.spec_drivable.axisForward) < 0.1 then
										-- self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm * mcRPMvar + (self:getLastSpeed() * 14), self.spec_motorized.motor.maxRpm)
										self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm + (math.abs(self:getLastSpeed()) * 14), self.spec_motorized.motor.maxRpm)
										-- self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage - (self:getLastSpeed() / 50)
										if cvtaDebugCVTon == true then
											print("#### Angleichen zur Motorbremswirkung, Pedal losgelassen: " .. math.min(self.spec_motorized.motor.lastMotorRpm * mcRPMvar + (self:getLastSpeed() * 14), self.spec_motorized.motor.maxRpm))
										end
									end
								end
								-- end -- smooth
							end
														
							-- Nm kurven für unterschiedliche Lasten, Berücksichtigung pto MODERN
							if self.spec_motorized.motor.smoothedLoadPercentage < 0.4 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 1 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*1)
								if self.spec_motorized.motorTemperature ~= nil then
									self.spec_motorized.motorTemperature.heatingPerMS = 0.0015
									-- self.spec_motorized.motorTemperature.coolingPerMS = 0.002
									
								end
							end
							if self.spec_motorized.motor.smoothedLoadPercentage >= 0.4 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.5 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.99 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*1)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.5 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.65 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.982 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*1)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.65 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.7 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.985 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.99)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.7 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.75 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.989 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.99)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.75 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.993 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.99)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.8 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.85 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.995 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.99)
								-- self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * ((self.spec_motorized.motor.smoothedLoadPercentage/9.95)+0.908) * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.85 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.9 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.998 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.99)
								-- self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * ((self.spec_motorized.motor.smoothedLoadPercentage/9.95)+0.905) * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.9 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.99 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 1 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.99)
								-- self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * ((self.spec_motorized.motor.smoothedLoadPercentage/9.95)+0.90) * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.87)
							end
							
							-- Drehzahl Erhöhung sobald Pedal aktiviert wird zur Fahrt H
							if math.max(0, self.spec_drivable.axisForward) >= 0.02 and self:getLastSpeed() <= 7 then 
								self.spec_motorized.motor.lastMotorRpm = math.max(math.max(math.min(self.spec_motorized.motor.lastMotorRpm * 1.01, self.spec_motorized.motor.maxRpm*0.99), self.spec_motorized.motor.minRpm+323), self.spec_motorized.motor.lastPtoRpm*0.99)
								if cvtaDebugCVTon == true then
									print("#### Drehzahl Erhöhung sobald Pedal aktiviert wird zur Fahrt: " .. math.max(math.max(math.min(self.spec_motorized.motor.lastMotorRpm * 1.01, self.spec_motorized.motor.maxRpm*0.99), self.spec_motorized.motor.minRpm+323), self.spec_motorized.motor.lastPtoRpm*0.99))
									print("#### self:getDamageAmount(): " .. self:getDamageAmount())
								end
							end
						end
					end -- Havester Curves.
					
					
					if cvtaDebugCVTu2on then
						print("CVTa: spec.CVTdamage: " .. tostring(spec.CVTdamage))
					end
				end -- isMotorStarted

				if cvtaDebugCVTuOn == true then
					print("motorFan.enabled: " .. tostring(self.spec_motorized.motorFan.enabled))
					print("smoothedLoadPercentage: " .. tostring(self.spec_motorized.motor.smoothedLoadPercentage))
					print("rawLoadPercentage     : " .. tostring(self.spec_motorized.motor.rawLoadPercentage))
				end
				-- self.spec_motorized.motor.equalizedMotorRpm = self.spec_motorized.motor.lastMotorRpm
				-- self.spec_motorized.motor.lastRealMotorRpm = self.spec_motorized.motor.lastMotorRpm
				
				-- DBL convert Pedalposition and/or PedalVmax
				spec.forDBL_pedalpercent = string.format("%.1f", ( self.spec_drivable.axisForward*100 ))
				spec.forDBL_tmspedalvmax = math.min(string.format("%.1f", (( self:getCruiseControlSpeed()*math.pi) )), self.spec_motorized.motor.maxForwardSpeed*math.pi)
				spec.forDBL_tmspedalvmaxactual = math.min(string.format("%.1f", (( self:getCruiseControlSpeed()*math.pi) )*self.spec_drivable.axisForward), self.spec_motorized.motor.maxForwardSpeed*math.pi)
				if spec.autoDiffs ~= 1 then
					spec.forDBL_autodiffs = 0 -- inaktiv
				end
				if spec.CVTdamage ~= nil then
					spec.forDBL_cvtwear = spec.CVTdamage
				else
					spec.forDBL_cvtwear = 0.00
					spec.CVTdamage = 0.000
				end
				
				
				if spec.autoDiffs == 1 then
					if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 or spec.CVTconfig == 7 or spec.CVTconfig == 11 then
						if spec.vOne == 1 then
							spec.forDBL_autodiffs = 0 -- Vorwahl und inaktiv
							spec.forDBL_preautodiffs = 1 -- Vorwahl und inaktiv
						elseif spec.vOne == 2 then
							spec.forDBL_autodiffs = 1 -- aktiv
							spec.forDBL_preautodiffs = 0 -- aktiv
						end
					elseif spec.CVTconfig == 4 or spec.CVTconfig == 5 or spec.CVTconfig == 6 then
						if spec.vOne >= 1 then
							if self:getLastSpeed() <= 16 then
								spec.forDBL_autodiffs = 1 -- aktiv
								spec.forDBL_preautodiffs = 0 -- aktiv
							else
								spec.forDBL_autodiffs = 0 -- Vorwahl
								spec.forDBL_preautodiffs = 1 -- Vorwahl
							
							end
						end
					end
				elseif spec.autoDiffs ~= 1 then
					spec.forDBL_autodiffs = 0 -- inaktiv
					spec.forDBL_preautodiffs = 0 -- inaktiv
				end
				-- spec.forDBL_cvtwear = math.max(math.min(spec.CVTdamage, 100), 0) -- integer

				-- Brainstorm for later:
					-- DebugUtil.printTableRecursively()
					-- self.spec_motorized.consumersByFillType[FillType.DEF]
					-- rpm at vmax new gen    40 = 950; 50 = 1250; 60 = 1450;
				
			end
			
			-- DevTools
			if VcvtaResetWear == true then
				spec.forDBL_cvtwear = 0.00
				spec.CVTdamage = 0.000
				spec.forDBL_critheat = 0
				spec.forDBL_warnheat = 0
				spec.forDBL_critdamage = 0
				spec.forDBL_warndamage = 0
				print("CVTa: Verschleiß und Warnings wurden für dieses Fahrzeug zurückgesetzt")
				VcvtaResetWear = false
			end
			
					
			-- if g_server ~= nil then	end
			if debug_for_DBL then
				print("AOD####################################################################")
				print("spec.forDBL_drivinglevel: " .. spec.forDBL_drivinglevel)
				print("spec.vOne: " .. spec.vOne)
				print("spec.forDBL_accramp: " .. spec.forDBL_accramp)
				print("spec.vTwo: " .. spec.vTwo)
				print("-------------------------------------------------------------")
				print("spec.forDBL_brakeramp: " .. spec.forDBL_brakeramp)
				print("spec.vThree: " .. spec.vThree)
				print("-------------------------------------------------------------")
				print("spec.forDBL_warnheat: " .. spec.forDBL_warnheat)
				print("spec.forDBL_warndamage: " .. spec.forDBL_warndamage)
				print("spec.forDBL_critheat: " .. spec.forDBL_critheat)
				print("spec.forDBL_critdamage: " .. spec.forDBL_critdamage)
				print("spec.CVTdamage: " .. spec.CVTdamage)
				print("spec.forDBL_cvtwear: " .. spec.forDBL_cvtwear)
				-- print("-------------------------------------------------------------")
				-- print("spec.forDBL_neutral: " .. spec.forDBL_neutral)
				print("spec.CVTCanStart: " .. tostring(spec.CVTCanStart))
				print("spec.forDBL_motorcanstart: " .. tostring(spec.forDBL_motorcanstart))
				print("-------------------------------------------------------------")
				print("spec.forDBL_autodiffs: " .. tostring(spec.forDBL_autodiffs))
				print("spec.autoDiffs: " .. tostring(spec.autoDiffs))
				print("-------------------------------------------------------------")
				print("spec.forDBL_tmspedal: " .. tostring(spec.forDBL_tmspedal))
				print("spec.isTMSpedal: " .. tostring(spec.isTMSpedal))
				print("spec.forDBL_tmspedalvmax: " .. spec.forDBL_tmspedalvmax)
				print("spec.forDBL_pedalpercent: " .. spec.forDBL_pedalpercent)
				print("spec.forDBL_tmspedalvmaxactual: " .. spec.forDBL_tmspedalvmaxactual)
				print("-------------------------------------------------------------")
				print("spec.forDBL_digitalhandgasstep: " .. spec.forDBL_digitalhandgasstep)
				print("spec.vFive: " .. spec.vFive)
				-- print("spec.RpmInputValue: " .. spec.RpmInputValue)
				print("spec.HandgasPercent: " .. spec.HandgasPercent)
				print("-------------------------------------------------------------")
				print("spec.forDBL_rpmrange: " .. spec.forDBL_rpmrange)
				print("-------------------------------------------------------------")
				print("spec.forDBL_rpmdmin: " .. spec.forDBL_rpmdmin)
				print("-------------------------------------------------------------")
				print("spec.forDBL_rpmdmax: " .. spec.forDBL_rpmdmax)
				print("-------------------------------------------------------------")
				print("spec.forDBL_ipmactive: " .. spec.forDBL_ipmactive)
				print("-------------------------------------------------------------")
				print("spec.forDBL_rpmrange: " .. spec.forDBL_rpmrange)
				print("EOD_________________________________________________________________________")
			end -- isVarioTM
			
			if spec.CVTCanStart == true then
				spec.forDBL_motorcanstart = 1
			else
				spec.forDBL_motorcanstart = 0
			end
			
			-- motor need warmup and show it for manual transmissions.
			
			if spec.isVarioTM == false and not isPKWLKW and spec.CVTconfig ~= 8 and spec.CVTconfig ~= 0 then
				if self.spec_motorized.motorTemperature.value < 50 then
					spec.forDBL_motorcoldlamp = 1
					self:raiseActive()
					if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.maxRpm / 1.4 then
						self:addDamageAmount(self.spec_motorized.motor.lastMotorRpm * 0.0000007 * self.spec_motorized.motor.smoothedLoadPercentage, true)
					end 
				else
					spec.forDBL_motorcoldlamp = 0
				end 
			end 
			
			-- print("motorAppliedTorque: " .. self.spec_motorized.motor.motorAppliedTorque)
			-- print("maxAcceleration: " .. self.spec_motorized.motor.maxAcceleration)
			-- print("self:getClutchPedal(): " ..  tostring(self:getClutchPedal() ))
	else
		-- set Acceleration of CVT-Addon deactivated vehicle, so that they don't cheating faster than others
		self.spec_motorized.motor.accelerationLimit = 1.6
	end -- if spec.CVTconfig deactivated
	
	-- manual shifter set to manual config, if not disabled
	if not spec.isVarioTM and not isPKWLKW and spec.CVTconfig ~= 8 then
		spec.CVTconfig = 9
	end
end -- onUpdate

addConsoleCommand("cvtaResetWear", "resetts the cvt wear", "FcvtaResetWear", CVTaddon)
function CVTaddon:FcvtaResetWear()
	VcvtaResetWear = true
end

addConsoleCommand("cvtaPrintTable", "prints Table Recursively", "DprintTableRecursively", self)
function CVTaddon:DprintTableRecursively(paramTable)
	if paramTable ~= nil then
		DebugUtil.printTableRecursively(paramTable, "- " , 0, 50)
	else
		print("table angeben!")
		print("cvtaPrintTable [table]")
		print("z.B.: cvtaPrintTable self.spec_frontloaderAttacher")
	end
end

addConsoleCommand("cvtaVER", "Versions CVT-Addon", "cCVTaVer", CVTaddon)
function CVTaddon:cCVTaVer()
	print("CVT-Addon Mod Version: " .. modversion)
	print("CVT-Addon Script Version: " .. scrversion)
	print("CVT-Addon Date: " .. lastupdate)
end

addConsoleCommand("CvTaHB", "Versions CVT-Addon", "cCVTaHappyBirthday", CVTaddon)
function CVTaddon:cCVTaHappyBirthday(bdayuser)
	print(" ")
	print(" ")
	print(" ")
	print("° ")
	print("*___________________________________________________/\\")
	print(" |¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯SbSh-PooL¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯|\\")
	print(" |   Das Team vom CVT-Addon und das Script selbst,   |¯")
	print(" |   wünschen allen Geburtstagskindern frohe Ostern. |")
	print(" |   365 Tage Freude wie heute,                      |")
	print(" |   525.600 Minuten Zufriedenheit,                  |")
	print(" |   genieße die Jahre und die Zeit!                 |")
	print(" |   Ostern? 365 Tage/Jahr gibt's B-Day's der Leute, |")
	print(" |   alle anderen Feierlichkeiten, ebenso wunderbar- |")
	print(" |   gibt's nur einmal im Jahr'.                     |")
	print(" |___________________________________________________|")
	print(" ´¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯`")
	print(" ")
	if bdayuser == nil then
		bdayuser = ""
	end
	g_currentMission:showBlinkingWarning("H a p p y   B i r t h d a y ".. tostring(bdayuser) .. " !", 20480)
end

addConsoleCommand("cvtaDebugDBL", "Debug CVT-Addon DBL Values", "cCVTaDBL", CVTaddon)
function CVTaddon:cCVTaDBL()
	-- local spec = self.spec_CVTaddon
	if debug_for_DBL == true then
		print("CVTa: DBL Debug disabled")
		debug_for_DBL = false
	elseif debug_for_DBL == false then
	print("CVTa: DBL Debug enabled")
		debug_for_DBL = true
	end
end

addConsoleCommand("cvtaDebugWT", "Debug CVT-Addon", "cCVTaCVTwt", CVTaddon)
function CVTaddon:cCVTaCVTwt()
	-- local spec = self.spec_CVTaddon
	if sbshDebugWT == true then
		print("CVTa: Verschleiß Debug disabled")
		sbshDebugWT = false
	elseif sbshDebugWT == false then
		print("CVTa: Verschsleiß Debug enabled")
		sbshDebugWT = true
	end
end

addConsoleCommand("cvtaDebugCVT", "Debug CVT-Addon", "cCVTaCVTdg", CVTaddon)
function CVTaddon:cCVTaCVTdg()
	-- local spec = self.spec_CVTaddon
	if cvtaDebugCVTon == true then
		print("CVTa: Debug disabled")
		cvtaDebugCVTon = false
	elseif cvtaDebugCVTon == false then
		print("CVTa: Debug enabled")
		cvtaDebugCVTon = true
	end
end

addConsoleCommand("cvtaDebugCVTx", "Debug CVT-Addon xtra", "cCVTaCVTdgx", CVTaddon)
function CVTaddon:cCVTaCVTdgx()
	-- local spec = self.spec_CVTaddon
	if cvtaDebugCVTxOn == true then
		print("CVTa: Fly Debug disabled")
		cvtaDebugCVTxOn = false
	elseif cvtaDebugCVTxOn == false then
		print("CVTa: Fly Debug enabled")
		cvtaDebugCVTxOn = true
	end
end

addConsoleCommand("cvtaDebugTableACHTUNG", "Debug Table print", "cCVTaCVTdTbl", CVTaddon)
function CVTaddon:cCVTaCVTdTbl()
	-- local spec = self.spec_CVTaddon
	if debugTable == true then
		print("CVTa: debugTable Debug disabled")
		debugTable = false
		firstTimeRun = nil
	elseif debugTable == false then
		print("CVTa: debugTable Debug enabled")
		debugTable = true
	end
end

addConsoleCommand("cvtaDebugCVTheat", "Debug CVT-Addon xtra", "cCVTaCVTheat", CVTaddon)
function CVTaddon:cCVTaCVTheat()
	-- local spec = self.spec_CVTaddon
	if cvtaDebugCVTheatOn == true then
		print("CVTa: Heat Debug disabled")
		cvtaDebugCVTheatOn = false
	elseif cvtaDebugCVTheatOn == false then
		print("CVTa: Heat Debug enabled")
		cvtaDebugCVTheatOn = true
	end
end

addConsoleCommand("cvtaDebugCVTcanStart", "Debug CVT-Addon start", "cCVTaCVTstart", CVTaddon)
function CVTaddon:cCVTaCVTstart()
	-- local spec = self.spec_CVTaddon
	if cvtaDebugCVTcanStartOn == true then
		print("CVTa: Start Debug disabled")
		cvtaDebugCVTcanStartOn = false
	elseif cvtaDebugCVTcanStartOn == false then
		print("CVTa: Start Debug enabled")
		cvtaDebugCVTcanStartOn = true
	end
end

addConsoleCommand("cvtaDebugCVTu", "Debug CVT-Addon xtra", "cCVTaCVTupd", CVTaddon)
function CVTaddon:cCVTaCVTupd()
	-- local spec = self.spec_CVTaddon
	if cvtaDebugCVTuOn == true then
		print("CVTa: Upd Debug disabled")
		cvtaDebugCVTuOn = false
	elseif cvtaDebugCVTuOn == false then
		print("CVTa: Upd Debug enabled")
		cvtaDebugCVTuOn = true
	else
		print("CVTa: Upd Debug enabled *forced")
		cvtaDebugCVTuOn = true
	end
end

addConsoleCommand("cvtaDebugCVTu2", "Debug CVT-Addon xtra", "cCVTaCVTupd2", CVTaddon)
function CVTaddon:cCVTaCVTupd2()
	-- local spec = self.spec_CVTaddon
	if cvtaDebugCVTu2on == true then
		print("CVTa: Upd2 Debug disabled")
		cvtaDebugCVTu2on = false
	elseif cvtaDebugCVTu2on == false then
		print("CVTa: Upd2 Debug enabled")
		cvtaDebugCVTu2on = true
	else
		print("CVTa: Upd2 Debug enabled *forced")
		cvtaDebugCVTu2on = true
	end
end

addConsoleCommand("cvtaSETcfg", "Versions CVT-Addon", "cCVTaSetCfg", CVTaddon)
function CVTaddon:cCVTaSetCfg(c)
	local spec = self.spec_CVTaddon
	print("CVT-Addon Sets " .. tostring(c))
	print("CVT-Addon Sets Config from: " .. tostring(spec.CVTconfig))
	spec.CVTconfig = c
	print("to " .. spec.CVTconfig)
end

----------------------------------------------------------------------------------------------------------------------	
----------------------------------------------------------------------------------------------------------------------			
------------- Should be external in CVT_Addon_HUD.lua, but I can't sync spec between 2 lua's -------------------------			
function CVTaddon:onDraw(dt)
	local spec = self.spec_CVTaddon
	-- fix for the issue with the göweil dlc "and g_currentMission.controlledVehicle ~= nil" thanks glowin
	if g_client ~= nil and g_currentMission.controlledVehicle ~= nil then
		-- motor need warmup and show it for manual transmissions.
		if g_currentMission.hud.isVisible and spec.isVarioTM == false and not isPKWLKW and spec.CVTconfig ~= 8 and spec.CVTconfig ~= 0 and self.getIsEntered ~= nil and self:getIsEntered() then
			local TposX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX - g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY - 0.02
			local TposY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY + g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY
			-- COLD
			spec.CVTIconMScold:setColor(1, 1, 1, 1)
			spec.CVTIconMScold:setPosition(TposX, TposY+0.01)
			spec.CVTIconMScold:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
			spec.CVTIconMScold:setScale(0.025*g_gameSettings.uiScale, 0.05*g_gameSettings.uiScale)
			if self.spec_motorized.motorTemperature.value <= 51 then
				spec.CVTIconMScold:render()
				
			end
			
			-- OK
			spec.CVTIconMSok:setColor(1, 1, 1, 1)
			spec.CVTIconMSok:setPosition(TposX, TposY+0.01)
			spec.CVTIconMSok:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
			spec.CVTIconMSok:setScale(0.025*g_gameSettings.uiScale, 0.05*g_gameSettings.uiScale)
			if self.spec_motorized.motorTemperature.value > 51 and self.spec_motorized.motorTemperature.value < 93 then
				spec.CVTIconMSok:render()
			end
			
			-- WARN
			spec.CVTIconMSwarn:setColor(1, 1, 1, 1)
			spec.CVTIconMSwarn:setPosition(TposX, TposY+0.01)
			spec.CVTIconMSwarn:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
			spec.CVTIconMSwarn:setScale(0.025*g_gameSettings.uiScale, 0.05*g_gameSettings.uiScale)
			if self.spec_motorized.motorTemperature.value >= 93 and self.spec_motorized.motorTemperature.value < 98 then
				spec.CVTIconMSwarn:render()
			end
			
			-- CRIT
			spec.CVTIconMScrit:setColor(1, 1, 1, 1)
			spec.CVTIconMScrit:setPosition(TposX, TposY+0.01)
			spec.CVTIconMScrit:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
			spec.CVTIconMScrit:setScale(0.025*g_gameSettings.uiScale, 0.05*g_gameSettings.uiScale)
			if self.spec_motorized.motorTemperature.value <= 51 and self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.maxRpm / 1.54 then
				spec.CVTIconMScrit:render()
			end
		end
		
		if spec.CVTconfig ~= 8 and CVTaddon.PoH ~= 3 then
			-- local spec = self.spec_CVTaddon
			local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName)
			local StI = storeItem.categoryName
			local isTractor = StI == "TRACTORSS" or StI == "TRACTORSM" or StI == "TRACTORSL"
			local isErnter = StI == "HARVESTERS" or StI == "FORAGEHARVESTERS" or StI == "POTATOVEHICLES" or StI == "BEETVEHICLES" or StI == "SUGARCANEVEHICLES" or StI == "COTTONVEHICLES" or StI == "MISCVEHICLES"
			local isLoader = StI == "FRONTLOADERVEHICLES" or StI == "TELELOADERVEHICLES" or StI == "SKIDSTEERVEHICLES" or StI == "WHEELLOADERVEHICLES"
			local isPKWLKW = StI == "CARS" or StI == "TRUCKS"
			local isWoodWorker = storeItem.categoryName == "WOODHARVESTING"
			local isFFF = storeItem.categoryName == "FORKLIFTS"
			
			if g_currentMission.hud.isVisible and spec.isVarioTM == true then
				-- calculate position and size
				local uiScale = g_gameSettings.uiScale;
				
				local ptmsX, ptmsY = g_currentMission.inGameMenu.hud.speedMeter.cruiseControlElement:getPosition()
				-- v |   + hoch
				local posX
				local posY
				if CVTaddon.PoH == 1 then
					posX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1) - (0.035*g_gameSettings.uiScale)
					posY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY
				elseif CVTaddon.PoH == 2 then
					posX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX + 0.06
					posY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY + (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 2.4) + (0.035*g_gameSettings.uiScale)
				end
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
					-- local isPTO = false
					-- if spec.lastPTORot ~= nil then
						-- if spec.lastPTORot > self.spec_motorized.motor.minRpm then
							-- isPTO = true
						-- end
					-- end
					local warnTempC = { 0.4, 1, 0, math.max(math.min(spec.transparendSpdT, 0.7), 0.1) }
					local critTempC = { 1, 0, 0.4, math.max(math.min(spec.transparendSpdT, 0.7), 0.1) }
					local coldTempC = { 0, 0, 1, math.max(math.min(spec.transparendSpdT, 0.7), 0.1) }
					local warnDmgC = { 0, 0.5, 1, math.max(math.min(spec.transparendSpdT, 0.7), 0.1) }
					local critDmgC = { 1, 0.3, 0, math.max(math.min(spec.transparendSpdT, 0.7), 0.1) }
					
					local HgColour = { 0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1) }
					
					if spec.vFive == nil then -- fix for mp nil at first HG use/unuse
						spec.vFive = 0
					end
					if spec.vFive ~= nil and spec.vFive == 9 then
						HgColour = { 1, 0.5, 0.2, 1 }
					-- elseif spec.vFive ~= nil and spec.vFive >= 10 then
						
					end
					local HgRColour = { 1, 0.2, 0.2, 1 }
					spec.CVTIconBg:setColor(0.01, 0.01, 0.01, math.max(math.min(spec.transparendSpd, 0.6), 0.2))
					spec.CVTIconFb:setColor(0, 0, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))
					spec.CVTIconFs1:setColor(0, 0.9, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))
					spec.CVTIconFs2:setColor(0, 0.9, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))
					spec.CVTIconPtms:setColor(0, 0.9, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))

					spec.CVTIconHg2:setColor(unpack(HgColour))
					spec.CVTIconHg3:setColor(unpack(HgColour))
					spec.CVTIconHg4:setColor(unpack(HgColour))
					spec.CVTIconHg5:setColor(unpack(HgColour))
					spec.CVTIconHg6:setColor(unpack(HgColour))
					spec.CVTIconHg7:setColor(unpack(HgColour))
					spec.CVTIconHg8:setColor(unpack(HgColour))
					spec.CVTIconHg9:setColor(unpack(HgColour))
					if spec.vFive ~= nil and spec.vFive == 9 then
						spec.CVTIconHg10:setColor(unpack(HgColour))
					elseif spec.vFive ~= nil and spec.vFive >= 10 then
						spec.CVTIconHg10:setColor(unpack(HgRColour))
					end
										if spec.forDBL_critheat == 1 then
						spec.CVTIconHEAT:setColor(unpack(critTempC))
					end
					if spec.forDBL_warnheat == 1 and spec.forDBL_critheat ~= 1 then
						spec.CVTIconHEAT:setColor(unpack(warnTempC))
					end
					
					if spec.forDBL_warnheat == 1 and spec.forDBL_critheat == 1 then
						spec.CVTIconHEAT:setColor(unpack(critTempC))
					end
					if self.spec_motorized.motorTemperature.value < 50 then
						spec.CVTIconHEAT:setColor(unpack(coldTempC))
					end
					if spec.forDBL_warndamage == 1 then
						spec.CVTIconDmg:setColor(unpack(warnDmgC))
					end
					if spec.forDBL_critdamage == 1 then
						spec.CVTIconDmg:setColor(unpack(critDmgC))
					end
					if spec.forDBL_warndamage == 1 and spec.forDBL_critdamage == 1 then
						spec.CVTIconDmg:setColor(unpack(critDmgC))
					end
					
					
					
					spec.CVTIconAr1:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1)) 
					spec.CVTIconAr2:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
					spec.CVTIconAr3:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
					spec.CVTIconAr4:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
					
					spec.CVTIconBr1:setColor(0.6, 0.1, 0.1, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1)) 
					spec.CVTIconBr2:setColor(0.6, 0.1, 0.1, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
					spec.CVTIconBr3:setColor(0.6, 0.1, 0.1, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
					spec.CVTIconBr4:setColor(0.6, 0.1, 0.1, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
					
					spec.CVTIconHydro:setColor(0.8, 0.1, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
					-- spec.CVTIconN:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
					-- spec.CVTIconN2:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
					
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
					
					spec.CVTIconDmg:setPosition(posX-0.01, posY+0.012)
					spec.CVTIconHEAT:setPosition(posX-0.01, posY)
					
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
					-- spec.CVTIconN2:setPosition(posX-0.01, posY)
					
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
					spec.CVTIconHEAT:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
					spec.CVTIconDmg:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
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
					-- spec.CVTIconN2:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
					
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
					spec.CVTIconHEAT:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
					spec.CVTIconDmg:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
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
					-- spec.CVTIconN2:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
					
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
					if spec.forDBL_critdamage ~= 0 then
						spec.CVTIconDmg:render()
					end
					if self:getIsMotorStarted() then
						if spec.vOne == 2 then
							if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 or spec.CVTconfig == 7 or spec.CVTconfig == 10 or spec.CVTconfig == 11 then
								spec.CVTIconFs1:render()
							end
						elseif spec.vOne == 1 then
							if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 or spec.CVTconfig ==  7 or spec.CVTconfig == 10 or spec.CVTconfig == 11 then
								spec.CVTIconFs2:render()
							end
						end
						-- if spec.vOne >= 1 then
						if spec.CVTconfig == 4 or spec.CVTconfig == 5 or spec.CVTconfig == 6 then
							spec.CVTIconFs1:render()
							spec.CVTIconFs2:render()
						end
						-- end
						if spec.isTMSpedal == 1 then
						local tmsSpeed = string.format("%.1f", math.min((self:getCruiseControlSpeed() ) * math.pi, self.spec_motorized.motor.maxForwardSpeed * math.pi))
							spec.CVTIconPtms:render()
							if self:getCruiseControlState() == 0 then
								renderText(ptmsX+0.006, ptmsY-0.002, size, tmsSpeed)
							end
						end
						
						-- VCA DiffLocks AutoDiffsAWD
						if spec.autoDiffs == 1 then
							if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 or spec.CVTconfig == 7 or spec.CVTconfig == 11 then
								if spec.vOne == 1 then
									setTextColor(0.8, 0.8, 0, 0.8)
									setTextAlignment(RenderText.ALIGN_LEFT)
									setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
									setTextBold(false)
									spec.forDBL_autodiffs = 0 -- Vorwahl und inaktiv
									spec.forDBL_preautodiffs = 1 -- Vorwahl und inaktiv
								elseif spec.vOne == 2 then
									setTextColor(0, 0.95, 0, 0.8)
									setTextAlignment(RenderText.ALIGN_LEFT)
									setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
									setTextBold(false)
									spec.forDBL_autodiffs = 1 -- aktiv
									spec.forDBL_preautodiffs = 0 -- aktiv
								end
								renderText( 0.485 * ( VCAposX + VCAwidth + 1 ), VCAposY + 0.2 * VCAheight, VCAl + 0.005, "A" )
							elseif spec.CVTconfig == 4 or spec.CVTconfig == 5 or spec.CVTconfig == 6 then
								if spec.vOne >= 1 then
									setTextColor(0, 0.95, 0, 0.8)
									setTextAlignment(RenderText.ALIGN_LEFT)
									setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
									setTextBold(false)
									if self:getLastSpeed() <= 16 then
										spec.forDBL_autodiffs = 1 -- aktiv
										spec.forDBL_preautodiffs = 0 -- aktiv
									else
										spec.forDBL_autodiffs = 0 -- Vorwahl
										spec.forDBL_preautodiffs = 1 -- Vorwahl
									
									end
								end
								renderText( 0.485 * ( VCAposX + VCAwidth + 1 ), VCAposY + 0.2 * VCAheight, VCAl + 0.005, "A" )
							end
						elseif spec.autoDiffs ~= 1 then
							spec.forDBL_autodiffs = 0 -- inaktiv
							spec.forDBL_preautodiffs = 0 -- inaktiv
						end
						
						-- PTO hud icon changed to warning indicator
						if spec.forDBL_warnheat ~= 0 or spec.forDBL_critheat ~= 0 then
							spec.CVTIconHEAT:render()
						end
						if self.spec_motorized.motorTemperature.value < 50 and spec.CVTconfig ~= 10 then
							spec.CVTIconHEAT:render() -- for cold
						end
						if spec.forDBL_warndamage ~= 0 then
							spec.CVTIconDmg:render()
						end
						if spec.vFive ~= 0 and spec.vFive ~= nil then
							if spec.vFive == 1 then
								spec.CVTIconHg2:render()
							elseif spec.vFive == 2 then
								spec.CVTIconHg3:render()
							elseif spec.vFive == 3 then
								spec.CVTIconHg4:render()
							elseif spec.vFive == 4 then
								spec.CVTIconHg5:render()
							elseif spec.vFive == 5 then
								spec.CVTIconHg6:render()
							elseif spec.vFive == 6 then
								spec.CVTIconHg7:render()
							elseif spec.vFive == 7 then
								spec.CVTIconHg8:render()
							elseif spec.vFive == 8 then
								spec.CVTIconHg9:render()
							elseif spec.vFive >= 9 then
								spec.CVTIconHg10:render()
							end
						end
											
						if spec.vTwo == 4 then
						spec.CVTIconAr4:render()
						elseif spec.vTwo == 1 then
							spec.CVTIconAr1:render()
						elseif spec.vTwo == 2 then
							spec.CVTIconAr2:render()
						elseif spec.vTwo == 3 then
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
						
						-- if spec.CVTCanStart == 0 then
							-- spec.CVTIconN2:render()
						-- end
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
end
----------------------------------------------------------------------------------------------------------------------
-- HUD draw	end		
----------------------------------------------------------------------------------------------------------------------


-- insert help menu
function CVTaddon:loadMapDataHelpLineManager(superFunc, ...)
    if superFunc(self, ...) then
		self:loadFromXML(Utils.getFilename("helpMenu/helpMenuCVTa.xml", CVTaddon.modDirectory))
        return true
    end
    return false
end
HelpLineManager.loadMapData = Utils.overwrittenFunction(HelpLineManager.loadMapData, CVTaddon.loadMapDataHelpLineManager)
-- HelpLineManager.loadMapData = Utils.prependedFunction(HelpLineManager.loadMapData, CVTaddon.loadMapDataHelpLineManager)
-- HelpLineManager.loadMapData = Utils.appendedFunction(HelpLineManager.loadMapData, CVTaddon.loadMapDataHelpLineManager)

----------------------------------------------------------------------------------------------------------------------			
-- ----------------   Server Sync   --------------------------------

function CVTaddon.SyncClientServer(vehicle, vOne, vTwo, vThree, CVTCanStart, vFive, autoDiffs, isVarioTM, isTMSpedal, CVTconfig, warnHeat, critHeat, warnDamage, critDamage, CVTdamage, HandgasPercent, ClutchInputValue)
	local spec = vehicle.spec_CVTaddon
	spec.vOne = vOne
	spec.vTwo = vTwo
	spec.vThree = vThree
	spec.CVTCanStart = CVTCanStart
	spec.vFive = vFive
	spec.autoDiffs = autoDiffs
	-- spec.lastDirection = lastDirection
	spec.isVarioTM = isVarioTM
	spec.isTMSpedal = isTMSpedal
	-- spec.moveRpmL = moveRpmL
	-- spec.rpmDmax = rpmDmax
	-- spec.rpmrange = rpmrange
	spec.CVTconfig = CVTconfig
	spec.forDBL_warnheat = warnHeat
	spec.forDBL_critheat = critHeat
	spec.forDBL_warndamage = warnDamage
	spec.forDBL_critdamage = critDamage
	spec.CVTdamage = CVTdamage
	spec.HandgasPercent = HandgasPercent --
	spec.ClutchInputValue = ClutchInputValue
	-- spec.mcRPMvar = mcRPMvar
end								   
function CVTaddon:onReadStream(streamId, connection)
	local spec = self.spec_CVTaddon
	spec.vOne = streamReadInt32(streamId)  -- state driving level
	spec.vTwo = streamReadInt32(streamId) -- state accelerationRamp
	spec.vThree = streamReadInt32(streamId) -- state brakeRamp
	spec.CVTCanStart = streamReadBool(streamId) -- state neutral
	spec.vFive = streamReadInt32(streamId) -- state Handgas
	spec.autoDiffs = streamReadInt32(streamId) -- state autoDiffs n awd
	-- spec.lastDirection = streamReadInt32(streamId) -- backup for neutral
	spec.isVarioTM = streamReadBool(streamId) -- checks if cvt
	spec.isTMSpedal = streamReadInt32(streamId) -- checks if pedalresolution is in use
	-- spec.moveRpmL = streamReadFloat32(streamId) -- tms pedalmodus in %
	-- spec.rpmDmax = streamReadInt32(streamId) -- rpm range for max rpm
	-- spec.rpmrange = streamReadInt32(streamId) -- rpm state for max rpm
	spec.CVTconfig = streamReadInt32(streamId) -- cfg id
	spec.forDBL_warnheat = streamReadInt32(streamId) -- warnHeat
	spec.forDBL_critheat = streamReadInt32(streamId) -- critHeat
	spec.forDBL_warndamage = streamReadInt32(streamId) -- warnDamage
	spec.forDBL_critdamage = streamReadInt32(streamId) -- critDamage
	spec.CVTdamage = streamReadFloat32(streamId) -- Verschleiß
	spec.HandgasPercent = streamReadFloat32(streamId) -- Verschleiß
	spec.ClutchInputValue = streamReadFloat32(streamId) -- CVT Kupplung (new inputAction like origin)
	-- #GLOWIN-TEMP-SYNC
	if FS22_DashboardLive ~= nil and self.spec_DashboardLive ~= nil then
		--
	else
		spec.SyncMotorTemperature = streamReadFloat32(streamId)
		spec.SyncFanEnabled = streamReadBool(streamId)
		print("Sync: onReadStream")
	end
	-- Set DBL Values after read stream
	if spec.forDBL_ipmactive == nil then spec.forDBL_ipmactive = 0 end
	
	spec.forDBL_pedalpercent = "0"
	spec.forDBL_tmspedalvmax = "0"
	spec.forDBL_tmspedalvmaxactual = "0"
	
	if spec.autoDiffs == 1 then
		spec.forDBL_autodiffs = 1 -- aktiv
	else
		spec.forDBL_autodiffs = 0 -- inaktiv
	end
	if spec.isTMSpedal ~= nil then
		if spec.isTMSpedal == 0 then
			spec.forDBL_tmspedal = 0
		elseif spec.isTMSpedal == 1 then
			spec.forDBL_tmspedal = 1
		end
	end
	-- if spec.CVTCanStart ~= nil then
		-- if spec.CVTCanStart == 0 then
			-- spec.forDBL_neutral = 1
		-- elseif spec.CVTCanStart == 1 then
			-- spec.forDBL_neutral = 0
		-- end
	-- end
	if spec.vOne ~= nil then
		if spec.vOne == 1 then
			spec.forDBL_drivinglevel = tostring(2)
		elseif spec.vOne == 2 then
			spec.forDBL_drivinglevel = tostring(1)
		end
	end
	spec.forDBL_digitalhandgasstep = tostring(spec.vFive)
	if spec.vTwo ~= nil then
		if spec.vTwo == 4 then
			spec.forDBL_accramp = tostring(4)
		elseif spec.vTwo == 1 then
			spec.forDBL_accramp = tostring(1)
		elseif spec.vTwo == 2 then
			spec.forDBL_accramp = tostring(2)
		elseif spec.vTwo == 3 then
			spec.forDBL_accramp = tostring(3)
		end
	end
	spec.forDBL_rpmdmax = tostring(spec.rpmDmax)
	if spec.vThree ~= nil then
		if (spec.vThree == 1) then -- BRamp 1
			spec.forDBL_brakeramp = tostring(17) -- off
		end
		if (spec.vThree == 2) then -- BRamp 2
			spec.forDBL_brakeramp = tostring(0) -- km/h
		end
		if (spec.vThree == 3) then -- BRamp 3
			spec.forDBL_brakeramp = tostring(4) -- km/h
		end
		if (spec.vThree == 4) then -- BRamp 4
			spec.forDBL_brakeramp = tostring(8) -- km/h
		end
		if (spec.vThree == 5) then -- BRamp 5
			spec.forDBL_brakeramp = tostring(15) -- km/h
		end
	end
	spec.forDBL_warnheat = 0
	spec.forDBL_warndamage = 0
	spec.forDBL_critheat = 0
	spec.forDBL_critdamage = 0
	spec.HandgasPercent = 0.0
	spec.ClutchInputValue = 0.0
	if spec.CVTdamage ~= nil then
		spec.forDBL_cvtwear = spec.CVTdamage
	else
		spec.forDBL_cvtwear = 0.0
		spec.CVTdamage = 0.0
	end
end

function CVTaddon:onWriteStream(streamId, connection)
	local spec = self.spec_CVTaddon
	streamWriteInt32(streamId, spec.vOne)
	streamWriteInt32(streamId, spec.vTwo)
	streamWriteInt32(streamId, spec.vThree)
	streamWriteBool(streamId, spec.CVTCanStart)
	streamWriteInt32(streamId, spec.vFive)	
	streamWriteInt32(streamId, spec.autoDiffs)	
	-- streamWriteInt32(streamId, spec.lastDirection)	
	streamWriteBool(streamId, spec.isVarioTM)
	streamWriteInt32(streamId, spec.isTMSpedal)
	-- streamWriteFloat32(streamId, spec.moveRpmL)
	-- streamWriteInt32(streamId, spec.rpmDmax)
	-- streamWriteInt32(streamId, spec.rpmrange)
	streamWriteInt32(streamId, spec.CVTconfig)
	streamWriteInt32(streamId, spec.forDBL_warnheat)
	streamWriteInt32(streamId, spec.forDBL_critheat)
	streamWriteInt32(streamId, spec.forDBL_warndamage)
	streamWriteInt32(streamId, spec.forDBL_critdamage)
	streamWriteFloat32(streamId, spec.CVTdamage)
	streamWriteFloat32(streamId, spec.HandgasPercent) -- nil
	streamWriteFloat32(streamId, spec.ClutchInputValue)
	-- streamWriteFloat32(streamId, spec.mcRPMvar)
	-- #GLOWIN-TEMP-SYNC
	if FS22_DashboardLive ~= nil and self.spec_DashboardLive ~= nil then
		-- dbl will sync it
	else
		streamWriteFloat32(streamId, spec.SyncMotorTemperature)
		streamWriteBool(streamId, spec.SyncFanEnabled)
		print("Sync: onWriteStream")
	end
end

function CVTaddon:onReadUpdateStream(streamId, timestamp, connection)
	if not connection:getIsServer() then
		local spec = self.spec_CVTaddon
		if streamReadBool(streamId) then			
			spec.vOne = streamReadInt32(streamId)
			spec.vTwo = streamReadInt32(streamId)
			spec.vThree = streamReadInt32(streamId)
			spec.CVTCanStart = streamReadBool(streamId)
			spec.vFive = streamReadInt32(streamId)
			spec.autoDiffs = streamReadInt32(streamId)
			-- spec.lastDirection = streamReadInt32(streamId)
			spec.isVarioTM = streamReadBool(streamId)
			spec.isTMSpedal = streamReadInt32(streamId)
			-- spec.moveRpmL = streamReadFloat32(streamId)
			-- spec.rpmDmax = streamReadInt32(streamId)
			-- spec.rpmrange = streamReadInt32(streamId)
			spec.CVTconfig = streamReadInt32(streamId)
			spec.forDBL_warnheat = streamReadInt32(streamId) -- warnHeat
			spec.forDBL_critheat = streamReadInt32(streamId) -- critHeat
			spec.forDBL_warndamage = streamReadInt32(streamId) -- warnDamage
			spec.forDBL_critdamage = streamReadInt32(streamId) -- critDamage
			spec.CVTdamage = streamReadFloat32(streamId)
			spec.HandgasPercent = streamReadFloat32(streamId) --?
			spec.ClutchInputValue = streamReadFloat32(streamId)
			
			-- #GLOWIN-TEMP-SYNC
			if FS22_DashboardLive ~= nil and self.spec_DashboardLive ~= nil then
				-- dbl will sync it
			else
				spec.SyncMotorTemperature = streamReadFloat32(streamId)
				spec.SyncFanEnabled = streamReadBool(streamId)
					print("Sync: onReadUpdateStream")
				-- self.spec_motorized.motorTemperature.value = spec.SyncMotorTemperature -- test, damit bekommt aber der server oder host die noch falschen Daten vom client
			end
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
			streamWriteInt32(streamId, spec.vThree) --
			streamWriteBool(streamId, spec.CVTCanStart) --
			streamWriteInt32(streamId, spec.vFive)
			streamWriteInt32(streamId, spec.autoDiffs)  --
			-- streamWriteInt32(streamId, spec.lastDirection) --
			streamWriteBool(streamId, spec.isVarioTM)
			streamWriteInt32(streamId, spec.isTMSpedal) --
			-- streamWriteFloat32(streamId, spec.moveRpmL) --
			-- streamWriteInt32(streamId, spec.rpmDmax)  --
			-- streamWriteInt32(streamId, spec.rpmrange)  --
			streamWriteInt32(streamId, spec.CVTconfig)  --
			streamWriteInt32(streamId, spec.forDBL_warnheat) --
			streamWriteInt32(streamId, spec.forDBL_critheat) --
			streamWriteInt32(streamId, spec.forDBL_warndamage)
			streamWriteInt32(streamId, spec.forDBL_critdamage)
			streamWriteFloat32(streamId, spec.CVTdamage) -- 
			streamWriteFloat32(streamId, spec.HandgasPercent) -- 
			streamWriteFloat32(streamId, spec.ClutchInputValue) 
			-- streamWriteBool(streamId, spec.check
			-- #GLOWIN-TEMP-SYNC
			if FS22_DashboardLive ~= nil and self.spec_DashboardLive ~= nil then
				-- dbl will sync it
			else
				streamWriteFloat32(streamId, spec.SyncMotorTemperature)
				streamWriteBool(streamId, spec.SyncFanEnabled)
					print("Sync: onWriteUpdateStream")
			self.spec_motorized.motorTemperature.valueSend = spec.SyncMotorTemperature
			end
		end
	end
end

-- Drivable = true
-- addModEventListener(CVTaddon)
-- Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, CVTaddon.registerActionEvents)
-- Drivable.onUpdate  = Utils.appendedFunction(Drivable.onUpdate, CVTaddon.onUpdate);