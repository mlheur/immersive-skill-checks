-- these database path values are tightly coupled with the UI data in the XML files.
DBPATH = "ISC"
SKILLS = DBPATH..".immersive-selection"
TITLES = DBPATH..".skill-titles"
RESULTS = DBPATH..".results"
LAST_ROUND = DBPATH..".last-rolled-round"
AllGameSkillsCache = {}

--------------------------------------------------------------------------------
-- INITs, general DB functions
--------------------------------------------------------------------------------

function init()
    ISC.dbg("++ISC_datamanager:init()")
    refresh()
	DB.addHandler(SKILLS..".*.immersive", "onUpdate", doRedraw) -- reset the list skill titles when the immersive settings change
	DB.addHandler("combattracker.round", "onUpdate", doAutoRoll ) -- for enabling autoroll
	ActionsManager.registerResultHandler("immersive-skill-check", ISC_ResultsMgr.onRoll) -- this is how to register a callback to get the result of a die throw.
    ISC.dbg("--ISC_datamanager:init()")
end

-- plan a heirarchy of resets whenever game skill data changes, to be called from onUpdate handlers
function refresh()
    ISC.dbg("++ISC_datamanager:refresh()")
    DB.createNode(DBPATH) -- ensure our DB node exists
    getAutoRoll() -- set a default value if none exists
    getAllGameSkills() -- update self.AllGameSkillsCache
    if DB.getChild(SKILLS) == nil then
        ISC_SkillsMgr.setDefaultImmersiveSkills()
    else
        ISC_SkillsMgr.HUP()
    end
    doRedraw()
    ISC.dbg("--ISC_datamanager:refresh()")
end

-- factor out any DB calls into ISC_DataMgr
function resetNode(dbPath)
	ISC.dbg("==ISC_datamanager:resetNode(): dbPath=["..dbPath.."]")
    DB.deleteChildren(dbPath)
end

-- internal helper function to do error checking before calling getValue().
function getDBNodeValue(dbPath, attr)
    if type(dbPath) ~= "string" then dbPath = dbPath.getPath() end
    local node = DB.getChild(dbPath)
    if node == nil then
        ISC.dbg("==ISC_datamanager:getDBNodeValue(): no such node, return nil, dbPath=["..dbPath.."]")
        return nil
    end
    v = DB.getValue(node, attr)
	ISC.dbg("==ISC_datamanager:getDBNodeValue(): dbPath=["..dbPath.."] attr=["..attr.."]")
    return v
end

--------------------------------------------------------------------------------
-- Combat Round Data Mgmt
--------------------------------------------------------------------------------

function getRound()
    return DB.getValue("combattracker.round") or 0
end

function getRoundRolled()
    v = DB.getValue(LAST_ROUND)
    if v == nil or v < 0 then
        setRoundRolled(0)
        return 0
    end
    return v
end

function setRoundRolled(r)
    r = r or getRound()
    DB.createNode(LAST_ROUND,"number").setValue(r)
end

--------------------------------------------------------------------------------
-- AutoRoll Data Mgmt
--------------------------------------------------------------------------------

-- Changes the value in the DB, tightly coupled with the UI tickbox.
-- I want to refactor out the ISC_ from the control names, but that's a task for
-- later.
function setAutoRoll(v)
    DB.createChild(DBPATH, "ISC_bAutoRoll", "number").setValue(v)
end

-- returns a boolean if autoroll is enabled.  Also sets a default value
-- when the DB has no value.
function getAutoRoll()
    nAutoRoll = DB.getChild(DBPATH, "ISC_bAutoRoll")
    if nAutoRoll == nil then
        setAutoRoll(ISC.AUTO_DEFAULT)
        return ISC.AUTO_DEFAULT
    end
    return nAutoRoll.getValue() ~= 0
end

function doAutoRoll(nUpdated)
    -- the actual roll function is a member of the main window.  Get the window handle
    -- so we can call its roll function.
	wResultsWindow = Interface.findWindow("ISC_resultswindow", DBPATH)
    -- window handles don't exist when the window is closed.  We won't do the autoroll
    -- now, but next time the results window opens, so long as autoroll is enabled
    -- and the combat tracker round is different than the last roll, it'll do the
    -- roll when the window opens.  If many autorolls were skipped, only one roll
    -- will happen when the window opens.
	if wResultsWindow == nil then return end
    -- if we go the window handle then the window is open and we can run the roll now.
    -- this callback is always registered, and will be called every time the combat
    -- tracker round number changes
	if wResultsWindow["ISC_bAutoRoll"].getValue() == 0 then return end
	wResultsWindow.rollNow()
end

--------------------------------------------------------------------------------
-- Window Mgmt
--------------------------------------------------------------------------------

-- helper function to get window before calling its redraw function.
function doRedraw(wndName)
    updateImmersiveSkills()
    wndName = wndName or "ISC_resultswindow"
	wResultsWindow = Interface.findWindow(wndName, DBPATH)
	if wResultsWindow ~= nil then
	    wResultsWindow.redraw()
    end
end

