--[[
╔╦╗┌─┐┌─┐┌┬┐┬ ┬ ┬  ╦╔═┌─┐┌─┐╔╦╗┌─┐┬ ┬
 ║║├┤ ├─┤ │││ └┬┘  ╠╩╗│ ││ ┬║║║├─┤│││
═╩╝└─┘┴ ┴─┴┘┴─┘┴   ╩ ╩└─┘└─┘╩ ╩┴ ┴└┴┘
┌┐ ┬ ┬  ╔═╗╔═╗╔═╗╔╗╔╔╗╔              
├┴┐└┬┘  ║  ║  ║ ║║║║║║║              
└─┘ ┴   ╚═╝╚═╝╚═╝╝╚╝╝╚╝              

VERSION:	1.00

CHANGELOG:	VERSION 1.00
				Initial Release
				
		Follow me on Facebook! Its the easiest way to communicate with me.
		CCONN's Facebook: https://www.facebook.com/CCONN81
		
		Like the script and want to donate?
		All donations go towards purchasing additional scripts and premium time so I can script more for you guys.
		CCONN's DONATE LINK: https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=JTWL7DK86V56S
--]]

if myHero.charName ~= "KogMaw" then return end

--[[
		Required Libs
  ]]
require "Prodiction"
require "VPrediction"
require "FastCollision"
require "Collision"

--[[
		Variables
  ]]
local Target = AutoCarry.GetAttackTarget()
local qRNG, wRNG, eRNG, rRNG
local qSPD, wSPD, eSPD, rSPD = 800, 0, 800, 1000
local qDLY, wDLY, eDLY, rDLY = 0.60, 0, 0.60, 0.250
local qWTH, wWTH, eWTH, rWTH = 80, 0, 80, 100
local qRDY = (myHero:CanUseSpell(_Q) == READY)
local wRDY = (myHero:CanUseSpell(_W) == READY)
local eRDY = (myHero:CanUseSpell(_E) == READY)
local rRDY = (myHero:CanUseSpell(_R) == READY)
local Prodict = ProdictManager.GetInstance()
local ProdictQ = Prodict:AddProdictionObject(_Q, qRNG, qSPD, qDLY, qWTH)
local ProdictE = Prodict:AddProdictionObject(_E, eRNG, eSPD, eDLY, eWTH)
local ProdictR = Prodict:AddProdictionObject(_R, rRNG, rSPD, rDLY, rWTH)
local ProdictQFastCol = FastCol(ProdictQ)
local ProdictQCol = Collision(qRNG, qSPD, qDLY, qWTH)
local VipPredTarget
local qp = TargetPredictionVIP(qRNG, qSPD, qDLY, qWTH)
local ep = TargetPredictionVIP(eRNG, eSPD, eDLY, eWTH)
local rp = TargetPredictionVIP(rRNG, rSPD, rDLY, rWTH)
local stacks, timer = 0, 0
local VP = VPrediction()
local Version = 1.00

function PluginOnLoad()
	Menu()
	qRNG, wRNG, eRNG, rRNG = AutoCarry.PluginMenu.spelloptions.qoptions.QRNG, AutoCarry.PluginMenu.spelloptions.woptions.WRNG, AutoCarry.PluginMenu.spelloptions.eoptions.ERNG, GetRRange()
	PrintChat("Deadly KogMaw version version 1.00 by CCONN")
end

--[[
		Script Menu
  ]]
  
