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

CVTaddon = {};
CVTaddon.eventActiveV1 = false
CVTaddon.eventActiveV2 = true
CVTaddon.eventActiveV3 = true
CVTaddon.eventActiveV4 = true
CVTaddon.eventIdV1 = nil
CVTaddon.eventIdV2 = nil
CVTaddon.eventIdV3 = nil
CVTaddon.eventIdV4 = nil
CVTaddon.vOne = 1
CVTaddon.vTwo = 4
CVTaddon.vThree = 2

-- local sbshDebugOn = true;

-- function CVTaddon.prerequisitesPresent(specializations)
    -- return true
-- end;

function CVTaddon.prerequisitesPresent(specializations) 
    return true
end 

function CVTaddon.registerEventListeners(vehicleType) 
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", CVTaddon) 
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", CVTaddon) 
    SpecializationUtil.registerEventListener(vehicleType, "draw", CVTaddon) 
    -- SpecializationUtil.registerEventListener(vehicleType, "onDraw", CVTaddon) 
end 

-- function CVTaddon:loadMap(...)
-- function CVTaddon:onLoad()
	-- self.vOne = 2 -- start with 1 for default in Vario II.
	-- vTwo = 1 -- make it not nil
	-- currentAccRamp = 4 -- start with acc.ramp 4 as standard
	-- eventIdV1, eventIdV2 = "", ""
-- end

-- function CVTaddon.checkIsManual(motor)
	
	-- local isVarioTM = self.spec_motorized.motor.lastManualShifterActive == false and self.spec_motorized.motor.groupType == 1 and self.spec_motorized.motor.gearType == 1
	-- local isManualTransmission = motor.backwardGears ~= nil or motor.forwardGears ~= nil
	-- if isManualTransmission and VehicleMotor.SHIFT_MODE_MANUAL_CLUTCH then	
		-- return true
	-- else
		-- return false
	-- end
	
-- end

-- function CVTaddon:RegisterActionEvents()
	-- if self.getIsEntered ~= nil and self:getIsEntered() then
		-- _, CVTaddon.eventIdV1 = g_inputBinding:registerActionEvent(InputAction.SETVARIOONE, CVTaddon, CVTaddon.VarioOne, false, true, false, true, 3.2, true) --
		-- _, CVTaddon.eventIdV2 = g_inputBinding:registerActionEvent(InputAction.SETVARIOTWO, CVTaddon, CVTaddon.VarioTwo, false, true, false, true, 1, true) --
	-- end
-- end
-- Drivable.registerActionEvents = Utils.appendedFunction(Drivable.registerActionEvents, CVTaddon.registerActionEvents)

function CVTaddon:onRegisterActionEvents()
	BackupMaxFwSpd = tostring(self.spec_motorized.motor.maxForwardSpeedOrigin)
	BackupMaxBwSpd = tostring(self.spec_motorized.motor.maxBackwardSpeedOrigin)
	calcBrakeForce = string.format("%.2f", BackupMaxFwSpd/100)
    if self.getIsEntered ~= nil and self:getIsEntered() then
        CVTaddon.actionEventsV1 = {}
        CVTaddon.actionEventsV2 = {}
        CVTaddon.actionEventsV3 = {}
        CVTaddon.actionEventsV4 = {}
		CVTaddon.eventActiveV1 = true
		CVTaddon.eventActiveV2 = true
		CVTaddon.eventActiveV3 = true
		CVTaddon.eventActiveV4 = true
		CVTaddon.vOne = 1
		CVTaddon.vTwo = 4
		CVTaddon.vThree = 2
		if sbshDebugOn then
			print("CVTaddon: vOne: ".. tostring(CVTaddon.vOne) .. " s: ".. tostring(self.vOne))
			print("CVTaddon: vTwo: ".. tostring(CVTaddon.vTwo) .. " s: ".. tostring(self.vTwo))
			print("CVTaddon: vThree: ".. tostring(CVTaddon.vThree) .. " s: ".. tostring(self.vThree))
		end
        _, CVTaddon.eventIdV1 = self:addActionEvent(CVTaddon.actionEventsV1, 'SETVARIOONE', self, CVTaddon.VarioOne, false, true, false, true, nil)
        g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV1, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV1, CVTaddon.eventActiveV1)
		
		_, CVTaddon.eventIdV2 = self:addActionEvent(CVTaddon.actionEventsV2, 'SETVARIOTWO', self, CVTaddon.VarioTwo, false, true, false, true, nil)
        g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV2, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV2, CVTaddon.eventActiveV2)
		
		_, CVTaddon.eventIdV3 = self:addActionEvent(CVTaddon.actionEventsV3, 'LMBF_TOGGLE_RAMP', self, CVTaddon.AccRamps, false, true, false, true, nil)
        g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV3, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV3, CVTaddon.eventActiveV3)
		
		_, CVTaddon.eventIdV4 = self:addActionEvent(CVTaddon.actionEventsV4, 'LMBF_TOGGLE_BRAMP', self, CVTaddon.BrakeRamps, false, true, false, true, nil)
        g_inputBinding:setActionEventTextPriority(CVTaddon.eventIdV4, GS_PRIO_NORMAL)
        g_inputBinding:setActionEventTextVisibility(CVTaddon.eventIdV4, CVTaddon.eventActiveV4)
    end