-- I have a few functions in DataMgr that maybe belong in WindowMgr, but not enough
-- to warrant refactoring those out right now.
function openWindow(class, record)
    record = record or DBPATH
	ISC.dbg("==ISC_datamanager:findWindow(): class=["..class.."] record=["..record.."]")
	local w = Interface.findWindow(class, record)
	if w then
		w.bringToFront()
	else
		Interface.openWindow(class, record)
	end
end

-- Another window manager function.  FG lacks any Interface.findChildWindow() function.
-- Interface.findWindow() only returns top level window classes, and not any windows
-- contained in window containers.
-- This will help locate a child window in a given <windowlist>.
function findWindow(windowlist,keyCT)
	ISC.dbg("==ISC_datamanager:findWindow(): keyCT=["..keyCT.."]")
	for wndName,w in pairs(windowlist.getWindows()) do
		if wndName == keyCT then
			return w
		end
	end
	return nil
end

--------------------------------------------------------------------------------
-- Skill Data Mgmt
--------------------------------------------------------------------------------

function clearSkills()
	ISC.dbg("==ISC_datamanager:clearSkills()")
    resetNode(SKILLS)
end

-- When a PC makes a skill check, we need a ref to the character sheet,
-- actual the DB node where the character sheet has this character's data.
-- Most importantly this is how ISC_ResultsMgr knows what modifier to
-- apply to the d20.
function getCharsheetSkill(pActor,sSkill)
	ISC.dbg("++ISC_datamanager:getCharsheetSkill(): pActor=["..pActor.."] sSkill=["..sSkill.."]")
    nActor = DB.findNode(pActor)
    if nActor == nil then
        ISC.dbg("--ISC_datamanager:getCharsheetSkill(): no such actor")
        return
    end
    nSkilllist = nActor.getChild("skilllist")
    if nSkilllist == nil then
        ISC.dbg("--ISC_datamanager:getCharsheetSkill(): charsheet has no skillist")
        return
    end
    for k,v in pairs(nSkilllist.getChildren()) do
        if v.getChild("name").getValue() == sSkill then
            ISC.dbg("--ISC_datamanager:getCharsheetSkill(): found a match")
            return v
        end
    end
	ISC.dbg("--ISC_datamanager:getCharsheetSkill(): no matching skill on charsheet")
end

-- The easiest way I found, for the UI to accurately display only the
-- immersive skill titles in the results window, was to create a simple
-- list in the DB with only in-scope skills on the list.
-- In the window XML file, the windowlist class uses this simple list
-- in its <datasource> tag.
-- So, whenever the *.immersive setting changes on any skill, we come
-- here and review all skills and repopulate the simple list with just
-- the immersive skills.  UI updates automatically based on this list.
-- I don't like this method because I have all the skills listed in a few
-- places already, and here I am adding another such list, causing more
-- bloat in the db.xml file.  One day when I know better, come back
-- and do a more effecient job of this.
-- At least this could be improved without dropping _everything_ and
-- walking the whole list on each change.
-- One improvement, only reset titles when Skill Selection window closes.
-- Another, don't walk the whole list, only touch here what changed in
-- nUpdated.
function updateImmersiveSkills(nUpdated)
	ISC.dbg("++ISC_datamanager:updateImmersiveSkills()")
    resetNode(TITLES)
    for _,vSkill in pairs(getAllGameSkills()) do
        sSkill = vSkill["name"]
        data = getSkillData(sSkill)
        if data["immersive"] ~= 0 then
            DB.createChild(TITLES, sSkill).createChild("name", "string").setValue(sSkill)
        end
    end
	ISC.dbg("--ISC_datamanager:updateImmersiveSkills()")
end

function getImmersiveSkills()
	ISC.dbg("++ISC_datamanager:getImmersiveSkills()")
    aTitles = {}
    for sSkill,vSkill in pairs(DB.getChildren(TITLES)) do
        aTitles[sSkill] = true
    end
	ISC.dbg("--ISC_datamanager:getImmersiveSkills()")
    return aTitles
end

function getDataCommonSkills()
	ISC.dbg("++ISC_datamanager:getDataCommonSkills()")
    allskills = {}
    for sSkill,vSkill in pairs(DataCommon.skilldata) do
        data = {}
        data["name"] = sSkill
        data["stat"] = vSkill["stat"]
        data["source"] = "DataCommon"
        ISC.dbg("  ISC_datamanager:getDataCommonSkills() found DataCommon.skilldata["..sSkill.."] name=["..data["name"].."] stat=["..data["stat"].."]")
        allskills[data["name"]] = data
    end
	ISC.dbg("--ISC_datamanager:getDataCommonSkills()")
    return allskills
end

function getAllGameSkills()
    ISC.dbg("++ISC_datamanager:getAllGameSkills()")
    allskills = getDataCommonSkills()
    for keySkill,nSkill in pairs(DB.getChildren("skill")) do
        data = {}
        data["name"] = getDBNodeValue(nSkill, "name")
        data["stat"] = getDBNodeValue(nSkill, "stat"):lower()
        data["source"] = "DB"
        ISC.dbg("  ISC_datamanager:getAllGameSkills() found DB.skill.["..keySkill.."] name=["..data["name"].."] stat=["..data["stat"].."]")
        allskills[data["name"]] = data
    end
    self.AllGameSkillsCache = allskills
	ISC.dbg("--ISC_datamanager:getAllGameSkills()")
    return allskills
