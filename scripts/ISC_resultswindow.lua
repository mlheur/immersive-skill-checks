function onInit()
	ISC.dbg("++ISC_resultswindow:onIint()");
	self["ISC_label_autoroll"].onButtonPress   = toggleAutoRoll;
	self["ISC_button_rollnow"].onButtonPress   = rollNow;
	self["ISC_button_skillset"].onButtonPress  = ISC_SkillsMgr.openSkillSetSelection;
	thisRound = ISC_DataMgr.getRound()
	ISC.dbg("  ISC_resultswindow:onIint() lastRound=["..ISC.lastRoundRolled.."] thisRound=["..thisRound.."]")
	bDrawn = false
	if ISC.lastRoundRolled ~= thisRound then
		if ISC_DataMgr.getAutoRoll() then
			bDrawn = true
			rollNow()
		end
	end
	if not bDrawn then redraw() end
	ISC.dbg("--ISC_resultswindow:onIint()");
end

function redraw()
	for i,wResultsChar in pairs(self["ISC_results_list"].getWindows()) do
		keyCT = wResultsChar.getDatabaseNode().getName()
		wResultsChar["ISC_results_skillresult_list"].setDatabaseNode(ISC_DataMgr.getCombatantResultList(keyCT))
	end
end

function rollNow()
	ISC.dbg("++ISC_resultswindow:rollNow()")
	ISC.lastRoundRolled = ISC_DataMgr.getRound()
	aTitles = ISC_DataMgr.resetTitles()
	ISC_DataMgr.clearResults()
	redraw()
	-- create a row for each character in CT
	for i,wResultsChar in pairs(self["ISC_results_list"].getWindows()) do
		for sSkill,vSkill in pairs(aTitles) do
			nResult = ISC_ResultsMgr.checkskill(wResultsChar.getDatabaseNode().getName(), sSkill)
		end
	end

	ISC.dbg("--ISC_resultswindow:rollNow()")
end

function toggleAutoRoll()
	ISC.dbg("++ISC_results:toggleAutoRoll()")
	self["ISC_bAutoRoll"].setValue(self["ISC_bAutoRoll"].getValue()+1);
	ISC.dbg("--ISC_results:toggleAutoRoll()")
end