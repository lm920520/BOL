--[[
╔╦╗┌─┐┌─┐┌┬┐┬ ┬ ┬  ╔═╗┌─┐┬─┐┬┌─┬
 ║║├┤ ├─┤ │││ └┬┘  ║  │ │├┬┘├┴┐│
═╩╝└─┘┴ ┴─┴┘┴─┘┴   ╚═╝└─┘┴└─┴ ┴┴
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

if myHero.charName ~= "Corki" then return end

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
local qSPD, wSPD, eSPD, rSPD = 850, 0, 902, 828
local qDLY, wDLY, eDLY, rDLY = 0.5, 0, 0.5, 0.5
local qWTH, wWTH, eWTH, rWTH = 250, 0, 100, 80
local qRDY = (myHero:CanUseSpell(_Q) == READY)
local wRDY = (myHero:CanUseSpell(_W) == READY)
local eRDY = (myHero:CanUseSpell(_E) == READY)
local rRDY = (myHero:CanUseSpell(_R) == READY)
local Prodict = ProdictManager.GetInstance()
local ProdictQ = Prodict:AddProdictionObject(_Q, qRNG, qSPD, qDLY, qWTH)
local ProdictE = Prodict:AddProdictionObject(_E, eRNG, eSPD, eDLY, eWTH)
local ProdictR = Prodict:AddProdictionObject(_R, rRNG, rSPD, rDLY, rWTH)
local ProdictRFastCol = FastCol(ProdictR)
local ProdictRCol = Collision(rRNG, rSPD, rDLY, rWTH)
local VipPredTarget
local qp = TargetPredictionVIP(qRNG, qSPD, qDLY, qWTH)
local ep = TargetPredictionVIP(eRNG, eSPD, eDLY, eWTH)
local rp = TargetPredictionVIP(rRNG, rSPD, rDLY, rWTH)
local VP = VPrediction()
local Version = 1.00

function PluginOnLoad()
	Menu()
	qRNG, wRNG, eRNG, rRNG = AutoCarry.PluginMenu.spelloptions.qoptions.QRNG, AutoCarry.PluginMenu.spelloptions.woptions.WRNG, AutoCarry.PluginMenu.spelloptions.eoptions.ERNG, AutoCarry.PluginMenu.spelloptions.roptions.RRNG
	PrintChat("Deadly Corki version version 1.00 by CCONN")
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
	AutoCarry.PluginMenu:addParam("sep", "Deadly Corki by CCONN", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("sep", "Version: 1.00", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu:addParam("sep", "www.facebook.com/CCONN81", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("Q: Phosphorous Bomb", "qoptions")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("W: Valkyrie", "woptions")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("E: Gatling Gun", "eoptions")
	AutoCarry.PluginMenu.spelloptions:addSubMenu("R: Missile Barrage", "roptions")
	
--[[
		Auto Carry Sub Menu
  ]]
	AutoCarry.PluginMenu.autocarry:addParam("ACuseQ", "Q: Phosphorous Bomb", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.autocarry:addParam("ACuseE", "E: Gatling Gun", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.autocarry:addParam("ACuseR", "R: Missile Barrage", SCRIPT_PARAM_ONOFF, true)

--[[
		Mixed Mode Sub Menu
  ]]
	AutoCarry.PluginMenu.mixedmode:addParam("MMuseQ", "Q: Phosphorous Bomb", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("MMuseE", "E: Gatling Gun", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.mixedmode:addParam("MMuseR", "R: Missile Barrage", SCRIPT_PARAM_ONOFF, true)
	
--[[
		Lane Clear Sub Menu
  ]]
	AutoCarry.PluginMenu.laneclear:addParam("LCuseQ", "Q: Phosphorous Bomb", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.laneclear:addParam("LCuseE", "E: Gatling Gun", SCRIPT_PARAM_ONOFF, true)
	AutoCarry.PluginMenu.laneclear:addParam("LCuseR", "R: Missile Barrage", SCRIPT_PARAM_ONOFF, true)
	
--[[
		Spell Options Sub Menu
  ]]
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QRNG", "Range", SCRIPT_PARAM_SLICE, 825, 0, 825, 0)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QMANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QOrder", "Cast Order: ", SCRIPT_PARAM_LIST, 4, {"First", "Second", "Third", "Fourth"})
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QPrediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QHitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	AutoCarry.PluginMenu.spelloptions.qoptions:addParam("QHitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
	
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.woptions:addParam("sep", "No options for this currently", SCRIPT_PARAM_INFO, "")
	
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("ERNG", "Range", SCRIPT_PARAM_SLICE, 600, 0, 600, 0)
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("EMANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("EOrder", "Cast Order: ", SCRIPT_PARAM_LIST, 2, {"First", "Second", "Third", "Fourth"})
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("EPrediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("EHitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	AutoCarry.PluginMenu.spelloptions.eoptions:addParam("EHitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
	
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", ">> General Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RRNG", "Range", SCRIPT_PARAM_SLICE, 1225, 0, 1225, 0)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RMANA", "Mana Threshold", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("ROrder", "Cast Order: ", SCRIPT_PARAM_LIST, 3, {"First", "Second", "Third", "Fourth"})
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", " ", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("sep", ">> Prediction Options <<", SCRIPT_PARAM_INFO, "")
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RPrediction", "Choose Prediction: ", SCRIPT_PARAM_LIST, 1, {"VPrediction", "Prodiction", "VIP Prediction"})
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RHitChance", "VPredict Hit Chance", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RCollision", "Choose Collision: ", SCRIPT_PARAM_LIST, 1, {"Fast Collision", "Collision"})
	AutoCarry.PluginMenu.spelloptions.roptions:addParam("RHitBox", "Use Hitboxes", SCRIPT_PARAM_ONOFF, true)
	
	
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
		if qRDY and Menu1.ACuseQ and GetDistance(Target) <= qRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.qoptions.QMANA / 100) then
				if Menu2.qoptions.QPrediction == 1 then CastVPredQ(Target) end
				if Menu2.qoptions.QPrediction == 2 then CastProdQ(Target) end
				if Menu2.qoptions.QPrediction == 3 then CastVIPQ(Target) end
			end
		end
		if eRDY and Menu1.ACuseE and GetDistance(Target) <= eRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.eoptions.EMANA / 100) then
				if Menu2.eoptions.EPrediction == 1 then CastVPredE(Target) end
				if Menu2.eoptions.EPrediction == 2 then CastProdE(Target) end
				if Menu2.eoptions.EPrediction == 3 then CastVIPE(Target) end
			end
		end
		if rRDY and Menu1.ACuseR and GetDistance(Target) <= rRNG then 
			if myHero.mana >= myHero.maxMana * (Menu2.roptions.RMANA / 100) then
				if Menu2.roptions.RPrediction == 1 then CastVPredR(Target) end
				if Menu2.roptions.RPrediction == 2 then CastProdR(Target) end
				if Menu2.roptions.RPrediction == 3 then CastVIPR(Target) end
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
		if qRDY and Menu1.MMuseQ and GetDistance(Target) <= qRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.qoptions.QMANA / 100) then
				if Menu2.qoptions.QPrediction == 1 then CastVPredQ(Target) end
				if Menu2.qoptions.QPrediction == 2 then CastProdQ(Target) end
				if Menu2.qoptions.QPrediction == 3 then CastVIPQ(Target) end
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
		if qRDY and Menu1.LCuseQ and GetDistance(Target) <= qRNG then
			if myHero.mana >= myHero.maxMana * (Menu2.qoptions.QMANA / 100) then
				if Menu2.qoptions.QPrediction == 1 then CastVPredQ(Target) end
				if Menu2.qoptions.QPrediction == 2 then CastProdQ(Target) end
				if Menu2.qoptions.QPrediction == 3 then CastVIPQ(Target) end
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
	end
end

--TODO add hitboxes
function CastProdQ(unit)
	if qRDY and ValidTarget(unit) and myHero.mana >= ManaCost(Q) then
		QPos = ProdictQ:GetPrediction(unit)
		if QPos ~= nil then
			CastSpell(_Q, QPos.x, QPos.z)
		end
	end
end

--TODO add hitboxes
function CastVPredQ(unit)
	if qRDY and ValidTarget(unit) and myHero.mana >= ManaCost(Q) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, qDLY, qWTH, qRNG, qSPD, myHero, false)
		if HitChance >= AutoCarry.PluginMenu.spelloptions.qoptions.QHitChance and GetDistance(CastPosition) <= qRNG then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

--TODO add hitboxes
function CastVIPQ(unit)
	VipPredTarget = qp:GetPrediction(Target)
	if qRDY and ValidTarget(unit) and myHero.mana >= ManaCost(Q) and VipPredTarget and GetDistance(unit) <= qRNG then
		CastSpell(_Q, VipPredTarget.x, VipPredTarget.z)
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
		if HitChance >= AutoCarry.PluginMenu.spelloptions.eoptions.EHitChance and GetDistance(unit) <= eRNG then
			CastSpell(_E, CastPosition.x, CastPosition.z)
		end
	end
end

--TODO add hitboxes
function CastVIPE(unit)
	VipPredTarget = ep:GetPrediction(unit)
	if eRDY and ValidTarget(unit) and myHero.mana >= ManaCost(E) and VipPredTarget then
		if GetDistance(unit) <= eRNG then
			CastSpell(_E, VipPredTarget.x, VipPredTarget.z)
		end
	end
end

--TODO add hitboxes
function CastProdR(unit)
	if rRDY and ValidTarget(unit) and myHero.mana >= ManaCost(R) then
		RPos = ProdictR:GetPrediction(unit)
		if RPos ~= nil then
			if AutoCarry.PluginMenu.spelloptions.roptions.RCollision == 1 then
				local willCollide = ProdictRFastCol:GetMinionCollision(RPos, myHero)
				if not willCollide then CastSpell(_R, RPos.x, RPos.z) end
			elseif AutoCarry.PluginMenu.spelloptions.roptions.RCollision == 2 then
				local willCollide = ProdictRCol:GetMinionCollision(RPos, myHero)
				if not willCollide then CastSpell(_R, Rpos.x, RPos.z) end
			end
		end
	end
end

--TODO add hitboxes
function CastVPredR(unit)
	if rRDY and ValidTarget(unit) and myHero.mana >= ManaCost(R) then
		local CastPosition, HitChance, Position = VP:GetLineCastPosition(unit, rDLY, rWTH, rRNG, rSPD, myHero, true)
		if HitChance >= AutoCarry.PluginMenu.spelloptions.roptions.RHitChance and GetDistance(CastPosition) <= rRNG then
			CastSpell(_R, CastPosition.x, CastPosition.z)
		end
	end
end

--TODO add hitboxes
function CastVIPR(unit)
	VipPredTarget = rp:GetPrediction(unit)
	if rRDY and ValidTarget(unit) and myHero.mana >= ManaCost(R) and VipPredTarget then
		if GetDistance(unit) <= rRNG then
			local RColl = (Collision(rRNG, rSPD, rDLY, rWTH))
			local willCollide = RColl:GetMinionCollision(unit, myHero)
			if not willCollide and GetDistance(unit) <= rRNG then
				CastSpell(_R, VipPredTarget.x, VipPredTarget.z)
			end
		end
	end
end

--[[
		Returns mana cost
		of spells
  ]]
function ManaCost(spell)
	if spell == Q then
		return 50 + (10 * myHero:GetSpellData(_Q).level)
	elseif spell == E then
		return 50
	elseif spell == R then
		return 20
	end
end