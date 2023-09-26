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
local scrversion = "0.3.0.49";
local modversion = "0.9.9.71"; -- moddesc
local lastupdate = "27.09.23";
-- last change	-- dbl values, server rpm
				
-- known issue	Neutral does'n sync lastDirection mp, you have to press a forward or reward directionbutton, not change direction
-- shop configuration produced call stacks




CVTaddon = {};
CVTaddon.modDirectory = g_currentModDirectory;
source(CVTaddon.modDirectory.."events/SyncClientServerEvent.lua")
-- source(g_currentModDirectory .. "CVT_Addon_HUD.lua")  -- need to sync 'spec' between CVT_Addon.lua and CVT_Addon_HUD.lua

-- local sbshDebugOn = true;
-- local changeFlag = false;
-- local debug_for_DBL = true;

local startetATM = false;
local vcaAWDon = false
local vcaInfoUnread = true
peakMotorTorqueOrigin = 0
-- local sbshFlyDebugOn = true;

function CVTaddon.prerequisitesPresent(specializations) 
    return true
end 

function CVTaddon.registerEventListeners(vehicleType) 
	SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", CVTaddon) 
	SpecializationUtil.registerEventListener(vehicleType, "onLoad", CVTaddon)
	SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", CVTaddon)
	SpecializationUtil.registerEventListener(vehicleType, "onPostLoad", CVTaddon)
	SpecializationUtil.registerEventListener(vehicleType, "saveToXMLFile", CVTaddon)
    SpecializationUtil.registerEventListener(vehicleType, "onLeaveVehicle", CVTaddon)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdateTick", CVTaddon)
    SpecializationUtil.registerEventListener(vehicleType, "onDraw", CVTaddon)
    SpecializationUtil.registerEventListener(vehicleType, "cCVTaDBL", CVTaddon)
    -- SpecializationUtil.registerEventListener(vehicleType, "addNewStoreConfig", CVTaddon)
	
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
			local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName)
			if sbshDebugOn then
				print("storeItem.categoryName: " .. tostring(storeItem.categoryName)) -- debug
			end
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
	local pcspec = self.spec_powerConsumer
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
	spec.CVTconfig = 0
	spec.CVTcfgExists = false
	-- spec.mcRPMvar = 1
	
 -- to make it easier read with dashbord-live
	spec.forDBL_pedalpercent = tostring(self.spec_motorized.motor.lastAcceleratorPedal*100)
	spec.forDBL_rpmrange = tostring(spec.rpmDmax .. " - " .. self.spec_motorized.motor.minRpm)
	spec.forDBL_rpmDmin = tostring(0)
	spec.forDBL_autoDiffs = tostring(0)
	spec.forDBL_IPMactive = tostring(0)
	spec.forDBL_brakeramp = tostring(0)
	
	if spec.vFour ~= nil then
		if spec.isTMSpedal == 0 then
			spec.forDBL_tmspedal = 0
		elseif spec.isTMSpedal == 1 then
			spec.forDBL_tmspedal = 1
		end
	end
	if spec.vFour ~= nil then
		if spec.vFour == 0 then
			spec.forDBL_neutral = 1
		elseif spec.vFour == 1 then
			spec.forDBL_neutral = 0
		end
	end
	if spec.vOne ~= nil then
		if spec.vOne == 1 then
			spec.forDBL_drivinglevel = tostring(2)
		elseif spec.vOne == 2 then
			spec.forDBL_drivinglevel = tostring(1)
		end
	end
	spec.forDBL_digitalhandgasstep = tostring(spec.vFive)
	if spec.vTwo ~= nil then
		if spec.vTwo == 1 then
			spec.forDBL_accramp = tostring(4)
		elseif spec.vTwo == 2 then
			spec.forDBL_accramp = tostring(1)
		elseif spec.vTwo == 3 then
			spec.forDBL_accramp = tostring(2)
		elseif spec.vTwo == 4 then
			spec.forDBL_accramp = tostring(3)
		end
	end
	spec.forDBL_rpmDmax = tostring(spec.rpmDmax)
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
	schemaSavegame:register(XMLValueType.INT, "vehicles.vehicle(?).FS22_CVT_Addon.CVTaddon#configurationId")
	print("CVT_Addon: init....... ")
	print("CVT_Addon: Script...: " .. scrversion)
	print("CVT_Addon: Mod......: " .. modversion)
	print("CVT-Addon Date: " .. lastupdate)
end -- initSpecialization

function CVTaddon:onPreLoad(savegame)
	local spec = self.spec_CVTaddon
    local configurationId = Utils.getNoNil(self.configurations["CVTaddon"], 0)
	-- print("CVTa: onPreLoad configurationId noNIL " .. configurationId)
    if savegame ~= nil then
        if configurationId > 0 then
            configurationId = savegame.xmlFile:getValue(savegame.key .. ".FS22_CVT_Addon.CVTaddon#configurationId", configurationId)
            -- if configurationId < 1 or configurationId > 8 then
                -- configurationId = 1
            -- end
            self.configurations["CVTaddon"] = configurationId
			-- print("CVTa: onPreLoad configurationId " .. configurationId)
			
        end
		-- print("CVTa: onPreLoad configurationId out " .. configurationId)
    end

end

function initNewStoreConfig()
	print("CVTaREG: initNewStoreConfig ########################################################################")
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
    local intVehicles = StI == "TRACTORSS" or StI == "TRACTORSM" or StI == "TRACTORSL" or StI == "HARVESTERS" or StI == "FORAGEHARVESTERS" or StI == "POTATOVEHICLES" or StI == "BEETVEHICLES" or StI == "SUGARCANEVEHICLES" or StI == "COTTONVEHICLES" or StI == "MISCVEHICLES" or StI == "FRONTLOADERVEHICLES" or StI == "TELELOADERVEHICLES" or StI == "SKIDSTEERVEHICLES" or StI == "WHEELLOADERVEHICLES" or StI == "WOODHARVESTING" or StI == "FORKLIFTS"
    if intVehicles then
        local xmlFile = XMLFile.load("vehicle", storeItem.xmlFilename, Vehicle.xmlSchema)
        local isVario = true
        local manualShift = getXMLString(xmlFile.handle, "vehicle.motorized.motorConfigurations.motorConfiguration(?).transmission(?)#name")
		local modNamez = getXMLString(xmlFile.handle, "vehicle.storeData.name")
		-- local specspower = getXMLString(xmlFile.handle, "vehicle.storeData.specs.power")
		
		-- print("CVTa modName: " .. tostring(modNamez))
		-- print("CVTa specspower: " .. tostring(specspower))
		-- print("CVTa Getriebename: " .. tostring(manualShift))
				
		if string.find(tostring(manualShift), "cvt") or string.find(tostring(manualShift), "cvx") or string.find(tostring(manualShift), "vario") or string.find(tostring(manualShift), "stufenlos") then
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
				-- print("CVTa modName: " .. tostring(modName))
            end
        end
        delete(xmlFile.handle)

        if isVario == true and integrateConfig == true then
            local name1 = g_i18n:getText("text_CVTclas_installed_short")
            local name2 = g_i18n:getText("text_CVTclasB1_installed_short")
            local name3 = g_i18n:getText("text_CVTclasB2_installed_short")
            local name4 = g_i18n:getText("text_CVTmod_installed_short")
            local name5 = g_i18n:getText("text_CVTmodB1_installed_short")
            local name6 = g_i18n:getText("text_CVTmodB2_installed_short")
            local name7 = g_i18n:getText("text_HST_installed_short")
            local name8 = g_i18n:getText("text_CVT_notInstalled_short")
            local name9 = "manuell"
            configurations["CVTaddon"] = {
                {name = name1, index = 1, isDefault = false, price = 0, dailyUpkeep = 0, isSelectable = true},
                {name = name2, index = 2, isDefault = false, price = 750, dailyUpkeep = 0, isSelectable = true},
                {name = name3, index = 3, isDefault = false, price = 1000, dailyUpkeep = 0, isSelectable = true},
                {name = name4, index = 4, isDefault = false, price = 0, dailyUpkeep = 0, isSelectable = true},
                {name = name5, index = 5, isDefault = false, price = 750, dailyUpkeep = 0, isSelectable = true},
                {name = name6, index = 6, isDefault = false, price = 1000, dailyUpkeep = 0, isSelectable = true},
                {name = name7, index = 7, isDefault = false, price = 0, dailyUpkeep = 5, isSelectable = true},
				{name = name8, index = 8, isDefault = false, price = 0, dailyUpkeep = 0, isSelectable = true},
				{name = name9, index = 9, isDefault = false, price = 0, dailyUpkeep = 0, isSelectable = false}
            }
        end
    end
    return configurations
end
if g_configurationManager.configurations["CVTaddon"] == nil then
    initNewStoreConfig()
