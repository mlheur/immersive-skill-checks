function openResults()
	ISC_DataMgr.openWindow("ISC_resultswindow")
end

function checkskill(keyCT, sSkill)
	ISC.dbg("==ISC_resultsmanager:checkskill(): keyCT=["..keyCT.."] sSkill=["..sSkill.."]")

	pResult = ISC_DataMgr.getCombantantResultNode(keyCT, sSkill).getPath()

	draginfo = ISC_DragMgr.createBaseData()
	draginfo["dbref"] = pResult
	local rActor = ActorManager.resolveActor("combattracker.list."..keyCT)
	for k,v in pairs(rActor) do
		ISC.dbg("==ISC_resultsmanager:checkskill() type(rActor["..k.."])=["..type(v).."]; v["..v.."]")
	end
	if rActor["sType"] == "charsheet" then
		ActionSkill.performRoll(draginfo, rActor, ISC_DataMgr.getCharsheetSkill(rActor["sCreatureNode"],sSkill))
	else
		ActionSkill.performNPCRoll(draginfo, rActor, sSkill, nMod);
	end

	local rRoll = {}
	rRoll.aDice = { "d20" }
	rRoll.nMod = draginfo.getNumberData()
	rRoll.sType = "immersive-skill-check"
	rRoll.sDesc = draginfo.getStringData()
	rRoll.bSecret = true
	rRoll.pResult = pResult

	local rThrow = ActionsManager.buildThrow(rSource, {}, rRoll, false);
	Comm.throwDice(rThrow);
end

function mkBonus(nMod)
	s = ""
	if nMod >= 0 then s = "+" end
	return s..nMod
end

function onRoll(rSource, rTarget, rRoll)
	ActionsManager2.decodeAdvantage(rRoll);
	local nTotal = ActionsManager.total(rRoll);
	ISC.dbg("==ISC_resultsmanager:onRoll()")
	ISC.dbg("==ISC_resultsmanager:onRoll() rRoll.pResult=["..rRoll.pResult.."]")
	ISC.dbg("==ISC_resultsmanager:onRoll() rRoll.nMod=["..rRoll.nMod.."]")
	ISC.dbg("==ISC_resultsmanager:onRoll() nTotal=["..nTotal.."]")
	nResult = ISC_DataMgr.getCombantantResultNode(rRoll.pResult)
	nResult.createChild("total","number").setValue(nTotal)
	nResult.createChild("label","string").setValue(mkBonus(rRoll.nMod))
end
