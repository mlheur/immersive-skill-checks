local aSavedImmersiveSkills = {};

function onInit()
    ISC.dbg("++ISC_setskills:onInit()");
    self["ISC_button_cancel"].onButtonPress = revertInput;
    self["ISC_button_ok"].onButtonPress = acceptInput;
    self["ISC_button_defaults"].onButtonPress = resetDefaults;
    aSavedImmersiveSkills = ISC.getSkillset();
    ISC.dbg("--ISC_setskills:onInit()");
end

function resetDefaults()
    ISC.loadSkillset(ISC.defaultImmersiveSkills());
end

function revertInput()
    ISC.dbg("++ISC_setskills:revertInput()");
    ISC.dbg("  ISC_setskills revert applying aSavedImmersiveSkills");
    ISC.loadSkillset(aSavedImmersiveSkills);
    self.close();
    ISC.dbg("--ISC_setskills:revertInput()");
end
function acceptInput()
    ISC.dbg("++ISC_setskills:acceptInput()");
    self.close();
    ISC.dbg("--ISC_setskills:acceptInput()");
end


function applySelection(aSelected)
    ISC.dbg("++ISC_setskills:applySelection()");
    for k,v in pairs(aSelected) do
        ISC.dbg("aSelected[k:["..tostring(k).."],v:["..tostring(v).."]]");
        local dbPath = "ISC.ISC_aImmersiveSkills." .. k;
        local wndSkillSelection = self["ISC_setskills_listframe"].createWindowWithClass("ISC_aImmersiveSkills_class",dbPath);
        ISC.dbg("wndSkillSelection: ["..tostring(wndSkillSelection).."]")
        iImmersive = 0;
        for i,ctl in pairs(wndSkillSelection.getControls()) do
            local ctlName = ctl.getName();
            if ctlName == "immersive" then
                ctl.setValue(v);
            elseif ctlName == "skillname" then
                ctl.setValue(k);
            end
        end
    end
    ISC.dbg("--ISC_setskills:applySelection()");
end

