function onInit()
    ISC.dbg("++ISC_setskills:onInit()");
    self["ISC_button_cancel"].onButtonPress = self.close;
    self["ISC_button_ok"].onButtonPress = acceptInput;

    -- track what we know about skills
    aSelectedSkills = {};

    -- get the list of all skills in the ruleset
    for k,v in pairs(DataCommon.skilldata) do
        ISC.dbg("DataCommon.skilldata[k:["..tostring(k).."],v:["..tostring(v).."]]");
        aSelectedSkills[k] = false;
    end

    -- get the list of all skills in the ruleset
    for k,v in pairs(DataCommon.psskilldata) do
        ISC.dbg("DataCommon.psskilldata[k:["..tostring(k).."],v:["..tostring(v).."]]");
        aSelectedSkills[v] = false;
    end

    -- get the skills tracked for immersion
    aImmSkills = ISC.getImmersiveSkills();
    for i,v in ipairs(aImmSkills) do
        ISC.dbg("aImmSkills["..tostring(v).."]")
        aSelectedSkills[v] = true;
    end

    -- populate the list
    for k,v in pairs(aSelectedSkills) do
        ISC.dbg("aSelectedSkills[k:["..tostring(k).."],v:["..tostring(v).."]]");
        local nextSkill = self["ISC_setskills_listframe"].createWindowWithClass("ISC_setskills_entry",true,false);
        nextSkill["ISC_setskills_skillname"].setValue(k);
        if v then
            nextSkill["ISC_setskills_selected"].setValue(1)
        else
            nextSkill["ISC_setskills_selected"].setValue(0)
        end
    end

    ISC.dbg("--ISC_setskills:onInit()");
end

function acceptInput()
    aNewImmersiveSkills = {};
    -- walk the list and track which ones are ticked off.

    -- save the set
    ISC.setImmersiveSkills(table.concat(aNewImmersiveSkills,","));
    self.close();
end