end

function CVTaddon:onPostLoad(savegame)
	local spec = self.spec_CVTaddon
	local configurationId = Utils.getNoNil(self.configurations["CVTaddon"], 2)
	-- spec.mcRPMvar = 1
	if g_client ~= nil then
		if self.spec_motorized ~= nil then
			if spec == nil then return end
			spec.CVTcfgExists = self.configurations["CVTaddon"] ~= nil and self.configurations["CVTaddon"] ~= 0
			
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
				spec.CVTconfig = xmlFile:getValue(key.."#configurationId", spec.CVTconfig)
				
				print("CVT_Addon: personal adjustments loaded for "..self:getName())
				print("CVT_Addon: Load Driving Level id: "..tostring(spec.vOne))
				print("CVT_Addon: Load Acceleration Ramp id: "..tostring(spec.vTwo))
				print("CVT_Addon: Load Brake Ramp id: "..tostring(spec.vThree))
			end
		end
	end -- g_client
	
	-- print("CVTa: configurationId getNoNil " .. configurationId)
	-- self.configurations["CVTaddon"] = spec.CVTcfgExists and 7 or 6 or 5 or 4 or 3 or 2 or 1
	-- self.configurations["CVTaddon"] = spec.CVTconfig and 1 or 2 or 3 or 4 or 5 or 6 or 7 or 8
	if spec.CVTcfgExists then
		-- self.configurations["CVTaddonConfigs"] = spec.CVTconfig
		spec.CVTconfig = configurationId
		print("CVTa: configurationId: " .. configurationId)
	end
	
	-- gU_targetSelf = self
	
	-- print("CVTa: configurationId safe hlm " .. configurationId)
	-- print("CVTa: configurationId spec.CVTconfig " .. spec.CVTconfig)
	-- if spec.CVTconfig == nil or 0 then
		-- spec.CVTconfig = configurationId
	-- end
	
 -- to make it easier read with dashbord-live
	spec.forDBL_pedalpercent = tostring(self.spec_motorized.motor.lastAcceleratorPedal*100)
	spec.forDBL_rpmrange = tostring(spec.rpmDmax .. " - " .. self.spec_motorized.motor.minRpm)
	spec.forDBL_rpmDmin = tostring(0)
	spec.forDBL_autoDiffs = tostring(0)
	spec.forDBL_IPMactive = tostring(0)
	spec.forDBL_brakeramp = tostring(0)
	
	if spec.vFour ~= nil then
		if spec.isTMSpedal == 0 then
			spec.forDBL_tmspedal = 0
		elseif spec.isTMSpedal == 1 then
			spec.forDBL_tmspedal = 1
		end
	end
	if spec.vFour ~= nil then
		if spec.vFour == 0 then
			spec.forDBL_neutral = 1
		elseif spec.vFour == 1 then
			spec.forDBL_neutral = 0
		end
	end
	if spec.vOne ~= nil then
		if spec.vOne == 1 then
			spec.forDBL_drivinglevel = tostring(2)
		elseif spec.vOne == 2 then
			spec.forDBL_drivinglevel = tostring(1)
		end
	end
	spec.forDBL_digitalhandgasstep = tostring(spec.vFive)
	if spec.vTwo ~= nil then
		if spec.vTwo == 1 then
			spec.forDBL_accramp = tostring(4)
		elseif spec.vTwo == 2 then
			spec.forDBL_accramp = tostring(1)
		elseif spec.vTwo == 3 then
			spec.forDBL_accramp = tostring(2)
		elseif spec.vTwo == 4 then
			spec.forDBL_accramp = tostring(3)
		end
	end
	spec.forDBL_rpmDmax = tostring(spec.rpmDmax)
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
end -- onPostLoad

function CVTaddon:saveToXMLFile(xmlFile, key, usedModNames)
	
	if self.spec_motorized ~= nil then
		local spec = self.spec_CVTaddon
		spec.CVTconfig = self.configurations["CVTaddon"] or 1
		-- #configPart
		-- spec.cvtexists = self.configurations["CVTaddon"] == 2
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
			xmlFile:setValue(key.."#configurationId", spec.CVTconfig)
		end

		print("CVT_Addon: saved.")
		-- print("CVT_Addon: saved personal adjustments for "..self:getName())
		-- print("CVT_Addon: Save Driving Level id: "..tostring(spec.vOne))
		-- print("CVT_Addon: Save Acceleration Ramp id: "..tostring(spec.vTwo))
		-- print("CVT_Addon: Save Brake Ramp id: "..tostring(spec.vThree))
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
		if (spec.rpmrange == 1) then -- full / off
			
			if sbshDebugOn then
				print("VarioRpmDmax rpmrange 1: "..tostring(spec.rpmrange))
				print("VarioRpmDmax Taste gedrückt 1: "..tostring(spec.rpmDmax))
				print("maxRpmOrigin 1: "..tostring(spec.maxRpmOrigin))
			end
			print("VarioRpmDmax rpmrange 1: "..tostring(spec.rpmrange))
			print("VarioRpmDmax full pwr")
		end
		if (spec.rpmrange == 2) then -- reduce 1
			
			if sbshDebugOn then
				print("VarioRpmDmax rpmrange 2: "..tostring(spec.rpmrange))
				print("VarioRpmDmax Taste gedrückt 2: "..tostring(spec.rpmDmax))
				print("maxRpmOrigin 2: "..tostring(spec.maxRpmOrigin))
			end
			print("VarioRpmDmax rpmrange 2: "..tostring(spec.rpmrange))
			print("VarioRpmDmax Eco field")
		end
		if (spec.rpmrange == 3) then -- reduce 2
			
			if sbshDebugOn then
				print("VarioRpmDmax rpmrange 3: "..tostring(spec.rpmrange))
				print("VarioRpmDmax Taste gedrückt 3: "..tostring(spec.rpmDmax))
				print("maxRpmOrigin 3: "..tostring(spec.maxRpmOrigin))
			end
			print("VarioRpmDmax rpmrange 3: "..tostring(spec.rpmrange))
			print("VarioRpmDmax Eco1")
		end
		if (spec.rpmrange == 4) then -- reduce 3
			
			if sbshDebugOn then
				print("VarioRpmDmax rpmrange 4: "..tostring(spec.rpmrange))
				print("VarioRpmDmax Taste gedrückt 4: "..tostring(spec.rpmDmax))
				print("maxRpmOrigin 4: "..tostring(spec.maxRpmOrigin))
			end
			print("VarioRpmDmax rpmrange 4: "..tostring(spec.rpmrange))
			print("VarioRpmDmax Eco2")
		end
		if spec.rpmrange == 4 or spec.rpmrange == nil then
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
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig))
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
		if spec.vThree == 5 or spec.vThree == nil then
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
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig))
		end	
		if debug_for_DBL then
			print("CVTa BR event: " .. spec.vThree)		
			print("CVTa BR 4_dbl: " .. spec.forDBL_brakeramp)		
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
		if spec.vTwo == 4 or spec.vTwo == nil then
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
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig))
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
		if spec.vFive >= 10 then
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
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig))
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
		if spec.vFive <= 1 then
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
			g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig), nil, nil, self)
		else
			g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig))
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
	-- not able to use when modern config
	if spec.CVTconfig ~= 4 or spec.CVTconfig ~= 5 or spec.CVTconfig ~= 6 then
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
				g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig))
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

function CVTaddon:VarioTwo() -- FAHRSTUFE 2 street
	-- changeFlag = true -- tryout
	local spec = self.spec_CVTaddon
	spec.BlinkTimer = -1
	spec.Counter = 0
	-- spec.AsLongBlink = g_currentMission.environment.dayTime
	-- not able to use when modern config
	if spec.CVTconfig ~= 4 or spec.CVTconfig ~= 5 or spec.CVTconfig ~= 6 then
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
				g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig))
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
				-- self.spec_motorized.motor.manualClutchValue = 0
				if g_server and g_client and not g_currentMission.connectedToDedicatedServer then
					self.spec_motorized.motor.currentDirection = spec.lastDirection -- again to push it
				else
					self.spec_motorized.motor.currentDirection = 1
				end
				
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
					self.spec_motorized.motor.maxBackwardSpeed = 0.1
					self.spec_motorized.motor.maxForwardSpeed = 0.1
					-- self.spec_motorized.motor.manualClutchValue = 1
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
				g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.autoDiffs, spec.vFive, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig))
			end	
		end
	end
	-- DBL convert
	if spec.vFour == 0 then
		spec.forDBL_neutral = 1
	elseif spec.vFour == 1 then
		spec.forDBL_neutral = 0
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
				g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig))
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
				g_server:broadcastEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig), nil, nil, self)
			else
				g_client:getServerConnection():sendEvent(SyncClientServerEvent.new(self, spec.vOne, spec.vTwo, spec.vThree, spec.vFour, spec.vFive, spec.autoDiffs, spec.lastDirection, spec.isVarioTM, self.isTMSpedal, self.PedalResolution, spec.rpmDmax, spec.rpmrange, spec.CVTconfig))
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
	if self.spec_vca ~= nil then
		if spec.CVTconfig == 4 or spec.CVTconfig == 5 or spec.CVTconfig == 6 then
			self.spec_vca.handbrake = true
		end
	end
