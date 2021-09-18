local aSavedImmersiveSkills = {};

function onInit()
	ISC.dbg("++ISC_setskills:onInit()");
	self["ISC_button_cancel"].onButtonPress = revertInput;
	self["ISC_button_ok"].onButtonPress = acceptInput;
	self["ISC_button_defaults"].onButtonPress = resetDefaults;
	aSavedImmersiveSkills = ISC.getSkillset();
	ISC.loadSkillset(aSavedImmersiveSkills);
	ISC.dbg("--ISC_setskills:onInit()");
end

function onClose()
end

function resetDefaults()
	ISC.dbg("++ISC_setskills:resetDefaults()");
	ISC.loadSkillset(ISC.defaultImmersiveSkills());
	ISC.dbg("--ISC_setskills:resetDefaults()");
end

function revertInput()
	ISC.dbg("++ISC_setskills:revertInput()");
	ISC.loadSkillset(aSavedImmersiveSkills);
	self.close();
	ISC.dbg("--ISC_setskills:revertInput()");
end
function acceptInput()
	ISC.dbg("++ISC_setskills:acceptInput()");
	self.close();
	ISC.dbg("--ISC_setskills:acceptInput()");
end