ISCnode = "ISC"
DEBUG = true;
DefaultImmersiveSkills = "Arcana, History, Insight, Perception, Religion, Stealth, Survival";
function dbg(...) if ISC.DEBUG then print(unpack(arg)) end end

function getNode() 
	local node = DB.findNode(ISCnode)
	node = node or DB.createNode(ISCnode)
	ISC.dbg("~~ISC:getNode() == ["..tostring(node).."]");
	return node
end

function onInit()
	ISC.dbg("~~ISC:onInit()");
	if User.isHost() then
		DesktopManager.registerDockShortcut(
			"ISC_button_up",
			"ISC_button_dn",
			"Imm Skill Chk",
			"ISC_results_window",
			"ISC",
			0
		);
    end
end

function rollNow()
	ISC.dbg("~~ISC:rollNow()");
	-- ActionSkill.getRoll(rActor, nodeSkill);
end

function getVal(key)
	ISC.dbg("++ISC:getVal("..tostring(key)..")");
	if (key == nil) then return end;
	local val = DB.getValue(getNode(), key)
	ISC.dbg("--ISC:getVal("..tostring(key)..") == ["..tostring(val).."]");
	return val;
end
function setVal(key,val)
	ISC.dbg("~~ISC:setVal("..tostring(key)..","..tostring(val)..")");
	if (key == nil) then return end;
	return DB.setValue(getNode(), key, type(val), val);
end

function getAutoRoll()
	ISC.dbg("++ISC:getAutoRoll()");
	local sAutoRoll = getVal("sAutoRoll");
	if (sAutoRoll == nil) then
		setVal("sAutoRoll","false")
		sAutoRoll = getVal("sAutoRoll");
	end
	local bAutoRoll = not (sAutoRoll == "false")
	ISC.dbg("--ISC:getAutoRoll() == ["..tostring(bAutoRoll).."]");
	return bAutoRoll
end
function setAutoRoll(bAutoRoll)
	ISC.dbg("~~ISC:setAutoRoll("..tostring(bAutoRoll)..")");
	if bAutoRoll then sAutoRoll = "1" else sAutoRoll = "0" end
	setVal("sAutoRoll",tostring(bAutoRoll));
end

function getImmersiveSkills()
	sImmSkills = ISC.getVal("sImmSkills");
	if (sImmSkills == nil) then
		ISC.setVal("sImmSkills",DefaultImmersiveSkills);
		sImmSkills = ISC.getVal("sImmSkills");
	end
	ISC.dbg("~~ISC:getImmersiveSkills() == [" .. sImmSkills .. "]");
	return(StringManager.split(sImmSkills,",",true));
end
function setImmersiveSkills(skillList)
	ISC.dbg("~~ISC:setImmersiveSkills ("..skillList..")");
	ISC.setVal("sImmSkills",skillList);
end

