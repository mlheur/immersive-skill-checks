DEBUG = true;
DEFAULTS = {"Arcana","History","Insight","Perception","Religion","Stealth","Survival"};
AUTO_DEFAULT = 1

function dbg(...) if ISC.DEBUG then print(unpack(arg)) end end

function onInit()
	ISC.dbg("++ISC:onInit()");
	if User.isHost() then
		ISC_DataMgr.init()
		DesktopManager.registerDockShortcut(
			"ISC_button_up",
			"ISC_button_dn",
			"Immersion",
			"ISC_resultswindow",
			ISC_DataMgr.DBPATH,
			0
		);
		--ISC_ResultsMgr.openResults()
	end
	ISC.dbg("--ISC:onInit()");
end