end

function addSkillData(vSkill)
    if vSkill["name"] == nil then
        ISC.dbg("==ISC_datamanager:addSkillData() vSkill has no name, ditching")
        return
    end
    ISC.dbg("++ISC_datamanager:addSkillData() vSkill[name]=["..vSkill["name"].."]")
    if self.AllGameSkillsCache[vSkill["name"]] == nil then
        ISC.dbg("--ISC_datamanager:addSkillData(): not in cache, probably not a skill anymore in game database")
        return
    end
    local pSkill = SKILLS .. "." .. vSkill["name"];
    DB.createChild(pSkill, "name",     "string").setValue(vSkill["name"]);
    DB.createChild(pSkill, "immersive","number").setValue(vSkill["immersive"] or 0)
    DB.createChild(pSkill, "stat",     "string").setValue(vSkill["stat"])
    DB.createChild(pSkill, "source",   "string").setValue(vSkill["source"])
    ISC.dbg("--ISC_datamanager:addSkillData(): added")
end

function getSkillData(sSkill)
	ISC.dbg("++ISC_datamanager:getSkillData(): sSkill=["..sSkill.."]")
    local data = {}
    local pSkill = SKILLS .. "." .. sSkill;
    data["name"] = getDBNodeValue(pSkill, "name")
    data["immersive"] = getDBNodeValue(pSkill, "immersive") or 0
    data["stat"] = getDBNodeValue(pSkill, "stat")
    data["source"] = getDBNodeValue(pSkill, "source")
	ISC.dbg("--ISC_datamanager:getSkillData()")
    return data
end

-- get from consolidated local copy...
function getSkillAbility(sSkill)
	ISC.dbg("++ISC_datamanager:getSkillAbility() sSkill=["..sSkill.."]")
    pSkill = SKILLS .. "." .. sSkill
    sAbility = getDBNodeValue(pSkill,"stat")
	ISC.dbg("--ISC_datamanager:getSkillAbility() sSkill=["..sSkill.."] sAbility=["..sAbility.."]")
    return sAbility
end

function isValidGameSkill(sSkill)
	ISC.dbg("==ISC_datamanager:isValidGameSkill() sSkill=["..sSkill.."]")
    if DataCommon.skilldata[sSkill] ~= nil then return true end
    for keySkill,nSkill in pairs(DB.getChildren("skill")) do
        if sSkill == getDBNodeValue(nSkill, "name") then return true end
    end
    return false
end

-- Abstractify the DB calls from the rest of the code.
-- this one only gets called to turn on default skills
-- after resetting everything.  Maybe can be trimmed.
function setImmersion(sSkill,immersive)
	ISC.dbg("==ISC_datamanager:setImmersion(): sSkill=["..sSkill.."] immersive=["..immersive.."]")
    if DataCommon.skilldata[sSkill] ~= nil then
	    local dbPath = SKILLS .. "." .. sSkill;
	    DB.createNode(dbPath .. ".immersive","number").setValue(immersive);
    end
end

-- Abstractify the DB call to get the list of all DB nodes for all skill immersion settings.
function getSkillset()
	ISC.dbg("==ISC_datamanager:getSkillset()")
    return DB.getChildren(SKILLS)
end

--------------------------------------------------------------------------------
-- Results of Skill Checks
--------------------------------------------------------------------------------

-- Get the DB node whose children are the list of skill check results on a single
-- given actor.  UI will display results based on the values added to this list.
-- Actually, UI associations are created just before the roll in
-- ISC_resultswindow.refresh() by calling windowlist.setdatbasenode() for the combatant
-- when that happens the UI elements are drawn with label="", total=0.
-- Later, the onRoll handler comes back and uses this function to find
-- the result windowclass instance to store the modifier and total for display.
function getCombatantResultList(keyCT)
	ISC.dbg("==ISC_datamanager:getCombatantResultList(): keyCT=["..keyCT.."]")
    nResults = DB.createNode(RESULTS)
    if nResults == nil then return end
    return DB.createChild(nResults, keyCT)
end
-- next layer down from getCombatantResultList, this is a single result on
-- that list...
function getCombantantResultNode(keyCT, sSkill)
    if sSkill == nil then
        ISC.dbg("==ISC_datamanager:getCombantantResultNode(): pResult=keyCT=["..keyCT.."]")
        return DB.createNode(keyCT)
    else
	    ISC.dbg("==ISC_datamanager:getCombantantResultNode(): keyCT=["..keyCT.."] sSkill=["..sSkill.."]")
        return getCombatantResultList(keyCT).createChild(sSkill)
    end
end
-- these two functions are how we dynamically map all the skill roll results
-- in the database with the UI that displays those to the DM.

-- helper function, a kind of late binding for RESULTS parameter.
function clearResults()
	ISC.dbg("==ISC_datamanager:clearResults()")
    resetNode(RESULTS)
end