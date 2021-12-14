-- convenient hook for Interface.findWindow or Interface.openWindow
-- we have a persistent ISC_ResultsMgr from which we can call openResults()
-- from code.
function openResults()
	ISC_DataMgr.openWindow("ISC_resultswindow")
end

-- prepare and throw the dice for the skill check.
-- probably this is missing a lot of modifiers from the desktop and effects, maybe even MISC skill addons.
-- ToDo: full and regressive testing on all possible ways to modify a roll.
function checkskill(keyCT, sSkill)
	ISC.dbg("++ISC_resultsmanager:checkskill(): keyCT=["..keyCT.."] sSkill=["..sSkill.."]")

	-- Find the spot in the database where this skill check result will be stored for display in the UI.
	pResult = ISC_DataMgr.getCombantantResultNode(keyCT, sSkill).getPath()

	-- Prepare the roll we'll be using to throw the die.
	local rRoll = {}
	rRoll.aDice = { "d20" } -- ToDo: maybe we should pull this from draginfo.getDieList()
	rRoll.nMod = 0 -- draginfo.getNumberData(), will be updated after figuring PC vs NPC.
	rRoll.sType = "immersive-skill-check" -- needed so the ActionsManager finds the correct onRoll callback, defined below.
	  -- ToDo: make the above string into a persistent variable since we access it twice already in code.
	rRoll.sDesc = "" -- draginfo.getStringData(), will be set after draginfo is set by ActionSkill.perform*Rolld
	rRoll.bSecret = true -- these are immersive, never show the players.
	-- the above roll attributes are defined by FG.  The rest below are custom data payloads passed to async callbacks.
	rRoll.pResult = pResult -- this gets passed on blindly to our onRoll function, that's where the result
	                        -- will be stored for display in the UI.

	-- get a blank draginfo struct, so we can let FG engine automate PC's roll modifier and fancy display string.
	draginfo = ISC_DragMgr.createBaseData()
	draginfo["dbref"] = pResult -- pretty sure this is useless but feels like the right thing to do.

	-- resolve for FG which actor is making the skill check.  This helps the chat window message for the result
	-- to appear from the actor instead of always from the host (DM)
	local rActor = ActorManager.resolveActor("combattracker.list."..keyCT)

	-- just here for referencing the rActor data model during debugging...  wastes cycles so remove on final release.
	for k,v in pairs(rActor) do
		ISC.dbg("  ISC_resultsmanager:checkskill() type(rActor["..k.."])=["..type(v).."]; v["..v.."]")
	end

	-- handle PCs (with skills) from NPCs (who only have abilities).
	PCHasSkill = false
	if rActor["sType"] == "charsheet" then
		-- mostly to get the roll modifier based on effects.  Seems to work
		-- well but this needs better testing for edge cases.
		-- ToDo: if a game session has custom db.xml skill entries with names
		-- matching 5e skills, even though I've overwritten those in ISC data,
		-- this "performRoll" call will ignore that since the charsheet skill
		-- data still references DataCommon.skilldata values directly.  Need
		-- to check that fall back to NPC type skill checks if that's the case.
		nCharSkill = ISC_DataMgr.getCharsheetSkill(rActor["sCreatureNode"],sSkill)
		if nCharSkill ~= nil then
			PCHasSkill = true
			ActionSkill.performRoll(draginfo, rActor, nCharSkill)
			rRoll.nMod = draginfo.getNumberData()
		end
	end
	if rActor["sType"] ~= "charsheet" or not PCHasSkill then
		-- in FG/5e, NPCs don't have skills...
		-- in custom db.xml skill nodes, it's easily possible for PC records to be missing those custom skills...
		-- ... in those cases, fall back on the skill's ability modifier.
		sAbility = ISC_DataMgr.getSkillAbility(sSkill)
		ISC.dbg("  ISC_resultsmanager:checkskill() sAbility=["..sAbility.."]")
		rRoll.nMod = ActorManager5E.getAbilityBonus(rActor, sAbility)
		ISC.dbg("  ISC_resultsmanager:checkskill() rRoll.nMod=["..rRoll.nMod.."]")
		ActionSkill.performNPCRoll(draginfo, rActor, sSkill, rRoll.nMod);
		ISC.dbg("  ISC_resultsmanager:checkskill() rRoll.getNumberData()=["..draginfo.getNumberData().."]")
	end
	-- If the role gets displayed, this is the verbose fancy string to show in front of the result, who did the check and what their modifiers were.
	rRoll.sDesc = draginfo.getStringData()

	-- encapsulate the roll into a throw
	local rThrow = ActionsManager.buildThrow(rSource, {}, rRoll, false);
	-- throw the dice and wait for the callback.
	Comm.throwDice(rThrow);
	ISC.dbg("--ISC_resultsmanager:checkskill()")
end

-- beautify the modifier for display above the result.
function mkBonus(nMod)
	s = ""
	if nMod >= 0 then s = "+" end
	return s..nMod
end

-- this is an asyncronous callback from FGU after the dice have been thrown.
-- everything we need for displaying the result has to be passed to us in
-- one of the three parameters.  rRoll is the best structure to use for this,
-- the throw mechanics will try to pass along unsupported string attributes as
-- faithfully as possible, KISS works well.
function onRoll(rSource, rTarget, rRoll)
	ActionsManager2.decodeAdvantage(rRoll); -- check ADV/DIS modifiers, not sure if it catches all of them or what?  Actually those will be applied in the next step.
	local nTotal = ActionsManager.total(rRoll); -- Apply modifiers and effects to the pure d20 result, and return the modified total.
	ISC.dbg("==ISC_resultsmanager:onRoll()")
	ISC.dbg("==ISC_resultsmanager:onRoll() rRoll.pResult=["..rRoll.pResult.."]")
	ISC.dbg("==ISC_resultsmanager:onRoll() rRoll.nMod=["..rRoll.nMod.."]")
	ISC.dbg("==ISC_resultsmanager:onRoll() nTotal=["..nTotal.."]")
	nResult = ISC_DataMgr.getCombantantResultNode(rRoll.pResult) -- get the database node where the individual result will be stored
	-- and store it...
	nResult.createChild("total","number").setValue(nTotal)
	nResult.createChild("label","string").setValue(mkBonus(rRoll.nMod))
end
