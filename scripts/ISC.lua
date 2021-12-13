DEBUG = true;
DEFAULTS = {"Arcana","History","Insight","Perception","Religion","Stealth","Survival"};
AUTO_DEFAULT = true
lastRoundRolled = -1 -- I don't have any DB path enabled to track lastRoundRolled between play sessions.  Look into it if that's an issue or not.  Probably is an issue.

function dbg(...) if ISC.DEBUG then print(unpack(arg)) end end

function onInit()
	ISC.dbg("++ISC:onInit()");
    ISC_DataMgr.init()
	if User.isHost() then
		DesktopManager.registerDockShortcut(
			"ISC_button_up",
			"ISC_button_dn",
			"Immersion",
			"ISC_resultswindow",
			ISC_DataMgr.DBPATH,
			0
		);
		ISC_ResultsMgr.openResults()
	end
	ISC.dbg("--ISC:onInit()");
end