end

function CVTaddon:onUpdateTick(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected, vehicle)
	local spec = self.spec_CVTaddon
	-- local pcspec = self.spec_powerConsumer
	-- SpecializationUtil.raiseEvent(self, "onStartWorkAreaProcessing", dt, spec.workAreas)
	-- print("CVTa srv: "  .. g_dedicatedServer)
	if spec.isVarioTM == false then
		spec.CVTconfig = 8
		self.configurations["CVTaddon"] = 8
	end
	if spec.CVTconfig ~= 8 then
		local changeFlag = false
		local motor = nil
		-- local lowerfind = Vehicle:getIsLowered(defaultIsLowered)
		
		-- Anbaugeräte ermitteln und prüfen ob abgesenkt Front/Back
		if #self.spec_attacherJoints.attachedImplements ~= nil then
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
		end
		if moveDownBack == true or moveDownFront == true then
			spec.impIsLowered = true
		else
			spec.impIsLowered = false
		end
			
			local storeItem = g_storeManager:getItemByXMLFilename(self.configFileName)
			local StI = storeItem.categoryName
			local isTractor = StI == "TRACTORSS" or StI == "TRACTORSM" or StI == "TRACTORSL"
			local isErnter = storeItem.categoryName == "HARVESTERS" or StI == "FORAGEHARVESTERS" or StI == "POTATOVEHICLES" or StI == "BEETVEHICLES" or StI == "SUGARCANEVEHICLES" or StI == "COTTONVEHICLES" or StI == "MISCVEHICLES"
			local isLoader = storeItem.categoryName == "FRONTLOADERVEHICLES" or StI == "TELELOADERVEHICLES" or StI == "SKIDSTEERVEHICLES" or StI == "WHEELLOADERVEHICLES"
			local isPKWLKW = StI == "CARS" or StI == "TRUCKS"
			local isWoodWorker = storeItem.categoryName == "WOODHARVESTING"
			local isFFF = storeItem.categoryName == "FORKLIFTS"
			spec.isVarioTM = self.spec_motorized.motor.lastManualShifterActive == false and self.spec_motorized.motor.groupType == 1 and self.spec_motorized.motor.gearType == 1 and self.spec_motorized.motor.forwardGears == nil
			-- print("CVTa Kat: " .. StI)
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
							if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 then
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
						-- print("CVTa diffManual: " .. tostring(self:vcaGetState("diffManual")))
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
				if self.spec_vca ~= nil then
					if spec.CVTconfig == 4 or spec.CVTconfig == 5 or spec.CVTconfig == 6 then
						if self.spec_motorized.motor.lastAcceleratorPedal > 0.01 then
							self.spec_vca.handbrake = false
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
					print("CVT-Addon: FS22_LessMotorBrakeForce found, please deinstall the LessMotorBrakeForce mod !")
				end

				-- get maxForce sum of all tools attached
				local maxForce = 0
				local vehicles = self:getChildVehicles()
				for _, vehicle in ipairs(vehicles) do
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
				end
				
				
		-- Boost function e.g. IPM		The exact multiplier number Giants uses is 0.00414, (rounded) =1hp. So target hp x 0.00414 = torque scale value #.
				if (self.spec_motorized.motor.motorExternalTorque * self.spec_motorized.motor.lastMotorRpm * math.pi / 30) == 0 or self:getLastSpeed() < 15 then
					peakMotorTorqueOrigin = self.spec_motorized.motor.peakMotorTorque
				end
				if spec.CVTconfig == 2 or spec.CVTconfig == 3 or spec.CVTconfig == 5 or spec.CVTconfig == 6 then
																		-- 1800 * 0.43 * pi / 30   = 81.053
																		-- 81.053 / pi * 30 * 1800 = 0.42999
					if (self.spec_motorized.motor.motorExternalTorque * self.spec_motorized.motor.lastMotorRpm * math.pi / 30) ~= 0 or self:getLastSpeed() > 15 then
						-- self.spec_motorized.motor.peakMotorPower = self.spec_motorized.motor.peakMotorPower + 14.7  -- * 1.1337 (110kw) 	-- 14.7 kw = 20 ps
						-- self.spec_motorized.motor.ptoMotorRpmRatio = self.spec_motorized.motor.ptoMotorRpmRatio * 0.5
						
						-- self.spec_motorized.motor.peakMotorPower = self.spec_motorized.motor.peakMotorPower * 100
						-- print("CVTa: IPM: " .. (25 / math.pi * 30 / self.spec_motorized.motor.lastMotorRpm))
						-- self:setPtoMotorRpmRatio(2)
						-- self.spec_motorized.motor.ptoMotorRpmRatio = 6
						if spec.CVTconfig == 2 then
							print("CVTa: IPM c15")
							self.spec_motorized.motor.motorRotationAccelerationLimit = math.max(self.spec_motorized.motor.motorRotationAccelerationLimit *1.25 , 2)
							spec.forDBL_IPMactive = 1
						elseif spec.CVTconfig == 3 then
							print("CVTa: IPM c25")
							spec.forDBL_IPMactive = 1
							
							
						elseif spec.CVTconfig == 5 then
							print("CVTa: IPM m15")
							spec.forDBL_IPMactive = 1
						elseif spec.CVTconfig == 6 then
							print("CVTa: IPM m27")
							spec.forDBL_IPMactive = 1
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
						spec.forDBL_IPMactive = 0
					end
				end

				if spec.CVTconfig == 7 then
					-- print("CVTa: HST ######################################################################### HST")
				end
				-- print("CVTa: CVTconfig " .. spec.CVTconfig)
				-- print("CVTa: gearType " .. self.spec_motorized.motor.gearType)
				-- print("CVTa: groupType " .. self.spec_motorized.motor.groupType)
				-- print("CVTa: lastManualShifterActive " .. tostring(self.spec_motorized.motor.lastManualShifterActive))
				-- print("CVTa: externalTorqueVirtualMultiplicator " .. tostring(self.spec_motorized.motor.externalTorqueVirtualMultiplicator))
				-- print("CVTa: motorExternalTorque " .. tostring(self.spec_motorized.motor.motorExternalTorque))
				-- print("CVTa: motorAvailableTorque " .. tostring(self.spec_motorized.motor.motorAvailableTorque))
				-- print("CVTa: lastMotorAvailableTorque " .. tostring(self.spec_motorized.motor.lastMotorAvailableTorque))
				-- print("CVTa: lastMotorAppliedTorque " .. tostring(self.spec_motorized.motor.lastMotorAppliedTorque))
				-- print("CVTa: motorRotSpeed " .. tostring(self.spec_motorized.motor.motorRotSpeed))
				-- print("CVTa: ptoMotorRpmRatio " .. tostring(self.spec_motorized.motor.ptoMotorRpmRatio))
				-- print("CVTa: lastSmoothedClutchPedal " .. tostring(self.spec_motorized.motor.lastSmoothedClutchPedal))
				-- print("CVTa: motorRotSpeedClutchEngaged " .. tostring(self.spec_motorized.motor.motorRotSpeedClutchEngaged))
				-- print("CVTa: differentialRotSpeed " .. tostring(self.spec_motorized.motor.differentialRotSpeed))
				-- print("CVTa: gearRatio " .. tostring(self.spec_motorized.motor.gearRatio))
				-- print("CVTa: torqueScale " .. tostring(self.spec_motorized.motor.torqueScale))
				-- print("CVTa: rotInertia " .. tostring(self.spec_motorized.motor.rotInertia))
				-- print("CVTa: speedLimit " .. tostring(self.spec_motorized.motor.speedLimit))
				-- print("CVTa: maxForwardSpeed " .. tostring(self.spec_motorized.motor.maxForwardSpeed))
				-- print("CVTa: speedLimitAcc " .. tostring(self.spec_motorized.motor.speedLimitAcc))
				-- print("CVTa: peakMotorPowerRotSpeed " .. tostring(self.spec_motorized.motor.peakMotorPowerRotSpeed))
				-- print("CVTa: motorRotationAccelerationLimit " .. tostring(self.spec_motorized.motor.motorRotationAccelerationLimit))
				-- print("CVTa: constantAccelerationCharge " .. tostring(self.spec_motorized.motor.constantAccelerationCharge))
				-- print("CVTa: differentialRotAcceleration " .. tostring(self.spec_motorized.motor.differentialRotAcceleration))
				-- print("CVTa: peakMotorTorque " .. tostring(self.spec_motorized.motor.peakMotorTorque))
				-- print("CVTa: lastDifference " .. tostring(self.spec_motorized.motor.lastDifference))
				-- print("CVTa: peakMotorTorqueOrigin " .. tostring(peakMotorTorqueOrigin))
				-- print("CVTa: isVarioTM " .. tostring(spec.isVarioTM))
				local calAvPwr = self.spec_motorized.motor.motorAvailableTorque + math.max((25 / math.pi * 30 / self.spec_motorized.motor.lastMotorRpm), 0)
				-- print("CVTa: calAvPwr " .. tostring(calAvPwr))
				-- print("CVTa: self:getConsumingLoad() " .. tostring(self:getConsumingLoad()))
				-- print("CVTa: self:getDoConsumePtoPower() " .. tostring(self:getDoConsumePtoPower()))
				-- print("CVTa: ptoRpm " .. tostring(self.spec_powerConsumer.ptoRpm))
				-- print("CVTa: neededMinPtoPower " .. tostring(self.spec_powerConsumer.neededMinPtoPower))
				-- print("CVTa: sourceMotorPeakPower " .. tostring(self.spec_powerConsumer.sourceMotorPeakPower))
				
				
		-- ACCELERATION RAMPS - BESCHLEUNIGUNGSRAMPEN
				if self:getIsMotorStarted() then
					-- print("CVT_Addon: Motor AN")
				
					if spec.vFour ~= 0 then
						if spec.vTwo == 1 and spec.isVarioTM then
							if self:getLastSpeed() <= (self.spec_motorized.motor.maxForwardSpeed*math.pi)/(2.3) then -- Beschleunigung wird ab kmh X full
								self.spec_motorized.motor.accelerationLimit = 1.7 -- Standard IV
							else
								self.spec_motorized.motor.accelerationLimit = 1.7 -- Standard
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
								self.spec_motorized.motor.accelerationLimit = 0.35 -- I
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
								self.spec_motorized.motor.accelerationLimit = 0.80 -- II
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
								self.spec_motorized.motor.accelerationLimit = 1.20 -- III
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
					-- print("CVTa targetGear : " .. tostring(self.spec_motorized.motor.targetGear))
					-- print("CVTa currentDirection : " .. tostring(self.spec_motorized.motor.currentDirection))
					-- print("CVTa movingDirection2 : " .. tostring(self.spec_motorized.motor.vehicle.movingDirection))
					if spec.vFour == 0 then
						Nonce = 1
						self.spec_motorized.motor.currentDirection = 0
						self.spec_motorized.motorFan.enabled = true
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
							-- self:controlVehicle(0.0, 0.0, 0.0, 0.0, math.huge, 0.0, 0.0, 0.0, 0.0, 0.0)
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
						-- self.spec_motorized.motor.lastTurboScale = math.min(math.abs(self.spec_motorized.motor.rawLoadPercentage), 1)
						-- self.spec_motorized.motor.blowOffValveState = math.min(self.spec_motorized.motor.blowOffValveState + (self.spec_motorized.motor.lastMotorRpm / 1000 ), 1)
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
					
	
					-- Rückwärts retarder Last
					if self.spec_motorized.motor.currentDirection == -1 then
						self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage * 1.2
					end
					
					if math.abs(self.spec_motorized.motor.lastAcceleratorPedal) <= 0.01 then
						self.spec_motorized.motor.motorAppliedTorque = 0
					end
					
					-- automatic drivinglevel for modern cvt, CVTconfig: 4,5,6
					if spec.CVTconfig == 4 or spec.CVTconfig == 5 or spec.CVTconfig == 6 then
						if self:getLastSpeed() > 17 then
							spec.vOne = 1
						else
							spec.vOne = 2
						end
					end
					-- print("CVTa vOne: " .. spec.vOne)
					
					-- different classic and modern
					local mcRPMvar = 1
					if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 then -- classic
						if g_server and g_client and not g_currentMission.connectedToDedicatedServer then
							-- spec.mcRPMvar = 1.0009*0.97 	-- c.local
							mcRPMvar = 1.001*0.97 	-- c.local
						else
							-- spec.mcRPMvar = 1.0009	-- c.server
							mcRPMvar = 1.001	-- c.server
						end
					elseif spec.CVTconfig == 4 or spec.CVTconfig == 5 or spec.CVTconfig == 6 then -- modern
						if g_client and g_client and not g_currentMission.connectedToDedicatedServer then
							-- spec.mcRPMvar = 0.9991*0.97	-- m.local
							mcRPMvar = 0.9991*0.97	-- m.local
						else
							-- spec.mcRPMvar = 0.9991	-- m.server
							mcRPMvar = 0.9991	-- m.server
						end
					-- else
						-- spec.mcRPMvar = 1
					end
					-- print("CVTa mcRPMvar: " .. tostring(mcRPMvar))
					
	-- -- FAHRSTUFE I. 
					if spec.vOne == 2 and spec.isVarioTM then
						-- Planetengetriebe / Hydromotor Übersetzung
						spec.isHydroState = false
						spec.spiceDFWspeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 4.49), 6.94)
						spec.spiceDBWspeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 3.21), 6.36)
						
						self.spec_motorized.motor.maxForwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 4.49), 6.94)
						self.spec_motorized.motor.maxBackwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 3.21), 6.36)
						-- g_currentMission:addExtraPrintText(g_i18n:getText("txt_VarioOne")) -- #l10n
						self.spec_motorized.motor.gearRatio = math.max(self.spec_motorized.motor.gearRatio, 100) * 1.81 + (self.spec_motorized.motor.rawLoadPercentage*9)
						self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin * 1.6
						self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.maxForwardGearRatioOrigin + 1
						self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin * 2
						self.spec_motorized.motor.rawLoadPercentage = (self.spec_motorized.motor.rawLoadPercentage * 0.83)
						self.spec_motorized.motor.differentialRotSpeed = self.spec_motorized.motor.differentialRotSpeed * 0.8
						
						-- TMS like
						-- wenn Tempomat aus, wird die Tempomatgescwindigkeit als Steps der maxSpeed benutzt
						if spec.isTMSpedal == 1 and self:getCruiseControlState() == 0 and math.abs(self.spec_motorized.motor.lastAcceleratorPedal) >= 0.04 then
							self.spec_motorized.motor.maxBackwardSpeed = (math.min(self:getCruiseControlSpeed(), math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 3.21), 6.36) )) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
							self.spec_motorized.motor.maxForwardSpeed = (math.min(self:getCruiseControlSpeed(), math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 4.49), 6.94) )) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
							self.spec_motorized.motor.motorAppliedTorque = math.max(self.spec_motorized.motor.motorAppliedTorque, 0.5)
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
										if self:getLastSpeed() > (self.spec_motorized.motor.maxForwardSpeed*math.pi)-2 then
											self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage *0.97
											self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * mcRPMvar + self:getLastSpeed()
										end
										
										if math.max(0, self.spec_drivable.axisForward) < 0.2 then
										-- if self.isClient and not self.isServer
											self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm * mcRPMvar + (self:getLastSpeed() * 15), self.spec_motorized.motor.maxRpm)
											self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage - (self:getLastSpeed() / 50)
											-- self.spec_motorized.motor.blowOffValveState = self.spec_motorized.motor.lastTurboScale
											-- self.spec_motorized.motor.blowOffValveState = math.min(self.spec_motorized.motor.blowOffValveState + (self.spec_motorized.motor.lastMotorRpm / 1000 ), 1)
										-- else
											-- self.spec_motorized.motor.blowOffValveState = 0  ##here
											
											-- Anpassung server/local I.
											-- if g_client:getServerConnection() then
												-- self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 0.9
											-- end
										end
										if math.max(0, self.spec_drivable.axisForward) > 0.5 and math.max(0, self.spec_drivable.axisForward) <= 0.9 and self.spec_motorized.motor.rawLoadPercentage < 0.5 then
											self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 0.8 * mcRPMvar
											-- self.spec_motorized.motor.lastTurboScale = math.min(math.abs(self.spec_motorized.motor.rawLoadPercentage), 1)
											-- self.spec_motorized.motor.blowOffValveState = 0
										end
										
										-- self.spec_motorized.motor.lastPtoRpm = self.spec_motorized.motor.lastPtoRpm*0.7
									end
									-- print("smooth: " .. spec.smoother)
								end -- smooth
							end
							-- Nm kurven für unterschiedliche Lasten, Berücksichtigung pto
							if self.spec_motorized.motor.smoothedLoadPercentage >= 0.3 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.5 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.985 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7)+(math.abs(self.spec_motorized.motor.lastAcceleratorPedal)*25), self.spec_motorized.motor.maxRpm)
								self.spec_motorized.motorTemperature.heatingPerMS = 0.0015
								if self.spec_motorized.motorTemperature.value >= 88 then
									self.spec_motorized.motorFan.enabled = true
								end
							end
							if self.spec_motorized.motor.smoothedLoadPercentage >= 0.5 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.65 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.975 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7)+(math.abs(self.spec_motorized.motor.lastAcceleratorPedal)*45), self.spec_motorized.motor.maxRpm)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage >= 0.65 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.7 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.98 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm)
							end
							if self.spec_motorized.motor.rawLoadPercentage >= 0.7 and self.spec_motorized.motor.rawLoadPercentage <= 0.75 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.985 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm)
							end
							if self.spec_motorized.motor.rawLoadPercentage >= 0.75 and self.spec_motorized.motor.rawLoadPercentage <= 0.8 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.99 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm)
							end
							if self.spec_motorized.motor.rawLoadPercentage >= 0.8 and self.spec_motorized.motor.rawLoadPercentage <= 0.85 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.994 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm)
							end
							if self.spec_motorized.motor.rawLoadPercentage >= 0.85 and self.spec_motorized.motor.rawLoadPercentage <= 0.9 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 0.997 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm)
							end
							if self.spec_motorized.motor.rawLoadPercentage >= 0.9 then
								self.spec_motorized.motor.lastMotorRpm = math.min(math.max((self.spec_motorized.motor.lastMotorRpm * 1.001 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7), self.spec_motorized.motor.maxRpm)
								self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 3 + (self.spec_motorized.motor.rawLoadPercentage*19)
								self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatio + self.spec_motorized.motor.smoothedLoadPercentage*15
							end
							-- self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm * spec.mcRPMvar, self.spec_motorized.motor.maxRpm )

							-- Wenn ein Anbaugerät zu schwere Last erzeugt, schafft es die 4. Beschleunigungsrampe nicht oder nimmt Schaden
							if self.spec_motorized.motor.rawLoadPercentage > 0.96 and (self:getTotalMass() - self:getTotalMass(true)) >= (self:getTotalMass(true)/2.26) and spec.vTwo == 1 and spec.impIsLowered == true then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.94 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.2)
								self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 3.1 + (self.spec_motorized.motor.rawLoadPercentage*9)
								self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
								self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
								self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm - 50
								self.spec_motorized.motorTemperature.heatingPerMS = 0.015 * self.spec_motorized.motor.rawLoadPercentage
								self:addDamageAmount((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4)
								-- print("CVTa: > 96 % - Lowered, vTwo=1")
								-- Getriebeschaden erzeugen
								if self.spec_motorized.motor.rawLoadPercentage > 0.98 then
									g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 2048)
									self:addDamageAmount(self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 ) )
									self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm -100
									self.spec_motorized.motorTemperature.heatingPerMS = 0.0040 * self.spec_motorized.motor.rawLoadPercentage
									-- print("CVTa: > 98 %")
									if self.spec_motorized.motor.rawLoadPercentage > 0.99 then
										self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 3
										self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 3
										self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 0.5 * mcRPMvar
										self.spec_motorized.motorTemperature.heatingPerMS = 0.0120 * self.spec_motorized.motor.rawLoadPercentage
										self:addDamageAmount((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.7)
										-- print("CVTa: > 99 %")
									end
								end
							end
							-- Wenn ein Anbaugerät zu schwere Last erzeugt, schafft es die 3. Beschleunigungsrampe nicht oder nimmt Schaden
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.97 and (self:getTotalMass() - self:getTotalMass(true)) >= (self:getTotalMass(true)/1.69) and spec.vTwo == 4 and spec.impIsLowered == true then
								g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 2048)
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.96 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.2)
								self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 3.1 + (self.spec_motorized.motor.rawLoadPercentage*9)
								self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 1
								self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 1
								self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm - 50
								-- print("CVTa: > 96 % - Lowered, vTwo=1")
								-- Getriebeschaden erzeugen
								if self.spec_motorized.motor.smoothedLoadPercentage > 0.98 then
									g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 2048)
									self:addDamageAmount(self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 ) )
									self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm -100
									self.spec_motorized.motorTemperature.heatingPerMS = 0.0040 * self.spec_motorized.motor.rawLoadPercentage
									-- print("CVTa: > 98 %")
									if self.spec_motorized.motor.smoothedLoadPercentage > 0.99 then
										g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 2048)
										self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
										self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
										self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 0.6 * mcRPMvar
										-- print("CVTa: > 99 %")
									end
								end
							end
						end
					end

		-- HYDROSTAT  für evtl. Radlader und Holzernter    ToDo: need separate
					-- local hydrostaticVehicles = isLoader or isWoodWorker or isFFF or isErnter
					if spec.vOne ~= nil and spec.CVTconfig == 7 then
						spec.isHydroState = true
						-- spec.HydrostatPedal = math.abs(self.spec_motorized.motor.lastAcceleratorPedal) -- nach oben verschoben z.719
						
						-- Hydrostatisches Fahrpedal
						-- local spiceDFWspeedHs = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 2.8), 3.16)
						-- local spiceDBWspeedHs = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 2.8), 3.16)
						-- local spiceDFWspeedH = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 2.8), 3.16) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
						-- local spiceDBWspeedH = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 2.8), 3.16) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
						self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.maxForwardGearRatio
						self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minForwardGearRatio
						
						if math.abs(self.spec_motorized.motor.lastAcceleratorPedal) >= 0.02 then
							self.spec_motorized.motor.maxForwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 2.8), 3.16) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
							self.spec_motorized.motor.maxBackwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 2.8), 3.16) * math.abs(self.spec_motorized.motor.lastAcceleratorPedal)
							-- g_currentMission:addExtraPrintText("Hydrostat Antrieb")
						end
						if math.abs(self.spec_motorized.motor.lastAcceleratorPedal) < 0.02 then
							self.spec_motorized.motor.maxForwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 2.1, 2.8), 3.16)
							self.spec_motorized.motor.maxBackwardSpeed = math.min(math.max(self.spec_motorized.motor.maxForwardSpeedOrigin / 1.4, 2.8), 3.16)
							-- g_currentMission:addExtraPrintText("Hydrostat byPass")
						end
						self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 2.5
						if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm + 150 then
							if self.spec_motorized.motor.smoothedLoadPercentage < 0.3 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.98), self.spec_motorized.motor.lastPtoRpm)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.4 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.6 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 1.0002), self.spec_motorized.motor.lastPtoRpm)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.6 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 1.005), self.spec_motorized.motor.lastPtoRpm)
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
					-- if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 then
						-- Planetengetriebe / Hydromotor Übersetzung
						spec.isHydroState = false
						self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 0.95 + (self.spec_motorized.motor.rawLoadPercentage*9)
						self.spec_motorized.motor.minForwardGearRatio = self.spec_motorized.motor.minForwardGearRatioOrigin
						self.spec_motorized.motor.minBackwardGearRatio = self.spec_motorized.motor.minBackwardGearRatioOrigin
						self.spec_motorized.motor.maxBackwardGearRatio = self.spec_motorized.motor.maxBackwardGearRatioOrigin
						
						-- TMS like
						-- wenn Tempomat aus, wird die Tempomatgescwindigkeit als Steps der maxSpeed benutzt
						if spec.isTMSpedal == 1 and self:getCruiseControlState() == 0 and math.abs(self.spec_motorized.motor.lastAcceleratorPedal) >= 0.04 then
							self.spec_motorized.motor.maxBackwardSpeed = (math.min(self:getCruiseControlSpeed(), (self.spec_motorized.motor.maxBackwardSpeedOrigin * math.abs(self.spec_motorized.motor.lastAcceleratorPedal))))
							self.spec_motorized.motor.maxForwardSpeed = (math.min(self:getCruiseControlSpeed(), (self.spec_motorized.motor.maxForwardSpeedOrigin * math.abs(self.spec_motorized.motor.lastAcceleratorPedal))))
							self.spec_motorized.motor.motorAppliedTorque = math.max(self.spec_motorized.motor.motorAppliedTorque, 0.5)
							
						else
							self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeedOrigin
							self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeedOrigin
						end
						-- smoothing nicht im Leerlauf
						if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm + 150 then
							if self.spec_motorized.motor.smoothedLoadPercentage < 0.3 then
								-- Gaspedal and Variator
								spec.smoother = spec.smoother + dt;
								if spec.smoother ~= nil and spec.smoother > 100 then -- Drehzahl zucken eliminieren
									spec.smoother = 0;
									if self:getLastSpeed() > 3 then 
										self.spec_motorized.motor.lastMotorRpm = math.max(math.max(math.min((self:getLastSpeed() * math.abs(math.max(self.spec_motorized.motor.rawLoadPercentage, 0.55)))*42, self.spec_motorized.motor.maxRpm*0.99), self.spec_motorized.motor.minRpm+203), self.spec_motorized.motor.lastPtoRpm*0.7)

										-- Drehzahl Erhöhung angleichen zur Motorbremswirkung, wenn Pedal losgelassen wird
										-- self.spec_motorized.motor.lastTurboScale = self.spec_motorized.motor.lastTurboScale * 0.95 + (self.spec_motorized.motor.lastMotorRpm/100 * self.spec_motorized.motor.smoothedLoadPercentage) * 0.05
										if math.max(0, self.spec_drivable.axisForward) < 0.2 then
											self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm * mcRPMvar + (self:getLastSpeed() * 15), self.spec_motorized.motor.maxRpm)
											self.spec_motorized.motor.rawLoadPercentage = self.spec_motorized.motor.rawLoadPercentage - (self:getLastSpeed() / 50)
										-- else
											-- Anpassung server/local II.
											-- if g_client:getServerConnection() then
												-- self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 0.9
											-- end
										end
									end
								end -- smooth
							end
							
							-- Nm kurven für unterschiedliche Lasten, Berücksichtigung pto
							if self.spec_motorized.motor.smoothedLoadPercentage < 0.3 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.986 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.8)
								self.spec_motorized.motorTemperature.heatingPerMS = 0.0016
							end
							if self.spec_motorized.motor.smoothedLoadPercentage >= 0.3 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.5 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.99 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.5 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.65 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.9825 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.65 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.7 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.985 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.7 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.75 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.9875 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.75 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.8 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.99 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.8 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.85 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.995 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.85 and self.spec_motorized.motor.smoothedLoadPercentage <= 0.9 then
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.997 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.7)
							end
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.9 then
								-- self.spec_motorized.motor.lastMotorRpm = math.max(((self.spec_motorized.motor.lastMotorRpm * 1.02 * math.min(math.max(self.spec_motorized.motor.rawLoadPercentage, 0.96), 0.98))), self.spec_motorized.motor.lastPtoRpm*0.7)
								self.spec_motorized.motor.lastMotorRpm = math.max(self.spec_motorized.motor.lastMotorRpm * 0.999 * mcRPMvar, self.spec_motorized.motor.lastPtoRpm*0.6)
								self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 1.1 + (self.spec_motorized.motor.rawLoadPercentage*9)
								-- self.spec_motorized.motor.lastPtoRpm = self.spec_motorized.motor.lastPtoRpm * 0.9
								self.spec_motorized.motorTemperature.heatingPerMS = 0.0020 * self.spec_motorized.motor.rawLoadPercentage
								-- ändert bei sehr hoher Last die Übersetzung
							end
							-- self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm * spec.mcRPMvar, self.spec_motorized.motor.maxRpm )
							
							-- Wenn ein Anbaugerät zu schwere Last erzeugt, schafft es die 2. Fahrstufe nicht
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.92 and spec.impIsLowered == true then
								-- g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 1024)
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.98 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.4)
								self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 3.1 + (self.spec_motorized.motor.rawLoadPercentage*9)
								self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 1
								self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 1
								self.spec_motorized.motorTemperature.heatingPerMS = 0.0030 * self.spec_motorized.motor.rawLoadPercentage
								self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm -10
							end
							-- Wenn ein Anbaugerät zu schwere Last erzeugt, schafft es die 2. Fahrstufe nicht oder nimmt Schaden
							if self.spec_motorized.motor.smoothedLoadPercentage > 0.96 and (self:getTotalMass() - self:getTotalMass(true)) >= (self:getTotalMass(true)) and spec.vTwo == 1 then
								g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 1024)
								self.spec_motorized.motor.lastMotorRpm = math.max((self.spec_motorized.motor.lastMotorRpm * 0.95 * mcRPMvar), self.spec_motorized.motor.lastPtoRpm*0.8)
								self.spec_motorized.motor.lastPtoRpm = self.spec_motorized.motor.lastPtoRpm * 0.6
								self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 3.1 + (self.spec_motorized.motor.rawLoadPercentage*9)
								self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
								self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 2
								self.spec_motorized.motorTemperature.heatingPerMS = 0.0040 * self.spec_motorized.motor.rawLoadPercentage
								self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm -10
								local massDiff = (self:getTotalMass() - self:getTotalMass(true)) / 100
								
								-- Getriebeschaden erzeugen
								if self.spec_motorized.motor.smoothedLoadPercentage > 0.99 then
									g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 2048)
									if spec.impIsLowered == false then
										self.spec_motorized.motorTemperature.heatingPerMS = 0.0080 * self.spec_motorized.motor.rawLoadPercentage
										if self.spec_motorized.motor.lastMotorRpm > self.spec_motorized.motor.minRpm + 150 then
											self:addDamageAmount((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.4)
											self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 4
											self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 4
											self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 1.12 * mcRPMvar
										end
									end
								end
								if spec.impIsLowered == true and self.spec_motorized.motor.rawLoadPercentage > 0.92 then
									g_currentMission:showBlinkingWarning(g_i18n:getText("txt_attCVTpressure"), 1024)
									self.spec_motorized.motorTemperature.heatingPerMS = 0.0150 * self.spec_motorized.motor.rawLoadPercentage
									self:addDamageAmount((self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 )) *0.7)
									self.spec_motorized.motor.maxForwardSpeed = ( self:getLastSpeed() / math.pi ) - 3
									self.spec_motorized.motor.maxBackwardSpeed = ( self:getLastSpeed() / math.pi ) - 3
									self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 1.5
									-- print("addDamage lowered: "  .. self.spec_motorized.motor.smoothedLoadPercentage * ((self:getTotalMass() - self:getTotalMass(true)) / 1000 ))
								end
							end
							-- 			kmh 		> 				max kmh								-						max kmh                     :14
							--          47							16.87 * 3.141592654 (53) 		    -                 "   (53)/14= 3.786    53-3.786= 49.214 kmh
							if self:getLastSpeed() > ((self.spec_motorized.motor.maxForwardSpeed*math.pi)-(self.spec_motorized.motor.maxForwardSpeed*math.pi/14)) then
								-- Ändert die Drehzahl wenn man sich der vMax nähert  ##here
								self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm + (self:getLastSpeed()/6 ), self.spec_motorized.motor.maxRpm-18)
							end
						end
					end
					
					
					-- MOTORDREHZAHL (Handgas-digital)
					local maxRpm = self.spec_motorized.motor.maxRpm
					local minRpm = self.spec_motorized.motor.minRpm
					spec.lastPTORot = self.spec_motorized.motor.lastPtoRpm
					if self.spec_motorized.motor.lastPtoRpm == nil then
						self.spec_motorized.motor.lastPtoRpm = 0
					end
					if self.spec_vca == nil then
						-- Handgas Stufen
						if spec.vFive == 1 then
							self.spec_motorized.motor.lastMotorRpm = self.spec_motorized.motor.lastMotorRpm * 1
						end
						if spec.vFive > 1 then
							self.spec_motorized.motor.lastMotorRpm = math.min((math.max(math.max(minRpm + spec.vFive*120+spec.vFive*4, (self.spec_motorized.motor.lastMotorRpm)), self.spec_motorized.motor.lastPtoRpm*0.75)), maxRpm)
						end
					end
					if self.spec_vca ~= nil then
						-- Handgas Stufen
						if spec.vFive == 1 then
							if self.spec_vca.handThrottle ~= 0 then	self.spec_vca.handThrottle = 0 end
						end
						if spec.vFive > 1 then
							self.spec_vca.handThrottle = math.min((minRpm / 1000) * (spec.vFive / 8), 1)
						end
					end
					
					-- RPM Modus
					if spec.rpmrange == 2 then
						-- Eco field
						self.spec_motorized.lastFuelUsage = self.spec_motorized.lastFuelUsage * 0.95
						self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm, self.spec_motorized.motor.maxRpm * 0.94)
						-- self.spec_motorized.motor.peakMotorPower = self.spec_motorized.motor.peakMotorPower * 0.93
						self.spec_motorized.motor.motorAppliedTorque = self.spec_motorized.motor.motorAppliedTorque * 0.93
						g_currentMission:addExtraPrintText("range: 2 eco field")
					elseif spec.rpmrange == 3 then
						-- Eco 1
						self.spec_motorized.lastFuelUsage = self.spec_motorized.lastFuelUsage * 0.92
						self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm, self.spec_motorized.motor.maxRpm * 0.87 )
						self.spec_motorized.motor.motorAppliedTorque = self.spec_motorized.motor.motorAppliedTorque * 0.51
						g_currentMission:addExtraPrintText("range: 3 eco 1")
					elseif spec.rpmrange == 4 then
						-- Eco 2
						self.spec_motorized.lastFuelUsage = self.spec_motorized.lastFuelUsage * 0.85
						self.spec_motorized.motor.lastMotorRpm = math.min(self.spec_motorized.motor.lastMotorRpm, self.spec_motorized.motor.maxRpm * 0.80 )
						self.spec_motorized.motor.motorAppliedTorque = self.spec_motorized.motor.motorAppliedTorque * 0.3
						g_currentMission:addExtraPrintText("range: 4 eco 2")
					else
						-- Full / off
						-- g_currentMission:addExtraPrintText("range: 1 full")
						-- g_currentMission:addExtraPrintText("isVarioTM: " .. tostring(spec.isVarioTM))
					end
					-- print("motorPeakPower: " .. tostring(self.spec_motorized.motor.peakMotorPower))
					-- print("spec.rpmrange: " .. tostring(spec.rpmrange))
				end
				
				-- TurboCharge and BlowOff - ggf. simulated wasteGate
				-- local rpmPercentage = (self.lastMotorRpm - math.max(self.lastPtoRpm or self.minRpm, self.minRpm)) / (self.maxRpm - self.minRpm)
				-- local targetTurboRpm = rpmPercentage * self:getSmoothLoadPercentage()
				
				self.spec_motorized.motor.lastTurboScale = self.spec_motorized.motor.lastTurboScale * 0.95 + ((self.spec_motorized.motor.lastMotorRpm - math.max(self.spec_motorized.motor.lastPtoRpm or self.spec_motorized.motor.minRpm, self.spec_motorized.motor.minRpm)) / (self.spec_motorized.motor.maxRpm - self.spec_motorized.motor.minRpm)*self.spec_motorized.motor.smoothedLoadPercentage) * 0.05
										
				if math.max(0, self.spec_drivable.axisForward) < 0.2 then
					self.spec_motorized.motor.blowOffValveState = self.spec_motorized.motor.lastTurboScale
				else
					self.spec_motorized.motor.blowOffValveState = 0
				end
				
				-- print("motorFan.enabled: " .. tostring(self.spec_motorized.motorFan.enabled))
				-- print("smoothedLoadPercentage: " .. tostring(self.spec_motorized.motor.smoothedLoadPercentage))
				-- print("rawLoadPercentage     : " .. tostring(self.spec_motorized.motor.rawLoadPercentage))
				-- print("Steering: " .. tostring(self.spec_drivable.lastSteeringAngle)) -- wheel.lastSteeringAngle steeringAxleAngle
				-- print("steeringAxleAngle: " .. tostring(self.spec_drivable.steeringAxleAngle)) -- wheel.lastSteeringAngle steeringAxleAngle
				self.spec_motorized.motor.equalizedMotorRpm = self.spec_motorized.motor.lastMotorRpm -- to compare in VehicleDebug and usable in realismAddon_AnimSpeed
				self.spec_motorized.motor.lastRealMotorRpm = self.spec_motorized.motor.lastMotorRpm
				
				-- DBL convert Pedalposition and/or PedalVmax
				spec.forDBL_pedalpercent = string.format("%.1f", ( self.spec_drivable.axisForward*100 ))
				spec.forDBL_tmspedalVmax = math.min(string.format("%.1f", (( self:getCruiseControlSpeed()*math.pi) )), self.spec_motorized.motor.maxForwardSpeed*math.pi)
				spec.forDBL_tmspedalVmaxActual = math.min(string.format("%.1f", (( self:getCruiseControlSpeed()*math.pi) )*self.spec_drivable.axisForward), self.spec_motorized.motor.maxForwardSpeed*math.pi)
				if spec.autoDiffs ~= 1 then
					spec.forDBL_autoDiffs = 0 -- inaktiv
				end

				-- Brainstorm for later:
					-- DebugUtil.printTableRecursively()
					-- self.spec_motorized.consumersByFillType[FillType.DEF]
					-- rpm at vmax new gen    40 = 950; 50 = 1250; 60 = 1450;
				
			end
					
		if g_server ~= nil then	end
		if debug_for_DBL then
			-- print("####################################################################")
			-- print("spec.forDBL_drivinglevel: " .. spec.forDBL_drivinglevel)
			-- print("spec.vOne: " .. spec.vOne)
			-- print("-------------------------------------------------------------")
			-- print("spec.forDBL_accramp: " .. spec.forDBL_accramp)
			-- print("spec.vTwo: " .. spec.vTwo)
			-- print("-------------------------------------------------------------")
			print("spec.forDBL_brakeramp: " .. spec.forDBL_brakeramp)
			print("spec.vThree: " .. spec.vThree)
			-- print("-------------------------------------------------------------")
			-- print("spec.forDBL_neutral: " .. spec.forDBL_neutral)
			-- print("spec.vFour: " .. spec.vFour)
			-- print("-------------------------------------------------------------")
			-- print("spec.forDBL_autoDiffs: " .. tostring(spec.forDBL_autoDiffs))
			-- print("spec.autoDiffs: " .. tostring(spec.autoDiffs))
			-- print("-------------------------------------------------------------")
			-- print("spec.forDBL_tmspedal: " .. tostring(spec.forDBL_tmspedal))
			-- print("spec.isTMSpedal: " .. tostring(spec.isTMSpedal))
			-- print("-------------------------------------------------------------")
			-- print("spec.forDBL_tmspedalVmax: " .. spec.forDBL_tmspedalVmax)
			-- print("-------------------------------------------------------------")
			-- print("spec.forDBL_pedalpercent: " .. spec.forDBL_pedalpercent)
			-- print("-------------------------------------------------------------")
			-- print("spec.forDBL_tmspedalVmaxActual: " .. spec.forDBL_tmspedalVmaxActual)
			-- print("-------------------------------------------------------------")
			-- print("spec.forDBL_digitalhandgasstep: " .. spec.forDBL_digitalhandgasstep)
			-- print("spec.vFive: " .. spec.vFive)
			-- print("-------------------------------------------------------------")
			-- print("spec.forDBL_rpmrange: " .. spec.forDBL_rpmrange)
			-- print("-------------------------------------------------------------")
			-- print("spec.forDBL_rpmDmin: " .. spec.forDBL_rpmDmin)
			-- print("-------------------------------------------------------------")
			-- print("spec.forDBL_rpmDmax: " .. spec.forDBL_rpmDmax)
			-- print("-------------------------------------------------------------")
			-- print("spec.forDBL_IPMactive: " .. spec.forDBL_IPMactive)
			-- print("-------------------------------------------------------------")
			-- print("spec.forDBL_rpmrange: " .. spec.forDBL_rpmrange)
			-- print("_________________________________________________________________________")
		end
		-- print("motorAppliedTorque: " .. self.spec_motorized.motor.motorAppliedTorque)
		-- print("maxAcceleration: " .. self.spec_motorized.motor.maxAcceleration)
		
	end -- if spec.CVTconfig deactivated
