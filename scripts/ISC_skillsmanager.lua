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
	gameSkillList = ISC_DataMgr.getAllGameSkills()
	newSkillList = newSkillList or {};
	-- learn any new skills from the game data
	for _,vSkill in pairs(gameSkillList) do
		-- ignore those that'll be added by the new list
		ISC.dbg("  ISC_skillsmanager:resetSkills(): working on game skill vSKill[name]=["..vSkill["name"].."]");
		if (newSkillList[vSkill["name"]] == nil) or (newSkillList[vSkill["name"]]["name"] == nil ) then
			ISC.dbg("  ISC_skillsmanager:resetSkills(): added game skill, not defined in new skill list.");
			ISC_DataMgr.addSkillData(vSkill)
		end
	end
	-- add back any saved skills
	for _,vSkill in pairs(newSkillList) do
		-- addSKill will return early if the skill was removed from game data.
		ISC_DataMgr.addSkillData(vSkill)
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

function HUP()
	ISC.dbg("++ISC_skillsmanager:HUP()");
	resetSkills(getSkillset())
	ISC.dbg("--ISC_skillsmanager:HUP()");
end

-- save in LUA table, in-memory, a copy of the current DB skill immersion selection.
-- most commonly used when opening the Immersive Skills Selection window, to be
-- reapplied if the user cancels any changes while that window was open.
function getSkillset()
    skillset = {}
    for sSkill,nSkill in pairs(ISC_DataMgr.getSkillset()) do
		vSkill = ISC_DataMgr.getSkillData(sSkill)
        skillset[sSkill] = vSkill
    end
    return skillset
end