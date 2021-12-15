local aSavedImmersiveSkills = {};

function onInit()
	self["ISC_button_cancel"].onButtonPress = doCancel
	self["ISC_button_ok"].onButtonPress = doOK
	self["ISC_button_defaults"].onButtonPress = doDefaults
	-- ToDo: add a handler to redo ISC.loadskillset() on DB change.
	-- ToDo: add a button to open the results window from the selection window.
	aSavedImmersiveSkills = ISC_SkillsMgr.getSkillset(); -- save in case of [Cancel]
	ISC_SkillsMgr.resetSkills(aSavedImmersiveSkills); -- reload just in case in-game skills were updated since last open.  Maybe this should be a handler.
end

function doCancel()
	ISC_SkillsMgr.resetSkills(aSavedImmersiveSkills)
	self.close()
end

function doOK()
	self.close()
end

function doDefaults()
	ISC_SkillsMgr.setDefaultImmersiveSkills()
end
