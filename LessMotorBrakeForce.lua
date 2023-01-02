-- @titel       LessMotorBrakeforce Script for FarmingSimulator 2022
-- @author      s4t4n
-- @version     v1.0.0.0 Release Modhub
-- @version		v1.0.0.1 Small Changes(FS22 1.2.0.2)
-- @date        23/12/2022
-- @info        LessMotorBrakeforce Script for FarmingSimulator 2022
-- changed		app to pre 23.12.2022 SbSh(s4t4n)
-- changelog	Anpassung an FS22_realismAddon_gearbox von modelleicher
--				+ Vario Fahrstufen und Beschleunigungsrampen

LessMotorBrakeforce = {};

function LessMotorBrakeforce.prerequisitesPresent(specializations)
    return true
end;

-- function LessMotorBrakeforce:loadMap(...)
function LessMotorBrakeforce:mapLoaded()
	vOne = 1 -- start with 1 for default in Vario II.
	vTwo = 1 -- make it not nil
	currentAccRamp = 4 -- start with acc.ramp 4 as standard
	self.eventIdV1, self.eventIdV2 = "", ""
end

function LessMotorBrakeforce.checkIsManual(motor)
	
	local isVarioTM = self.spec_motorized.motor.lastManualShifterActive == false and self.spec_motorized.motor.groupType == 1 and self.spec_motorized.motor.gearType == 1
	local isManualTransmission = motor.backwardGears ~= nil or motor.forwardGears ~= nil
	if isManualTransmission and VehicleMotor.SHIFT_MODE_MANUAL_CLUTCH then	
		return true
	else
		return false
	end
	
end

function LessMotorBrakeforce:registerActionEvents()
	if self.getIsEntered ~= nil and self:getIsEntered() then
		_, LessMotorBrakeforce.eventIdV1 = g_inputBinding:registerActionEvent(InputAction.SETVARIOONE, LessMotorBrakeforce, LessMotorBrakeforce.VarioOne, false, true, false, true, 3.2, true) --
		_, LessMotorBrakeforce.eventIdV2 = g_inputBinding:registerActionEvent(InputAction.SETVARIOTWO, LessMotorBrakeforce, LessMotorBrakeforce.VarioTwo, false, true, false, true, 1, true) --
	end
end

function LessMotorBrakeforce:VarioOne()
	if (LessMotorBrakeforce.vOne == 1) then return end
	vOne = 3.2
	self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeed / LessMotorBrakeforce.vOne -- test
	self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeed / LessMotorBrakeforce.vOne -- test
	
end
function LessMotorBrakeforce:VarioTwo()
	if (LessMotorBrakeforce.vOne ~= 1) then return end
	vOne = 1
	self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeed / LessMotorBrakeforce.vOne -- test
	self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeed / LessMotorBrakeforce.vOne -- test
	
end

