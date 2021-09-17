ISCnode = "ISC";
DEBUG = true;
function dbg(...) if ISC.DEBUG then print(unpack(arg)) end end

function onInit()
	ISC.dbg("++ISC:onInit()");
	if User.isHost() then
		DesktopManager.registerDockShortcut(
			"ISC_button_up",
			"ISC_button_dn",
			"Immersion",
			"ISC_results_window",
			"ISC",
			0
		);
		if DB.getChild(ISCnode,"ISC_aImmersiveSkills") == nil then
			firstInit();
		end
	end
	ISC.dbg("--ISC:onInit()");
end

function enumerateSkills()
	ISC.dbg("++ISC:enumerateSkills()");
	allSkills = {};
	for k,v in pairs(DataCommon.psskilldata) do allSkills[v] = 0 end
	for k,v in pairs(DataCommon.skilldata) do allSkills[k] = 0 end
	ISC.dbg("--ISC:enumerateSkills()");
	return allSkills;
end

function defaultImmersiveSkills()
	ISC.dbg("++ISC:defaultImmersiveSkills()");
	defSkills = enumerateSkills();
	defSkills["Arcana"]      = 1;
	defSkills["History"]     = 1;
	defSkills["Insight"]     = 1;
	defSkills["Perception"]  = 1;
	defSkills["Religion"]    = 1;
	defSkills["Stealth"]     = 1;
	defSkills["Survival"]    = 1;
	ISC.dbg("--ISC:defaultImmersiveSkills()");
	return defSkills;
end

function loadSkillset(aSkillSet)
	ISC.dbg("++ISC:loadSkillset()");
	DB.deleteChildren("ISC.ISC_aImmersiveSkills");
	for k,v in pairs(aSkillSet) do
		ISC.dbg("  ISC:loadSkillset() given [k:["..tostring(k).."],v:["..tostring(v).."]]");
		local dbPath = "ISC.ISC_aImmersiveSkills." .. k;
		local dbNode = DB.createNode(dbPath);
		DB.createNode(dbPath .. ".immersive","number").setValue(v);
		DB.createNode(dbPath .. ".skillname","string").setValue(k);
	end
	ISC.dbg("--ISC:loadSkillset()");
end

function getSkillset()
	ISC.dbg("++ISC:getSkillset()");
	local aSkillSet = {};
	for iSkill,skillNode in pairs(DB.getChildren("ISC.ISC_aImmersiveSkills")) do
		local immersive = "";
		local skillname = ""
		for iAttr,attr in pairs(skillNode.getChildren()) do
			attrName = attr.getName();
			if attrName == "immersive" then immersive = attr.getValue() end
			if attrName == "skillname" then skillname = attr.getValue() end
		end
		aSkillSet[skillname] = immersive;
		ISC.dbg("  ISC:getSkillset() saving skill [k:["..tostring(skillname).."],v:["..tostring(immersive).."]]")
	end
	ISC.dbg("--ISC:getSkillset()");
	return aSkillSet;
end

function firstInit()
	ISC.dbg("++ISC:firstInit()");
	loadSkillset(defaultImmersiveSkills());
	ISC.dbg("--ISC:firstInit()");
end