function Menu()
--[[
		Sub Menus
  ]]
	AutoCarry.PluginMenu:addSubMenu("Auto Carry", "autocarry")
	AutoCarry.PluginMenu:addSubMenu("Mixed Mode", "mixedmode")
	AutoCarry.PluginMenu:addSubMenu("Lane Clear", "laneclear")
	AutoCarry.PluginMenu:addSubMenu("Spell Options", "spelloptions")
	AutoCarry.PluginMenu:addSubMenu("Kill Steal", "killsteal")
	AutoCarry.PluginMenu:addSubMenu("Draw", "draw")
	AutoCarry.PluginMenu:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("sep", "Deadly KogMaw by CCONN", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("sep", "Version: 1.00", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("sep", "www.facebook.com/CCONN81", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("Q: Caustic Spittle", "qoptions")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("W: Bio-Arcane Barrage", "woptions")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("E: Void Ooze", "eoptions")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("R: Living Artillery", "roptions")
	
--[[
		Auto Carry Sub Menu
  ]]
	AutoCarry.PluginMenu.autocarry:addParam("ACuseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.autocarry:addParam("ACuseW", "Use W", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.autocarry:addParam("ACuseE", "Use E", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.autocarry:addParam("ACuseR", "Use R", SCRIPT_PARAM_ONOFF, true)

--[[
		Mixed Mode Sub Menu
  ]]
	AutoCarry.PluginMenu.mixedmode:addParam("MMuseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("MMuseW", "Use W", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("MMuseE", "Use E", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("MMuseR", "Use R", SCRIPT_PARAM_ONOFF, true)
	
--[[
		Lane Clear Sub Menu
  ]]
	AutoCarry.PluginMenu.laneclear:addParam("LCuseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.laneclear:addParam("LCuseW", "Use W", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.laneclear:addParam("LCuseE", "Use E", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.laneclear:addParam("LCuseR", "Use R", SCRIPT_PARAM_ONOFF, true)
	
--[[
		Spell Options Sub Menu
  ]]
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QRNG", "Range", SCRIPT_PARAM_SLICE, 1000, 0, 1000, 0)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QMANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QOrder", "Cast Order: ", SCRIPT_PARAM_LIST, 4, {"First", "Second", "Third", "Fourth"})
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QPrediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QHitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QCollision", "Choose Collision: ", SCRIPT_PARAM_LIST, 1, {"Fast Collision", "Collision"})
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QHitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
	
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("WRNG", "Range", SCRIPT_PARAM_SLICE, 710, 0, 710, 0)
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("WMANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("WOrder", "Cast Order: ", SCRIPT_PARAM_LIST, 1, {"First", "Second", "Third", "Fourth"})
	
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("ERNG", "Range", SCRIPT_PARAM_SLICE, 1280, 0, 1280, 0)
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("EMANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("EOrder", "Cast Order: ", SCRIPT_PARAM_LIST, 2, {"First", "Second", "Third", "Fourth"})
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("EPrediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("EHitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("EHitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
	
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", "Range is dynamic", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RMANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("ROrder", "Cast Order: ", SCRIPT_PARAM_LIST, 3, {"First", "Second", "Third", "Fourth"})
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RPrediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RHitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RHitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", ">> Stack Management <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RStackCheck", "Use Stack Check", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RStack1", "Rank 1 max stacks", SCRIPT_PARAM_SLICE, 2, 1, 10, 0)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RStack2", "Rank 2 max stacks", SCRIPT_PARAM_SLICE, 3, 1, 10, 0)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RStack3", "Rank 3 max stacks", SCRIPT_PARAM_SLICE, 4, 1, 10, 0)
	
	
--[[
		Kill Steal Sub Menu
  ]]
	AutoCarry.PluginMenu.killsteal:addParam("KSEnable", "Enable Kill Steals", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("KSOverride", "Override Mana Thresholds", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("sep", ">> Kill Steal Permutations <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.killsteal:addParam("Q", "Q", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("E", "E", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("R", "R", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.killsteal:addParam("sep", "more coming soon...", SCRIPT_PARAM_INFO, "")
	--TODO add more killsteal permuations

--[[
		Draw Sub Menu
  ]]
	AutoCarry.PluginMenu.draw:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.draw:addParam("DrawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.draw:addParam("DrawE", "Draw E Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.draw:addParam("DrawR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.draw:addParam("DrawXP", "Draw XP Range", SCRIPT_PARAM_ONOFF, true)
end

--[[
		Draw Related
  ]]
function PluginOnDraw()
	if qRDY and AutoCarry.PluginMenu.draw.DrawQ then
		DrawCircle(myHero.x, myHero.y, myHero.z, qRNG, 0xFFFFFF)
	end
	if wRDY and AutoCarry.PluginMenu.draw.DrawW then
		DrawCircle(myHero.x, myHero.y, myHero.z, wRNG, 0xFFFFFF)
	end
	if eRDY and AutoCarry.PluginMenu.draw.DrawE then
		DrawCircle(myHero.x, myHero.y, myHero.z, eRNG, 0xFFFFFF)
	end
	if rRDY and AutoCarry.PluginMenu.draw.DrawR then
		DrawCircle(myHero.x, myHero.y, myHero.z, rRNG, 0xFFFFFF)
	end
		if AutoCarry.PluginMenu.draw.DrawXP then
	DrawCircle(myHero.x, myHero.y, myHero.z, 1600, 0xFFFFFF)
	end
end
--TODO lag free circles

--[[
		Main Script Function
  ]]
function PluginOnTick()
	Target = AutoCarry.GetAttackTarget()
	StackReset()
	if Target and AutoCarry.MainMenu.AutoCarry then ComboAC() end
	if Target and AutoCarry.MainMenu.MixedMode then ComboMM() end
	if Target and AutoCarry.MainMenu.LaneClear then ComboLC() end
	if AutoCarry.PluginMenu.killsteal.KSEnable then KillSteal() end
end

--[[
		Kill Steals
  ]]
  
--TODO Add all permutations for kill steals
--TODO Add mana thresholds and overrides
function KillSteal()
	for i = 1, heroManager.iCount do
	local enemy = heroManager:getHero(i)
	local Menu1 = AutoCarry.PluginMenu.killsteal
	local Menu2 = AutoCarry.PluginMenu.spelloptions
		if qRDY and Menu1.Q and ValidTarget(enemy, qRNG) and enemy.health < getDmg("Q",enemy,myHero) and myHero.mana >= ManaCost(Q) then
			if Menu2.qoptions.QPrediction == 1 then CastVPredQ(enemy) end
			if Menu2.qoptions.QPrediction == 2 then CastProdQ(enemy) end
			if Menu2.qoptions.QPrediction == 3 then CastVIPQ(enemy) end
		end
		if eRDY and Menu1.E and ValidTarget(enemy, eRNG) and enemy.health < getDmg("E",enemy,myHero) and myHero.mana >= ManaCost(E) then
			if Menu2.eoptions.EPrediction == 1 then CastVPredE(enemy) end
			if Menu2.eoptions.EPrediction == 2 then CastProdE(enemy) end
			if Menu2.eoptions.EPrediction == 3 then CastVIPE(enemy) end
		end
		if rRDY and Menu1.R and ValidTarget(enemy, rRNG) and enemy.health < getDmg("R",enemy,myHero) and myHero.mana >= ManaCost(R) then
			if Menu2.roptions.RPrediction == 1 then CastVPredR(enemy) end
			if Menu2.roptions.RPrediction == 2 then CastProdR(enemy) end
			if Menu2.roptions.RPrediction == 3 then CastVIPR(enemy) end
		end
	end
end

--[[
		Combo that is executed when
		holding the AutoCarry hotkey
  ]]
  --TODO Add spell casting order
function ComboAC()
	local Menu1 = AutoCarry.PluginMenu.autocarry
	local Menu2 = AutoCarry.PluginMenu.spelloptions
	if Target then
		if wRDY and Menu1.ACuseW and GetDistance(Target) <= GetWRange() and GetDistance(Target) <= wRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.woptions.WMANA / 100) then
				CastW(Target)
			end
		end
		if eRDY and Menu1.ACuseE and GetDistance(Target) <= eRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.eoptions.EMANA / 100) then
				if Menu2.eoptions.EPrediction == 1 then CastVPredE(Target) end
				if Menu2.eoptions.EPrediction == 2 then CastProdE(Target) end
				if Menu2.eoptions.EPrediction == 3 then CastVIPE(Target) end
			end
		end
		if rRDY and Menu1.ACuseR and GetDistance(Target) <= GetRRange() then 
			if myHero.mana >= myHero.maxMana * (Menu2.roptions.RMANA / 100) then
				if Menu2.roptions.RPrediction == 1 then CastVPredR(Target) end
				if Menu2.roptions.RPrediction == 2 then CastProdR(Target) end
				if Menu2.roptions.RPrediction == 3 then CastVIPR(Target) end
			end
		end
		if qRDY and Menu1.ACuseQ and GetDistance(Target) <= qRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.qoptions.QMANA / 100) then
				if Menu2.qoptions.QPrediction == 1 then CastVPredQ(Target) end
				if Menu2.qoptions.QPrediction == 2 then CastProdQ(Target) end
				if Menu2.qoptions.QPrediction == 3 then CastVIPQ(Target) end
			end
		end
	end
end

--[[
		Combo that is executed when
		holding the Mixed Mode hotkey
  ]]
  --TODO Add spell casting order
function ComboMM()
	local Menu1 = AutoCarry.PluginMenu.mixedmode
	local Menu2 = AutoCarry.PluginMenu.spelloptions
	if Target ~= nil then
		if wRDY and Menu1.MMuseW and GetDistance(Target) <= GetWRange() and GetDistance(Target) <= wRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.woptions.WMANA / 100) then
				CastW(Target)
			end
		end
		if eRDY and Menu1.MMuseE and GetDistance(Target) <= eRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.eoptions.EMANA / 100) then
				if Menu2.eoptions.EPrediction == 1 then CastVPredE(Target) end
				if Menu2.eoptions.EPrediction == 2 then CastProdE(Target) end
				if Menu2.eoptions.EPrediction == 3 then CastVIPE(Target) end
			end
		end
		if rRDY and Menu1.MMuseR and GetDistance(Target) <= rRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.roptions.RMANA / 100) then
				if Menu2.roptions.RPrediction == 1 then CastVPredR(Target) end
				if Menu2.roptions.RPrediction == 2 then CastProdR(Target) end
				if Menu2.roptions.RPrediction == 3 then CastVIPR(Target) end
			end
		end
		if qRDY and Menu1.MMuseQ and GetDistance(Target) <= qRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.qoptions.QMANA / 100) then
				if Menu2.qoptions.QPrediction == 1 then CastVPredQ(Target) end
				if Menu2.qoptions.QPrediction == 2 then CastProdQ(Target) end
				if Menu2.qoptions.QPrediction == 3 then CastVIPQ(Target) end
			end
		end
	end
end

--[[
		Combo that is executed when
		holding the Lane Clear hotkey
  ]]
  --TODO Add spell casting order
function ComboLC()
	local Menu1 = AutoCarry.PluginMenu.laneclear
	local Menu2 = AutoCarry.PluginMenu.spelloptions
	if Target and ValidTarget(Target) then
		if wRDY and Menu1.LCuseW and GetDistance(Target) <= GetWRange() and GetDistance(Target) <= wRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.woptions.WMANA / 100) then
				CastW(Target)
			end
		end
		if eRDY and Menu1.LCuseE and GetDistance(Target) <= eRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.eoptions.EMANA / 100) then
				if Menu2.eoptions.EPrediction == 1 then CastVPredE(Target) end
				if Menu2.eoptions.EPrediction == 2 then CastProdE(Target) end
				if Menu2.eoptions.EPrediction == 3 then CastVIPE(Target) end
			end
		end
		if rRDY and Menu1.LCuseR and GetDistance(Target) <= rRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.roptions.RMANA / 100) then
				if Menu2.roptions.RPrediction == 1 then CastVPredR(Target) end
				if Menu2.roptions.RPrediction == 2 then CastProdR(Target) end
				if Menu2.roptions.RPrediction == 3 then CastVIPR(Target) end
			end
		end
		if qRDY and Menu1.LCuseQ and GetDistance(Target) <= qRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.qoptions.QMANA / 100) then
				if Menu2.qoptions.QPrediction == 1 then CastVPredQ(Target) end
				if Menu2.qoptions.QPrediction == 2 then CastProdQ(Target) end
				if Menu2.qoptions.QPrediction == 3 then CastVIPQ(Target) end
			end
		end
	end
end

--TODO add hitboxes
function CastProdQ(unit)
	if qRDY and ValidTarget(unit) and myHero.mana >= ManaCost(Q) then
		QPos = ProdictQ:GetPrediction(unit)
		if QPos ~= nil then
			if AutoCarry.PluginMenu.spelloptions.qoptions.QCollision == 1 then
				local willCollide = ProdictQFastCol:GetMinionCollision(QPos, myHero)
				if not willCollide then CastSpell(_Q, QPos.x, QPos.z) end
			elseif AutoCarry.PluginMenu.spelloptions.qoptions.QCollision == 2 then
				local willCollide = ProdictQCol:GetMinionCollision(QPos, myHero)
				if not willCollide then CastSpell(_Q, Qpos.x, QPos.z) end
			end
		end
	end
end

--TODO add hitboxes
function CastVPredQ(unit)
	if qRDY and ValidTarget(unit) and myHero.mana >= ManaCost(Q) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, qDLY, qWTH, qRNG, qSPD, myHero, true)
		if HitChance >= AutoCarry.PluginMenu.spelloptions.qoptions.QHitChance and GetDistance(CastPosition) <= qRNG then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

