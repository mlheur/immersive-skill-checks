function onInit()
	ISC.dbg("++ISC_resultswindow:onIint()");
	self["ISC_label_autoroll"].onButtonPress   = toggleAutoRoll;
	self["ISC_button_rollnow"].onButtonPress   = rollNow;
	self["ISC_button_skillset"].onButtonPress  = ISC_SkillsMgr.openSkillSetSelection;
	thisRound = DB.getValue("combattracker.round")
	ISC.dbg("  ISC_resultswindow:onIint() lastRound=["..ISC.lastRoundRolled.."] thisRound=["..thisRound.."]")
	if ISC.lastRoundRolled ~= thisRound then
		if self["ISC_bAutoRoll"].getValue() ~= 0 then
			rollNow()
		end
	end
	ISC.dbg("--ISC_resultswindow:onIint()");
end

function rollNow()
	ISC.dbg("++ISC_resultswindow:rollNow()")

	ISC.lastRoundRolled = DB.getValue("combattracker.round")
	ISC_DataMgr.resetTitles()
	ISC_ResultsMgr.clearResults()
	
	-- create a row for each character in CT
	for keyCT, nodeCT in pairs(CombatManager.getCombatantNodes()) do
		nCombatant = ISC_ResultsMgr.addCombatant(keyCT, nodeCT)
		pCombatant = nCombatant.getPath()
		ISC.dbg("checking: next character pCombatant=["..pCombatant.."]")

		wCombatant = ISC.findWindow(self["ISC_results_list"], pCombatant)
		wCombatant["ISC_results_skillresult_list"].setDatabaseNode(pCombatant .. ".results")
		for sSkill,vSkill in pairs(immskills) do
			if vSkill["immersive"] ~= 0 then
				nResult = ISC_ResultsMgr.checkskill(nCombatant, sSkill, wCombatant)
			end
		end
	end

	ISC.dbg("--ISC_resultswindow:rollNow()")
end

function toggleAutoRoll()
	ISC.dbg("++ISC_results:toggleAutoRoll()")
	self["ISC_bAutoRoll"].setValue(self["ISC_bAutoRoll"].getValue()+1);
	ISC.dbg("--ISC_results:toggleAutoRoll()")
end