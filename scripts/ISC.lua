ISCnode = "ISC";
defaultSkills = {"Arcana","History","Insight","Perception","Religion","Stealth","Survival"};
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
			defaultImmersiveSkills();
		end
	end
	ISC.dbg("--ISC:onInit()");
end

function addSkillNode(skillname,immersive)
	immersive = immersive or 0;
	local dbPath = "ISC.ISC_aImmersiveSkills." .. skillname;
	local dbNode = DB.createNode(dbPath);
	DB.createNode(dbPath .. ".skillname","string").setValue(skillname);
	DB.createNode(dbPath .. ".immersive","number").setValue(immersive);
end

function listDBSkills()
	ISC.dbg("++ISC:listDBSkills()");
	local dbSkillNode = DB.findNode("skill");
	local dbSkillList = {}
	if dbSkillNode ~= nil then
		ISC.dbg("  ISC:listDBSkills got skill node");
		for iSkill,nodeSkill in pairs(dbSkillNode.getChildren()) do
			for iAttr,attr in pairs(nodeSkill.getChildren()) do
				if attr.getName() == "name" then
					dbSkillList[#dbSkillList+1] = attr.getValue();
					ISC.dbg("  ISC:listDBSkills found child:["..dbSkillList[#dbSkillList].."]");
				end
			end
		end
	end
	ISC.dbg("--ISC:listDBSkills()");
	return dbSkillList;
end

function listValidSkills()
	ISC.dbg("++ISC:listValidSkills()");
	-- hash it out
	validSkills = {};
	for skillname in pairs(DataCommon.skilldata, DataCommon.psskilldata) do
		ISC.dbg("listValidSkills:skillname - ruleset = ["..skillname.."]");
		validSkills[skillname] = 1;
	end
	for i,skillname in pairs(listDBSkills()) do
		ISC.dbg("listValidSkills:skillname - DB = ["..skillname.."]");
		validSkills[skillname] = 1;
	end
	-- list hash keys
	validSkillList = {}
	for skillname in pairs(validSkills) do
		validSkillList[#validSkillList+1] = skillname;
	end
	ISC.dbg("--ISC:listValidSkills()");
	return validSkillList;
end

function resetSkills(validSkills)
	ISC.dbg("++ISC:resetSkills()");
	validSkills = validSkills or listValidSkills();
	DB.deleteChildren("ISC.ISC_aImmersiveSkills");
	for _,skillname in next, listValidSkills() do
		addSkillNode(skillname,0)
	end
	ISC.dbg("--ISC:resetSkills()");
end

function defaultImmersiveSkills()
	ISC.dbg("++ISC:defaultImmersiveSkills()");
	resetSkills();
	for _,skillname in pairs(defaultSkills) do
		addSkillNode(skillname,1)
	end
	ISC.dbg("--ISC:defaultImmersiveSkills()");
end

function loadSkillset(aSkillSet)
	ISC.dbg("++ISC:loadSkillset()");
	validSkills = listValidSkills();
	resetSkills(validSkills);
	for skillname,immersive in pairs(aSkillSet) do
		if validSkills[skillname] ~= nil then
			addSkillNode(skillname,immersive);
		end
	end
	ISC.dbg("--ISC:loadSkillset()");
end

function getSkillset()
	ISC.dbg("++ISC:getSkillset()");
	local aSkillSet = {};
	for iSkill,skillNode in pairs(DB.getChildren("ISC.ISC_aImmersiveSkills")) do
		local immersive = 0;
		local skillname = "**unset**"
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