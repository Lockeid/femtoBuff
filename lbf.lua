local LBF = LibStub("LibButtonFacade", true)

if not LBF then return end

local f = CreateFrame("Frame",nil,UIParent)
f:RegisterEvent"PLAYER_ENTERING_WORLD"
f:RegisterEvent"UNIT_AURA"

local borders = {
	None = {0.8, 0, 0, 1},
	Magic = {0.2, 0.6, 1, 1},
	Curse = {0.6, 0, 1, 1},
	Poison = {0, 0.6, 0, 1},
	Disease = {0.6, 0.4, 0, 1},
	Enchant = {0.2, 0, 0.4, 1},
}

function f:ColorBorder(button, kind)
	if _G[button] then _G[button.."Border"]:SetVertexColor(unpack(borders[kind])) end
end
function f:Stylize(name)
	local button = _G[name]
	local count = _G[name.."Count"]
	local dur = _G[name.."Duration"]
	
	dur:SetFont("Fonts\\FRIZQT__.ttf",fBSettings.DurationSize,"THINOUTLINE")
	dur:SetPoint("TOP",button,0,5)
	dur:SetDrawLayer"OVERLAY"
	
	count:SetFont("Fonts\\FRIZQT__.ttf",fBSettings.CountSize,"THINOUTLINE")
	count:SetPoint("BOTTOMRIGHT",button,-2,2)
	count:SetDrawLayer"OVERLAY"
	
end

function f:CheckFrames()
		local i 
		local Group = LBF:Group("femtoBuff") 
		i=1
		while _G["BuffButton"..i] do
			local button = format("BuffButton%d", i)
			Group:AddButton(_G[button])
			f:Stylize(button)
			i = i + 1
		end
		i = 1
		while _G["TempEnchant"..i] do
			local button = format("TempEnchant%d", i)
			Group:AddButton(_G[button])
			f:Stylize(button)			
			f:ColorBorder(button, "Enchant")
			i = i + 1
		end
		i = 1
		while _G["DebuffButton"..i] do		
			local button = format("DebuffButton%d", i)
			-- Little hack for placement
			if i == 1 and _G[button] then _G[button]:ClearAllPoints(); _G[button]:SetPoint(unpack(femtoBuff_Options.Debuff)); _G[button].SetPoint = function() end end
			local name, rank, texture, count, kind, duration, expirationTime, _, _, shouldConsolidate = UnitAura("player", i);
			kind = kind or "None"
			Group:AddButton(_G[button])
			f:Stylize(button)
			f:ColorBorder(button, kind)
			i = i + 1
		end
end
	
--[[
-- Copy/Paste from Blizzard code, juste changed to add the buttons to the LBF group
function BuffFrame_Update()
	local Group = LBF:Group("femtoBuff")
	-- Handle Buffs
	BUFF_ACTUAL_DISPLAY = 0;
	for i=1, BUFF_MAX_DISPLAY do
		local button = format("BuffButton%d", i)
		if _G[button] then
			Group:AddButton(_G[button])
			f:Stylize(button)
		end
		if ( AuraButton_Update("BuffButton", i, "HELPFUL") ) then
			BUFF_ACTUAL_DISPLAY = BUFF_ACTUAL_DISPLAY + 1;
		end
	end
	
	--Handle temporary enchants
	for i=1, 2 do
		local button = format("TempEnchant%d", i)
		if _G[button] then
			Group:AddButton(_G[button])
			f:ColorBorder(button, "Enchant")
			f:Stylize(button)
		end
	end

	-- Handle debuffs
	DEBUFF_ACTUAL_DISPLAY = 0;
	for i=1, DEBUFF_MAX_DISPLAY do
		local button = format("DebuffButton%d", i)
		-- Little hack for placement
		if i == 1 and _G[button] then _G[button]:ClearAllPoints(); _G[button]:SetPoint(unpack(femtoBuff_Options.Debuff)); _G[button].SetPoint = function() end end
		if _G[button] then
			Group:AddButton(_G[button])
			local _, _, _, _, kind = UnitDebuff("player", i)
			kind = kind or "None"
			f:ColorBorder(button, kind)
			f:Stylize(button)
		end
		if ( AuraButton_Update("DebuffButton", i, "HARMFUL") ) then
			DEBUFF_ACTUAL_DISPLAY = DEBUFF_ACTUAL_DISPLAY + 1;
		end
	end
end --]]

f:SetScript("OnEvent", function(self, event, ...)
	local unit = ...
	if(event=="PLAYER_ENTERING_WORLD") then
		if(femtoBuff_Options.LBF) then
			LBF:Group("femtoBuff"):Skin(unpack(femtoBuff_Options.LBF))
		end
		LBF:RegisterSkinCallback("femtoBuff",
			function(_, skin, glossAlpha, gloss, _, _, colors)
				if (femtoBuff_Options.LBF) then		-- Don't create lots of tables. ever!
					femtoBuff_Options.LBF[1] = skin
					femtoBuff_Options.LBF[2] = glossAlpha
					femtoBuff_Options.LBF[3] = gloss
					femtoBuff_Options.LBF[4] = colors
				else
					femtoBuff_Options.LBF = {skin, glossAlpha, gloss, colors}
				end
				-- Hackish but this is the only way to color the borders
				local i = 1
				while _G["TempEnchant"..i] do
					local button = format("TempEnchant%d", i)
					Group:AddButton(_G[button])
					f:Stylize(button)			
					f:ColorBorder(button, "Enchant")
					i = i + 1
				end
				i = 1
				while _G["DebuffButton"..i] do		
					local button = format("DebuffButton%d", i)
					-- Little hack for placement
					if i == 1 and _G[button] then _G[button]:ClearAllPoints(); _G[button]:SetPoint(unpack(femtoBuff_Options.Debuff)); _G[button].SetPoint = function() end end
					local name, rank, texture, count, kind, duration, expirationTime, _, _, shouldConsolidate = UnitAura("player", i);
					kind = kind or "None"
					Group:AddButton(_G[button])
					f:Stylize(button)
					f:ColorBorder(button, kind)
					i = i + 1
				end	
			end
		)
		f:CheckFrames()
	elseif(event == "UNIT_AURA") then
		if(unit == PlayerFrame.unit) then
			f:CheckFrames()
		end
	end
end)