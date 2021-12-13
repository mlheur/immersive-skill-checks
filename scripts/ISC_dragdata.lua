-- https://www.fantasygrounds.com/forums/showthread.php?48145-Creating-Cloning-or-Writing-a-Class-for-dragdata
-- https://www.fantasygrounds.com/forums/showthread.php?50651-Custom-Draginfo

--When drag objects are set using the setData function, here is the expected format of the LUA table used to define the drag object:
--
--    type: String. Drag object type.
--    icon: String. Icon associated with this drag object.
--    description: String. Description associated with this drag object.
--    dbref: String (or databasenode). Data base node identifier (or databasenode object) associated with this drag object.
--    secret: Boolean. Flag indicating whether drag data should be displayed local only when dropped on chat window.
--    shortcuts: Table of shortcut records. Each shortcut record is a table containing class and recordname string fields. Any shortcut records associated with this drag object.
--    slots: Table of slot records. See below.
--
--    Each slot record is a LUA table with the following fields:
--    
--    type: String. Slot type.
--    number: Number. Numeric value associated with this slot.
--    string: String. Textual value associated with this slot.
--    token: String. Token identified associated with this slot.
--    shortcut: Table. Shortcut associated with this slot. Each shortcut record is a table containing class and recordname string fields.
--    dice: Table. Dice associated with this slot. The table contains numerically indexed die resource names.
--    metadata: Table. Metadata associated with this slot.
--    custom: Object. Custom LUA variable associated with this slot. This information will not be saved for drag objects placed on hot key bar.
    
dd = {}

function _slot()
    ISC.dbg("==ISC_dragdata:_slot()")
    s = {}
    s.type = nil
    s.number = nil
    s.string = nil
    s.token = nil
    s.shortcut = {} -- s.shortcut[1].class = "wndclass"; s.shortcut[1].recordname = rec
    s.dice = {} -- s.dice[1] = "d20"
    s.metadata = {} -- s.metadata[k] = v
    s.custom = nil
    return s
end

function createBaseData()
    ISC.dbg("==ISC_dragdata:createBaseData()")
    -- attrs
    dd.type = nil
    dd.icon = nil
    dd.description = nil
    dd.dbref = nil
    dd.secret = false
    dd.shortcuts = {}
    dd.slots = {_slot(type)}
    dd.slot_ptr = 1
    dd.hotkey_enabled = false
    dd.reveal = false
    -- functions
    dd.addDie = addDie
	dd.addShortcut = addShortcut
	dd.createBaseData = createBaseData
	dd.disableHotkeying = disableHotkeying
	dd.getCustomData = getCustomData
	dd.getDatabaseNode = getDatabaseNode
	dd.getDescription = getDescription
	dd.getDieList = getDieList
	dd.getMetaData = getMetaData
	dd.getMetaDataList = getMetaDataList
	dd.getNumberData = getNumberData
	dd.getSecret = getSecret
	dd.getShortcutData = getShortcutData
	dd.getShortcutList = getShortcutList
	dd.getSlot = getSlot
	dd.getSlotCount = getSlotCount
	dd.getSlotType = getSlotType
	dd.getStringData = getStringData
	dd.getTokenData = getTokenData
	dd.getType = getType
	dd.isType = isType
	dd.nextSlot = nextSlot
	dd.reset = reset
	dd.resetType = resetType
	dd.revealDice = revealDice
	dd.setCustomData = setCustomData
	dd.setData = setData
	dd.setDatabaseNode = setDatabaseNode
	dd.setDatabaseNode = setDatabaseNode
	dd.setDescription = setDescription
	dd.setDieList = setDieList
	dd.setIcon = setIcon
	dd.setMetaData = setMetaData
	dd.setNumberData = setNumberData
	dd.setSecret = setSecret
	dd.setShortcutData = setShortcutData
	dd.setSlot = setSlot
	dd.setSlotType = setSlotType
	dd.setStringData = setStringData
	dd.setTokenData = setTokenData
	dd.setType = setType
    return dd
end

function addDie(d)
    ISC.dbg("==ISC_dragdata:addDie("..d..")")
    table.insert(dd.slots[dd.slot_ptr].dice, d)
end

function addShortcut(c,r)
    ISC.dbg("==ISC_dragdata:addShortcut("..c..","..r..")")
    s = {}
    s.class = c
    s.record = r
    table.insert(dd.shortcuts, s)
end

