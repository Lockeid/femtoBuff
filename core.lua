--== Settings ==--
fBSettings = {
	CountSize = 12,
	
	DurationSize = 16,
}

--== Initialization ==--
local femtoBuff = CreateFrame("Frame","femtoBuff",UIParent)
femtoBuff:SetScript("OnEvent",function(self,event,...) if self[event] then self[event](self,event,...) end end)
femtoBuff:RegisterEvent"VARIABLES_LOADED"
local lock = 0 -- 0: locked 1: movable
local BuffAnchor, DebuffAnchor, TempAnchor

--== Defaults ==--
local deftemp = {"CENTER",UIParent:GetName() ,"CENTER",0,0}
local defbuff = {"CENTER",UIParent:GetName() ,"CENTER",0,-50}
local defdebuff = {"CENTER",UIParent:GetName() ,"CENTER",0,50}
femtoBuff_Options = femtoBuff_Options or {}

femtoBuff_Options.Buff = setmetatable(femtoBuff_Options.Buff or defbuff,{__index = defbuff})
femtoBuff_Options.Debuff = setmetatable(femtoBuff_Options.Debuff or defdebuff,{__index = defdebuff})
femtoBuff_Options.Temp = setmetatable(femtoBuff_Options.Temp or deftemp,{__index = deftemp})

DAY_ONELETTER_ABBR = "%dd"
HOUR_ONELETTER_ABBR = "%dh"
MINUTE_ONELETTER_ABBR = "%dm"
SECOND_ONELETTER_ABBR = "%ds"


--== Move the buttons and store data when finished ==--
--TODO: use other frames to move icons, so that you don't need to have a debuff or a buff
function femtoBuff:CreateAnchor(frame,data)
	local f = CreateFrame("Button",nil,frame)
	--f:SetAllPoints()
	f:SetPoint("BOTTOMLEFT",frame,"TOPRIGHT",0,0)
	f:SetHeight(15)
	f:SetWidth(15)
	f:SetScript("OnMouseDown",function(self)  if (IsAltKeyDown() and lock == 1) then  frame:ClearAllPoints(); frame:StartMoving() end end)
	f:SetScript("OnMouseUp",function(self) frame:StopMovingOrSizing(); femtoBuff_Options[data] = {frame:GetPoint()} end)
	f:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 5, insets = {left = 0, right = 0, top = 0, bottom = 0},})
	f:Hide()
	return f
end

--== Because debuff aren't handled the same way as buffs ==--
function femtoBuff:CreateDebuffAnchor()
	local p = DebuffButton1 or UIParent
	local f = CreateFrame("Button",nil,p)
	--f:SetAllPoints()
	if(DebuffButton1) then
		f:SetPoint("BOTTOMLEFT",DebuffButton1,"TOPRIGHT",0,0)
	else
		f:SetPoint(femtoBuff_Options.Debuff[1],femtoBuff_Options.Debuff[2],femtoBuff_Options.Debuff[3],femtoBuff_Options.Debuff[4]+22,femtoBuff_Options.Debuff[5]+22)
	end
	f:SetHeight(15)
	f:SetWidth(15)
	local m = DebuffButton1 or f
	f:SetScript("OnMouseDown",function(self)  if (IsAltKeyDown() and lock == 1) then m:ClearAllPoints(); m:StartMoving() end end)
	f:SetScript("OnMouseUp",function(self) m:StopMovingOrSizing(); femtoBuff_Options["Debuff"] = {m:GetPoint()} end)
	f:SetBackdrop({bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 5, insets = {left = 0, right = 0, top = 0, bottom = 0},})
	f:Hide()
	return f
end
--== Same as before, just update the anchor ==--
function femtoBuff:UpdateDebuffAnchor(f)
	f:ClearAllPoints()
	if(DebuffButton1) then
		f:SetPoint("BOTTOMLEFT",DebuffButton1,"TOPRIGHT",0,0)
	else
		f:SetPoint(femtoBuff_Options.Debuff[1],femtoBuff_Options.Debuff[2],femtoBuff_Options.Debuff[3],femtoBuff_Options.Debuff[4]+22,femtoBuff_Options.Debuff[5]+22)
	end
	local m = DebuffButton1 or f
	f:SetScript("OnMouseDown",function(self)  if (IsAltKeyDown() and lock == 1) then m:ClearAllPoints(); m:StartMoving() end end)
	f:SetScript("OnMouseUp",function(self) m:StopMovingOrSizing(); femtoBuff_Options["Debuff"] = {m:GetPoint()} end)
end
function femtoBuff:UpdateBuffAnchor(f)
	f:ClearAllPoints()
	if(CONSOLIDATE_BUFFS == "1" and ConsolidatedBuffs:IsShown()) then
		f:SetPoint("BOTTOMLEFT",ConsolidatedBuffs,"TOPRIGHT",0,0)
	else
		f:SetPoint("BOTTOMLEFT",BuffFrame,"TOPRIGHT",0,0)
	end
	local m = ConsolidatedBuffs or BuffFrame
	f:SetScript("OnMouseDown",function(self)  if (IsAltKeyDown() and lock == 1) then m:ClearAllPoints(); m:StartMoving() end end)
	f:SetScript("OnMouseUp",function(self) m:StopMovingOrSizing(); femtoBuff_Options["Buff"] = {m:GetPoint()} end)