--TODO add hitboxes
function CastVIPQ(unit)
	VipPredTarget = qp:GetPrediction(Target)
	if qRDY and ValidTarget(unit) and myHero.mana >= ManaCost(Q) and VipPredTarget then
		local QColl = (Collision(qRNG, qSPD, qDLY, qWTH))
		local willCollide = QColl:GetMinionCollision(unit, myHero)
		if not willCollide and GetDistance(unit) <= qRNG then
			CastSpell(_Q, VipPredTarget.x, VipPredTarget.z)
		end
	end
end

function CastW(unit)
	if wRDY and ValidTarget(unit) then
		CastSpell(_W, myHero)
	end
end

--TODO add hitboxes
function CastProdE(unit)
	if eRDY and ValidTarget(unit) and myHero.mana >= ManaCost(E) then
		EPos = ProdictE:GetPrediction(unit)
		if EPos ~= nil then
			CastSpell(_E, EPos.x, EPos.z)
		end
	end
end

--TODO add hitboxes
function CastVPredE(unit)
	if eRDY and ValidTarget(unit) and myHero.mana >= ManaCost(E) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, eDLY, eWTH, eRNG, eSPD, myHero, false)
		if HitChance >= AutoCarry.PluginMenu.spelloptions.eoptions.EHitChance and GetDistance(CastPosition) <= eRNG then
			CastSpell(_E, CastPosition.x, CastPosition.z)
		end
	end
