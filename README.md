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

To Do:
 - clicking on token opens charsheet or npc record
 - auto resize main window, add limits
 - add nodes and remap character results list on skill immersion change or combattracker.list change
 - make onUpdate callbacks more efficient, only accessing updated nodes rather than walking the list
 - add an option selection to share roll results (immersion breaking IMO)
 - remove inneficcient debugging loops, comment all ISC.dbg calls?
 - sanitize whitespace
 - package it up as .ext
 - improve spacing (tighter rows, adjust long skill names)
 - include custom skills, beyond DataCommon.skilldata, .psskilldata
 - share and solicit feedback
 - better handling when PC has never activated their charsheet.skilllist nodes
 - auto adjust PC/NPC names to see the NPC # (suggest: if len(name)>15 name=left(name,10)+"..."+right(name,2))