DEBUG = true;

DBPATH = "ISC";
RESULTS = DBPATH..".roll-data";
SKILLS = DBPATH..".immersive-skills";
TITLES = DBPATH..".skill-titles"
DEFAULTS = {"Arcana","History","Insight","Perception","Religion","Stealth","Survival"};

function dbg(...) if ISC.DEBUG then print(unpack(arg)) end end

function onInit()
	ISC.dbg("++ISC:onInit()");
	if User.isHost() then
		DesktopManager.registerDockShortcut(
			"ISC_button_up",
			"ISC_button_dn",
			"Immersion",
			"ISC_resultswindow",
			ISC.DBPATH,
			0
		);
		if DB.getChild(ISC.SKILLS) == nil then
			ISC_SkillsMgr.setDefaultImmersiveSkills();
		end
		ActionsManager.registerResultHandler("immersive-skill-check", ISC_ResultsMgr.onRoll)
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

