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
-- VERSION 1.01.P
	-- Prodiction Only Version
	-- Cleaned up Global Variables
	-- Removed normal spell casting. All spells are now cast using packets
	-- Corrected error in ManaCost function
	-- Added ManaCheck function --removed temporarily
	-- Added new Combo function that consolidates all combos into one function
	-- Changed W Reset to only invoke while holding AutoCarry key


---------------------------------------------------------------------------------------------------
-- TO DO LIST: ------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
-- OnAttack()
	-- Q & W reset only when in AA range
-- FARM Q
	-- VPrediction health prediction for farmq
	-- Only Q when AA not available
	-- use Q to reset AA for last hit?
	-- use W to reset AA for last hit?
-- Kill Steals
	-- Add custom KS R range
	-- Add all KS combinations
	-- Add mana thresholds and overrides
-- Spell Casting
	-- Add hitboxes to all casting functions
	-- Add ManaCheck to all functions
-- FPS Drop
	-- Split Prodiction / VPrediction to different scripts until resolved
-- Drawing
	-- Add Lag Free Circles
-- Arcane Shift
	-- Add casting functions / Menu options
-- Combos
	-- Add spell casting order
-- Standalone
	-- Convert script to standlone
	-- Integrated SOW
	-- Add target selector
---------------------------------------------------------------------------------------------------

if not VIP_USER and myHero.charName ~= "Ezreal" then return end

---------------------------------------------------------------------------------------------------
--	Required Libs ---------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
require "Prodiction"
require "FastCollision"

---------------------------------------------------------------------------------------------------
--  Global Variables ------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
local version = "1.01.P"
local Target = AutoCarry.GetAttackTarget()
local SpellReady = {Q = nil, W = nil, E = nil, R = nil}
local SpellQ = {Range = nil, Speed = nil, Delay = nil, Width = nil}
local SpellW = {Range = nil, Speed = nil, Delay = nil, Width = nil}
local SpellE = {Range = nil, Speed = nil, Delay = nil, Width = nil}
local SpellR = {Range = nil, Speed = nil, Dealy = nil, Width = nil}
local Prodict, ProdictQ, ProdictW, ProdictR
local ProdictQFastCol, ProdictQCol
local VipPredTarget
local VP, qp, wp, rp

---------------------------------------------------------------------------------------------------
-- OnLoad: Invoked once during script load only --------------------------------------------------
---------------------------------------------------------------------------------------------------
function PluginOnLoad()
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

	SpellQ.Width = 80
	SpellW.Width = 80
	SpellR.Width = 150
-------------------------------------------------
-- VPrediction Variables ------------------------
-------------------------------------------------

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

-------------------------------------------------
-- Collision & Fast Collision Variables ---------
-------------------------------------------------
	ProdictQFastCol = FastCol(ProdictQ)
-------------------------------------------------
-- Load Message ---------------------------------
-------------------------------------------------
	PrintChat(">> Deadly Ezreal version "..tostring(version).." by CCONN")
end

