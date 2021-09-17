function onInit()
	ISC.dbg("++ISC_results:onIint()");
	self["ISC_label_autoroll"].onButtonPress   = toggleAutoRoll;
	self["ISC_button_rollnow"].onButtonPress   = rollNow;
	self["ISC_button_skillset"].onButtonPress  = openSkillSetSelection;
	openSkillSetSelection();
	ISC.dbg("--ISC_results:onIint()");
end

function rollNow()
	ISC.dbg("++ISC_Results:rollNow()")
	--
	ISC.dbg("--ISC_Results:rollNow()")
end

function openSkillSetSelection()
	ISC.dbg("++ISC_results:openSkillSetSelection()")
	Interface.openWindow("ISC_setskills_window",getDatabaseNode());
	ISC.dbg("--ISC_results:openSkillSetSelection()")
end


function toggleAutoRoll()
	ISC.dbg("++ISC_results:toggleAutoRoll()")
	self["ISC_bAutoRoll"].setValue(self["ISC_bAutoRoll"].getValue()+1);
	ISC.dbg("--ISC_results:toggleAutoRoll()")
end