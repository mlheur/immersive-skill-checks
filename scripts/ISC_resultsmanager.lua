function openResults()
	ISC_DataMgr.openWindow("ISC_resultswindow", ISC.DBPATH)
end

function clearResults()
    DB.deleteChildren(ISC.RESULTS)
end

function addCombatant(keyCT, nodeCT)
	local pathCT = nodeCT.getPath()
	local name = DB.getValue(pathCT .. ".name")
	local pCombatant = ISC.RESULTS .. "." .. keyCT
	local nCombatant = DB.createNode(pCombatant)
	nCombatant.createChild("name", "string").setValue(name)
	nCombatant.createChild("pathCT", "string").setValue(pathCT)
	nTokenISC = nCombatant.createChild("token")
	nTokenCT = nodeCT.getChild("token")
	DB.copyNode(nTokenCT, nTokenISC)
	DB.deleteChildren(pCombatant .. ".results")
	return nCombatant
end

_path = ""
function checkskill(nCombatant, sSkill, wCombatant)
	local pCombatant = nCombatant.getPath()
	local pathCT = nCombatant.getChild("pathCT").getValue()
	pSkill = pCombatant .. ".results." .. sSkill
	nSkill = DB.createNode(pSkill)
	nSkill.createChild("label", "string").setValue("bonus")
	nSkill.createChild("total", "number").setValue("42")

	ISC.dbg("==ISC_resultsmanager:checkskill() sSkill=["..sSkill.."],  pathCT=["..pathCT.."]")

	sAbility = DataCommon.skilldata[sSkill]["stat"]
	sLookup = DataCommon.skilldata[sSkill]["lookup"]

	local rActor = ActorManager.resolveActor(pathCT)
	local sActor = rActor["sCreatureNode"]
	local nActor = DB.findNode(sActor)
	for k,v in pairs(rActor) do
		ISC.dbg("==ISC_resultsmanager:checkskill() type(rActor["..k.."])=["..type(v).."]; v["..v.."]")
	end

	local nMod, bADV, bDIS, sAddText = ActorManager5E.getCheck(rActor, sAbility, sSkill);
	ISC.dbg("                                   nMod=["..nMod.."]")
	if bADV then ISC.dbg("                                   bADV=[true]") end
	if bDIS then ISC.dbg("                                   bDIS=[true]") end
	ISC.dbg("                                   sAddText=["..sAddText.."]")
	draginfo = ISC_DragData.createBaseData("")

	if rActor["sType"] == "charsheet" then
		nCharSkill = ISC_DataMgr.getCharSkillNode(sActor,sSkill)
		nMod = nCharSkill.getChild("total").getValue()
		ActionSkill.performRoll(draginfo, rActor, nCharSkill)
	else
		ActionSkill.performNPCRoll(draginfo, rActor, sSkill, nMod);
	end

	local rRoll = {}
	rRoll.aDice = { "d20" }
	rRoll.nMod = nMod
	rRoll.sType = "immersive-skill-check"
	rRoll.sDesc = draginfo.getStringData()
	rRoll.bSecret = true
	rRoll.pSkill = pSkill

	local rThrow = ActionsManager.buildThrow(rSource, {}, rRoll, false);
	Comm.throwDice(rThrow);

	prefix = ""
	if nMod >= 0 then prefix = "+" end
	nSkill.createChild("label", "string").setValue(prefix .. nMod)
end

function onRoll(rSource, rTarget, rRoll)
	ISC.dbg("==ISC_resultsmanager:onRoll()")
	ActionsManager2.decodeAdvantage(rRoll);
	local nTotal = ActionsManager.total(rRoll);
	ISC.dbg("==== nTotal ["..nTotal.."]")
	ISC.dbg("==== _path ["..rRoll.pSkill.."]")
	DB.findNode(rRoll.pSkill).getChild("total").setValue(nTotal)
end
