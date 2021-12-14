-- these database path values are tightly coupled with the UI data in the XML files.
DBPATH = "ISC"
SKILLS = DBPATH..".immersive-selection"
TITLES = DBPATH..".skill-titles"
RESULTS = DBPATH..".results"
LAST_ROUND = DBPATH..".last-rolled-round"

--------------------------------------------------------------------------------
-- INITs, general DB functions
--------------------------------------------------------------------------------

function init()
    DB.createChild(DBPATH) -- ensure our DB node exists
    getAutoRoll() -- set a default value if none exists
    if DB.getChild(SKILLS) == nil then -- more defaults
        ISC_SkillsMgr.setDefaultImmersiveSkills()
    end
	DB.addHandler(SKILLS..".*.immersive", "onUpdate", resetTitles) -- reset the list skill titles when the immersive settings change
	DB.addHandler("combattracker.round", "onUpdate", doAutoRoll ) -- for enabling autoroll
	ActionsManager.registerResultHandler("immersive-skill-check", ISC_ResultsMgr.onRoll) -- this is how to register a callback to get the result of a die throw.
end

-- factor out any DB calls into ISC_DataMgr
function resetNode(dbPath)
	ISC.dbg("==ISC_datamanager:resetNode(): dbPath=["..dbPath.."]")
    DB.deleteChildren(dbPath)
end

-- internal helper function to do error checking before calling getValue().
function getDBNodeValue(dbPath, attr)
    if type(dbPath) ~= "string" then dbPath = dbPath.getPath() end
	ISC.dbg("==ISC_datamanager:getDBNodeValue(): dbPath=["..dbPath.."] attr=["..attr.."]")
    local node = DB.getChild(dbPath)
    if node == nil then return nil end
    return DB.getValue(node, attr)
end

--------------------------------------------------------------------------------
-- Combat Round Data Mgmt
--------------------------------------------------------------------------------

function getRound()
    return DB.getValue("combattracker.round")
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
function resetTitles(nUpdated)
	ISC.dbg("++ISC_datamanager:resetTitles()")
    aTitles = {}
    resetNode(TITLES)
    for sSkill,vSkill in pairs(getAllGameSkills()) do
        data = getSkillData(sSkill)
        if data["immersive"] ~= 0 then
            DB.createNode(TITLES.."."..sSkill..".name","string").setValue(sSkill)
            aTitles[sSkill] = true
        end
    end
	ISC.dbg("--ISC_datamanager:resetTitles()")
    return aTitles
end

function getAllGameSkills()
	ISC.dbg("++ISC_datamanager:getAllGameSkills()")
    allskills = {}
    for sSkill,vSkill in pairs(DataCommon.skilldata) do
        ISC.dbg("  ISC_datamanager:getAllGameSkills() found DataCommon.skilldata["..sSkill.."]")
        data = {}
        data["name"] = sSkill
        data["stat"] = vSkill["stat"]
        data["source"] = "DataCommon"
        allskills[data["name"]] = data
    end
    -- this will overwrite any 5e skills with the same name,
    -- not really sure a better to deal with collisions while
    -- I'm only passing a string value beteween functions.
    -- ToDo: refactor function signatures to take a skill node
    for keySkill,nSkill in pairs(DB.getChildren("skill")) do
        ISC.dbg("  ISC_datamanager:getAllGameSkills() found DB.skill.["..keySkill.."]")
        data = {}
        data["name"] = getDBNodeValue(nSkill, "name")
        data["stat"] = getDBNodeValue(nSkill, "stat"):lower()
        data["source"] = "DB"
        allskills[data["name"]] = data
    end
	ISC.dbg("--ISC_datamanager:getAllGameSkills()")
    return allskills
end

-- For each skill in the game, keep track of whether the DM considers it
-- an immersive skill or not.  Naively we could store this in the DB as
--     <...><skillname type="number">1</skillname></...>
-- Except we can't do that because the skillname in the XML tag replaces
-- spaces with underscores.  We need the actual name in the UI data
-- so we have to store the immersive value alongside the name of the skill:
--  <Sleight_of_Hand>
--    <immersive type="number">0</immersive>
--    <name type="string">Sleight of Hand</name>
--  </Sleight_of_Hand>
-- Here's how we abstract those nasty details from the rest of the code.
function addSkillNode(vSkill)
    ISC.dbg("++ISC_datamanager:addSkillNode()")
    -- There's room for lots more data integrity checking before proceeding.
    -- That's only useful if the caller makes any mistakes, and will increase
    -- cycle time.  Since we have few callers, it's more efficient to manage
    -- the callers instead of increasing cycle time.
    if isValidGameSkill(vSkill["name"]) then
        vSkill["immersive"] = vSkill["immersive"] or 0
        local dbPath = SKILLS .. "." .. vSkill["name"]; -- this is where dbpath will have underscores added.
        DB.createNode(dbPath .. ".name","string").setValue(vSkill["name"]);
        DB.createNode(dbPath .. ".immersive","number").setValue(vSkill["immersive"])
        DB.createNode(dbPath .. ".stat","string").setValue(vSkill["stat"])
        DB.createNode(dbPath .. ".source","string").setValue(vSkill["source"])
        ISC.dbg("  ISC_datamanager:addSkillNode(): added skill=["..vSkill["name"].."] immersive=["..vSkill["immersive"].."]")
    else -- this else clause is just for debugging.  Should be removed for efficiency.
        ISC.dbg("  ISC_datamanager:addSkillNode(): is not a valid skill")
    end
    ISC.dbg("--ISC_datamanager:addSkillNode()")
end

-- Pull out DB data and return it as a table. This is the inverse function of addSkillNode().
function getSkillData(sSkill)
	ISC.dbg("++ISC_datamanager:getSkillData(): sSkill=["..sSkill.."]")
    data = {}
    pSkill = SKILLS .. "." .. sSkill;
    data["name"] = getDBNodeValue(pSkill, "name")
    data["immersive"] = getDBNodeValue(pSkill, "immersive") or 0
    data["stat"] = getDBNodeValue(pSkill, "stat")
    data["source"] = "DB"
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