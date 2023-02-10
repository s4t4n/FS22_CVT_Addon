-- @titel       LessMotorBrakeforce Script for FarmingSimulator 2022
-- @new titel   CVT_Addon Script for FarmingSimulator 2022
-- @author      s4t4n
-- @HUD			simple Text for the first

CVTaddonHUD = {}

function CVTaddonHUD:onDraw(vehicle, dt)
	local spec = self.spec_CVTaddon -- need sync with CVT_Addon.lua spec
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
		-- render BG
		-- h -
		-- + nach 
        -- local D_posX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1.3) -0.018
        local posX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterX - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1) - (0.035*g_gameSettings.uiScale)
		
		-- v |   + hoch
		local posY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY
  
		-- vector2D[1] * self.overlay.scaleWidth * g_aspectScaleX / g_referenceScreenWidth,
        -- vector2D[2] * self.overlay.scaleHeight * g_aspectScaleY / g_referenceScreenHeight
		
		-- function vehicleControlAddon.getUiScale()
			-- local uiScale = 1.0
			-- if g_gameSettings ~= nil and type( g_gameSettings.uiScale ) == "number" then
				-- uiScale = g_gameSettings.uiScale
			-- end
			-- return uiScale 
		-- end
		
		
		-- local BG_PosX = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY - (g_currentMission.inGameMenu.hud.speedMeter.speedIndicatorRadiusY * 1)
		-- local BG_PosY = g_currentMission.inGameMenu.hud.speedMeter.gaugeCenterY - 0.02
		
        -- local SpeedMeterDisplay = g_currentMission.inGameMenu.hud.speedMeter
		-- local width, height = getNormalizedScreenValues(unpack(CVTaddon.BGSIZE.BACKGROUND))
		local BGcvt = 1
		local overlayP = 1
		-- local overlay.overlay = 1
		local Transparancy = 0.6
		-- local CVTaddon.overlayP = overlayP
		-- if CVTaddon.overlay[overlay] == nil then

        local size = 0.014 * g_gameSettings.uiScale
		
		local drawHgStep = ""
		for i=1, spec.vFive-1 do
			drawHgStep = drawHgStep .."["
			
		end
		spec.HgScaleX = 0.04 / 9 * (spec.vFive-1)
		-- if spec.vOne == 3.2 then
		if spec.vOne == 2 then
			spec.D_insTextV = "txt_VarioOne"  -- ToDo make graphic instead of Text Dots to comp with 4k
			
		end
		-- if spec.vOne == 1 then
		if spec.vOne == 1 then
			spec.D_insTextV = "txt_VarioTwo"  -- ToDo make graphic instead of Text Dots to comp with 4k
		end
		if spec.vFour == 0 then
			spec.N_insTextV = "txt_VarioN"
		elseif spec.vFour == 1 then
			if self.spec_motorized.motor.currentDirection == 1 then
				spec.N_insTextV = "txt_VarioD"
			elseif self.spec_motorized.motor.currentDirection == -1 then
				spec.N_insTextV = "txt_VarioR"
			end
		end
        -- add current driving level to table
        spec.D_genText = tostring(g_i18n:getText(spec.D_insTextV))
        spec.N_genText = tostring(g_i18n:getText(spec.N_insTextV))
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
		-- local fontName = self.xmlFile:getValue(spec.D_genText .. "#font", "DIGIT"):upper();
        -- local fontMaterial = g_materialManager:getFontMaterial(fontName, self.customEnvironment);
		-----------------------------------------------------------------------------------------------------------------
		if spec.AR_genText ~= nil and spec.BR_genText ~= nil and spec.D_genText ~= nil then
			if not isPKWLKW then
				spec.currBGcolor = { 0.01, 0.01, 0.01, math.max(math.min(spec.transparendSpd, 0.6), 0.2) }
				CVTaddon.CVTIconBg:setColor(unpack(spec.currBGcolor))
				CVTaddon.CVTIconFb:setColor(0, 0, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))
				CVTaddon.CVTIconFs1:setColor(0, 0.9, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))
				CVTaddon.CVTIconFs2:setColor(0, 0.9, 0, math.max(math.min(spec.transparendSpdT, 1), 0.7))
				CVTaddon.CVTIconHg:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				CVTaddon.CVTIconAr1:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1)) --
				CVTaddon.CVTIconAr2:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				CVTaddon.CVTIconAr3:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				CVTaddon.CVTIconAr4:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				CVTaddon.CVTIconHydro:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				CVTaddon.CVTIconN:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				CVTaddon.CVTIconN2:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				CVTaddon.CVTIconV:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				CVTaddon.CVTIconR:setColor(0, 0.8, 0, math.max(math.min(spec.transparendSpdT-0.3, 0.5), 0.1))
				
				CVTaddon.CVTIconBg:setPosition(posX-0.01, posY)
				CVTaddon.CVTIconFb:setPosition(posX-0.01, posY)
				CVTaddon.CVTIconFs1:setPosition(posX-0.01, posY)
				CVTaddon.CVTIconFs2:setPosition(posX-0.01, posY)
				CVTaddon.CVTIconHg:setPosition(posX-0.01, posY)
				CVTaddon.CVTIconAr1:setPosition(posX-0.01, posY)
				CVTaddon.CVTIconAr2:setPosition(posX-0.01, posY)
				CVTaddon.CVTIconAr3:setPosition(posX-0.01, posY)
				CVTaddon.CVTIconAr4:setPosition(posX-0.01, posY)
				CVTaddon.CVTIconHydro:setPosition(posX-0.01, posY)
				CVTaddon.CVTIconN:setPosition(posX-0.01, posY)
				CVTaddon.CVTIconN2:setPosition(posX-0.01, posY)
				CVTaddon.CVTIconV:setPosition(posX-0.01, posY)
				CVTaddon.CVTIconR:setPosition(posX-0.01, posY)
				
				CVTaddon.CVTIconBg:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				CVTaddon.CVTIconFb:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				CVTaddon.CVTIconFs1:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				CVTaddon.CVTIconFs2:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				CVTaddon.CVTIconHg:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				CVTaddon.CVTIconAr1:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				CVTaddon.CVTIconAr2:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				CVTaddon.CVTIconAr3:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				CVTaddon.CVTIconAr4:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				CVTaddon.CVTIconHydro:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				CVTaddon.CVTIconN:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				CVTaddon.CVTIconN2:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				CVTaddon.CVTIconV:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)
				CVTaddon.CVTIconR:setAlignment(Overlay.ALIGN_VERTICAL_MIDDLE, Overlay.ALIGN_HORIZONTAL_LEFT)

				-- :setAlignment(self.alignmentVertical, self.alignmentHorizontal)
				
				CVTaddon.CVTIconBg:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				CVTaddon.CVTIconFb:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				CVTaddon.CVTIconFs1:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				CVTaddon.CVTIconFs2:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				CVTaddon.CVTIconHg:setScale(spec.HgScaleX*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				CVTaddon.CVTIconAr1:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				CVTaddon.CVTIconAr2:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				CVTaddon.CVTIconAr3:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				CVTaddon.CVTIconAr4:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				CVTaddon.CVTIconHydro:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				CVTaddon.CVTIconN:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				CVTaddon.CVTIconN2:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				-- CVTaddon.CVTIconN2:setBlinking(true)
				CVTaddon.CVTIconV:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				CVTaddon.CVTIconR:setScale(0.04*g_gameSettings.uiScale, 0.094*g_gameSettings.uiScale)
				
				-- self.mapHotspot:setPersistent(true)
				-- self.mapHotspot:setRenderLast(true)
				-- self.mapHotspot:setBlinking(true)
				
			
				-- local HGuvs = {x,y, x,y, x,y, x,y}
			--	local HGuvs = {s1s  s2e   e 3s   e 4e}
				-- local hgUVs = {0,0, 0,1, 0.5,0, 0.5,1} -- verschiebt nur und cropped nicht
				-- Array of UV coordinates as {x, y, width, height}
				-- local HGuvs  = getNormalizedUVs{0, 0, 108, 512}
				-- CVTaddon.CVTIconHg:setUVs(hgUVs)
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
				
				CVTaddon.CVTIconBg:render()
				CVTaddon.CVTIconFb:render()
				if spec.isMotorOn then
					CVTaddon.CVTIconHg:render()
					
					if spec.vOne == 2 then
						CVTaddon.CVTIconFs1:render()
					elseif spec.vOne == 1 then
						CVTaddon.CVTIconFs2:render()
					end
					if spec.vTwo == 1 then
					CVTaddon.CVTIconAr4:render()
					elseif spec.vTwo == 2 then
						CVTaddon.CVTIconAr1:render()
					elseif spec.vTwo == 3 then
						CVTaddon.CVTIconAr2:render()
					elseif spec.vTwo == 4 then
						CVTaddon.CVTIconAr3:render()
					end
					if spec.vFour == 0 then
						CVTaddon.CVTIconN2:render()
					end
					if self.spec_motorized.motor.currentDirection == 1 then
						CVTaddon.CVTIconV:render()
					elseif self.spec_motorized.motor.currentDirection == -1 then
						CVTaddon.CVTIconR:render()
					end
					if spec.isHydroState then
						
						CVTaddon.CVTIconHydro:render()
					end

					-- setTextBold(true)
					-- renderText(posX, D_posY+0.03, size+0.025, spec.D_genText)
					-- renderText(posX-0.01, posY+0.024, size, spec.N_genText)
					setTextBold(false)
					-- renderText(posX, posY, size, spec.AR_genText)
					renderText(posX, posY-0.02, size, spec.BR_genText)
					-- setTextAlignment(RenderText.ALIGN_RIGHT)
					-- renderText(posX+0.010, posY+0.026, size-0.005, drawHgStep)
					-- g_currentMission:addExtraPrintText("uiScale: "..tostring(uiScale))
					-- g_currentMission:addExtraPrintText("g_screenAspectRatio: "..tostring(g_screenAspectRatio))
					-- g_currentMission:addExtraPrintText("g_aspectScaleX: "..tostring(g_aspectScaleX))
					-- g_currentMission:addExtraPrintText("g_aspectScaleY: "..tostring(g_aspectScaleY))
					-- g_currentMission:addExtraPrintText("g_referenceScreenWidth: "..tostring(g_referenceScreenWidth))
					-- g_currentMission:addExtraPrintText("g_referenceScreenHeight: "..tostring(g_referenceScreenHeight))
				end
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
-- addModEventListener(CVTaddonHUD)
-- addModEventListener(CVTaddon)
-- CVTaddonHUD:registerSpecialization()