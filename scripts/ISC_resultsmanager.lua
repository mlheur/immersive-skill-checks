function openResults()
	ISC_DataMgr.openWindow("ISC_resultswindow")
end

function checkskill(keyCT, sSkill)
	ISC.dbg("++ISC_resultsmanager:checkskill(): keyCT=["..keyCT.."] sSkill=["..sSkill.."]")

	pResult = ISC_DataMgr.getCombantantResultNode(keyCT, sSkill).getPath()

	local rRoll = {}
	rRoll.aDice = { "d20" }
	rRoll.nMod = 0 -- draginfo.getNumberData(), will be updated after figuring PC vs NPC.
	rRoll.sType = "immersive-skill-check"
	rRoll.sDesc = "" -- draginfo.getStringData(), will be set after draginfo is set by ActionSkill.perform*Rolld
	rRoll.bSecret = true
	rRoll.pResult = pResult

	draginfo = ISC_DragMgr.createBaseData()
	draginfo["dbref"] = pResult
	local rActor = ActorManager.resolveActor("combattracker.list."..keyCT)
	-- just here for referencing the rActor data model during debugging...
	for k,v in pairs(rActor) do
		ISC.dbg("  ISC_resultsmanager:checkskill() type(rActor["..k.."])=["..type(v).."]; v["..v.."]")
	end
	if rActor["sType"] == "charsheet" then
		ActionSkill.performRoll(draginfo, rActor, ISC_DataMgr.getCharsheetSkill(rActor["sCreatureNode"],sSkill))
		rRoll.nMod = draginfo.getNumberData()
	else
		-- in FG/5e, NPCs don't have skills, they rely on the modifier for the ability the skill is based on.
		sAbility = DataCommon.skilldata[sSkill]["stat"]
		ISC.dbg("  ISC_resultsmanager:checkskill() sAbility=["..sAbility.."]")
		rRoll.nMod = ActorManager5E.getAbilityBonus(rActor, sAbility)
		ISC.dbg("  ISC_resultsmanager:checkskill() rRoll.nMod=["..rRoll.nMod.."]")
		ActionSkill.performNPCRoll(draginfo, rActor, sSkill, rRoll.nMod);
		ISC.dbg("  ISC_resultsmanager:checkskill() rRoll.getNumberData()=["..draginfo.getNumberData().."]")
	end
	rRoll.sDesc = draginfo.getStringData()

	local rThrow = ActionsManager.buildThrow(rSource, {}, rRoll, false);
	Comm.throwDice(rThrow);
	ISC.dbg("--ISC_resultsmanager:checkskill()")
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