end -- onUpdate




function CVTaddon:cCVTaVer()
	print("CVT-Addon Mod Version: " .. modversion)
	print("CVT-Addon Script Version: " .. scrversion)
	print("CVT-Addon Date: " .. lastupdate)
end
addConsoleCommand("cvtaVER", "Versions CVT-Addon", "cCVTaVer", CVTaddon)

function CVTaddon:cCVTaDBL(DBLcommand)
	local spec = self.spec_CVTaddon
	-- local spec = CVTaddon.spec_CVTaddon
	print("select: "..DBLcommand.."-------------------------------------")
	if DBLcommand == 1 then
		print("spec.forDBL_drivinglevel: " .. spec.forDBL_drivinglevel)
		print("spec.vOne: " .. spec.vOne)
	elseif DBLcommand == 2 then
		print("-------------------------------------------------------------")
		print("spec.forDBL_accramp: " .. spec.forDBL_accramp)
		print("spec.vTwo: " .. spec.vTwo)
	elseif DBLcommand == 3 then
		print("-------------------------------------------------------------")
		print("spec.forDBL_brakeramp: " .. spec.forDBL_brakeramp)
		print("spec.vThree: " .. spec.vThree)
	elseif DBLcommand == 4 then
		print("-------------------------------------------------------------")
		print("spec.forDBL_neutral: " .. spec.forDBL_neutral)
		print("spec.vFour: " .. spec.vFour)
	elseif DBLcommand == 5 then
		print("-------------------------------------------------------------")
		print("spec.forDBL_autoDiffs: " .. tostring(spec.forDBL_autoDiffs))
		print("spec.autoDiffs: " .. tostring(spec.autoDiffs))
	elseif DBLcommand == 6 then
		print("-------------------------------------------------------------")
		print("spec.forDBL_tmspedal: " .. tostring(spec.forDBL_tmspedal))
		print("spec.isTMSpedal: " .. tostring(spec.isTMSpedal))
	elseif DBLcommand == 7 then
		print("-------------------------------------------------------------")
		print("spec.forDBL_tmspedalVmax: " .. spec.forDBL_tmspedalVmax)
	elseif DBLcommand == 8 then
		print("-------------------------------------------------------------")
		print("spec.forDBL_pedalpercent: " .. spec.forDBL_pedalpercent)
	elseif DBLcommand == 9 then
		print("-------------------------------------------------------------")
		print("spec.forDBL_tmspedalVmaxActual: " .. spec.forDBL_tmspedalVmaxActual)
	elseif DBLcommand == 10 then
		print("-------------------------------------------------------------")
		print("spec.forDBL_digitalhandgasstep: " .. spec.forDBL_digitalhandgasstep)
		print("spec.vFive: " .. spec.vFive)
	elseif DBLcommand == 11 then
		print("-------------------------------------------------------------")
		print("spec.forDBL_rpmrange: " .. spec.forDBL_rpmrange)
	elseif DBLcommand == 12 then
		print("-------------------------------------------------------------")
		print("spec.forDBL_rpmDmin: " .. spec.forDBL_rpmDmin)
	elseif DBLcommand == 13 then
		print("-------------------------------------------------------------")
		print("spec.forDBL_rpmDmax: " .. spec.forDBL_rpmDmax)
	elseif DBLcommand == 14 then
		print("-------------------------------------------------------------")
		print("spec.forDBL_IPMactive: " .. spec.forDBL_IPMactive)
	elseif DBLcommand == 15 then
		print("-------------------------------------------------------------")
		-- print("spec.forDBL_rpmrange: " .. spec.forDBL_rpmrange)
	elseif DBLcommand == 16 then
		print("-------------------------------------------------------------")
	else
		-- return "1:DL | 2:AR | 3:BR | 4:N | 5:aD | 6:TP | 7:TPm | 8:P% | 9:TPa | 10:DHg | 11:RR | 12:Rn | 13:Rx | 14:IPM | 15: | 16: "
		print("1:DL | 2:AR | 3:BR | 4:N | 5:aD | 6:TP | 7:TPm | 8:P% | 9:TPa | 10:DHg | 11:RR | 12:Rn | 13:Rx | 14:IPM | 15: | 16: ")
	end
