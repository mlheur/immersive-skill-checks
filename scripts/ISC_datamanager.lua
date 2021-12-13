DBPATH = "ISC"
SKILLS = DBPATH..".immersive-selection"
TITLES = DBPATH..".skill-titles"
RESULTS = DBPATH..".results"

function init()
    DB.createChild(DBPATH)
    getAutoRoll()
    if DB.getChild(SKILLS) == nil then
        ISC_SkillsMgr.setDefaultImmersiveSkills()
    end
    initHandlers()
end

function initHandlers()
	DB.addHandler(SKILLS..".*.immersive", "onUpdate", resetTitles)
	DB.addHandler("combattracker.round", "onUpdate", doAutoRoll )
	ActionsManager.registerResultHandler("immersive-skill-check", ISC_ResultsMgr.onRoll)
end

function getRound()
    return DB.getValue("combattracker.round")
end

function doAutoRoll(nUpdated)
	wResultsWindow = Interface.findWindow("ISC_resultswindow", DBPATH)
	if wResultsWindow == nil then return end
	if wResultsWindow["ISC_bAutoRoll"].getValue() == 0 then return end
	wResultsWindow.rollNow()
end

function openWindow(class)
	local w = Interface.findWindow(class, DBPATH)
	if w then
		w.bringToFront()
	else
		Interface.openWindow(class, DBPATH)
	end
end

function setAutoRoll(v)
    DB.createChild(DBPATH, "ISC_bAutoRoll", "number").setValue(v)
end

function getAutoRoll()
    nAutoRoll = DB.getChild(DBPATH, "ISC_bAutoRoll")
    if nAutoRoll == nil then
        setAutoRoll(true)
        return true
    end
    return nAutoRoll.getValue() ~= 0
end

function resetNode(dbPath)
	ISC.dbg("==ISC_datamanager:resetNode(): dbPath=["..dbPath.."]")
    DB.deleteChildren(dbPath)
end

function getCharsheetSkill(sActor,sSkill)
	ISC.dbg("==ISC_datamanager:getCharsheetSkill(): sActor=["..sActor.."] sSkill=["..sSkill.."]")
    nActor = DB.findNode(sActor)
    nSkilllist = nActor.getChild("skilllist")
    for k,v in pairs(nSkilllist.getChildren()) do
        if v.getChild("name").getValue() == sSkill then
            return v
        end
    end
end

function resetTitles(nUpdated)
	ISC.dbg("==ISC_datamanager:resetTitles()")
    aTitles = {}
    resetNode(TITLES)
    for _,skillname in pairs(DataCommon.psskilldata) do
        skilldata = getSkillData(skillname)
        if skilldata["immersive"] ~= 0 then
            DB.createNode(TITLES.."."..skillname..".name","string").setValue(skillname)
            aTitles[skillname] = true
        end
    end
    return aTitles
end

function addSkillNode(skilldata)
    ISC.dbg("++ISC_datamanager:addSkillNode()")
    if skilldata["name"] ~= nil then
        if DataCommon.skilldata[skilldata["name"]] ~= nil then
            skilldata["immersive"] = skilldata["immersive"] or 0
            local dbPath = SKILLS .. "." .. skilldata["name"];
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
	ISC.dbg("==ISC_datamanager:setImmersion(): skillname=["..skillname.."] immersive=["..immersive.."]")
    if DataCommon.skilldata[skillname] ~= nil then
	    local dbPath = SKILLS .. "." .. skillname;
	    DB.createNode(dbPath .. ".immersive","number").setValue(immersive);
    end
end

function getDBNodeValue(dbPath, attr)
	ISC.dbg("==ISC_datamanager:getDBNodeValue(): dbPath=["..dbPath.."] attr=["..attr.."]")
    local node = DB.getChild(dbPath)
    if node == nil then return nil end
    return DB.getValue(node, attr)
end

function getSkillData(skillname)
	ISC.dbg("==ISC_datamanager:getSkillData(): skillname=["..skillname.."]")
    skilldata = {}
    local dbPath = SKILLS .. "." .. skillname;
    skilldata["name"] = getDBNodeValue(dbPath, "name")
    skilldata["immersive"] = getDBNodeValue(dbPath, "immersive") or 0
    return skilldata
end

function getSkillset()
	ISC.dbg("==ISC_datamanager:getSkillset()")
    return DB.getChildren(SKILLS)
end

function findWindow(windowlist,keyCT)
	ISC.dbg("==ISC_datamanager:findWindow(): keyCT=["..keyCT.."]")
	for wndName,w in pairs(windowlist.getWindows()) do
		if wndName == keyCT then
			return w
		end
	end
	return nil
end

function getCombatantResultList(keyCT)
	ISC.dbg("==ISC_datamanager:getCombatantResultList(): keyCT=["..keyCT.."]")
    nResults = DB.createNode(RESULTS)
    if nResults == nil then return end
    return DB.createChild(nResults, keyCT)
end

function getCombantantResultNode(keyCT, sSkill)
    if sSkill == nil then
        ISC.dbg("==ISC_datamanager:getCombantantResultNode(): pResult=keyCT=["..keyCT.."]")
        return DB.createNode(keyCT)
    else
	    ISC.dbg("==ISC_datamanager:getCombantantResultNode(): keyCT=["..keyCT.."] sSkill=["..sSkill.."]")
        return getCombatantResultList(keyCT).createChild(sSkill)
    end
end

function clearResults()
	ISC.dbg("==ISC_datamanager:clearResults()")
    DB.deleteChildren(RESULTS)
end