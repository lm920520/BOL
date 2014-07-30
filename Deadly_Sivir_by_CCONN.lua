--[[
╔╦╗┌─┐┌─┐┌┬┐┬ ┬ ┬  ╔═╗┬┬  ┬┬┬─┐  ┌┐ ┬ ┬  ╔═╗╔═╗╔═╗╔╗╔╔╗╔
 ║║├┤ ├─┤ │││ └┬┘  ╚═╗│└┐┌┘│├┬┘  ├┴┐└┬┘  ║  ║  ║ ║║║║║║║
═╩╝└─┘┴ ┴─┴┘┴─┘┴   ╚═╝┴ └┘ ┴┴└─  └─┘ ┴   ╚═╝╚═╝╚═╝╝╚╝╝╚╝
              
	Follow me on Facebook! Its the easiest way to communicate with me.
	CCONN's Facebook: https://www.facebook.com/CCONN81
		
	Like the script and want to donate?
	All donations go towards purchasing additional scripts and premium time so I can script more for you guys.
	CCONN's DONATE LINK: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JTWL7DK86V56S
--]]

---------------------------------------------------------------------------------------------------
-- CHANGELOG: -------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- VERSION 1.00
	-- Initial Release
---------------------------------------------------------------------------------------------------
-- TO DO LIST: ------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

if not VIP_USER or myHero.charName ~= "Sivir" then return end

---------------------------------------------------------------------------------------------------
--	Required Libs ---------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
require "Prodiction"
require "VPrediction"
require "SOW"

---------------------------------------------------------------------------------------------------
--  Global Variables ------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
local version = 1.00
local Target
local SpellReady = {Q = nil, W = nil, E = nil, R = nil}
local SpellQ = {Range = nil, Speed = nil, Delay = nil, Width = nil}
local SpellW = {Range = nil, Speed = nil, Delay = nil, Width = nil}
local SpellE = {Range = nil, Speed = nil, Delay = nil, Width = nil}
local SpellR = {Range = nil, Speed = nil, Dealy = nil, Width = nil}
local Prodict, ProdictQ
local VipPredTarget
local VP, qp, ts

---------------------------------------------------------------------------------------------------
-- OnLoad: Invoked once during script load only ---------------------------------------------------
---------------------------------------------------------------------------------------------------
function OnLoad()
	Menu()
-------------------------------------------------
-- Spell Data Variables -------------------------
-------------------------------------------------
	SpellQ.Speed = 1350
	SpellQ.Delay = 0.25
	SpellQ.Width = 85
-------------------------------------------------
-- VPrediction Variables ------------------------
-------------------------------------------------
	VP = VPrediction()
-------------------------------------------------
-- Prodiction Variables -------------------------
-------------------------------------------------
	Prodict = ProdictManager.GetInstance()
	ProdictQ = Prodict:AddProdictionObject(_Q, SpellQ.Range, SpellQ.Speed, SpellQ.Delay, SpellQ.Width)
-------------------------------------------------
-- BoL VIP Prediction Variables -----------------
-------------------------------------------------
	qp = TargetPredictionVIP(SpellQ.Range, SpellQ.Speed, SpellQ.Delay, SpellQ.Width)
-------------------------------------------------
-- SOW Variables --------------------------------
-------------------------------------------------
	SOW = SOW(VP)
	SOW:LoadToMenu(Config.SOW)
-------------------------------------------------
-- Load Message ---------------------------------
-------------------------------------------------
	PrintChat("<font color=\"#7f65ff\"><b>Deadly Sivir version "..tostring(version).." by CCONN</b></font>")
end

---------------------------------------------------------------------------------------------------
-- SpellCheck: Invoked every tick in the main OnTick function -------------------------------------
-- used to set variables that require constant updates --------------------------------------------
---------------------------------------------------------------------------------------------------
function SpellCheck()
	if SpellQ.Range ~= Config.spelloptions.qoptions.RNG then
		SpellQ.Range = Config.spelloptions.qoptions.RNG
	end
	if SpellR.Range ~= Config.spelloptions.roptions.RNG then
		SpellR.Range = Config.spelloptions.roptions.RNG
	end
	SpellReady.Q = (myHero:CanUseSpell(_Q) == READY)
	SpellReady.W = (myHero:CanUseSpell(_W) == READY)
	SpellReady.E = (myHero:CanUseSpell(_E) == READY)
	SpellReady.R = (myHero:CanUseSpell(_R) == READY)
end

