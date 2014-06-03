--[[
╔╦╗┌─┐┌─┐┌┬┐┬ ┬ ┬  ╔═╗┌─┐┬─┐┌─┐┌─┐┬      ┌┐ ┬ ┬  ╔═╗╔═╗╔═╗╔╗╔╔╗╔
 ║║├┤ ├─┤ │││ └┬┘  ║╣ ┌─┘├┬┘├┤ ├─┤│      ├┴┐└┬┘  ║  ║  ║ ║║║║║║║
═╩╝└─┘┴ ┴─┴┘┴─┘┴   ╚═╝└─┘┴└─└─┘┴ ┴┴─┘    └─┘ ┴   ╚═╝╚═╝╚═╝╝╚╝╝╚╝
              
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
-- VERSION 1.01
	-- Cleaned up Global Variables
	-- Removed normal spell casting. All spells are now cast using packets
	-- Corrected error in ManaCost function
	-- Added ManaCheck function --removed temporarily
	-- Added new Combo function that consolidates all combos into one function
	-- Changed W Reset to only invoke while holding AutoCarry key and target is within AA range
-- VERSION 1.02
	-- Standalone script
	-- Integrated SOW Orbwalker by Honda7
	-- Added target selector
	-- Farm Q uses VPrediction health prediction
	-- Added W new W reset function


---------------------------------------------------------------------------------------------------
-- TO DO LIST: ------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- OnAttack()
	-- Q reset when in AA range
-- FARM Q
	-- Only Q when AA not available
	-- use W to reset AA for last hit? -
-- Kill Steals
	-- Add custom KS R range
	-- Add all KS combinations
	-- Add mana thresholds and overrides
	-- Add collision R KS that checks for KS at 30% of max dmg
	-- Change 100% dmg R kill steal to use collision
-- Spell Casting
	-- Add hitboxes to all casting functions
	-- Add ManaCheck to all functions
-- Drawing
	-- Add Lag Free Circles
-- Arcane Shift
	-- Add casting functions / Menu options
-- Combos
	-- Add spell casting order
-- Prodiction Callbacks
	-- Add E anti-gap closer
---------------------------------------------------------------------------------------------------

if not VIP_USER or myHero.charName ~= "Ezreal" then return end

---------------------------------------------------------------------------------------------------
--	Required Libs ---------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
require "Prodiction"
require "VPrediction"
require "FastCollision"
require "Collision"
require "SOW"

---------------------------------------------------------------------------------------------------
--  Global Variables ------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
local version = 1.02
local Target
local SpellReady = {Q = nil, W = nil, E = nil, R = nil}
local SpellQ = {Range = nil, Speed = nil, Delay = nil, Width = nil}
local SpellW = {Range = nil, Speed = nil, Delay = nil, Width = nil}
local SpellE = {Range = nil, Speed = nil, Delay = nil, Width = nil}
local SpellR = {Range = nil, Speed = nil, Dealy = nil, Width = nil}
local Prodict, ProdictQ, ProdictW, ProdictR
local ProdictQFastCol, ProdictQCol
local VipPredTarget
local VP, qp, wp, rp, ts

---------------------------------------------------------------------------------------------------
-- OnLoad: Invoked once during script load only ---------------------------------------------------
---------------------------------------------------------------------------------------------------
function OnLoad()
	Menu()
-------------------------------------------------
-- Spell Data Variables -------------------------
-------------------------------------------------
	SpellQ.Speed = 2000
	SpellW.Speed = 1600
	SpellR.Speed = 2000

	SpellQ.Delay = 0.25
	SpellW.Delay = 0.25
	SpellR.Delay = 0.25

	SpellQ.Width = 60
	SpellW.Width = 80
	SpellR.Width = 150
-------------------------------------------------
-- VPrediction Variables ------------------------
-------------------------------------------------
	VP = VPrediction()
-------------------------------------------------
-- Prodiction Variables -------------------------
-------------------------------------------------
	Prodict = ProdictManager.GetInstance()
	ProdictQ = Prodict:AddProdictionObject(_Q, SpellQ.Range, SpellQ.Speed, SpellQ.Delay, SpellQ.Width)
	ProdictW = Prodict:AddProdictionObject(_W, SpellW.Range, SpellW.Speed, SpellW.Delay, SpellW.Width)
	ProdictR = Prodict:AddProdictionObject(_R, SpellR.Range, SpellR.Speed, SpellR.Delay, SpellR.Width)
-------------------------------------------------
-- BoL VIP Prediction Variables -----------------
-------------------------------------------------
	qp = TargetPredictionVIP(SpellQ.Range, SpellQ.Speed, SpellQ.Delay, SpellQ.Width)
	wp = TargetPredictionVIP(SpellW.Range, SpellW.Speed, SpellW.Delay, SpellW.Width)
	rp = TargetPredictionVIP(SpellR.Range, SpellR.Speed, SpellR.Delay, SpellR.Width)
-------------------------------------------------
-- Collision & Fast Collision Variables ---------
-------------------------------------------------
	ProdictQCol = Collision(SpellQ.Range, SpellQ.Speed, SpellQ.Delay, SpellQ.Width)
	ProdictQFastCol = FastCol(ProdictQ)
-------------------------------------------------
-- SOW Variables --------------------------------
-------------------------------------------------
	SOW = SOW(VP)
	SOW:LoadToMenu(Config.SOW)
-------------------------------------------------
-- Load Message ---------------------------------
-------------------------------------------------
	PrintChat("<font color=\"#7f65ff\"><b>Deadly Ezreal version "..tostring(version).." by CCONN</b></font>")
end

---------------------------------------------------------------------------------------------------
-- SpellCheck: Invoked every tick in the main OnTick function -------------------------------------
-- used to set variables that require constant updates --------------------------------------------
---------------------------------------------------------------------------------------------------
function SpellCheck()
	if SpellQ.Range ~= Config.spelloptions.qoptions.RNG then
		SpellQ.Range = Config.spelloptions.qoptions.RNG
	end
	if SpellW.Range ~= Config.spelloptions.woptions.RNG then
		SpellW.Range = Config.spelloptions.woptions.RNG
	end
	if SpellE.Range ~= Config.spelloptions.eoptions.RNG then
		SpellE.Range = Config.spelloptions.eoptions.RNG
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
	Config = scriptConfig("Deadly Ezreal", "Ezreal")
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
	Config:addParam("sep", "Deadly Ezreal "..tostring(version).." by CCONN", SCRIPT_PARAM_INFO, "")
	Config:addParam("sep", "www.facebook.com/CCONN81", SCRIPT_PARAM_INFO, "")
	Config.spelloptions:addSubMenu("Q: Mystic Shot", "qoptions")
	Config.spelloptions:addSubMenu("W: Essence Flux", "woptions")
	Config.spelloptions:addSubMenu("E: Arcane Shift", "eoptions")
	Config.spelloptions:addSubMenu("R: Trueshot Barrage", "roptions")
-------------------------------------------------
-- Auto Carry Sub Menu --------------------------
-------------------------------------------------
	Config.autocarry:addParam("useQ", "Q: Mystic Shot", SCRIPT_PARAM_ONOFF, true)
	Config.autocarry:addParam("useW", "W: Essence Flux", SCRIPT_PARAM_ONOFF, true)
	Config.autocarry:addParam("useE", "E: Arcane Shift", SCRIPT_PARAM_ONOFF, true)
	Config.autocarry:addParam("useR", "R: Trueshot Barrage", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Mixed Mode Sub Menu --------------------------
-------------------------------------------------
	Config.mixedmode:addParam("useQ", "Q: Mystic Shot", SCRIPT_PARAM_ONOFF, true)
	Config.mixedmode:addParam("useW", "W: Essence Flux", SCRIPT_PARAM_ONOFF, true)
	Config.mixedmode:addParam("useE", "E: Arcane Shift", SCRIPT_PARAM_ONOFF, true)
	Config.mixedmode:addParam("useR", "R: Trueshot Barrage", SCRIPT_PARAM_ONOFF, true)
	Config.mixedmode:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	Config.mixedmode:addParam("sep", ">> Last Hit Options <<", SCRIPT_PARAM_INFO, "")
	Config.mixedmode:addParam("farmQ", "Last hit with Q", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Last Hit Menu --------------------------------
-------------------------------------------------
	Config.farm:addParam("useQ", "Q: Mystic Shot", SCRIPT_PARAM_ONOFF, true)
	Config.farm:addParam("useW", "W: Essence Flux", SCRIPT_PARAM_ONOFF, true)
	Config.farm:addParam("useE", "E: Arcane Shift", SCRIPT_PARAM_ONOFF, true)
	Config.farm:addParam("useR", "R: Trueshot Barrage", SCRIPT_PARAM_ONOFF, true)
	Config.farm:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	Config.farm:addParam("sep", ">> Last Hit Options <<", SCRIPT_PARAM_INFO, "")
	Config.farm:addParam("farmQ", "Last hit with Q", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Lane Clear Sub Menu --------------------------
-------------------------------------------------
	Config.laneclear:addParam("useQ", "Q: Mystic Shot", SCRIPT_PARAM_ONOFF, true)
	Config.laneclear:addParam("useW", "W: Essence Flux", SCRIPT_PARAM_ONOFF, true)
	Config.laneclear:addParam("useE", "E: Arcane Shift", SCRIPT_PARAM_ONOFF, true)
	Config.laneclear:addParam("useR", "R: Trueshot Barrage", SCRIPT_PARAM_ONOFF, true)
	Config.laneclear:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	Config.laneclear:addParam("sep", ">> Last Hit Options <<", SCRIPT_PARAM_INFO, "")
	Config.laneclear:addParam("farmQ", "Last hit with Q", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Q Spell Options Sub Menu ---------------------
-------------------------------------------------
	Config.spelloptions.qoptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.qoptions:addParam("RNG", "Range", SCRIPT_PARAM_SLICE, 1150, 0, 1150, 0)
	Config.spelloptions.qoptions:addParam("MANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	--Config.spelloptions.qoptions:addParam("Order", "Cast Order: ", SCRIPT_PARAM_LIST, 4, {"First", "Second", "Third", "Fourth"})
	Config.spelloptions.qoptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.qoptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.qoptions:addParam("Prediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	Config.spelloptions.qoptions:addParam("HitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Config.spelloptions.qoptions:addParam("Collision", "Choose Collision: ", SCRIPT_PARAM_LIST, 1, {"Fast Collision", "Collision"})
	Config.spelloptions.qoptions:addParam("HitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
	Config.spelloptions.qoptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.qoptions:addParam("sep", ">> Q Farm Options <<", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.qoptions:addParam("QFarmMana", "Mana Threshold", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
-------------------------------------------------
-- W Spell Options Sub Menu ---------------------
-------------------------------------------------
	Config.spelloptions.woptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.woptions:addParam("Reset", "Reset Auto Attacks Only", SCRIPT_PARAM_ONOFF, true)
	Config.spelloptions.woptions:addParam("RNG", "Range", SCRIPT_PARAM_SLICE, 1000, 0, 1000, 0)
	Config.spelloptions.woptions:addParam("MANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	--Config.spelloptions.woptions:addParam("Order", "Cast Order: ", SCRIPT_PARAM_LIST, 2, {"First", "Second", "Third", "Fourth"})
	Config.spelloptions.woptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.woptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.woptions:addParam("Prediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	Config.spelloptions.woptions:addParam("HitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Config.spelloptions.woptions:addParam("HitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- E Spell Options Sub Menu ---------------------
-------------------------------------------------
	Config.spelloptions.eoptions:addParam("sep", ">> No Options Yet <<", SCRIPT_PARAM_INFO, "")
-------------------------------------------------
-- R Spell Options Sub Menu ---------------------
-------------------------------------------------
	Config.spelloptions.roptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.roptions:addParam("RNG", "Range", SCRIPT_PARAM_SLICE, 19000, 0, 19000, 0)
	Config.spelloptions.roptions:addParam("MANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	--Config.spelloptions.roptions:addParam("Order", "Cast Order: ", SCRIPT_PARAM_LIST, 3, {"First", "Second", "Third", "Fourth"})
	Config.spelloptions.roptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.roptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	Config.spelloptions.roptions:addParam("Prediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	Config.spelloptions.roptions:addParam("HitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	Config.spelloptions.roptions:addParam("HitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Kill Steal Sub Menu---------------------------
-------------------------------------------------
	Config.killsteal:addParam("KSEnable", "Enable Kill Steals", SCRIPT_PARAM_ONOFF, true)
	Config.killsteal:addParam("KSOverride", "Override Mana Thresholds", SCRIPT_PARAM_ONOFF, true)
	Config.killsteal:addParam("sep", ">> Kill Steal Permutations <<", SCRIPT_PARAM_INFO, "")
	Config.killsteal:addParam("Q", "Q", SCRIPT_PARAM_ONOFF, true)
	Config.killsteal:addParam("W", "W", SCRIPT_PARAM_ONOFF, true)
	Config.killsteal:addParam("R", "R", SCRIPT_PARAM_ONOFF, true)
	Config.killsteal:addParam("sep", "more coming soon...", SCRIPT_PARAM_INFO, "")
-------------------------------------------------
-- Draw Sub Menu --------------------------------
-------------------------------------------------
	Config.draw:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	Config.draw:addParam("DrawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	Config.draw:addParam("DrawE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	Config.draw:addParam("DrawXP", "Draw XP Range", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Target Selector Variables --------------------
-------------------------------------------------
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1200, DAMAGE_PHYSICAL)
	ts.name = "Ezreal"
	Config:addTS(ts)
end

---------------------------------------------------------------------------------------------------
-- OnDraw -----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function OnDraw()
	if SpellReady.Q and Config.draw.DrawQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.Range, 0xFFFFFF)
	end
	if SpellReady.W and Config.draw.DrawW then
		DrawCircle(myHero.x, myHero.y, myHero.z, SpellW.Range, 0xFFFFFF)
	end
	if SpellReady.E and Config.draw.DrawE then
		DrawCircle(myHero.x, myHero.y, myHero.z, eRNG, 0xFFFFFF)
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
	if SpellReady.Q and Config.MixedMode and Config.mixedmode.farmQ
	or SpellReady.Q and Config.Farm and Config.farm.farmQ
	or SpellReady.Q and Config.LaneClear and Config.laneclear.farmQ then
	FarmQ() end
end

---------------------------------------------------------------------------------------------------
-- Farm Q: Last hit minions with spells -----------------------------------------------------------
---------------------------------------------------------------------------------------------------
function FarmQ()
	for i=1, objManager.maxObjects, 1 do
		local object = objManager:getObject(i)
		if object ~= nil and object.type == "obj_AI_Minion" and object.team~=myHero.team then
			if object.visible and not object.dead and GetDistance(myHero, object) <= SpellQ.Range then
				local Health = VP:GetPredictedHealth(object, SpellQ.Delay + (GetDistance(object, myHero)) / SpellQ.Speed)
				if Health > 0 and Health <= getDmg("Q", object, myHero) then
					CastVPredQ(object)
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
		if SpellReady.W and Menu1.W and ValidTarget(enemy, eRNG) and enemy.health < getDmg("W",enemy,myHero) and myHero.mana >= ManaCost(W) then
			if Menu2.eoptions.Prediction == 1 then CastVPredW(enemy) end
			if Menu2.eoptions.Prediction == 2 then CastProdW(enemy) end
			if Menu2.eoptions.Prediction == 3 then CastVIPW(enemy) end
		end
		if SpellReady.R and Menu1.R and ValidTarget(enemy, SpellR.Range) and enemy.health < getDmg("R",enemy,myHero) + 60 and myHero.mana >= ManaCost(R) then
			if Menu2.roptions.Prediction == 1 then CastVPredR(enemy) end
			if Menu2.roptions.Prediction == 2 then CastProdR(enemy) end
			if Menu2.roptions.Prediction == 3 then CastVIPR(enemy) end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Casts Q with Prodiction ------------------------------------------------------------------------
-- Uses Fast Collision or Normal Collision --------------------------------------------------------
---------------------------------------------------------------------------------------------------
function CastProdQ(unit)
	if SpellReady.Q and ValidTarget(unit) and myHero.mana >= ManaCost(Q) then
		QPos = ProdictQ:GetPrediction(unit)
		if QPos ~= nil then
			if Config.spelloptions.qoptions.Collision == 1 then
				local willCollide = ProdictQFastCol:GetMinionCollision(QPos, myHero)
				if not willCollide then
					PacketCast(_Q, QPos)
				end
			elseif Config.spelloptions.qoptions.Collision == 2 then
				local willCollide = ProdictQCol:GetMinionCollision(QPos, myHero)
				if not willCollide then
					PacketCast(_Q, QPos)
				end
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Casts Q with VPrediction -----------------------------------------------------------------------
-- Uses built in VPrediction collision check ------------------------------------------------------
---------------------------------------------------------------------------------------------------
function CastVPredQ(unit)
	if SpellReady.Q and ValidTarget(unit) and myHero.mana >= ManaCost(Q) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellQ.Delay, SpellQ.Width, SpellQ.Range, SpellQ.Speed, myHero, true)
		if HitChance >= Config.spelloptions.qoptions.HitChance and GetDistance(CastPosition) <= SpellQ.Range then
			PacketCast(_Q, CastPosition)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Casts Q with BoL VIP Prediction ----------------------------------------------------------------
-- Uses Normal Collision --------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function CastVIPQ(unit)
	VipPredTarget = qp:GetPrediction(Target)
	if SpellReady.Q and ValidTarget(unit) and myHero.mana >= ManaCost(Q) and VipPredTarget and GetDistance(unit) <= SpellQ.Range then
		local QColl = (Collision(SpellQ.Range, SpellQ.Speed, SpellQ.Delay, SpellQ.Width))
		local willCollide = QColl:GetMinionCollision(unit, myHero)
		if not willCollide and GetDistance(unit) <= SpellQ.Range then
			PakcetCast(_Q, VipPredTarget)
		end
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
				if Config.spelloptions.woptions.Prediction == 1 then CastVPredW(unit) end
				if Config.spelloptions.woptions.Prediction == 2 then CastProdW(unit) end
				if Config.spelloptions.woptions.Prediction == 3 then CastVIPW(unit) end
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Casts W using Prodiction -----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function CastProdW(unit)
	if SpellReady.W and ValidTarget(unit) and myHero.mana >= ManaCost(W) then
		WPos = ProdictW:GetPrediction(unit)
		if WPos ~= nil then
			PacketCast(_W, WPos)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Casts W using VPrediction ----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function CastVPredW(unit)
	if SpellReady.W and ValidTarget(unit) and myHero.mana >= ManaCost(W) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellW.Delay, SpellW.Width, SpellW.Range, SpellW.Speed, myHero, false)
		if HitChance >= Config.spelloptions.woptions.HitChance and GetDistance(unit) <= SpellW.Range then
			PacketCast(_W, CastPosition)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Casts W using BoL VIP Prediction ---------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function CastVIPW(unit)
	VipPredTarget = wp:GetPrediction(unit)
	if SpellReady.W and ValidTarget(unit) and myHero.mana >= ManaCost(W) and  VipPredTarget then
		if GetDistance(unit) <= SpellW.Range then
			PacketCast(_W, VipPredTarget)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Casts R using Prodiction -----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function CastProdR(unit)
	if SpellReady.R and ValidTarget(unit) and myHero.mana >= ManaCost(R) then
		RPos = ProdictR:GetPrediction(unit)
		if RPos ~= nil then
			PacketCast(_R, RPos)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Casts R using VPrediction ----------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function CastVPredR(unit)
	if SpellReady.R and ValidTarget(unit) and myHero.mana >= ManaCost(R) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, SpellR.Delay, SpellR.Width, SpellR.Range, SpellR.Speed, myHero, false)
		if HitChance >= Config.spelloptions.roptions.HitChance and GetDistance(CastPosition) <= SpellR.Range then
			PacketCast(_R, CastPosition)
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Casts R using BoL VIP Prediction ---------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function CastVIPR(unit)
	VipPredTarget = rp:GetPrediction(unit)
	if SpellReady.R and ValidTarget(unit) and myHero.mana >= ManaCost(R) and VipPredTarget then
		if GetDistance(unit) <= SpellR.Range then
			if GetDistance(unit) <= SpellR.Range then
				PacketCast(_R, VipPredTarget)
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Returns mana cost of spells --------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function ManaCost(spell)
	if spell == Q then
		return 25 + (3 * myHero:GetSpellData(_Q).level)
	elseif spell == W then
		return 40 + (10 * myHero:GetSpellData(_W).level)
	elseif spell == E then
		return 90
	elseif spell == R then
		return 100
	end
end

---------------------------------------------------------------------------------------------------
-- Compares current mana against custom mana thresholds -------------------------------------------
---------------------------------------------------------------------------------------------------
--[[
function ManaCheck(spell)
	local Menu = Config.spelloptions[string.lower(spell).."options"].MANA
	if myHero.mana >= myHero.maxMana * (Menu / 100) then
		return true
	end
end
]]

---------------------------------------------------------------------------------------------------
-- Combo ------------------------------------------------------------------------------------------
-- Uses parameters to consolidate multiple combos into one function -------------------------------
---------------------------------------------------------------------------------------------------
function Combo(unit, menu)
	local Menu1 = menu
	local Menu2 = Config.spelloptions
	if unit and ValidTarget(unit) then
		if SpellReady.Q and Menu1.useQ then
			if GetDistance(unit) <= SpellQ.Range and GetDistance(unit) then
				if myHero.mana >= myHero.maxMana * (Menu2.qoptions.MANA / 100) then
					if Menu2.qoptions.Prediction == 1 then CastVPredQ(Target) end
					if Menu2.qoptions.Prediction == 2 then CastProdQ(Target) end
					if Menu2.qoptions.Prediction == 3 then CastVIPQ(Target) end
				end
			end
		end
		if SpellReady.W and Menu1.useW and GetDistance(Target) <= SpellW.Range then
			if not Menu2.woptions.Reset then
				if myHero.mana >= myHero.maxMana * (Menu2.woptions.MANA / 100) then
					if Menu2.woptions.Prediction == 1 then CastVPredW(Target) end
					if Menu2.woptions.Prediction == 2 then CastProdW(Target) end
					if Menu2.woptions.Prediction == 3 then CastVIPW(Target) end
				end
			end
		end
		if SpellReady.R and Menu1.useR then
			if GetDistance(Target) <= SpellR.Range then
				if myHero.mana >= myHero.maxMana * (Menu2.roptions.MANA / 100) then
					if Menu2.roptions.Prediction == 1 then CastVPredR(Target) end
					if Menu2.roptions.Prediction == 2 then CastProdR(Target) end
					if Menu2.roptions.Prediction == 3 then CastVIPR(Target) end
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