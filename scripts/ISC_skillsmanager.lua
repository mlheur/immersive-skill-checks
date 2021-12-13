function openSkillSetSelection()
	ISC_DataMgr.openWindow("ISC_skillswindow", ISC.SKILLS)
end

function resetSkills(newSkillList)
	ISC.dbg("++ISC_skillsmanager:resetSkills()");
	ISC_DataMgr.resetNode(ISC_DataMgr.SKILLS);
	newSkillList = newSkillList or DataCommon.psskilldata;
	for _,skillname in pairs(newSkillList) do
		local skilldata = {}
		skilldata["name"] = skillname
		skilldata["immersive"] = newSkillList["immersive"] or 0
	    ISC_DataMgr.addSkillNode(skilldata)
	end
	ISC.dbg("--ISC_skillsmanager:resetSkills()");
end

function setDefaultImmersiveSkills()
	ISC.dbg("++ISC_skillsmanager:setDefaultImmersiveSkills()");
	resetSkills();
	for _,skillname in pairs(ISC.DEFAULTS) do
		ISC_DataMgr.setImmersion(skillname,1)
	end
	ISC.dbg("--ISC_skillsmanager:setDefaultImmersiveSkills()");
end

function loadSkillset(skillset)
	ISC.dbg("++ISC_skillsmanager:loadSkillset()");
	ISC_SkillsMgr.resetSkills();
	for skillname,skilldata in pairs(skillset) do
		ISC_DataMgr.addSkillNode(skilldata);
	end
	ISC.dbg("--ISC_skillsmanager:loadSkillset()");
end

function getSkillset()
    skillset = {}
    for skillname,skillnode in pairs(ISC_DataMgr.getSkillset()) do
        skillset[skillname] = ISC_DataMgr.getSkillData(skillname)
    end
    return skillset
end