function disableHotkeying(s)
    ISC.dbg("==ISC_dragdata:disableHotkeying("..s..")")
    s = s or false
    dd.hotkey_enabled = s
end

function getCustomData() return dd.slots[dd.slot_ptr].custom end
function getDatabaseNode() return dd.dbref end
function getDescription() return dd.description end
function getDieList() return dd.slots[dd.slot_ptr].dice end
function getMetaData(k) return dd.slots[dd.slot_ptr].metadata[k] end
function getMetaDataList() return dd.slots[dd.slot_ptr].metadata end
function getNumberData() return dd.slots[dd.slot_ptr].number end
function getSecret() return dd.secret end
function getShortcutData() return dd.slots[dd.slot_ptr].shortcut.class, dd.slots[dd.slot_ptr].shortcut.recordname end
function getShortcutList() return dd.slots[dd.slot_ptr].shortcut end
function getSlot() return dd.slot_ptr end
function getSlotCount() return #dd.slots end
function getSlotType() return dd.slots[dd.slot_ptr].type end
function getStringData() return dd.slots[dd.slot_ptr].string end
function getTokenData() return dd.slots[dd.slot_ptr].token end
function getType() return dd.type end
function isType(sCmp) return dd.type == sCmp end
function nextSlot() dd.slot_ptr = dd.slot_ptr + 1 end
function reset()
    dd = createBaseData()
end
function resetType() dd.type = dd.slots[dd.slot_ptr].type end
function revealDice(r) dd.reveal = r end
function setCustomData(c) dd.slots[dd.slot_ptr].custom = c end

function setData(dr)
    ISC.dbg("==ISC_dragdata:setData()")
    dd.type = dr.type
	dd.icon = dr.icon
	dd.description = dr.description
	dd.dbref = dr.dbref
	dd.secret = dr.secret
	dd.shortcuts = dr.shortcuts
	dd.slots = dr.slots
	dd.slot_ptr = dr.slot_ptr
	dd.hotkey_enabled = dr.hotkey_enabled
	dd.reveal = dr.reveal
end

function setDatabaseNode(n)
    if type(n) ~= "string" then
        n = n.getPath()
    end
    ISC.dbg("==ISC_dragdata:setDatabaseNode("..n..")")
    dd.dbref = n
end

function setDescription(d)
    ISC.dbg("==ISC_dragdata:setDescription("..d..")")
    dd.description = d
end

function setDieList(d)
    ISC.dbg("==ISC_dragdata:setDieList()")
    dd.slots[dd.slot_ptr]["dice"] = d
end

function setIcon(i)
    ISC.dbg("==ISC_dragdata:setIcon("..i..")")
    dd.icon = i
end

function setMetaData(k,v)
    ISC.dbg("==ISC_dragdata:setMetaData("..k..","..v..")")
    dd.slots[dd.slot_ptr]["metadata"][k] = v
end

function setNumberData(n)
    ISC.dbg("==ISC_dragdata:setNumberData("..n..")")
    dd.slots[dd.slot_ptr]["number"] = n
end

function setSecret(s)
    if s then ISC.dbg("==ISC_dragdata:setSecret(true)")
    else ISC.dbg("==ISC_dragdata:setSecret(false)")
    end
    dd.secret = s
end

function setShortcutData(c,r)
    ISC.dbg("==ISC_dragdata:setShortcutData("..c..","..r..")")
    s = {}
    s.class = c
    s.recordname = r
    dd.slots[dd.slot_ptr].shortcut = s
end

function setSlot(i)
    i = i or 1
    oMax = #dd.slots
    ISC.dbg("==ISC_dragdata:setSlot("..i..") oMax["..oMax.."]")
    dd.slot_ptr = i
    i = i + 1
    while i <= oMax do
        dd.slots[i] = nil
        i = i + 1
    end
end

function setSlotType(t)
    ISC.dbg("==ISC_dragdata:setSlotType("..t..")")
    dd.slots[dd.slot_ptr]["type"] = t
end

function setStringData(s)
    ISC.dbg("==ISC_dragdata:setStringData("..s..")")
    dd.slots[dd.slot_ptr]["string"] = s
 end

 function setTokenData(t)
    ISC.dbg("==ISC_dragdata:setTokenData("..t..")")
    dd.token = t
end

function setType(t)
    ISC.dbg("==ISC_dragdata:setType("..t..")")
    dd.type = t
end
