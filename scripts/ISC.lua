DEBUG = false;
DEFAULTS = {"Arcana", "History", "Insight", "Perception", "Religion", "Stealth", "Survival" }

datacommon_data = "ISC.datacommon_data"
dbskill_data    = "skill"
immskill_titles = "ISC.immskill_titles"

function dbg(...) if ISC.DEBUG then print("[ISC] "..unpack(arg)) end end

--------------------------------------------------------------------------------
-- Skill Selection
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
function buildDatacommonData()
	ISC.dbg("++ISC:buildDatacommonData()")
	nDatacommonData = DB.createNode(ISC.datacommon_data)
	for sSkill,tSkill in pairs(DataCommon.skilldata) do
		ISC.dbg("  ISC:buildDatacommonData(): sSkill=["..sSkill.."]")
		nDatacommonData.createChild(sSkill).createChild("name","string").setValue(sSkill)
	end
	ISC.dbg("--ISC:buildDatacommonData()")
end

--------------------------------------------------------------------------------
function setSourceDefaults(pSource, defaults)
	ISC.dbg("++ISC:setSourceDefaults(): pSource=["..pSource.."]")
	for _,nSkilldata in pairs(DB.getChildren(pSource)) do
		sSkill = nSkilldata.getChild("name").getValue()
		ISC.dbg("  ISC:setSourceDefaults(): sSkill=["..sSkill.."]")
		nSkilldata.createChild("immersive", "number").setValue(defaults[sSkill] or 0)
	end
	ISC.dbg("--ISC:setSourceDefaults()")
end

--------------------------------------------------------------------------------
function setDefaults()
	ISC.dbg("++ISC:setDefaults()")
	buildDatacommonData()
	_defaults = {}
	for _,s in ipairs(DEFAULTS) do _defaults[s] = 1 end
	setSourceDefaults(ISC.datacommon_data, _defaults)
	setSourceDefaults(ISC.dbskill_data, _defaults)
	ISC.dbg("--ISC:setDefaults()")
end

--------------------------------------------------------------------------------
function updateImmskillSelection(sSkill, bImmersive)
	ISC.dbg("++ISC:updateImmskillSelection() sSkill=["..sSkill.."]")
	nTitles = DB.createNode(ISC.immskill_titles)
	if bImmersive then
		ISC.dbg("  ISC:updateImmskillSelection() bImmersive=[true]")
		nSkill = DB.createChild(nTitles, sSkill).createChild("name","string").setValue(sSkill)
	else
		ISC.dbg("  ISC:updateImmskillSelection() bImmersive=[false]")
		DB.deleteChild(ISC.immskill_titles, sSkill)
	end
	ISC.dbg("--ISC:updateImmskillSelection()")
end

--------------------------------------------------------------------------------
-- Main Entry Point
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
function onInit()
	ISC.dbg("++ISC:onInit()");
	if User.isHost() then
		if DB.findNode(ISC.datacommon_data) == nil then
			ISC.setDefaults()
		end
		tButton = {}
		tButton["tooltipres"] = "ISC_resultswindow_title"
		tButton["class"]      = "immersive_results"
		tButton["path"]       = "ISC"
		DesktopManager.registerSidebarToolButton(tButton)
		ActionsManager.registerResultHandler("ISC", iscThrowMgr.onRoll) -- if rRoll["sType"] == "ISC" then call iscThrowMgr.onRoll after throwing dice.
		DB.addHandler("combattracker.round","onUpdate",iscThrowMgr.doRoundChange)
		-- Interface.openWindow("immersive_results", "ISC")
	end
	ISC.dbg("--ISC:onInit()");
end
