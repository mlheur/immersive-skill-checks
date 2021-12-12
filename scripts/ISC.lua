DEBUG = true;

DBPATH = "ISC";
SKILLS = DBPATH..".immersive-selection";
TITLES = DBPATH..".skillchecks"
DEFAULTS = {"Arcana","History","Insight","Perception","Religion","Stealth","Survival"};
lastRoundRolled = -1

function dbg(...) if ISC.DEBUG then print(unpack(arg)) end end

function initHandlers()
	DB.addHandler(ISC.SKILLS..".*.immersive", "onUpdate", ISC_DataMgr.resetTitles)
	DB.addHandler("combattracker.round", "onUpdate", doAutoRoll )
	ActionsManager.registerResultHandler("immersive-skill-check", ISC_ResultsMgr.onRoll)
end

function doAutoRoll(nUpdated)
	wResultsWindow = Interface.findWindow("ISC_resultswindow", ISC.DBPATH)
	if wResultsWindow == nil then return end
	if wResultsWindow["ISC_bAutoRoll"].getValue() == 0 then return end
	wResultsWindow.rollNow()
end

function onInit()
	ISC.dbg("++ISC:onInit()");
	if User.isHost() then
		initHandlers()
		if DB.getChild(ISC.SKILLS) == nil then
			ISC_SkillsMgr.setDefaultImmersiveSkills();
		end
		DesktopManager.registerDockShortcut(
			"ISC_button_up",
			"ISC_button_dn",
			"Immersion",
			"ISC_resultswindow",
			ISC.DBPATH,
			0
		);
		ISC_ResultsMgr.openResults()
	end
	ISC.dbg("--ISC:onInit()");
end

function findWindow(windowlist,dbPath)
	ISC.dbg("==ISC:findWindow(): dbPath=["..dbPath.."]")
	for _,w in pairs(windowlist.getWindows()) do
		if w.getDatabaseNode().getPath() == dbPath then
			return w
		end
	end
	return nil
end