end
addConsoleCommand("cvtaDBL", "Versions CVT-Addon", "cCVTaDBL", nil)

function CVTaddon:cCVTaSetCfg(cfgID)
	local spec = self.spec_CVTaddon
	print("CVT-Addon Sets " .. tostring(cfgID))
	print("CVT-Addon Sets Config from: " .. tostring(spec.CVTconfig))
	spec.CVTconfig = cfgID
	print("to " .. spec.CVTconfig)
end
addConsoleCommand("cvtaSETcfg", "Versions CVT-Addon", "cCVTaSetCfg", CVTaddon)

----------------------------------------------------------------------------------------------------------------------	
----------------------------------------------------------------------------------------------------------------------			
------------- Should be external in CVT_Addon_HUD.lua, but I can't sync spec between 2 lua's -------------------------			
function CVTaddon:onDraw(dt)
	local spec = self.spec_CVTaddon
	if g_client ~= nil and spec.CVTconfig ~= 8 then
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
					if spec.vOne == 2 then
						if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 then
							spec.CVTIconFs1:render()
						end
					elseif spec.vOne == 1 then
						if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 then
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
						if spec.CVTconfig == 1 or spec.CVTconfig == 2 or spec.CVTconfig == 3 then
							if spec.vOne == 1 then
								setTextColor(0.8, 0.8, 0, 0.8)
								setTextAlignment(RenderText.ALIGN_LEFT)
								setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
								setTextBold(false)
								spec.forDBL_autoDiffs = 1 -- Vorwahl und inaktiv
							elseif spec.vOne == 2 then
								setTextColor(0, 0.95, 0, 0.8)
								setTextAlignment(RenderText.ALIGN_LEFT)
								setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
								setTextBold(false)
								spec.forDBL_autoDiffs = 2 -- aktiv
							end
							renderText( 0.485 * ( VCAposX + VCAwidth + 1 ), VCAposY + 0.2 * VCAheight, VCAl + 0.005, "A" )
						elseif spec.CVTconfig == 4 or spec.CVTconfig == 5 or spec.CVTconfig == 6 then
							if spec.vOne >= 1 then
								setTextColor(0, 0.95, 0, 0.8)
								setTextAlignment(RenderText.ALIGN_LEFT)
								setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
								setTextBold(false)
								spec.forDBL_autoDiffs = 2 -- aktiv
							end
							renderText( 0.485 * ( VCAposX + VCAwidth + 1 ), VCAposY + 0.2 * VCAheight, VCAl + 0.005, "A" )
						end
					elseif spec.autoDiffs ~= 1 then
						spec.forDBL_autoDiffs = 0 -- inaktiv
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