function LessMotorBrakeforce:onUpdate(dt)
	local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
	if isEntered then
		if self.LessMotorBrakeforce == nil then
			self.LessMotorBrakeforce = true

			if self.spec_motorized ~= nil then
				if self.spec_motorized.motor ~= nil then
					if self.spec_motorized.motor.lowBrakeForceScale ~= nil then
						if self.spec_motorized.motor.lastManualShifterActive == false and self.spec_motorized.motor.groupType == 1 and self.spec_motorized.motor.gearType == 1 then
							self.spec_motorized.motor.lowBrakeForceScale = self.spec_motorized.motor.lowBrakeForceScale*0.52 -- in % 10 - 120 (0.90 - 1.20) Settings_Menü, einstellbar, save mp/sp
							-- self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00427 -- 15 km/h  -- Standard, 5kmh, 10 kmh, 15 kmh, 20 kmh, 25 kmh Settings_Menü, einstellbar, save mp/sp / Werte müssen noch ermittelt werden
							-- 0.00027777777777778 original
							-- 0.00127
							
							
							-- -- Beschleunigungsrampen inputbinding toggle 1 - 4
							-- -- ramp 1
							-- self.spec_motorized.motor.accelerationLimit = 0.50
							-- self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00027777777777778 -- default
							-- self.spec_motorized.motor.lowBrakeForceScale = self.spec_motorized.motor.lowBrakeForceScale*0.37
							
							-- -- ramp 2
							-- self.spec_motorized.motor.accelerationLimit = 1.00
							-- self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00150 -- ca 4 kmh
							-- self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00250 -- ca 8 kmh
							-- self.spec_motorized.motor.lowBrakeForceScale = self.spec_motorized.motor.lowBrakeForceScale*0.44
							
							-- -- ramp 3
							-- self.spec_motorized.motor.accelerationLimit = 1.50
							self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00427 -- 15 km/h
							-- self.spec_motorized.motor.lowBrakeForceScale = self.spec_motorized.motor.lowBrakeForceScale*0.52
							
							-- -- ramp 4
							-- self.spec_motorized.motor.accelerationLimit = 2.00 -- Standard
							-- self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00500 -- 17 kmh
							-- self.spec_motorized.motor.lowBrakeForceScale = self.spec_motorized.motor.lowBrakeForceScale*0.69
						end;
						
						-- if self.spec_motorized.motor.lastManualShifterActive == true then
							-- self.spec_motorized.motor.lowBrakeForceScale = 0.04; 
						-- end;
					end
				end
			end
		end
		
		
		-- -- Fahrstufe I. (Field/heavy weight tranport or work) inputbinding
		g_inputBinding:setActionEventActive(LessMotorBrakeforce.eventIdV1, LessMotorBrakeforce.vOne == 1)
		g_inputBinding:setActionEventTextVisibility(LessMotorBrakeforce.eventIdV1, LessMotorBrakeforce.vOne == 1)
		g_inputBinding:setActionEventTextPriority(LessMotorBrakeforce.eventIdV1, GS_PRIO_VERY_HIGH)
		if LessMotorBrakeforce.vOne ~= 1 then
			g_currentMission:addExtraPrintText(g_i18n:getText("txt_VarioOne")) -- #l10n
		end
		
		-- -- Fahrstufe II. (Street/light weight transport or work) inputbinding
		-- Standard lassen
			g_inputBinding:setActionEventActive(LessMotorBrakeforce.eventIdV2, LessMotorBrakeforce.vOne ~= 1)
			g_inputBinding:setActionEventTextVisibility(LessMotorBrakeforce.eventIdV2, LessMotorBrakeforce.vOne ~= 1)
			g_inputBinding:setActionEventTextPriority(LessMotorBrakeforce.eventIdV2, GS_PRIO_VERY_HIGH)
			if LessMotorBrakeforce.vOne == 1 then
				g_currentMission:addExtraPrintText(g_i18n:getText("txt_VarioTwo")) -- #l10n
			end

	end
	-- -- Dev Text Help Zeug
			-- g_currentMission:addExtraPrintText("accelerationLimit: " .. self.spec_motorized.motor.accelerationLimit)
			-- g_currentMission:addExtraPrintText("accelerationLimitLoadScale: " .. self.spec_motorized.motor.accelerationLimitLoadScale)
			-- g_currentMission:addExtraPrintText("lowBrakeForceScale: " .. self.spec_motorized.motor.lowBrakeForceScale)
			-- g_currentMission:addExtraPrintText("gearType: " .. tostring(self.spec_motorized.motor.gearType))
			-- g_currentMission:addExtraPrintText("isManualTransmission: " .. tostring(isManualTransmission))
			g_currentMission:addExtraPrintText("LessMotorBrakeforce.eventIdV1: " .. tostring(LessMotorBrakeforce.eventIdV1))
			g_currentMission:addExtraPrintText("self.eventIdV1: " .. tostring(self.eventIdV1))
			g_currentMission:addExtraPrintText("eventIdV1: " .. tostring(eventIdV1))
			g_currentMission:addExtraPrintText("vOne: " .. tostring(vOne))
			g_currentMission:addExtraPrintText("LMBF.vOne: " .. tostring(LessMotorBrakeforce.vOne))
			g_currentMission:addExtraPrintText("self.vOne: " .. tostring(self.vOne))
			g_currentMission:addExtraPrintText("isEntered: " .. tostring(isEntered))
			-- g_currentMission:addExtraPrintText("groupType: " .. tostring(self.spec_motorized.motor.groupType))
			-- g_currentMission:addExtraPrintText("lastManualShifterActive: " .. tostring(self.spec_motorized.motor.lastManualShifterActive))
			-- g_currentMission:addExtraPrintText("lowBrakeForceSpeedLimit: " .. tostring(self.spec_motorized.motor.lowBrakeForceSpeedLimit))
			g_currentMission:addExtraPrintText("maxForwardSpeed: " .. tostring(self.spec_motorized.motor.maxForwardSpeed))
			-- print("lowBrakeForceSpeedLimit: " .. tostring(self.spec_motorized.motor.lowBrakeForceSpeedLimit))
			-- g_currentMission:addExtraPrintText("lastAcceleratorPedal: " .. self.spec_motorized.motor.gearShiftMode)
			-- g_currentMission:addExtraPrintText("minGearRatio: " .. self.spec_motorized.motor.maxGearRatio)
			-- g_currentMission:addExtraPrintText("maxClutchTorque: " .. tostring(self.spec_motorized.motor.maxClutchTorque))
			-- g_currentMission:addExtraPrintText("constantRpmCharge: " .. tostring(self.spec_motorized.motor.constantRpmCharge))
	
end
-- Drivable = true
-- addModEventListener(LessMotorBrakeforce)
Drivable.onUpdate  = Utils.appendedFunction(Drivable.onUpdate, LessMotorBrakeforce.onUpdate);