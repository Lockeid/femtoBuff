if IsAddOnLoaded"rActionButtonStyler" then


local f = CreateFrame("Frame","femtoBuff_rABS",UIParent)
f:RegisterEvent"PLAYER_ENTERING_WORLD"
f:RegisterEvent"UNIT_AURA"


local tex = "Interface\\AddOns\\rActionButtonStyler\\media\\gloss"
	
	local borders = {
		None = {0.8, 0, 0, 1},
		Magic = {0.2, 0.6, 1, 1},
		Curse = {0.6, 0, 1, 1},
		Poison = {0, 0.6, 0, 1},
		Disease = {0.6, 0.4, 0, 1},
		Enchant = {0.2, 0, 0.4, 1},
	}
	
	function f:Style(name)
		local button = _G[name]
		local border = _G[name.."Border"]
		local icon = _G[name.."Icon"]
		local t = _G[name.."StylerTexture"]
		local count = _G[name.."Count"]
		local dur = _G[name.."Duration"]
		
		
		if not t then
			local t = button:CreateTexture(name.."StylerTexture","ARTWORK")
			t:SetPoint("TOPLEFT",button,"TOPLEFT",0,0)
			t:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",0,0)
			t:SetTexture(tex)
			
			icon:SetTexCoord(0.1,0.9,0.1,0.9)
			icon:SetPoint("TOPLEFT",button,"TOPLEFT",1,-1)
			icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-1,1)
		end
		
		dur:SetFont("Fonts\\FRIZQT__.ttf",fBSettings.DurationSize,"THINOUTLINE")
		dur:SetPoint("TOP",button,0,5)
		dur:SetDrawLayer"OVERLAY"
		
		count:SetFont("Fonts\\FRIZQT__.ttf",fBSettings.CountSize,"THINOUTLINE")
		count:SetPoint("BOTTOMRIGHT",button,-2,2)
		count:SetDrawLayer"OVERLAY"
		
	end
	
	function f:ColorBorder(button, kind)
		if _G[button] then _G[button.."Border"]:SetVertexColor(unpack(borders[kind])) end
	end
	
	function f:CheckFrames()
		local i 
		i=1
		while _G["BuffButton"..i] do
			local button = format("BuffButton%d", i)
			f:Style(button)
			i = i + 1
		end
		i = 1
		while _G["TempEnchant"..i] do
			local button = format("TempEnchant%d", i)
			f:Style(button)
			f:ColorBorder(button, "Enchant")
			i = i + 1
		end
		i = 1
		while _G["DebuffButton"..i] do		
			local button = format("DebuffButton%d", i)
			-- Little hack for placement
			if i == 1 and _G[button] then _G[button]:ClearAllPoints(); _G[button]:SetPoint(unpack(femtoBuff_Options.Debuff)); end
			local name, rank, texture, count, kind, duration, expirationTime, _, _, shouldConsolidate = UnitAura("player", i);
			kind = kind or "None"
			f:Style(button)
--~ 			f:ColorBorder(button, kind)
			i = i + 1
		end
		

					
	end
	
	f:SetScript("OnEvent", function(self, event, ...)
		local unit = ...
		if(event=="PLAYER_ENTERING_WORLD") then
			f:CheckFrames()
		elseif(event == "UNIT_AURA") then
			if(unit == PlayerFrame.unit) then
				f:CheckFrames()
			end
		end
	end)
end