---------------------------------------------------------------------------------------------------
-- SpellCheck: Invoked every tick in the main OnTick function -------------------------------------
-- used to set variables that require constant updates --------------------------------------------
---------------------------------------------------------------------------------------------------
function SpellCheck()
	if SpellQ.Range ~= AutoCarry.PluginMenu.spelloptions.qoptions.RNG then
		SpellQ.Range = AutoCarry.PluginMenu.spelloptions.qoptions.RNG
	end
	if SpellW.Range ~= AutoCarry.PluginMenu.spelloptions.woptions.RNG then
		SpellW.Range = AutoCarry.PluginMenu.spelloptions.woptions.RNG
	end
	if SpellE.Range ~= AutoCarry.PluginMenu.spelloptions.woptions.RNG then
		SpellE.Range = AutoCarry.PluginMenu.spelloptions.eoptions.RNG
	end
	if SpellR.Range ~= AutoCarry.PluginMenu.spelloptions.roptions.RNG then
		SpellR.Range = AutoCarry.PluginMenu.spelloptions.roptions.RNG
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
	AutoCarry.PluginMenu:addSubMenu("Auto Carry", "autocarry")
	AutoCarry.PluginMenu:addSubMenu("Mixed Mode", "mixedmode")
	AutoCarry.PluginMenu:addSubMenu("Lane Clear", "laneclear")
	AutoCarry.PluginMenu:addSubMenu("Last Hit", "farm")
	AutoCarry.PluginMenu:addSubMenu("Spell Options", "spelloptions")
	AutoCarry.PluginMenu:addSubMenu("Kill Steal", "killsteal")
	AutoCarry.PluginMenu:addSubMenu("Draw", "draw")
	AutoCarry.PluginMenu:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("sep", "Deadly Ezreal "..tostring(version).." by CCONN", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("sep", "www.facebook.com/CCONN81", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("Q: Mystic Shot", "qoptions")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("W: Essence Flux", "woptions")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("E: Arcane Shift", "eoptions")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("R: Trueshot Barrage", "roptions")
-------------------------------------------------
-- Auto Carry Sub Menu --------------------------
-------------------------------------------------
	AutoCarry.PluginMenu.autocarry:addParam("useQ", "Q: Mystic Shot", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.autocarry:addParam("useW", "W: Essence Flux", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.autocarry:addParam("useE", "E: Arcane Shift", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.autocarry:addParam("useR", "R: Trueshot Barrage", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Mixed Mode Sub Menu --------------------------
-------------------------------------------------
	AutoCarry.PluginMenu.mixedmode:addParam("useQ", "Q: Mystic Shot", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("useW", "W: Essence Flux", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("useE", "E: Arcane Shift", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("useR", "R: Trueshot Barrage", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.mixedmode:addParam("sep", ">> Last Hit Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.mixedmode:addParam("farmQ", "Last hit with Q", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Last Hit Menu --------------------------------
-------------------------------------------------
	AutoCarry.PluginMenu.farm:addParam("useQ", "Q: Mystic Shot", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.farm:addParam("useW", "W: Essence Flux", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.farm:addParam("useE", "E: Arcane Shift", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.farm:addParam("useR", "R: Trueshot Barrage", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.farm:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.farm:addParam("sep", ">> Last Hit Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.farm:addParam("farmQ", "Last hit with Q", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Lane Clear Sub Menu --------------------------
-------------------------------------------------
	AutoCarry.PluginMenu.laneclear:addParam("useQ", "Q: Mystic Shot", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.laneclear:addParam("useQ", "W: Essence Flux", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.laneclear:addParam("useE", "E: Arcane Shift", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.laneclear:addParam("useR", "R: Trueshot Barrage", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.laneclear:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.laneclear:addParam("sep", ">> Last Hit Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.laneclear:addParam("farmQ", "Last hit with Q", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Q Spell Options Sub Menu ---------------------
-------------------------------------------------
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("RNG", "Range", SCRIPT_PARAM_SLICE, 1100, 0, 1100, 0)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("MANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("Order", "Cast Order: ", SCRIPT_PARAM_LIST, 4, {"First", "Second", "Third", "Fourth"})
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("Prediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("HitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("Collision", "Choose Collision: ", SCRIPT_PARAM_LIST, 1, {"Fast Collision", "Collision"})
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("HitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", ">> Q Farm Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QFarmMana", "Mana Threshold", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
-------------------------------------------------
-- W Spell Options Sub Menu ---------------------
-------------------------------------------------
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("Reset", "Reset Auto Attacks Only", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("RNG", "Range", SCRIPT_PARAM_SLICE, 1050, 0, 1050, 0)
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("MANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("Order", "Cast Order: ", SCRIPT_PARAM_LIST, 2, {"First", "Second", "Third", "Fourth"})
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("Prediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("HitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("HitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- E Spell Options Sub Menu ---------------------
-------------------------------------------------
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("sep", ">> No Options Yet <<", SCRIPT_PARAM_INFO, "")
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("RNG", "Range", SCRIPT_PARAM_SLICE, 475, 0, 475, 0)
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("MANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("Order", "Cast Order: ", SCRIPT_PARAM_LIST, 2, {"First", "Second", "Third", "Fourth"})
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("Prediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("HitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("HitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
	--AutoCarry.PluginMenu.spelloptions.eoptions:addParam("Packet", "Use Packets", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- R Spell Options Sub Menu ---------------------
-------------------------------------------------
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RNG", "Range", SCRIPT_PARAM_SLICE, 19000, 0, 19000, 0)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("MANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("Order", "Cast Order: ", SCRIPT_PARAM_LIST, 3, {"First", "Second", "Third", "Fourth"})
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("Prediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("HitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("HitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
-------------------------------------------------
-- Kill Steal Sub Menu---------------------------
-------------------------------------------------
	AutoCarry.PluginMenu.killsteal:addParam("KSEnable", "Enable Kill Steals", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("KSOverride", "Override Mana Thresholds", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("sep", ">> Kill Steal Permutations <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.killsteal:addParam("Q", "Q", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("W", "W", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("R", "R", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("sep", "more coming soon...", SCRIPT_PARAM_INFO, "")
-------------------------------------------------
-- Draw Sub Menu --------------------------------
-------------------------------------------------
	AutoCarry.PluginMenu.draw:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.draw:addParam("DrawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.draw:addParam("DrawE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.draw:addParam("DrawXP", "Draw XP Range", SCRIPT_PARAM_ONOFF, true)
end

---------------------------------------------------------------------------------------------------
-- OnDraw -----------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function PluginOnDraw()
	if SpellReady.Q and AutoCarry.PluginMenu.draw.DrawQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, SpellQ.Range, 0xFFFFFF)
	end
	if SpellReady.W and AutoCarry.PluginMenu.draw.DrawW then
		DrawCircle(myHero.x, myHero.y, myHero.z, SpellW.Range, 0xFFFFFF)
	end
	if SpellReady.E and AutoCarry.PluginMenu.draw.DrawE then
		DrawCircle(myHero.x, myHero.y, myHero.z, eRNG, 0xFFFFFF)
	end
	if AutoCarry.PluginMenu.draw.DrawXP then
		DrawCircle(myHero.x, myHero.y, myHero.z, 1600, 0xFFFFFF)
	end
end

---------------------------------------------------------------------------------------------------
-- Main Script Function: Invoked every tick -------------------------------------------------------
---------------------------------------------------------------------------------------------------
function PluginOnTick()
	Target = AutoCarry.GetAttackTarget()
	SpellCheck()
	if Target and AutoCarry.MainMenu.AutoCarry then Combo(Target, AutoCarry.PluginMenu.autocarry) end
	if Target and AutoCarry.MainMenu.MixedMode then Combo(Target, AutoCarry.PluginMenu.mixedmode) end
	if Target and AutoCarry.MainMenu.LastHit then Combo(Target, AutoCarry.PluginMenu.farm) end
	if Target and AutoCarry.MainMenu.LaneClear then Combo(Target, AutoCarry.PluginMenu.laneclear) end
	if AutoCarry.PluginMenu.killsteal.KSEnable then KillSteal() end
	if SpellReady.Q and AutoCarry.MainMenu.MixedMode and AutoCarry.PluginMenu.mixedmode.farmQ
	or SpellReady.Q and AutoCarry.MainMenu.LastHit and AutoCarry.PluginMenu.farm.farmQ
	or SpellReady.Q and AutoCarry.MainMenu.LaneClear and AutoCarry.PluginMenu.laneclear.farmQ then
	FarmQ() end
end

---------------------------------------------------------------------------------------------------
-- Farm Q: Last hit minions with spells -----------------------------------------------------------
---------------------------------------------------------------------------------------------------
function FarmQ()
	for i, creep in pairs(AutoCarry.EnemyMinions().objects) do
		if creep and not creep.dead and GetDistance(creep) <= SpellQ.Range then
			if myHero.mana >= myHero.maxMana * (AutoCarry.PluginMenu.spelloptions.qoptions.QFarmMana / 100) then
				if creep.health <= getDmg("Q", creep, myHero) then
					if AutoCarry.CanAttack then
						PacketCast(_Q, creep)
					end
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
	local Menu1 = AutoCarry.PluginMenu.killsteal
	local Menu2 = AutoCarry.PluginMenu.spelloptions
		if SpellReady.Q and Menu1.Q and ValidTarget(enemy, SpellQ.Range) and enemy.health < getDmg("Q",enemy,myHero) and myHero.mana >= ManaCost(Q) then
			CastProdQ(enemy)
		end
		if SpellReady.W and Menu1.W and ValidTarget(enemy, eRNG) and enemy.health < getDmg("W",enemy,myHero) and myHero.mana >= ManaCost(W) then
			CastProdW(enemy)
		end
		if SpellReady.R and Menu1.R and ValidTarget(enemy, SpellR.Range) and enemy.health < getDmg("R",enemy,myHero) + 60 and myHero.mana >= ManaCost(R) then
			CastProdR(enemy)
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
			if AutoCarry.PluginMenu.spelloptions.qoptions.Collision == 1 then
				local willCollide = ProdictQFastCol:GetMinionCollision(QPos, myHero)
				if not willCollide then
					PacketCast(_Q, QPos)
				end
			end
		end
	end
end

---------------------------------------------------------------------------------------------------
-- Invoked when an auto attack is cast ------------------------------------------------------------
-- Used to reset auto attacks ---------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
function OnAttacked()
	if AutoCarry.PluginMenu.spelloptions.woptions.Reset and AutoCarry.MainMenu.AutoCarry then
		if Target and SpellReady.W and ValidTarget(Target) and myHero.mana >= ManaCost(W) then
			if GetDistance(Target) <= myHero.range then
				CastProdW(Target)
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
	local Menu = AutoCarry.PluginMenu.spelloptions[string.lower(spell).."options"].MANA
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
	local Menu2 = AutoCarry.PluginMenu.spelloptions
	if unit and ValidTarget(unit) then
		if SpellReady.Q and Menu1.useQ then
			if GetDistance(unit) <= SpellQ.Range then
				if myHero.mana >= myHero.maxMana * (Menu2.qoptions.MANA / 100) then
					CastProdQ(Target)
				end
			end
		end
		if SpellReady.W and Menu1.useW and GetDistance(Target) <= SpellW.Range then
			if not Menu2.woptions.Reset then
				if myHero.mana >= myHero.maxMana * (Menu2.woptions.MANA / 100) then
					CastProdW(Target)
				end
			end
		end
		if SpellReady.R and Menu1.useR then
			if GetDistance(Target) <= SpellR.Range then
				if myHero.mana >= myHero.maxMana * (Menu2.roptions.MANA / 100) then
					CastProdR(Target)
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