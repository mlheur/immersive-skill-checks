local aSavedImmersiveSkills = {};

function onInit()
	self["ISC_button_cancel"].onButtonPress = revertInput;
	self["ISC_button_ok"].onButtonPress = acceptInput;
	self["ISC_button_defaults"].onButtonPress = resetDefaults;
	-- ToDo: add a handler to redo ISC.loadskillset() on DB change.
	aSavedImmersiveSkills = ISC.getSkillset();
	ISC.loadSkillset(aSavedImmersiveSkills);
end

function resetDefaults()
	ISC.loadSkillset(ISC.defaultImmersiveSkills());
end

function revertInput()
	ISC.loadSkillset(aSavedImmersiveSkills);
	self.close();
end
function acceptInput()
	self.close();
end