function CVTaddon.SyncClientServer(vehicle, vOne, vTwo, vThree, vFour, vFive, autoDiffs, lastDirection, isVarioTM, isTMSpedal, PedalResolution, rpmDmax, rpmrange, CVTconfig)
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
	spec.rpmrange = rpmrange
	spec.CVTconfig = CVTconfig
	-- spec.mcRPMvar = mcRPMvar
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
	spec.rpmrange = streamReadInt32(streamId) -- rpm state for max rpm
	spec.CVTconfig = streamReadInt32(streamId) -- rpm state for max rpm
	-- spec.mcRPMvar = streamReadFloat32(streamId) -- rpm state for max rpm
	
	-- Set DBL Values after read stream
	if spec.forDBL_IPMactive == nil then spec.forDBL_IPMactive = 0 end
	
	spec.forDBL_pedalpercent = "0"
	spec.forDBL_tmspedalVmax = "0"
	spec.forDBL_tmspedalVmaxActual = "0"
	
	if spec.autoDiffs == 1 then
		spec.forDBL_autoDiffs = 1 -- aktiv
	else
		spec.forDBL_autoDiffs = 0 -- inaktiv
	end
	if spec.vFour ~= nil then
		if spec.isTMSpedal == 0 then
			spec.forDBL_tmspedal = 0
		elseif spec.isTMSpedal == 1 then
			spec.forDBL_tmspedal = 1
		end
	end
	if spec.vFour ~= nil then
		if spec.vFour == 0 then
			spec.forDBL_neutral = 1
		elseif spec.vFour == 1 then
			spec.forDBL_neutral = 0
		end
	end
	if spec.vOne ~= nil then
		if spec.vOne == 1 then
			spec.forDBL_drivinglevel = tostring(2)
		elseif spec.vOne == 2 then
			spec.forDBL_drivinglevel = tostring(1)
		end
	end
	spec.forDBL_digitalhandgasstep = tostring(spec.vFive)
	if spec.vTwo ~= nil then
		if spec.vTwo == 1 then
			spec.forDBL_accramp = tostring(4)
		elseif spec.vTwo == 2 then
			spec.forDBL_accramp = tostring(1)
		elseif spec.vTwo == 3 then
			spec.forDBL_accramp = tostring(2)
		elseif spec.vTwo == 4 then
			spec.forDBL_accramp = tostring(3)
		end
	end
	spec.forDBL_rpmDmax = tostring(spec.rpmDmax)
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
	streamWriteInt32(streamId, spec.rpmrange)
	streamWriteInt32(streamId, spec.CVTconfig)
	-- streamWriteFloat32(streamId, spec.mcRPMvar)
