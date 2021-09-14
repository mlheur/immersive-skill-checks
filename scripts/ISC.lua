ISCroot = "ISC";
windowclass_name = "ISC-results-window";

function onInit()
	if User.isHost() then
		DesktopManager.registerDockShortcut(
			"ISC-button-up",
			"ISC-button-dn",
			"Imm Skill Chk",
			windowclass_name,
			ISCroot,
			0
		);
		local node = DB.findNode(ISCroot);
		if (not root) then
			root = DB.createNode(ISCroot);
		end
		if (not DB.getValue(root,"bAutoRoll")) then
			setAutoRoll(false);
		end
    end
end

function rollNow()
	print("ISC: Roll Now");
end

function setImmersiveSkills(skillList)
	print("ISC: Set Immersive Skills []");
end

function setAutoRoll(bAutoRoll)
	print("ISC: Toggle Auto Roll [" .. (bAutoRoll and "true" or "false") .. "]");
	DB.setValue(DB.findNode(ISCroot),"bAutoRoll","boolean",bAutoRoll);
end