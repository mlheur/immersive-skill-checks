function onInit()
	ISC.dbg("++ISC_results:onIint()");
	syncAutoRollButton();
	self["ISC_label_autoroll"].onButtonPress   = toggleAutoRoll;
	self["ISC_button_autoroll"].onValueChanged = syncAutoRollDB;
	self["ISC_button_rollnow"].onButtonPress   = ISC.rollNow;
	self["ISC_button_skillset"].onButtonPress  = openSkillSetSelection;
	openSkillSetSelection();
	ISC.dbg("--ISC_results:onIint()");
end

function openSkillSetSelection()
	ISC.dbg("++ISC_Results:openSkillSetSelection()")
	Interface.openWindow("ISC_setskills_window",getDatabaseNode());
	ISC.dbg("--ISC_Results:openSkillSetSelection()")
end


function toggleAutoRoll()
	ISC.dbg("++ISC_Results:toggleAutoRoll()")
	ISC.setAutoRoll(self["ISC_button_autoroll"].getValue() == 0)
	syncAutoRollButton()
	ISC.dbg("--ISC_Results:toggleAutoRoll()")
end

function syncAutoRollButton()
	ISC.dbg("++ISC_Results:syncAutoRollButton()")
	if ISC.getAutoRoll() then
		self["ISC_button_autoroll"].setValue(1)
	else
		self["ISC_button_autoroll"].setValue(0)
	end
	ISC.dbg("--ISC_Results:syncAutoRollButton()")
end

function syncAutoRollDB()
	ISC.dbg("++ISC_Results:syncAutoRollDB()")
	ISC.setAutoRoll(self["ISC_button_autoroll"].getValue() == 1)
end