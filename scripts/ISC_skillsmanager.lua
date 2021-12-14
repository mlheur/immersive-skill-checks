-- handy hook to open the window from a persistent ISC_SkillsMgr.
function openSkillSetSelection()
	ISC_DataMgr.openWindow("ISC_skillswindow", ISC.SKILLS)
end

-- refresh in the ISC extension the list of skills available in the campaign.
-- ToDo: include custom skills created outside the 5e ruleset.
-- Probably the most effective solution is to grab the datasource used by the in-game 5e Skills window.
-- During reset, every skill is considered not immersive.  The caller has to take care
-- to enable immersion after doing the reset.
function resetSkills(newSkillList)
	ISC.dbg("++ISC_skillsmanager:resetSkills()");
	ISC_DataMgr.clearSkills()
	newSkillList = newSkillList or ISC_DataMgr.getAllGameSkills();
	for sSkill,vSkill in pairs(newSkillList) do
		local skilldata = {}
		skilldata["name"] = sSkill
		skilldata["immersive"] = vSkill["immersive"] or 0
		skilldata["stat"] = vSkill["stat"] or 0
	    ISC_DataMgr.addSkillNode(skilldata)
	end
	ISC.dbg("--ISC_skillsmanager:resetSkills()");
end

-- Reset the entire skill set based on hard-coded defaults.
function setDefaultImmersiveSkills()
	ISC.dbg("++ISC_skillsmanager:setDefaultImmersiveSkills()");
	resetSkills();
	for _,skillname in pairs(ISC.DEFAULTS) do
		ISC_DataMgr.setImmersion(skillname,1)
	end
	ISC.dbg("--ISC_skillsmanager:setDefaultImmersiveSkills()");
end

-- reapply a previous skill set after manipulating/mangling the in-UI selections.
-- most commonly used to cancel an undesired change in the Immersive Skills Selection window.
function loadSkillset(skillset)
	ISC.dbg("++ISC_skillsmanager:loadSkillset()");
	ISC_SkillsMgr.resetSkills();
	for skillname,skilldata in pairs(skillset) do
		ISC_DataMgr.addSkillNode(skilldata);
	end
	ISC.dbg("--ISC_skillsmanager:loadSkillset()");
end

-- save in LUA table, in-memory, a copy of the current DB skill immersion selection.
-- most commonly used when opening the Immersive Skills Selection window, to be
-- reapplied if the user cancels any changes while that window was open.
function getSkillset()
    skillset = {}
    for skillname,skillnode in pairs(ISC_DataMgr.getSkillset()) do
        skillset[skillname] = ISC_DataMgr.getSkillData(skillname)
    end
    return skillset
end