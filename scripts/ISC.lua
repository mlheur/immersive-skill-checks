DEBUG = true;
DEFAULTS = {"Arcana","History","Insight","Perception","Religion","Stealth","Survival"};
AUTO_DEFAULT = 1

function dbg(...) if ISC.DEBUG then print(unpack(arg)) end end

function onInit()
	ISC.dbg("++ISC:onInit()");
	if User.isHost() then
		ISC_DataMgr.init()
		tButton = {}
		tButton["tooltipres"] = "Immersion"
		tButton["class"]      = "ISC_resultswindow"
		tButton["path"]       = ISC_DataMgr.DBPATH
		tButton["icon"]       = "ISC_button_up"
		tButton["icon_down"]  = "ISC_button_dn"
		DesktopManager.registerSidebarStackButton(tButton)
	end
	ISC.dbg("--ISC:onInit()");
end