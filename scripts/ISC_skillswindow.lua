local aSavedImmersiveSkills = {};

function onInit()
	self["ISC_button_cancel"].onButtonPress = doCancel
	self["ISC_button_ok"].onButtonPress = doOK
	self["ISC_button_defaults"].onButtonPress = doDefaults
	-- ToDo: add a handler to redo ISC.loadskillset() on DB change.
	-- ToDo: add a hook to open the skill window from the setskills window.
	aSavedImmersiveSkills = ISC_SkillsMgr.getSkillset();
	ISC_SkillsMgr.loadSkillset(aSavedImmersiveSkills);
end

function doCancel()
	ISC_SkillsMgr.loadSkillset(aSavedImmersiveSkills)
	self.close()
end

function doOK()
	self.close()
end

function doDefaults()
	ISC_SkillsMgr.setDefaultImmersiveSkills()
end
