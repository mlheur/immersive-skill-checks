--------------------------------------------------------------------------------
-- PRE Callback
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
function doRoundChange()
	ISC.dbg("++iscThrowMgr:doRoundChange()")    
	bAutoroll = DB.getValue("ISC.bAutoroll")
	if bAutoroll ~= nil and bAutoroll ~= 0 then
        wResults = Interface.findWindow("immersive_results","ISC")
        if wResults then
            wResults["rollnow"].onButtonPress()
        else
            DB.createChild("ISC", "bPendingRoll", "number").setValue(1)
        end
	end
	ISC.dbg("--iscThrowMgr:doRoundChange()")    
end

--------------------------------------------------------------------------------
function mkRoll(nResult)
	ISC.dbg("++iscThrowMgr:mkRoll()")    
	local r = {}
	r["aDice"]   = { "d20" } -- lookup? put a d20 in the XML?
	r["nMod"]    = 0 -- will be set after resolving actor type and looking up their ability
	r["sType"]   = "ISC" -- must match ActionsManager.registerResultHandler("ISC", ...) for our callback to be called
	r["sDesc"]   = "" -- draginfo.getStringData(), will be set after draginfo is set by ActionSkill.perform*Rolld
	r["bSecret"] = true -- these are immersive, never show the players.
	r["pResult"] = nResult.getPath() -- this gets passed on blindly to our onRoll function
	ISC.dbg("--iscThrowMgr:mkRoll()")    
	return r
end

--------------------------------------------------------------------------------
function throwDice(nResult)
	ISC.dbg("++iscThrowMgr:throwDice()")    
	if nResult == nil then
		ISC.dbg("--iscThrowMgr:throwDice(): got nil, bailing")
		return
	end
	local rActor = ActorManager.resolveActor(nResult.getParent().getParent())
	local rThrow = ActionsManager.buildThrow(rActor, {}, mkRoll(nResult), false);
    nResult.getChild("total").setValue(99)
    nResult.getChild("label").setValue("[**]")
	Comm.throwDice(rThrow);
	ISC.dbg("--iscThrowMgr:throwDice()")    
end

--------------------------------------------------------------------------------
-- POST Callback
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- beautify the modifier for display above the result.
function mkBonus(nMod)
	s = ""
	if nMod >= 0 then s = "+" end
	return s..nMod
end

--------------------------------------------------------------------------------
function getCharsheetSkill(pCharsheet, sSkill)
	ISC.dbg("++iscThrowMgr:getCharsheetSkill(): pCharsheet=["..pCharsheet.."], sSkill=["..sSkill.."]")
    nCharsheet = DB.findNode(pCharsheet)
    if nCharsheet == nil then return nil end
    nSkilllist = nCharsheet.getChild("skilllist")
    if nSkilllist == nil then return nil end
    for key,nCharsheetSkill in pairs(nSkilllist.getChildren()) do
        if nCharsheetSkill.getChild("name").getValue() == sSkill then return nCharsheetSkill end
    end
	ISC.dbg("--iscThrowMgr:getCharsheetSkill(): return nil out the bottom")
    return nil
end

--------------------------------------------------------------------------------
function getPCBonus(rActor, sSkill)
    if rActor["sType"] ~= "charsheet" then return nil end
    nCharSkill = getCharsheetSkill(rActor["sCreatureNode"],sSkill)
    if nCharSkill == nil then return nil end
    draginfo = DragData.createBaseData()
    ActionSkill.performRoll(draginfo, rActor, nCharSkill)
    return draginfo.getNumberData()
end

--------------------------------------------------------------------------------
function getSkillAbility(sSkill)
	ISC.dbg("++iscThrowMgr:getSkillAbility(): sSkill=["..sSkill.."]")
    -- run the local list first, override DataCommon if there's one with the same name
    for kSkill,nSkill in pairs(DB.getChildren(ISC.dbskill_data)) do
        if nSkill.getChild("name").getValue() == sSkill then
            nStat = nSkill.getChild("stat")
            if nStat == nil then
                ISC.dbg("--iscThrowMgr:getSkillAbility(): from ISC.dbskill_data return 0, skill has no stat block")
                return 0
            end
        	ISC.dbg("--iscThrowMgr:getSkillAbility(): from ISC.dbskill_data return nStat.getValue():lower()")
            return nStat.getValue():lower()
        end
    end
    for sName,tSkill in pairs(DataCommon.skilldata) do
        if sName == sSkill then
        	ISC.dbg("--iscThrowMgr:getSkillAbility(): from DataCommon.skilldata return tSkill[stat]:lower()")
            return tSkill["stat"]:lower()
        end
    end
    ISC.dbg("--iscThrowMgr:getSkillAbility(): return nil out the bottom")
end

--------------------------------------------------------------------------------
-- this is an asyncronous callback from FGU after the dice have been thrown.
-- everything we need for displaying the result has to be passed to us in
-- one of the three parameters.  rRoll is the best structure to use for this,
-- the throw mechanics will try to pass along unsupported string attributes as
-- faithfully as possible, KISS works well.
function onRoll(rSource, rTarget, rRoll)
    local sSkill = DB.findNode(rRoll.pResult).getChild("name").getValue()
    rRoll.nMod = getPCBonus(rSource, sSkill) or (ActorManager5E.getAbilityBonus(rSource, getSkillAbility(sSkill)) or 0)

    ActionsManager2.decodeAdvantage(rRoll); -- check and update ADV/DIS modifiers in rRoll struct, not sure if it catches all of them or what?
    local nTotal = ActionsManager.total(rRoll); -- Apply modifiers and effects to the pure d20 result, and return the modified total.

	ISC.dbg("==ISC_resultsmanager:onRoll() sSkill=["..sSkill.."], rRoll.nMod=["..rRoll.nMod.."], nTotal=["..nTotal.."]")
	nResult = DB.findNode(rRoll.pResult)
	nResult.getChild("label").setValue(mkBonus(rRoll.nMod))
	nResult.getChild("total").setValue(nTotal)
end