end

function CVTaddon:BrakeRamps()
	if sbshDebugOn then
		print("BrRamp Taste gedrückt vThree: "..CVTaddon.vThree)
		print("BrRamp Taste gedrückt lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
	end
	if self.CVTaddon == nil then 
        return
    end
	if not CVTaddon.eventActiveV4 then
        return
    end
	if (CVTaddon.vThree == 1) then -- BRamp 1
		self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00027777777777778 -- 1-2 kmh
		if sbshDebugOn then
			print("BrRamp 1 vThree: "..CVTaddon.vThree)
			print("BrRamp 1 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
		end
	end
	if (CVTaddon.vThree == 2) then -- BRamp 2
		self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00150 -- ca 4 kmh
		if sbshDebugOn then
			print("BrRamp 2 vThree: "..CVTaddon.vThree)
			print("BrRamp 2 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
		end
	end
	if (CVTaddon.vThree == 3) then -- BRamp 3
		self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00250 -- ca 8 kmh
		if sbshDebugOn then
			print("BrRamp 3 vThree: "..CVTaddon.vThree)
			print("BrRamp 3 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
		end
	end
	if (CVTaddon.vThree == 4) then -- BRamp 4
		self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00427 -- 15 km/h
		if sbshDebugOn then
			print("BrRamp 4 vThree: "..CVTaddon.vThree)
			print("BrRamp 4 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
		end
	end
	if (CVTaddon.vThree == 5) then -- BRamp 5
		self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00500 -- 17 kmh
		if sbshDebugOn then
			print("BrRamp 5 vThree: "..CVTaddon.vThree)
			print("BrRamp 5 lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
		end
	end
	if CVTaddon.vThree == 5 then
		CVTaddon.vThree = 1
	else
		CVTaddon.vThree = CVTaddon.vThree + 1
	end
	if sbshDebugOn then
		print("BrRamp Taste losgelassen vThree: "..CVTaddon.vThree)
		print("BrRamp Taste losgelassen lBFSL: "..self.spec_motorized.motor.lowBrakeForceSpeedLimit)
	end
end

function CVTaddon:AccRamps()
	if sbshDebugOn then
		print("AccRamp Taste gedrückt vTwo: "..CVTaddon.vTwo)
		print("AccRamp Taste gedrückt acc: "..self.spec_motorized.motor.accelerationLimit)
	end
	if self.CVTaddon == nil then 
        return
    end
	if not CVTaddon.eventActiveV3 then
        return
    end
	if (CVTaddon.vTwo == 1) then -- Ramp 1
		self.spec_motorized.motor.accelerationLimit = 0.50
		self.spec_motorized.motor.lowBrakeForceScale = (calcBrakeForce-0.10)
		if sbshDebugOn then
			print("AccRamp 1 vTwo: "..CVTaddon.vTwo)
			print("AccRamp 1 acc0.5: "..self.spec_motorized.motor.accelerationLimit)
		end
	end
	if (CVTaddon.vTwo == 2) then -- Ramp 2
		self.spec_motorized.motor.accelerationLimit = 1.00
		self.spec_motorized.motor.lowBrakeForceScale = (calcBrakeForce)
		if sbshDebugOn then
			print("AccRamp 2 vTwo: "..CVTaddon.vTwo)
			print("AccRamp 2 acc1.0: "..self.spec_motorized.motor.accelerationLimit)
		end
	end
	if (CVTaddon.vTwo == 3) then -- Ramp 3
		self.spec_motorized.motor.accelerationLimit = 1.50
		self.spec_motorized.motor.lowBrakeForceScale = (calcBrakeForce+0.03)
		if sbshDebugOn then
			print("AccRamp 3 vTwo: "..CVTaddon.vTwo)
			print("AccRamp 3 acc1.5: "..self.spec_motorized.motor.accelerationLimit)
		end
	end
	if (CVTaddon.vTwo == 4) then -- Ramp 4
		self.spec_motorized.motor.accelerationLimit = 2.00 -- Standard
		self.spec_motorized.motor.lowBrakeForceScale = (calcBrakeForce+0.08)
		if sbshDebugOn then
			print("AccRamp 4 vTwo: "..CVTaddon.vTwo)
			print("AccRamp 4 acc2.0: "..self.spec_motorized.motor.accelerationLimit)
		end
	end
	if CVTaddon.vTwo == 4 then
		CVTaddon.vTwo = 1
	else
		CVTaddon.vTwo = CVTaddon.vTwo + 1
	end
	if sbshDebugOn then
		print("AccRamp Taste losgelassen vTwo: "..CVTaddon.vTwo)
		print("AccRamp Taste losgelassen acc: "..self.spec_motorized.motor.accelerationLimit)
	end
end

function CVTaddon:VarioOne() -- field
	if sbshDebugOn then
		print("VarioOne Taste gedrückt vOne: "..CVTaddon.vOne)
		print("VarioOne : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..calcBrakeForce)
	end
	if self.CVTaddon == nil then 
        return
    end
	if not CVTaddon.eventActiveV1 then
        return
    end
	if (CVTaddon.vOne == 1) then
		CVTaddon.vOne = 3.2
		self.spec_motorized.motor.maxForwardSpeed = self.spec_motorized.motor.maxForwardSpeed / 3.2
		self.spec_motorized.motor.maxBackwardSpeed = self.spec_motorized.motor.maxBackwardSpeed / 2
		self.spec_motorized.motor.lowBrakeForceScale = (calcBrakeForce+0.05)
		-- CVTaddon.eventActiveV1 = true
		if sbshDebugOn then
			print("VarioOne vOne: "..CVTaddon.vOne)
			print("VarioOne : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..calcBrakeForce)
		end
	end
	if sbshDebugOn then
		print("VarioOne Taste losgelassen vOne: "..CVTaddon.vOne)
		print("VarioOne : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..calcBrakeForce)
	end
end
function CVTaddon:VarioTwo() -- street
	if sbshDebugOn then
		print("VarioTwo Taste gedrückt vOne: "..CVTaddon.vOne)
		print("VarioTwo : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..calcBrakeForce)
		print("VarioTwo : BMFwSpd/BMBwSpd:"..tostring(BackupMaxFwSpd).."/"..tostring(BackupMaxBwSpd))
	end
	if self.CVTaddon == nil then 
        return
    end
	if not CVTaddon.eventActiveV2 then
        return
    end
	if (CVTaddon.vOne ~= 1) then
		CVTaddon.vOne = 1
		self.spec_motorized.motor.maxForwardSpeed = BackupMaxFwSpd
		self.spec_motorized.motor.maxBackwardSpeed = BackupMaxBwSpd
		self.spec_motorized.motor.lowBrakeForceScale = (calcBrakeForce-0.03)
		-- CVTaddon.eventActiveV2 = true
		if sbshDebugOn then
			print("VarioTwo vOne: "..CVTaddon.vOne)
			print("VarioTwo : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..calcBrakeForce)
			print("VarioTwo : BMFwSpd/BMBwSpd:"..tostring(BackupMaxFwSpd).."/"..tostring(BackupMaxBwSpd))
		end
	end
	if sbshDebugOn then
		print("VarioTwo Taste losgelassen vOne: "..CVTaddon.vOne)
		print("VarioTwo : FwS/BwS/lBFS/cBF:"..self.spec_motorized.motor.maxForwardSpeed.."/"..self.spec_motorized.motor.maxBackwardSpeed.."/"..self.spec_motorized.motor.lowBrakeForceScale.."/"..calcBrakeForce)
		print("VarioTwo : BMFwSpd/BMBwSpd:"..tostring(BackupMaxFwSpd).."/"..tostring(BackupMaxBwSpd))
	end
end

function CVTaddon:onUpdate(dt)
	local isEntered = self.getIsEntered ~= nil and self:getIsEntered()
	local isVarioTM = self.spec_motorized.motor.lastManualShifterActive == false and self.spec_motorized.motor.groupType == 1 and self.spec_motorized.motor.gearType == 1
	local currentSpeedDrv = tonumber(string.format("%.2f", self:getLastSpeed()))
	if isEntered then
		if self.CVTaddon == nil then
			self.CVTaddon = true

			if self.spec_motorized ~= nil then
				if self.spec_motorized.motor ~= nil then
					if self.spec_motorized.motor.lowBrakeForceScale ~= nil then
						if self.spec_motorized.motor.lastManualShifterActive == false and self.spec_motorized.motor.groupType == 1 and self.spec_motorized.motor.gearType == 1 then
							-- self.spec_motorized.motor.lowBrakeForceScale = self.spec_motorized.motor.lowBrakeForceScale*0.62; -- in % 10 - 120 (0.90 - 1.20) Settings_Menü, einstellbar, save mp/sp

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
							
							-- self.spec_motorized.motor.lowBrakeForceScale = self.spec_motorized.motor.lowBrakeForceScale*0.52
							
							-- -- ramp 4
							
							-- self.spec_motorized.motor.lowBrakeForceScale = self.spec_motorized.motor.lowBrakeForceScale*0.69
						end;
						
						-- if self.spec_motorized.motor.lastManualShifterActive == true then -- manualTransmission-Vehicle
							-- self.spec_motorized.motor.lowBrakeForceScale = 0.04; 
						-- end;
					end;
				end;
			end;
		end;
		
		-- Acceleration ramps - Beschleunigungsrampen
		if CVTaddon.vTwo == 1 and isVarioTM then
			g_currentMission:addExtraPrintText(g_i18n:getText("txt_accRamp4")) -- #l10n
		end
		if CVTaddon.vTwo == 2 and isVarioTM then
			g_currentMission:addExtraPrintText(g_i18n:getText("txt_accRamp1")) -- #l10n
		end
		if CVTaddon.vTwo == 3 and isVarioTM then
			g_currentMission:addExtraPrintText(g_i18n:getText("txt_accRamp2")) -- #l10n
		end
		if CVTaddon.vTwo == 4 and isVarioTM then
			g_currentMission:addExtraPrintText(g_i18n:getText("txt_accRamp3")) -- #l10n
		end
		
		-- Brake ramps - Bremsrampen
		if CVTaddon.vThree == 1 and isVarioTM then
			g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp5")) -- #l10n
		end
		if CVTaddon.vThree == 2 and isVarioTM then
			g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp1")) -- #l10n
		end
		if CVTaddon.vThree == 3 and isVarioTM then
			g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp2")) -- #l10n
		end
		if CVTaddon.vThree == 4 and isVarioTM then
			g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp3")) -- #l10n
		end
		if CVTaddon.vThree == 5 and isVarioTM then
			g_currentMission:addExtraPrintText(g_i18n:getText("txt_bRamp4")) -- #l10n
		end
		
		
		
		-- -- Fahrstufe I. 
		if CVTaddon.vOne ~= 1 and CVTaddon.vOne ~= nil and isVarioTM then
			g_currentMission:addExtraPrintText(g_i18n:getText("txt_VarioOne")) -- #l10n
		end
		
		-- -- Fahrstufe II. (Street/light weight transport or work) inputbinding
			if CVTaddon.vOne == 1 and isVarioTM then
				g_currentMission:addExtraPrintText(g_i18n:getText("txt_VarioTwo")) -- #l10n
			end

	end;
	if sbshDebugOn then
	-- -- Dev Text Help Zeug -------------------------------------------------------------------------------------------------------------------------------
			-- g_currentMission:addExtraPrintText("accelerationLimit: " .. self.spec_motorized.motor.accelerationLimit)
			-- g_currentMission:addExtraPrintText("accelerationLimitLoadScale: " .. self.spec_motorized.motor.accelerationLimitLoadScale)
			-- g_currentMission:addExtraPrintText("lowBrakeForceScale: " .. self.spec_motorized.motor.lowBrakeForceScale)
			-- g_currentMission:addExtraPrintText("gearType: " .. tostring(self.spec_motorized.motor.gearType))
			
			
			
					-- g_currentMission:addExtraPrintText("LMBF.VarioOne: " .. tostring(CVTaddon.VarioOne))
					-- g_currentMission:addExtraPrintText("s.VarioOne: " .. tostring(self.VarioOne))
					-- g_currentMission:addExtraPrintText("LMBf.eventIdV1: " .. tostring(CVTaddon.eventIdV1))
					-- g_currentMission:addExtraPrintText("LMBf.eventIdV2: " .. tostring(CVTaddon.eventIdV2))
					-- g_currentMission:addExtraPrintText("LMBF.vOne: " .. tostring(CVTaddon.vOne))
					-- g_currentMission:addExtraPrintText("self.vOne: " .. tostring(self.vOne))
					-- Sam: Gibt auch self.lastSpeed oder motor.lastSpeed oder so.. 
					-- 		Aber das ist eher die Bewegungsgeschwindigkeit vom Fahrzeug nicht die Drehzahl der Reifen, sprich wenns durch dreht is das 0
					
					--local wheel = self.spec_wheels.wheels[wheelIndex]
					-- wheel.AvgWheelSpeed = math.abs(refSpeed)
					-- self.vehicle.lastSpeedAcceleration
					-- getVehicleDamage
					-- g_currentMission:addExtraPrintText("hud vis: " .. tostring(g_currentMission.hud.isVisible))
					g_currentMission:addExtraPrintText("getLastSpeed: " .. string.format("%.2f", self:getLastSpeed()))
					-- g_currentMission:addExtraPrintText("eventActiveV1: " .. tostring(CVTaddon.eventActiveV1))
					-- g_currentMission:addExtraPrintText("eventActiveV2: " .. tostring(CVTaddon.eventActiveV2))
					-- g_currentMission:addExtraPrintText("BackupMaxFwSpd: " .. tostring(BackupMaxFwSpd))
					-- g_currentMission:addExtraPrintText("BackupMaxBwSpd: " .. tostring(BackupMaxBwSpd))
					g_currentMission:addExtraPrintText("vOne: " .. tostring(CVTaddon.vOne))
					g_currentMission:addExtraPrintText("vTwo: " .. tostring(CVTaddon.vTwo))
					g_currentMission:addExtraPrintText("vThree: " .. tostring(CVTaddon.vThree))
					g_currentMission:addExtraPrintText("accL: " .. tostring(self.spec_motorized.motor.accelerationLimit))
					-- g_currentMission:addExtraPrintText("maxForwardSpeed: " .. tostring(self.spec_motorized.motor.maxForwardSpeed))
					-- g_currentMission:addExtraPrintText("maxBackwardSpeed: " .. tostring(self.spec_motorized.motor.maxBackwardSpeed))
					-- g_currentMission:addExtraPrintText("maxForwardSpeedOrigin: " .. tostring(self.spec_motorized.motor.maxForwardSpeedOrigin))
			
			
			
			-- g_currentMission:addExtraPrintText("groupType: " .. tostring(self.spec_motorized.motor.groupType))
			-- g_currentMission:addExtraPrintText("lastManualShifterActive: " .. tostring(self.spec_motorized.motor.lastManualShifterActive))
			-- g_currentMission:addExtraPrintText("lowBrakeForceSpeedLimit: " .. tostring(self.spec_motorized.motor.lowBrakeForceSpeedLimit))
			
			-- print("lowBrakeForceSpeedLimit: " .. tostring(self.spec_motorized.motor.lowBrakeForceSpeedLimit))
			-- g_currentMission:addExtraPrintText("lastAcceleratorPedal: " .. self.spec_motorized.motor.gearShiftMode)
			-- g_currentMission:addExtraPrintText("minGearRatio: " .. self.spec_motorized.motor.maxGearRatio)
			-- g_currentMission:addExtraPrintText("maxClutchTorque: " .. tostring(self.spec_motorized.motor.maxClutchTorque))
			-- g_currentMission:addExtraPrintText("constantRpmCharge: " .. tostring(self.spec_motorized.motor.constantRpmCharge))
	--------------------------------------------------------------------------------------------------------------------------------------------------------------
	end
end

function CVTaddon:draw()
	print("CVTaddon: DRAW")
	if g_currentMission.hud.isVisible and isEntered then

        -- calculate position and size
        local posX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX
        local posY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1)
        local size = 0.015 * g_gameSettings.uiScale
		local insTextV = 0
		if CVTaddon.vOne == 1 then
			insTextV = "txt_VarioOne"
		end
		if CVTaddon.vOne == 3.2 then
			insTextV = "txt_VarioTwo"
		end
        -- add current driving level to table
        -- g_i18n:getText(insTextV)
        
        local genText = tostring(g_i18n:getText(insTextV))
        -- render
        -- setTextColor(0.7,1.0,0.4,1.0)
        setTextColor(1,1,1,1)
        setTextAlignment(RenderText.ALIGN_CENTER)
        setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
        setTextBold(false)
        renderText(posX, posY, size, genText)
        print("CVTaddon: DRAWi")
        -- Back to defaults
        -- setTextColor(1,1,1,1)
        -- setTextAlignment(RenderText.ALIGN_LEFT)
        -- setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE)
        -- setTextBold(false)

	end
end

-- Drivable = true
-- addModEventListener(CVTaddon)
-- Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, CVTaddon.registerActionEvents)
-- Drivable.onUpdate  = Utils.appendedFunction(Drivable.onUpdate, CVTaddon.onUpdate);