end
--== Create anchors ==--
function femtoBuff:InitMove()
	-- Buff part
	-- Fix for the 3.3 patch
	BuffAnchor = femtoBuff:CreateAnchor(BuffFrame, "Buff")
	BuffAnchor:SetBackdropColor(0,1,0)	
	--
	-- Debuff part	
	DebuffAnchor = femtoBuff:CreateDebuffAnchor()
	DebuffAnchor:SetBackdropColor(1,0,0)
	-- Temporary enchant part
	TempAnchor = femtoBuff:CreateAnchor(TemporaryEnchantFrame,"Temp")
	TempAnchor:SetBackdropColor(0,0,1)	
end

--== Data and initialization part II ==--
function femtoBuff:VARIABLES_LOADED()
	TemporaryEnchantFrame:ClearAllPoints()
	TemporaryEnchantFrame:SetPoint(unpack(femtoBuff_Options.Temp))
	TemporaryEnchantFrame.SetPoint = function() end

	TempEnchant2:ClearAllPoints()
	TempEnchant2:SetPoint("BOTTOMRIGHT", TempEnchant1, "BOTTOMLEFT", -8, 0)
	
	ConsolidatedBuffs:ClearAllPoints()
	ConsolidatedBuffs:SetPoint(unpack(femtoBuff_Options.Buff))
	ConsolidatedBuffs.SetPoint = function () end
	
	femtoBuff:InitMove()
end
-- Quite straightforward way to fix it, but I haven't found another way
function BuffFrame_UpdateAllBuffAnchors()
	local buff, previousBuff, aboveBuff;
	local numBuffs = 0;
	local slack = BuffFrame.numEnchants
	if ( BuffFrame.numConsolidated > 0 ) then
		slack = slack + 1;	-- one icon for all consolidated buffs
	end
	
	for i = 1, BUFF_ACTUAL_DISPLAY do
		buff = _G["BuffButton"..i];
		if ( buff.consolidated ) then	
			if ( buff.parent == BuffFrame ) then
				buff:SetParent(ConsolidatedBuffsContainer);
				buff.parent = ConsolidatedBuffsContainer;
			end
		else
			numBuffs = numBuffs + 1;
			index = numBuffs + slack;
			if ( buff.parent ~= BuffFrame ) then
				buff.count:SetFontObject(NumberFontNormal);
				buff:SetParent(BuffFrame);
				buff.parent = BuffFrame;
			end
			buff:ClearAllPoints();
			if ( (index > 1) and (mod(index, BUFFS_PER_ROW) == 1) ) then
				-- New row
				if ( index == BUFFS_PER_ROW+1 ) then
					buff:SetPoint("TOP", ConsolidatedBuffs, "BOTTOM", 0, -BUFF_ROW_SPACING);
				else
					buff:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -BUFF_ROW_SPACING);
				end
				aboveBuff = buff;
			elseif ( index == 1 ) then
				buff:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0);
			else
				if ( numBuffs == 1 ) then
					if(CONSOLIDATE_BUFFS == "1" and ConsolidatedBuffs:IsShown()) then
						buff:SetPoint("RIGHT",ConsolidatedBuffs,"LEFT",-5,0)
					else
						buff:SetPoint("TOPRIGHT",BuffFrame,"TOPRIGHT",0,0)
					end					
				else
					buff:SetPoint("RIGHT", previousBuff, "LEFT", -5, 0);
				end
			end
			previousBuff = buff;
		end
	end

	if ( ConsolidatedBuffsTooltip:IsShown() ) then
		ConsolidatedBuffs_UpdateAllAnchors();
	end
end
	
--== Slash command ==--
SLASH_FEMTOBUFF1 = "/fb"
SLASH_FEMTOBUFF2 = "/femtobuff"
SlashCmdList["FEMTOBUFF"] = function()
	if lock == 0 then 
		lock = 1 
		-- Buffs
		ConsolidatedBuffs:SetMovable(true)
		BuffFrame:SetMovable(true)
		femtoBuff:UpdateBuffAnchor(BuffAnchor)
		BuffAnchor:SetMovable(true)
		BuffAnchor:Show()
		-- Debuffs
		DebuffAnchor:Show()
		DebuffAnchor:SetMovable(true)
		femtoBuff:UpdateDebuffAnchor(DebuffAnchor)
		if DebuffButton1 then DebuffButton1:SetMovable(true) end
		-- Temporary
		TempAnchor:Show()
		TempAnchor:SetMovable(true)
		TemporaryEnchantFrame:SetMovable(true)
		print("|cff00effffemtoBuff: |r all the frames are now movable")
	else 
		lock = 0
		--Buffs
		ConsolidatedBuffs:SetMovable(false)
		BuffFrame:SetMovable(false)
		BuffAnchor:SetMovable(false)
		BuffAnchor:Hide()
		-- Debuffs
		DebuffAnchor:Hide()
		if DebuffButton1 then DebuffButton1:SetMovable(false) end
		DebuffAnchor:SetMovable(false)
		-- Temporary
		TempAnchor:Hide()
		TempAnchor:SetMovable(false)
		TemporaryEnchantFrame:SetMovable(false)
		print("|cff00effffemtoBuff: |r all the frames are now locked")
	end
end
