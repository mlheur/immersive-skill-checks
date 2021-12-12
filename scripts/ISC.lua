DEBUG = true;

DBPATH = "ISC";
RESULTS = DBPATH..".roll-data";
SKILLS = DBPATH..".immersive-skills";
TITLES = DBPATH..".skill-titles"
DEFAULTS = {"Arcana","History","Insight","Perception","Religion","Stealth","Survival"};

function dbg(...) if ISC.DEBUG then print(unpack(arg)) end end

function initHandlers()
	DB.addHandler(ISC.SKILLS..".*.immersive", "onUpdate", ISC_DataMgr.resetTitles)
	ActionsManager.registerResultHandler("immersive-skill-check", ISC_ResultsMgr.onRoll)
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

