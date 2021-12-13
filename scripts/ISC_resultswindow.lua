function onInit()
	ISC.dbg("++ISC_resultswindow:onIint()");
	-- set callbacks for UI elements.
	self["ISC_label_autoroll"].onButtonPress   = toggleAutoRoll;
	self["ISC_button_rollnow"].onButtonPress   = rollNow;
	self["ISC_button_skillset"].onButtonPress  = ISC_SkillsMgr.openSkillSetSelection;
	-- keep track if we used rollNow() to redraw each character's last roll result
	bDrawn = false
	-- if the round changed while the window was closed
	thisRound = ISC_DataMgr.getRound()
	ISC.dbg("  ISC_resultswindow:onIint() lastRound=["..ISC.lastRoundRolled.."] thisRound=["..thisRound.."]")
	if ISC.lastRoundRolled ~= thisRound then
		-- and if autoroll is enabled
		if ISC_DataMgr.getAutoRoll() then
			-- time to make a new set of immersive skill checks.
			bDrawn = true
			rollNow()
		end
	end
	-- reassociate the matrix after the UI is opened;
	-- those associations were lost when the window was closed and UI elements destroyed.
	if not bDrawn then redraw() end
	ISC.dbg("--ISC_resultswindow:onIint()");
end

-- When dealing with two degrees of freedom, we can't have any simple list associated to UI display objects.
-- We need to interpolate the skill with the character, and the output differs when we do skills first or characters first...
-- Also, the way FG works, UI data gets destroyed when a window is closed.  My way to deal with these nuances,
-- When the window reopens, re-walk the characters, get the data source where _that_ character's results are stored,
-- reassociate that character's UI results with their DB results.
-- Said another way, I'm turning a series of many lists into a single matrix.  I then have to tell the UI which
-- row of the matrix is associated with each character.  The columns will sort themselves out once the rows
-- are identified.
function redraw()
	for i,wResultsChar in pairs(self["ISC_results_list"].getWindows()) do
		keyCT = wResultsChar.getDatabaseNode().getName()
		wResultsChar["ISC_results_skillresult_list"].setDatabaseNode(ISC_DataMgr.getCombatantResultList(keyCT))
	end
end

-- walk the matrix and perform a skill check for each [character,skill] entry.
function rollNow()
	ISC.dbg("++ISC_resultswindow:rollNow()")
	-- when autorolling, keep track of which round we last rolled on; helps prevent double rolling during a single round.
	ISC.lastRoundRolled = ISC_DataMgr.getRound()
	-- ToDo: should not have to happen on each roll, but need to test all other cases do resetTitles before removing the sledghammer approach.
	aTitles = ISC_DataMgr.resetTitles()
	-- remove any previous results, helps ensure new check results get loaded; makes misses obvious (no bonus details, and result is 0)
	ISC_DataMgr.clearResults()
	-- necessary to reassociate the matrix after wiping the DB nodes where UI was getting its results from.
	redraw()
	-- for each character, for each skill, check() and display the result.
	for i,wResultsChar in pairs(self["ISC_results_list"].getWindows()) do
		for sSkill,vSkill in pairs(aTitles) do
			nResult = ISC_ResultsMgr.checkskill(wResultsChar.getDatabaseNode().getName(), sSkill)
		end
	end

	ISC.dbg("--ISC_resultswindow:rollNow()")
end

-- In the UI, the little tickbox works automatically.  This is used
-- by the faux button(label) beside the tickbox to manipulate the tickbox value.
function toggleAutoRoll()
	ISC.dbg("++ISC_results:toggleAutoRoll()")
	self["ISC_bAutoRoll"].setValue(self["ISC_bAutoRoll"].getValue()+1);
	ISC.dbg("--ISC_results:toggleAutoRoll()")
end