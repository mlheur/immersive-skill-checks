function openWindow(class,dbPath)
	local w = Interface.findWindow(class, dbPath)
	if w then
		w.bringToFront()
	else
		Interface.openWindow(class, dbPath)
	end
end

function resetNode(dbPath)
    DB.deleteChildren(dbPath)
end

function getCharSkillNode(sActor,sSkill)
    nActor = DB.findNode(sActor)
    nSkilllist = nActor.getChild("skilllist")
    for k,v in pairs(nSkilllist.getChildren()) do
        if v.getChild("name").getValue() == sSkill then
            return v
        end
    end
end

function resetTitles()
    resetNode(ISC.TITLES)
    for _,skillname in pairs(DataCommon.psskilldata) do
        skilldata = getSkillData(skillname)
        if skilldata["immersive"] ~= 0 then
            DB.createNode(ISC.TITLES.."."..skillname..".name","string").setValue(skillname)
        end
    end
end

function addSkillNode(skilldata)
    ISC.dbg("++ISC_datamanager:addSkillNode()")
    if skilldata["name"] ~= nil then
        if DataCommon.skilldata[skilldata["name"]] ~= nil then
            skilldata["immersive"] = skilldata["immersive"] or 0
            local dbPath = ISC.SKILLS .. "." .. skilldata["name"];
            if dbPath == nil then return false end
            DB.createNode(dbPath .. ".name","string").setValue(skilldata["name"]);
	        DB.createNode(dbPath .. ".immersive","number").setValue(skilldata["immersive"])
            ISC.dbg("  ISC_datamanager:addSkillNode(): added skill=["..skilldata["name"].."] immersive=["..skilldata["immersive"].."]")
        else
            ISC.dbg("  ISC_datamanager:addSkillNode(): skill=["..skilldata["name"].."] is not in DataCommon.skilldata")
        end
    else
        ISC.dbg("  ISC_datamanager:addSkillNode(): skilldata has no name")
    end
    ISC.dbg("--ISC_datamanager:addSkillNode()")
end

function setImmersion(skillname,immersive)
    if DataCommon.skilldata[skillname] ~= nil then
	    local dbPath = ISC.SKILLS .. "." .. skillname;
	    DB.createNode(dbPath .. ".immersive","number").setValue(immersive);
    end
end

function getDBNodeValue(dbPath, attr)
    local node = DB.getChild(dbPath)
    if node == nil then return nil end
    return DB.getValue(node, attr)
end

function getSkillData(skillname)
    skilldata = {}
    local dbPath = ISC.SKILLS .. "." .. skillname;
    skilldata["name"] = getDBNodeValue(dbPath, "name")
    skilldata["immersive"] = getDBNodeValue(dbPath, "immersive") or 0
    return skilldata
end

function getSkillset()
    return DB.getChildren(ISC.SKILLS)
end