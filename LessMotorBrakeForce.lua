-- @titel       LessMotorBrakeforce Script for FarmingSimulator 2022
-- @author      s4t4n, Danielmodding
-- @version     v1.0.0.0 Release Modhub
-- @version		v1.0.0.1 Small Changes(FS22 1.2.0.2)
-- @date        23/12/2022
-- @info        LessMotorBrakeforce Script for FarmingSimulator 2022
-- changed		app to pre 23.12.2022 SbSh(s4t4n)

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
					self.spec_motorized.motor.lowBrakeForceScale = self.spec_motorized.motor.lowBrakeForceScale*0.45; -- here you can change the engine brake effect.
																													  -- in next version you'll change via ingame hud
				end;
			end;
		end;
	end;
end;
Drivable = true
Drivable.onUpdate  = Utils.prependedFunction(Drivable.onUpdate, LessMotorBrakeforce.onUpdate);