end

--TODO add hitboxes
function CastVIPE(unit)
	VipPredTarget = ep:GetPrediction(unit)
	if eRDY and ValidTarget(unit) and myHero.mana >= ManaCost(E) and VipPredTarget then
		if GetDistance(unit) <= rRNG then
			CastSpell(_E, VipPredTarget.x, VipPredTarget.z)
		end
	end
end

--TODO add hitboxes
function CastProdR(unit)
	if rRDY and ValidTarget(unit) and StackCheck() and myHero.mana >= ManaCost(R) then
		RPos = ProdictR:GetPrediction(unit)
		if RPos ~= nil then
			CastSpell(_R, RPos.x, RPos.z)
		end
	end
end

--TODO add hitboxes
function CastVPredR(unit)
	if rRDY and ValidTarget(unit) and StackCheck() and myHero.mana >= ManaCost(R) then
		local CastPosition, HitChance, Position = VP:GetCircularCastPosition(unit, rDLY, rWTH, rRNG, rSPD, myHero, false)
		if HitChance >= AutoCarry.PluginMenu.spelloptions.roptions.RHitChance and GetDistance(CastPosition) <= rRNG then
			CastSpell(_R, CastPosition.x, CastPosition.z)
		end
	end
end

--TODO add hitboxes
function CastVIPR(unit)
	VipPredTarget = rp:GetPrediction(unit)
	if rRDY and ValidTarget(unit) and StackCheck() and myHero.mana >= ManaCost(R) and VipPredTarget then
		if GetDistance(unit) <= rRNG then
			CastSpell(_R, VipPredTarget.x, VipPredTarget.z)
		end
	end
