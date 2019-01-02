-- Original version ls15: less engine braking effect
-- by slin2R
-- Vielen Dank für die Freigabe!

-- Modification to: more engine braking effect by twizzle
-- LS 17 by s4t4n less effect

-- s4t4n Motorbremse auf ein reales Maß erstellt

-- local version = "1.0.3   beta (02.12.2018)";
-- local version = "1.0.5.0 beta (28.12.2018)";
-- local version = "1.0.6.0 beta (01.01.2019)";
-- local version = "1.0.6.1 beta (02.01.2019)";

VehicleMotor = {};
VehicleMotor.dir = g_currentModDirectory;
addModEventListener(VehicleMotor);
local modDesc = loadXMLFile("modDesc", g_currentModDirectory .. "modDesc.xml");
LS19_enginebrake.version = getXMLString(modDesc, "modDesc.version");
LS19_enginebrake.modDirectory = g_currentModDirectory;
--local path = system.pathForFile( "FS19_KeyboardSteer*", g_currentModDirectory )

--> This opens the specified file and returns nil if it couldn't be found
--local fh = io.open( path, "r" )


	print("   _________________________________________________________");
	print("_-¯ Engine braking effect Ver.:" .. self.version .. ", by s4t4n ¯-_");
	print("¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯");


function VehicleMotor:setLowBrakeForce(lowBrakeForceScale, lowBrakeForceSpeedLimit, brakeForce)

	if fh then
		print("_-¯ KeyboardSteer mod by mogli12 found, reb will adjust enginebrakes")
		--self.handbrake = false;
		if lowBrakeForceScale <= 0.001 then
			self.lowBrakeForceScale = 0.144
			self.brakeForce = brakeForce
			-- self.lowBrakeForceSpeedLimit = lowBrakeForceSpeedLimit;
			self.lowBrakeForceSpeedLimit = 1
		else
			self.lowBrakeForceScale = lowBrakeForceScale;
			self.lowBrakeForceSpeedLimit = 1
		end

	else
		print("_-¯ REB will work normally")
		if lowBrakeForceScale <= 0.001 then
			self.lowBrakeForceScale = 0.00000457
			-- self.lowBrakeForceScale = 0.044
			self.brakeForce = 0
			self.lowBrakeForceSpeedLimit = 1
		else
			self.lowBrakeForceScale = lowBrakeForceScale;
			-- self.brakeForce = brakeForce
			self.lowBrakeForceSpeedLimit = 1
		end

	end
	
	-- Pendelachse ohne Funktion ? ()fixed extern mod
	
	--if InputBinding.hasEvent(InputBinding.HANDBRAKE) then
    --                self.handbrake = true;
	--if self.handbrake then
    --    self.motor.brakeForce 	= 1000000;
	--	self.lowBrakeForceScale = 1000000;
    --end
	--else
	--	self.motor.brakeForce 	= 0.01;
	--	self.lowBrakeForceScale = 0.04;
	--end;
end

-- function WheelsUtil.getTireFriction(tireType, groundType, wetScale)
    -- if wetScale == nil then
        -- wetScale = 0
    -- end
    -- local coeff = WheelsUtil.tireTypes[tireType].frictionCoeffs[groundType]
    -- local coeffWet = WheelsUtil.tireTypes[tireType].frictionCoeffsWet[groundType]
    -- return coeff + (coeffWet-coeff)*wetScale
-- end

-- function WheelsUtil.getGroundType(isField, isRoad, depth)
    -- -- terrain softness:
    -- -- [  0, 0.1]: road
    -- -- [0.1, 0.8]: hard terrain
    -- -- [0.8, 1  ]: soft terrain
    -- if isField then
        -- return WheelsUtil.GROUND_FIELD
    -- elseif isRoad or depth < 0.1 then
        -- return WheelsUtil.GROUND_ROAD
    -- else
        -- if depth > 0.8 then
            -- return WheelsUtil.GROUND_SOFT_TERRAIN
        -- else
            -- return WheelsUtil.GROUND_HARD_TERRAIN
        -- end
    -- end
-- end

-- function VehicleMotor:loadSavegame() end;
-- function VehicleMotor:saveSavegame() end;
-- function VehicleMotor:update(dt) end;
-- function VehicleMotor:mouseEvent(posX, posY, isDown, isUp, button) end;
-- function VehicleMotor:keyEvent(unicode, sym, modifier, isDown) end;
-- function VehicleMotor:draw() end;
-- function VehicleMotor:delete()end;
-- function VehicleMotor:deleteMap() end;
