-- @titel       LessMotorBrakeforce Script for FarmingSimulator 2022
-- @new titel   CVT_Addon Script for FarmingSimulator 2022
-- @author      s4t4n
-- @HUD			simple Text for the first

CVTaddonHUD = {}

function CVTaddon:onDraw(spec)
	-- local spec = self.spec_CVTaddon
	if g_currentMission.hud.isVisible and spec.isVarioTM then
	-- self.spec_motorized.motor.lastManualShifterActive == false and self.spec_motorized.motor.groupType == 1 and self.spec_motorized.motor.gearType == 1 then

        -- calculate position and size
		
		-- h -
        local AR_posX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1.2) -0.015
        local BR_posX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1.2) -0.015
        local D_posX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1.2) -0.015
		
		-- v |
		local D_posY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY + 0.015
        local AR_posY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY
        local BR_posY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY - 0.015
        
        local size = 0.014 * g_gameSettings.uiScale
		
		-- if spec.vOne == 3.2 then
		if spec.vOne == 2 then
			spec.D_insTextV = "txt_VarioOne"
		end
		-- if spec.vOne == 1 then
		if spec.vOne == 1 then
			spec.D_insTextV = "txt_VarioTwo"
		end
        -- add current driving level to table
        spec.D_genText = tostring(g_i18n:getText(spec.D_insTextV))
        -- render
        setTextColor(0.3,1.0,0.1,1.0)
        -- setTextColor(1,1,1,1)
        setTextAlignment(RenderText.ALIGN_LEFT)
        setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
        setTextBold(false)
		if spec.AR_genText ~= nil and spec.BR_genText ~= nil and spec.D_genText ~= nil then
			renderText(AR_posX, AR_posY, size, spec.AR_genText)
			renderText(BR_posX, BR_posY, size, spec.BR_genText)
			renderText(D_posX, D_posY, size, spec.D_genText)
		end
 		-- Back to roots
        setTextColor(1,1,1,1)
        setTextAlignment(RenderText.ALIGN_LEFT)
        setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE)
        setTextBold(false)
	end
end
-- addModEventListener(CVTaddonHUD)
-- addModEventListener(CVTaddon)
-- CVTaddonHUD:registerSpecialization()