end

--[[
		Returns mana cost
		of spells
  ]]
function ManaCost(spell)
	if spell == Q then
		return 60
	elseif spell == E then
		return 70 + (10 * myHero:GetSpellData(_E).level)
	elseif spell == R then
		local mana = 40 + (40 * stacks)
		return mana < 401 and mana or 400
	end
end

--[[
		Calculates and returns the current
		range of KogMaw's Ultimate
  ]]
function GetRRange()
	if myHero:GetSpellData(_R).level == 1 then
		return 1400
	elseif myHero:GetSpellData(_R).level == 2 then
		return 1700
	elseif myHero:GetSpellData(_R).level == 3 then
		return 2200
	else
		return 0
	end
end

--[[
		Calculates and returns the current
		range increase of KogMaw's W
  ]]
function GetWRange()
	if myHero:GetSpellData(_W).level == 1 then
		return 630
	elseif myHero:GetSpellData(_W).level == 2 then
		return 650
	elseif myHero:GetSpellData(_W).level == 3 then
		return 670
	elseif myHero:GetSpellData(_W).level == 4 then
		return 690
	elseif myHero:GetSpellData(_W).level == 5 then
		return 710
	else
		return 0
	end
end

--[[
		Counts the current stacks of
		KogMaw's ultimate
  ]]
function PluginOnProcessSpell(unit, spell)
	if unit.isMe and spell.name:lower():find("kogmawlivingartillery") then
		stacks = stacks + 1
		timer = GetTickCount()
	end
end

--[[
		Checks current stacks of ultimate
		returns boolean
  ]]
function StackCheck()
	if (myHero.level > 5 and myHero.level < 12 and stacks < AutoCarry.PluginMenu.spelloptions.roptions.RStack1)
	or (myHero.level > 11 and myHero.level < 18 and stacks < AutoCarry.PluginMenu.spelloptions.roptions.RStack2)
	or (myHero.level > 17 and stacks < AutoCarry.PluginMenu.spelloptions.roptions.RStack3) then
		return true
	end
end

--[[
		Resets ultimate stacks after
		6 seconds since last casting
  ]]
function StackReset()
	if GetTickCount() > timer + 6500 then 
		stacks = 0
	end
end