end

-- if connection:getIsServer() then
-- if not connection:getIsServer() then

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
			spec.rpmrange = streamReadInt32(streamId)
			spec.CVTconfig = streamReadInt32(streamId)
			-- spec.mcRPMvar = streamReadFloat32(streamId)
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
			streamWriteInt32(streamId, spec.vFour)
			streamWriteInt32(streamId, spec.vFive)
			streamWriteInt32(streamId, spec.autoDiffs) -- 
			streamWriteInt32(streamId, spec.lastDirection)
			streamWriteBool(streamId, spec.isVarioTM)
			streamWriteInt32(streamId, spec.isTMSpedal)
			streamWriteInt32(streamId, spec.PedalResolution)
			streamWriteInt32(streamId, spec.rpmDmax) -- 
			streamWriteInt32(streamId, spec.rpmrange) -- 
			streamWriteInt32(streamId, spec.CVTconfig) -- 
			-- streamWriteFloat32(streamId, spec.mcRPMvar) -- 
			-- streamWriteBool(streamId, spec.check)
		end
	end
end

-- Drivable = true
-- addModEventListener(CVTaddon)
-- Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, CVTaddon.registerActionEvents)
-- Drivable.onUpdate  = Utils.appendedFunction(Drivable.onUpdate, CVTaddon.onUpdate);