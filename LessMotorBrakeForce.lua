-- @titel       LessMotorBrakeforce Script for FarmingSimulator 2022
-- @author      s4t4n, Danielmodding
-- @version     v1.0.0.0 Release Modhub
-- @version		v1.0.0.1 Small Changes(FS22 1.2.0.2)
-- @date        23/12/2022
-- @info        LessMotorBrakeforce Script for FarmingSimulator 2022
-- changed		app to pre 23.12.2022 SbSh(s4t4n)
-- changelog	Anpassung an FS22_realismAddon_gearbox von modelleicher

LessMotorBrakeforce = {};

function LessMotorBrakeforce.prerequisitesPresent(specializations)
    return true
end;

function LessMotorBrakeforce.checkIsManual(motor)
	
	local isManualTransmission = motor.backwardGears ~= nil or motor.forwardGears ~= nil
	if isManualTransmission and VehicleMotor.SHIFT_MODE_MANUAL_CLUTCH then	
		return true
	else
		return false
	end
end

function LessMotorBrakeforce:onUpdate(dt)
	if self.LessMotorBrakeforce == nil then
		self.LessMotorBrakeforce = true;

		if self.spec_motorized ~= nil then
			if self.spec_motorized.motor ~= nil then
				if self.spec_motorized.motor.lowBrakeForceScale ~= nil then
					-- 0.25 = -25% BrakeForce
					if self.spec_motorized.motor.lastManualShifterActive == false then
						self.spec_motorized.motor.lowBrakeForceScale = self.spec_motorized.motor.lowBrakeForceScale*0.52 
						self.spec_motorized.motor.lowBrakeForceSpeedLimit = 0.00427 -- 15 km/h
						-- Fahrstufe I.
						-- self.spec_motorized.motor.gearRatio = self.spec_motorized.motor.gearRatio * 1.5
						
						
						-- Fahrstufe II.
						
					end
					if self.spec_motorized.motor.lastManualShifterActive == true then
						-- self.spec_motorized.motor.lowBrakeForceScale = 0.04; 
					end
				end;
			end;
		end;
	end;
	g_currentMission:addExtraPrintText("gearRatio: " .. self.spec_motorized.motor.gearRatio)
	-- g_currentMission:addExtraPrintText("gearChangeTimeAutoReductionTime: " .. self.spec_motorized.motor.gearChangeTimeAutoReductionTime)
	-- g_currentMission:addExtraPrintText("differentialRotSpeed: " .. self.spec_motorized.motor.differentialRotSpeed*math.pi)
	-- g_currentMission:addExtraPrintText("rawLoadPercentage: " .. self.spec_motorized.motor.rawLoadPercentage)
	
end;
-- Drivable = true
Drivable.onUpdate  = Utils.appendedFunction(Drivable.onUpdate, LessMotorBrakeforce.onUpdate);