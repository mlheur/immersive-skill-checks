# Immersive Skill Checks

Extension for Fantasy Grounds that automatically rolls some skill checks for all PCs and tracked NPCs.

These rolls are considered 'immersive' in the sense players should be unaware what their D20 result was, and whether any given failure was due to lack of skill or just bad luck with the dice.

Installation:
 - download the latest version
```
 cd <fantasy_grounds_data_dir>/extensions
 git clone https://github.com/mlheur/immersive-skill-checks
```
 - enable extension "immersive-skill-checks" when creating or loading the campaign

Feedback:
 - "You need to give this to FG just so that it rolls random dice at the top of the combat tracker", Cloak

To Do:
 - clicking on token opens charsheet or npc record
 - auto resize main window, add limits
 - make onUpdate callbacks more efficient, only accessing updated nodes rather than walking the list
 - add an option selection to share roll results with players (immersion breaking IMO)
 - remove inneficcient debugging loops, comment all ISC.dbg calls?
 - package it up as .ext
 - share and solicit feedback
 - auto adjust long skill names, like long PC/NPC names
 - horizontal scrollbar
 - thorough testing of ADV/DIS and other special modifiers.
 - better first init handling, had to reset a few times.
 - option to show results in chat window

Being Tested:
 - better handling when PC has never activated their charsheet.skilllist nodes
 - include custom skills, beyond DataCommon.skilldata, .psskilldata
 - fix db.xml <ISC><id-00001 /></ISC>
 - auto adjust PC/NPC names to see the NPC # (suggest: if len(name)>15 name=left(name,10)+"..."+right(name,2))
 - add nodes and remap character results list on title change or combattracker.list change
 - update ISC data when db.xml <skill> children are added/deleted.

Done:
 - improve spacing (tighter rows, adjust long skill names)
 - sanitize whitespace