---------------------------------------------------------------------------------------------------
-- Script Menu: Invoked during OnLoad -------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function Menu()
-------------------------------------------------
-- Sub Menus ------------------------------------
-------------------------------------------------
	Config = scriptConfig("Deadly Sivir", "Sivir")
	Config:addSubMenu("Combo", "autocarry")
	Config:addSubMenu("Mixed Mode", "mixedmode")
	Config:addSubMenu("Lane Clear", "laneclear")
	Config:addSubMenu("Last Hit", "farm")
	Config:addSubMenu("Spell Options", "spelloptions")
	Config:addSubMenu("Kill Steal", "killsteal")
	Config:addSubMenu("Draw", "draw")
	Config:addSubMenu("Orbwalker","SOW")
	Config:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	Config:addParam("sep", ">> Key Binds <<", SCRIPT_PARAM_INFO, "")
	Config:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	Config:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config:addParam("MixedMode", "Mixed Mode", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))
	Config:addParam("Farm", "Last Hit", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('X'))
	Config:addParam("LaneClear", "Lane Clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V'))
	Config:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	Config:addParam("sep", "Deadly Sivir "..tostring(version).." by CCONN", SCRIPT_PARAM_INFO, "")
	Config:addParam("sep", "www.facebook.com/CCONN81", SCRIPT_PARAM_INFO, "")
	Config.spelloptions:addSubMenu("Q: Boomerang Blade", "qoptions")
	Config.spelloptions:addSubMenu("W: Ricochet", "woptions")
	Config.spelloptions:addSubMenu("E: Spell Shield", "eoptions")
	Config.spelloptions:addSubMenu("R: On The Hunt", "roptions")
-------------------------------------------------
-- Auto Carry Sub Menu --------------------------
-------------------------------------------------
	Config.autocarry:addParam("useQ", "Q: Boomerang Blade", SCRIPT_PARAM_ONOFF, true)
	Config.autocarry:addParam("useW", "W: Ricochet", SCRIPT_PARAM_ONOFF, true)
	--Config.autocarry:addParam("useE", "E: Spell Shield", SCRIPT_PARAM_ONOFF, true)
	Config.autocarry:addParam("useR", "R: On The Hunt", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Mixed Mode Sub Menu --------------------------
-------------------------------------------------
	Config.mixedmode:addParam("useQ", "Q: Boomerang Blade", SCRIPT_PARAM_ONOFF, true)
	Config.mixedmode:addParam("useW", "W: Ricochet", SCRIPT_PARAM_ONOFF, true)
	--Config.mixedmode:addParam("useE", "E: Spell Shield", SCRIPT_PARAM_ONOFF, true)
	Config.mixedmode:addParam("useR", "R: On The Hunt", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Last Hit Menu --------------------------------
-------------------------------------------------
	Config.farm:addParam("useQ", "Q: Boomerang Blade", SCRIPT_PARAM_ONOFF, true)
	Config.farm:addParam("useW", "W: Ricochet", SCRIPT_PARAM_ONOFF, true)
	--Config.farm:addParam("useE", "E: Spell Shield", SCRIPT_PARAM_ONOFF, true)
	Config.farm:addParam("useR", "R: On The Hunt", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Lane Clear Sub Menu --------------------------
-------------------------------------------------
	Config.laneclear:addParam("useQ", "Q: Boomerang Blade", SCRIPT_PARAM_ONOFF, true)
	Config.laneclear:addParam("useW", "W: Ricochet", SCRIPT_PARAM_ONOFF, true)
	--Config.laneclear:addParam("useE", "E: Spell Shield", SCRIPT_PARAM_ONOFF, true)
	Config.laneclear:addParam("useR", "R: On The Hunt", SCRIPT_PARAM_ONOFF, true)
	Config.laneclear:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	Config.laneclear:addParam("sep", ">> Last Hit Options <<", SCRIPT_PARAM_INFO, "")
	Config.laneclear:addParam("farmW", "Clear With Ricochet", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Q Spell Options Sub Menu ---------------------
-------------------------------------------------
	Config.spelloptions.qoptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.qoptions:addParam("RNG", "Range", SCRIPT_PARAM_SLICE, 1075, 0, 1075, 0)
	Config.spelloptions.qoptions:addParam("MANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	Config.spelloptions.qoptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.qoptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.qoptions:addParam("Prediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	Config.spelloptions.qoptions:addParam("HitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
-------------------------------------------------
-- W Spell Options Sub Menu ---------------------
-------------------------------------------------
	Config.spelloptions.woptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.woptions:addParam("Reset", "Reset Auto Attacks Only", SCRIPT_PARAM_ONOFF, true)
	Config.spelloptions.woptions:addParam("MANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	Config.spelloptions.woptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.woptions:addParam("sep", ">> W Clear Options <<", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.woptions:addParam("WFarmMana", "Mana Threshold", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
-------------------------------------------------
-- E Spell Options Sub Menu ---------------------
-------------------------------------------------
	Config.spelloptions.eoptions:addParam("sep", ">> No Options Yet <<", SCRIPT_PARAM_INFO, "")
-------------------------------------------------
-- R Spell Options Sub Menu ---------------------
-------------------------------------------------
	Config.spelloptions.roptions:addParam("sep", ">> No Options Yet <<", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.roptions:addParam("MANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	Config.spelloptions.roptions:addParam("ChampCount", "Min Number of Enemies", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Config.spelloptions.roptions:addParam("RNG", "Range", SCRIPT_PARAM_SLICE, 700, 0, 1075, 0)
-------------------------------------------------
-- Kill Steal Sub Menu---------------------------
-------------------------------------------------
	Config.killsteal:addParam("KSEnable", "Enable Kill Steals", SCRIPT_PARAM_ONOFF, true)
	Config.killsteal:addParam("KSOverride", "Override Mana Thresholds", SCRIPT_PARAM_ONOFF, true)
	Config.killsteal:addParam("sep", ">> Kill Steal Permutations <<", SCRIPT_PARAM_INFO, "")
	Config.killsteal:addParam("Q", "Q", SCRIPT_PARAM_ONOFF, true)
	Config.killsteal:addParam("sep", "more coming soon...", SCRIPT_PARAM_INFO, "")
-------------------------------------------------
-- Draw Sub Menu --------------------------------
-------------------------------------------------
	Config.draw:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	Config.draw:addParam("DrawXP", "Draw XP Range", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Target Selector Variables --------------------
-------------------------------------------------
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1075, DAMAGE_PHYSICAL)
	ts.name = "Sivir"
	Config:addTS(ts)
end

---------------------------------------------------------------------------------------------------
-- OnDraw -----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function OnDraw()
	if SpellReady.Q and Config.draw.DrawQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.Range, 0xFFFFFF)
	end
	if Config.draw.DrawXP then
		DrawCircle(myHero.x, myHero.y, myHero.z, 1600, 0xFFFFFF)
	end
end

---------------------------------------------------------------------------------------------------
-- Main Script Function: Invoked every tick -------------------------------------------------------
---------------------------------------------------------------------------------------------------
function OnTick()
	ts:update()
	if ts.target ~= nil then
		Target = ts.target
	end
	SpellCheck()
	if Target and Config.Combo then Combo(Target, Config.autocarry) end
	if Target and Config.MixedMode then Combo(Target, Config.mixedmode) end
	if Target and Config.Farm then Combo(Target, Config.farm) end
	if Target and Config.LaneClear then Combo(Target, Config.laneclear) end
	if Config.killsteal.KSEnable then KillSteal() end
	if SpellReady.W and Config.LaneClear and Config.laneclear.farmW then FarmW() end
end

---------------------------------------------------------------------------------------------------
-- Farm W: Pushes the minion wave with W ----------------------------------------------------------
---------------------------------------------------------------------------------------------------
function FarmW()
	for i=1, objManager.maxObjects, 1 do
		local object = objManager:getObject(i)
		if object ~= nil and object.type == "obj_AI_Minion" and object.team~=myHero.team then
			if object.visible and not object.dead and GetDistance(myHero, object) <= myHero.range then
				if myHero.mana >= myHero.maxMana * (Config.spelloptions.woptions.WFarmMana / 100) then
					CastW(object)
				end
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Kill Steals: Invoked in main OnTick function ---------------------------------------------------
---------------------------------------------------------------------------------------------------
function KillSteal()
	for i = 1, heroManager.iCount do
	local enemy = heroManager:getHero(i)
	local Menu1 = Config.killsteal
	local Menu2 = Config.spelloptions
		if SpellReady.Q and Menu1.Q and ValidTarget(enemy, SpellQ.Range) and enemy.health < getDmg("Q",enemy,myHero) and myHero.mana >= ManaCost(Q) then
			if Menu2.qoptions.Prediction == 1 then CastVPredQ(enemy) end
			if Menu2.qoptions.Prediction == 2 then CastProdQ(enemy) end
			if Menu2.qoptions.Prediction == 3 then CastVIPQ(enemy) end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Casts Q with Prodiction ------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function CastProdQ(unit)
	if SpellReady.Q and ValidTarget(unit) and myHero.mana >= ManaCost(Q) then
		QPos = ProdictQ:GetPrediction(unit)
		if QPos ~= nil then
			PacketCast(_Q, QPos)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Casts Q with VPrediction -----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function CastVPredQ(unit)
	if SpellReady.Q and ValidTarget(unit) and myHero.mana >= ManaCost(Q) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellQ.Delay, SpellQ.Width, SpellQ.Range, SpellQ.Speed, myHero, false)
		if HitChance >= Config.spelloptions.qoptions.HitChance and GetDistance(CastPosition) <= SpellQ.Range then
			PacketCast(_Q, CastPosition)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Casts Q with BoL VIP Prediction ----------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function CastVIPQ(unit)
	VipPredTarget = qp:GetPrediction(unit)
	if SpellReady.Q and ValidTarget(unit) and myHero.mana >= ManaCost(Q) and VipPredTarget and GetDistance(unit) <= SpellQ.Range then
		PacketCast(_Q, VipPredTarget)
	end
end


---------------------------------------------------------------------------------------------------
-- Invoked when an auto attack is cast ------------------------------------------------------------
-- Used to reset auto attacks ---------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

function OnProcessSpell(unit, spell)
	if unit.isMe and spell.name:lower():find("attack") then
		SpellTarget = spell.target
		DelayAction(function() ResetW(SpellTarget) end, spell.windUpTime - GetLatency() / 2000)
	end
end

function ResetW(unit)
	if Config.spelloptions.woptions.Reset and Config.Combo then
		if unit and SpellReady.W and ValidTarget(unit) and myHero.mana >= ManaCost(W) then
			if GetDistance(unit) <= myHero.range then
				CastW(unit)
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Casts W  ---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function CastW(unit)
	if SpellReady.W and ValidTarget(unit) and myHero.mana >= ManaCost(W) then
		PacketCast(_W, myHero)
	end
end

---------------------------------------------------------------------------------------------------
-- Counts the number of enemy champions within a certain range of a location ----------------------
---------------------------------------------------------------------------------------------------
function CountChampions(center, range)
	local count = 0
	for i = 1, heroManager.iCount, 1 do
		local champion = heroManager:getHero(i)
		if myHero.team ~= champion.team and ValidTarget(champion, range) then
			if GetDistance(champion, point) <= range then
				count = count + 1
			end
		end
	end            
	return count
end

---------------------------------------------------------------------------------------------------
-- Uses Ultimate based on enemy champion count within a certain range -----------------------------
---------------------------------------------------------------------------------------------------
     
function CastR(target)
	if CountChampions(myHero, SpellR.Range) >= Config.spelloptions.roptions.ChampCount then
		PacketCast(_R, myHero)
	end
end

---------------------------------------------------------------------------------------------------
-- Returns mana cost of spells --------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function ManaCost(spell)
	if spell == Q then
		return 60 + (10 * myHero:GetSpellData(_Q).level)
	elseif spell == W then
		return 60
	elseif spell == E then
		return 0
	elseif spell == R then
		return 100
	end
end

---------------------------------------------------------------------------------------------------
-- Combo ------------------------------------------------------------------------------------------
-- Uses parameters to consolidate multiple combos into one function -------------------------------
---------------------------------------------------------------------------------------------------
function Combo(unit, menu)
	local Menu1 = menu
	local Menu2 = Config.spelloptions
	if unit and ValidTarget(unit) then
		if SpellReady.R and Menu1.useR then
			if myHero.mana >= myHero.maxMana * (Menu2.roptions.MANA / 100) then
				CastR(unit)
			end
		end
		if SpellReady.Q and Menu1.useQ then
			if GetDistance(unit) <= SpellQ.Range then
				if myHero.mana >= myHero.maxMana * (Menu2.qoptions.MANA / 100) then
					if Menu2.qoptions.Prediction == 1 then CastVPredQ(unit) end
					if Menu2.qoptions.Prediction == 2 then CastProdQ(unit) end
					if Menu2.qoptions.Prediction == 3 then CastVIPQ(unit) end
				end
			end
		end
		if SpellReady.W and Menu1.useW and GetDistance(Target) <= myHero.range then
			if not Menu2.woptions.Reset then
				if myHero.mana >= myHero.maxMana * (Menu2.woptions.MANA / 100) then
					CastW(Target)
				end
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- PacketCast: Casts spells using packets ---------------------------------------------------------
-- usage: PacketCast(_Q, CastPosition) ------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function PacketCast(spell, position)
	Packet("S_CAST", {spellId = spell, fromX =  position.x, fromY =  position.z, toX =  position.x, toY =  position.z}):send()
end