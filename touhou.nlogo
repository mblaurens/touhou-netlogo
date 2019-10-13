;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;  variables and crap  ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

globals
[ toDo wasMouseDown?
  curScreen
  cursor p1 
  
  weapon subweapon subcontroller bombed?
  flinchTimer flinching?
  
  bossT bossSpawned? bUITList
  bPatternT bHPT bHPBracketL bHPBracketR bCountdownT
  
  hscoreTList scoreTList livesTList bombsTList powerTList grazeTList pointTList
  hscore score lives bombs power powerBonus graze point difficulty 
  progress progressT checkpointT pBracketL pBracketR
  energy energyT eBracketL eBracketR
  mode stage checkpoint stageEnd
  
  scorescreen? ssTList
  ssln1TList ssln2TList ssln3TList ssln4TList ssln5TList ssln6TList ssln7TList
  
  subcool tracker Etracker
  ]

breed [UITs UIT]
breed [buttonTs buttonT]
breed [players player]
breed [enemies enemy]
breed [bosses boss]
breed [bullets bullet]
breed [markers marker]
breed [explosions explosion]
breed [particles particle]
breed [powerups powerup]
breed [fadetexts fadetext]
breed [holders holder]
breed [Emarkers Emarker]

buttonTs-own [coords title action baseCol hoverCol]
players-own [cooldown]
enemies-own [hp move ai cooldown spawnTime speed turn]
bosses-own [hp maxhp ai ailist cooldown pattern countdown maxcountdown destx desty time]
bullets-own [enemy? ai hitbox damageset lengthmove subcount charge charge? graze? delay]
particles-own [deathTimer speed]
explosions-own [explodetimer damageset enemy? ai hitbox lengthmove subcount charge charge?]
powerups-own [ptype bomb?]
fadetexts-own [deathTimer speed]
holders-own [ai]





;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;  setup and go  ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;Alex
;change
;because some of us need a way to actually beta test...
to cheat
  set lives 9001
  set bombs 9001
end

;Lawrence
;Because I hate having to click setup every time.
to startup
  setup
end

;Lawrence
to setup
  ;boring crap
  ca
  reset-ticks
  
  ;initialize variables
  set toDo task[gotoMain]
  set wasMouseDown? false
  
  set hscore 99999999
  
  set subcontroller false
  set scoreTlist (list)
  set hscoreTlist (list)
  set livesTlist (list)
  set bombsTlist (list)
  set powerTlist (list)
  set grazeTlist (list)
  set pointTlist (list)
  set bUITlist (list)
  
  set ssTlist (list)
  set ssln1TList (list)
  set ssln2TList (list)
  set ssln3TList (list)
  set ssln4TList (list)
  set ssln5TList (list)
  set ssln6TList (list)
  set ssln7TList (list)

  set-default-shape enemies "flower"  ;pretty flowers ;A;
  set-default-shape bosses "sheep"    ;ocrapsheep
  set-default-shape powerups "square" ;ne
  
  ;invisi-cursor
  cro 1 [set cursor self hide-turtle]
end

;Lawrence
to go
  run toDo
  set toDo task []
  
  ask cursor [cursorAI]
  
  if curScreen = "MAIN"
  [ ask buttonTs [buttonTAI]]
  
  if curScreen = "GAMESETUP"
  [ ask buttonTs [buttonTAI]]
  
  if curscreen = "LEVELSELECT"
  [ ask buttonTs [buttonTAI]]
  
  if curScreen = "GAME"
  [ ask players [ playerAI]
    ask enemies [ enemyAI]
    ask bullets [ bulletAI]
    ask explosions [ explosionAI]
    ask particles [ particleAI]
    ask bosses [ bossAI]
    ask powerups [ powerupAI]
    ask fadetexts [ fadetextAI]
    runStage]
  
  set wasMouseDown? mouse-down?
  
  ;boring crap
  wait 1 / 30
  tick
end

;Lawrence
to runStage
  set bombed? bombed? - 1
  if stage mod 1 = 0.5 [runScoreScreen]
  if stage = 0 [runGameOver]
  if stage = 1 [runStageOne]
  if stage = 2 [runStageTwo]
  if stage = 3 [runStageThree]
  ;if stage = 4 [runStageFour]
  ;if stage = 5 [runStageFive]
  ;if stage = 6 [runStageSix]
  ;if stage = 7 [runGameEnd]
  
  ;(UGLY)
  ;progress meter
  if stage != 0 [
  if progress < stageEnd and progress != checkpoint [set progress progress + 1]
  if progress > stageEnd [nextStage]
  ask progressT [setxy (7 + (progress * 18 / stageEnd)) ycor]]
  
  ;energy meter
  ;change
  if stage mod 1 != 0.5
  [ if energy < 1000 [set energy energy + 1]
    if energy > 1000 [set energy 1000]
    ask energyT [setxy (31 + (energy * 7 / 1000)) ycor]]
  
  ;boss meter
  ifelse bossT != nobody
  [ foreach bUITlist [ask ? [show-turtle ask my-links [show-link]]]
    ask bHPT [setxy (6 + ([hp] of bossT * 18 / [item pattern maxHP] of bossT)) ycor]
    ask bPatternT [set label [pattern] of bossT]
    ask bCountdownT [set label [ceiling (countdown / 30)] of bossT]]
  [ foreach bUITlist [ask ? [hide-turtle ask my-links [hide-link]]]]
  
  let x 0 let y 0
  ;score
  set x 0 set y score
  while [x < 8]
  [ ask item x scoreTlist [set label y mod 10]
    set y ((y - (y mod 10)) / 10) set x x + 1]
  
  ;highscore
  set x 0 set y hscore
  while [x < 8]
  [ ask item x hscoreTlist [set label y mod 10]
    set y ((y - (y mod 10)) / 10) set x x + 1]
  
  ;lives
  set x 0
  while [x < 8]
  [ ask item x livesTlist [set hidden? (x < (8 - lives))]
    set x x + 1]
  
  ;bombs
  set x 0
  while [x < 8]
  [ ask item x bombsTlist [set hidden? (x < (8 - bombs))]
    set x x + 1]
  
  ;power
  set x 0 set y power
  while [x < 3]
  [ ask item x powerTlist [set label y mod 10]
    set y ((y - (y mod 10)) / 10) set x x + 1]
  
  ;graze
  set x 0 set y graze
  while [x < 3]
  [ ask item x grazeTlist [set label y mod 10]
    set y ((y - (y mod 10)) / 10) set x x + 1]
  
  ;point
  set x 0 set y point
  while [x < 3]
  [ ask item x pointTlist [set label y mod 10]
    set y ((y - (y mod 10)) / 10) set x x + 1]
end


;Lawrence
to nextStage
  ask enemies [enemyDeath]
  ask bullets [bulletDeath]
  ifelse ((stage mod 1) = 0.5) and mode = "LEVELSELECT"
  [set stage 0][set stage stage + 0.5]
  set progress 0
  if stage mod 1 = 0
  [ set graze 0
    set point 0]
  set bossSpawned? false
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;  menus and stuffs  ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Lawrence
to gotoMain
  cleanupLastScreen
  set curScreen "MAIN"
  
  create-buttonTs 1 
  [ set title "START" set action task[gotoGameSetup false]
    setxy 29.5 24 set size 0
    set coords (list 20 37 23 26) ;x1 x2 y1 y2
    set baseCol blue set hoverCol yellow]
  
  create-buttonTs 1 
  [ set title "LEVEL SELECT" set action task[gotoGameSetup true]
    setxy 30.5 19 set size 0
    set coords (list 20 37 18 21) ;x1 x2 y1 y2
    set baseCol blue set hoverCol yellow]
  
  create-buttonTs 1 
  [ set title "NOTHING!" set action task[]
    setxy 30 14 set size 0
    set coords (list 20 37 13 16) ;x1 x2 y1 y2
    set baseCol blue set hoverCol yellow]
  
  create-buttonTs 1 
  [ set title "NOTHING!" set action task[]
    setxy 30 9 set size 0
    set coords (list 20 37 8 11) ;x1 x2 y1 y2
    set baseCol blue set hoverCol yellow]
  
  create-buttonTs 1 
  [ set title "NOTHING!" set action task[]
    setxy 30 4 set size 0
    set coords (list 20 37 3 6) ;x1 x2 y1 y2
    set baseCol blue set hoverCol yellow]
  
  drawMain
end

;Lawrence
to gotoGameSetup [levelselect?]
  cleanupLastScreen
  set curScreen "GAMESETUP"
  
  create-buttonTs 1 
  [ set title "BACK" set action task[gotoMain]
    setxy 4.3 26 set size 0
    set coords (list 2 5 26 27) ;x1 x2 y1 y2
    set baseCol blue set hoverCol yellow]
  
  create-buttonTs 1 
  [ set title "EASY" 
    ifelse levelselect? [set action task[gotoLevelSelect]][set action task [set stage 1 set difficulty 0 gotoGame "STORY"]]
    setxy 10 21.5 set size 0
    set coords (list 2 17 20 24) ;x1 x2 y1 y2
    set baseCol blue set hoverCol yellow]
  
  create-buttonTs 1 
  [ set title "ALSO EASY" 
    ifelse levelselect? [set action task[gotoLevelSelect]][set action task [set stage 1 set difficulty 1 gotoGame "STORY"]]
    setxy 11 15.5 set size 0
    set coords (list 2 17 14 18) ;x1 x2 y1 y2
    set baseCol blue set hoverCol yellow]
  
  create-buttonTs 1 
  [ set title "STILL EASY" 
    ifelse levelselect? [set action task[gotoLevelSelect]][set action task [set stage 1 set difficulty 2 gotoGame "STORY"]]
    setxy 11 9.5 set size 0
    set coords (list 2 17 8 12) ;x1 x2 y1 y2
    set baseCol blue set hoverCol yellow]
  
  create-buttonTs 1 
  [ set title "GETTING TO IT LATER" 
    ifelse levelselect? [set action task[gotoLevelSelect]][set action task [set stage 1 set difficulty 3 gotoGame "STORY"]]
    setxy 13 3.5 set size 0
    set coords (list 2 17 2 6) ;x1 x2 y1 y2
    set baseCol blue set hoverCol yellow]
  
  create-buttonTs 1
  [ set title "CYCLE WEAPON" set action task[cycleWeapon]
    setxy 32 25 set size 0
    set coords (list 23 36 24 27)
    set baseCol blue set hoverCol yellow]
  ask patch 34 27 [set plabel-color black] set weapon 2 cycleweapon
  
  create-buttonTs 1
  [ set title "CYCLE SUBWEAPON" set action task[cycleSubweapon]
    setxy 32.5 15 set size 0
    set coords (list 23 36 14 17)
    set baseCol blue set hoverCol yellow]
  ask patch 34 17 [set plabel-color black] set subweapon "Bullet Hell" cycleSubweapon
  
  drawGameSetup
end

;Lawrence
to gotoLevelSelect
  cleanupLastScreen
  set curScreen "LEVELSELECT"
  
  create-buttonTs 1 
  [ set title "BACK" set action task[gotoMain]
    setxy 4.3 26 set size 0
    set coords (list 2 5 26 27) ;x1 x2 y1 y2
    set baseCol red set hoverCol yellow]
  
  create-buttonTs 1 
  [ set title "STAGE 1" set action task[set stage 1 gotoGame "LEVELSELECT"]
    setxy 8 22 set size 0
    set coords (list 2 13 14 23) ;x1 x2 y1 y2
    set baseCol red + 2 set hoverCol yellow + 2]
  
  create-buttonTs 1 
  [ set title "STAGE 2" set action task[set stage 2 gotoGame "LEVELSELECT"]
    setxy 20 22 set size 0
    set coords (list 14 25 14 23) ;x1 x2 y1 y2
    set baseCol red set hoverCol yellow]
  
  create-buttonTs 1 
  [ set title "STAGE 3" set action task[set stage 3 gotoGame "LEVELSELECT"]
    setxy 32 22 set size 0
    set coords (list 26 37 14 23) ;x1 x2 y1 y2
    set baseCol red + 2 set hoverCol yellow + 2]
  
  create-buttonTs 1 
  [ set title "STAGE 4" set action task[]
    setxy 8 11 set size 0
    set coords (list 2 13 3 12) ;x1 x2 y1 y2
    set baseCol red set hoverCol yellow]
  
  create-buttonTs 1 
  [ set title "STAGE 5" set action task[]
    setxy 20 11 set size 0
    set coords (list 14 25 3 12) ;x1 x2 y1 y2
    set baseCol red + 2 set hoverCol yellow + 2]
  
  create-buttonTs 1 
  [ set title "STAGE 6" set action task[]
    setxy 32 11 set size 0
    set coords (list 26 37 3 12) ;x1 x2 y1 y2
    set baseCol red set hoverCol yellow]
  
  drawLevelSelect
end

;Lawrence
to gotoGame [curmode]
  cleanupLastScreen
  set mode curmode
  set curScreen "GAME"
  
  drawGame
  
  ;player~~
  create-players 1 [set color sky setxy 13 5 set heading 0 set p1 self set subcontroller false]
  
  create-UITs 1 [set bUITlist (lput self bUITlist) setxy 4 27.5 set size 0 set label "ENEMY"]
  create-UITs 1 [set bUITlist (lput self bUITlist) set bPatternT self setxy 5 27.5 set size 0]
  create-UITs 1 [set bUITlist (lput self bUITlist) set bHPBracketL self setxy 6 28 set shape "square" set color orange]
  create-UITs 1 [set bUITlist (lput self bUITlist) set bHPBracketR self setxy 24 28 set shape "square" set color orange]
  create-UITs 1 [set bUITlist (lput self bUITlist) set bHPT self setxy 24 28 set heading 90 set size 0 create-link-with bHPBracketL [set color green set thickness 0.5]]
  create-UITs 1 [set bUITlist (lput self bUITlist) set bCountdownT self setxy 25.25 27.5 set size 0]
  
  create-UITs 1 [setxy 5.5 0.5 set size 0 set label "PROGRESS"]
  create-UITs 1 [set pBracketL self setxy 7 1 set shape "square 2" set color grey]
  create-UITs 1 [set pBracketR self setxy 25 1 set shape "square 2" set color grey create-link-with pBracketL]
  create-UITs 1 [set checkpointT self setxy 16 1 set shape "circle 2" set color grey]
  create-UITs 1 [set progressT self setxy 7 1 set heading 90 set color sky]
  
  create-UITs 11
  [ set ssTlist (lput self ssTlist)
    set ssln1Tlist (lput self ssln1Tlist) 
    setxy (3 + length ssln1Tlist) 23.5
    set size 0]
  let x 0
  while [x < length ssln1Tlist]
  [ ask item x ssln1Tlist [set label item x "Stage Clear"]
    set x x + 1]
  
  create-UITs 20
  [ set ssTlist (lput self ssTlist)
    set ssln2Tlist (lput self ssln2Tlist) 
    setxy (3 + length ssln2Tlist) 21.5
    set size 0]
  set x 0
  while [x < length ssln2Tlist]
  [ ask item x ssln2Tlist [set label item x "Stage * 1000 =      "]
    set x x + 1]
  
  create-UITs 20
  [ set ssTlist (lput self ssTlist)
    set ssln3Tlist (lput self ssln3Tlist) 
    setxy (3 + length ssln3Tlist) 20.5
    set size 0]
  set x 0
  while [x < length ssln3Tlist]
  [ ask item x ssln3Tlist [set label item x "Power *  100 =      "]
    set x x + 1]
  
  create-UITs 20
  [ set ssTlist (lput self ssTlist)
    set ssln4Tlist (lput self ssln4Tlist) 
    setxy (3 + length ssln4Tlist) 19.5
    set size 0]
  set x 0
  while [x < length ssln4Tlist]
  [ ask item x ssln4Tlist [set label item x "Graze *   10 =      "]
    set x x + 1]
  
  create-UITs 20
  [ set ssTlist (lput self ssTlist)
    set ssln5Tlist (lput self ssln5Tlist) 
    setxy (3 + length ssln5Tlist) 18.5
    set size 0]
  set x 0
  while [x < length ssln5Tlist]
  [ ask item x ssln5Tlist [set label item x "    * Point Item    "]
    set x x + 1]
  
  create-UITs 20
  [ set ssTlist (lput self ssTlist)
    set ssln6Tlist (lput self ssln6Tlist) 
    setxy (3 + length ssln6Tlist) 16.5
    set size 0]
  set x 0
  while [x < length ssln6Tlist]
  [ ask item x ssln6Tlist [set label item x "Difficulty     *    "]
    set x x + 1]
  
  create-UITs 20
  [ set ssTlist (lput self ssTlist)
    set ssln7Tlist (lput self ssln7Tlist) 
    setxy (3 + length ssln7Tlist) 15.5
    set size 0]
  set x 0
  while [x < length ssln7Tlist]
  [ ask item x ssln7Tlist [set label item x "Total     =         "]
    set x x + 1]
  
  foreach ssTlist [ask ? [hide-turtle]]
  
  
  create-UITs 8
  [ set hscoreTlist (lput self hscoreTlist) 
    setxy (39 - length hscoreTlist) 26.5
    set size 0]
  create-UITs 1 [setxy 29 26.5 set size 0 set label "TOP"]
  
  create-UITs 8
  [ set scoreTlist (lput self scoreTlist) 
    setxy (39 - length scoreTlist) 25.5
    set size 0]
  create-UITs 1 [setxy 29 25.5 set size 0 set label "SCORE"]
  
  create-UITs 8
  [ set livesTlist (lput self livesTlist) 
    setxy (39 - length livesTlist) 24
    set hidden? true set color green set shape "star"]
  create-UITs 1 [setxy 29 23.5 set size 0 set label "PLAYER"]
  
  create-UITs 8
  [ set bombsTlist (lput self bombsTlist) 
    setxy (39 - length bombsTlist) 23
    set hidden? true set color red set shape "star"]
  create-UITs 1 [setxy 29 22.5 set size 0 set label "BOMB"]
  
  create-UITs 3
  [ set powerTlist (lput self powerTlist) 
    setxy (34 - length powerTlist) 18.5
    set size 0]
  create-UITs 1 [setxy 29 18.5 set size 0 set label "POWER"]
  
  create-UITs 3
  [ set grazeTlist (lput self grazeTlist) 
    setxy (34 - length grazeTlist) 17.5
    set size 0]
  create-UITs 1 [setxy 29 17.5 set size 0 set label "GRAZE"]
  
  create-UITs 3
  [ set pointTlist (lput self pointTlist) 
    setxy (34 - length pointTlist) 16.5
    set size 0]
  create-UITs 1 [setxy 29 16.5 set size 0 set label "POINT"]
  
  create-UITs 1 [setxy 29 15.5 set size 0 set label "ENERGY"]
  create-UITs 1 [set eBracketL self setxy 31 16 set shape "square" set color orange]
  create-UITs 1 [set eBracketR self setxy 38 16 set shape "square" set color orange]
  create-UITs 1 [set energyT self setxy 38 16 set heading 90 set size 0 create-link-with eBracketL [set color green set thickness 0.5]]
  
  set progress 0
  set score 0
  set lives 3
  set bombs 2
  set power 0
  set graze 0
  set point 0
  set energy 200
end

;Lawrence
to showStageScore
  ;create-UITs
end

;Lawrence
to drawMain
  ask patches [set pcolor red]
end

;Lawrence
to drawGameSetup
  ask patches [set pcolor green]
end

;Lawrence
to drawLevelSelect
  ask patches [set pcolor blue]
end

;Lawrence
to drawGame
  ask patches with [pycor = max-pycor or pycor = min-pycor or pxcor < 2 or pxcor > 25]
  [set pcolor blue]
  ask patches with [pycor < max-pycor and pycor > min-pycor and pxcor >= 2 and pxcor <= 25]
  [set pcolor black]
end

;Lawrence
to cleanupLastScreen
  if curScreen = "MAIN" [mainCleanup]
  if curScreen = "GAMESETUP" [gamesetupCleanup]
  if curScreen = "LEVELSELECT" [levelSelectCleanup]
  if curScreen = "GAME" [gameCleanup]
end

;Lawrence
to mainCleanup
  ask buttonTs [die]
end

;Lawrence
to gamesetupCleanup
  ask buttonTs [die]
  ask patches [set plabel ""]
end

;Lawrence
to levelSelectCleanup
  ask buttonTs [die]
end

;Lawrence
to gameCleanup
  ask players [die]
  ask bullets [die]
  ask enemies [die]
  ask bosses [die]
  ask particles [die]
  ask UITs [die]
  ask powerups [die]
  ask fadetexts [die]
  
  set scoreTlist (list)
  set hscoreTlist (list)
  set livesTlist (list)
  set bombsTlist (list)
  set powerTlist (list)
  set grazeTlist (list)
  set pointTlist (list)
  set bUITlist (list)
  
  set ssTlist (list)
  set ssln1TList (list)
  set ssln2TList (list)
  set ssln3TList (list)
  set ssln4TList (list)
  set ssln5TList (list)
  set ssln6TList (list)
  set ssln7TList (list)
end

;Lawrence
to cycleWeapon
  ifelse weapon < 2 [set weapon weapon + 1][set weapon 0]
  if weapon = 0 [ask patch 34 27 [set plabel "Normal"]]
  if weapon = 1 [ask patch 34 27 [set plabel "Shotgun"]]
  if weapon = 2 [ask patch 34 27 [set plabel "Vulcan"]]
end

;Lawrence
to cycleSubweapon
  let changed? false
  if not changed? and subweapon = "Homing" [set subweapon "Charge Shot" set changed? true]
  if not changed? and subweapon = "Charge Shot" [set subweapon "Energy Sphere" set changed? true]
  if not changed? and subweapon = "Energy Sphere" [set subweapon "Spread Explode" set changed? true]
  if not changed? and subweapon = "Spread Explode" [set subweapon "Flamethrower" set changed? true]
  if not changed? and subweapon = "Flamethrower" [set subweapon "Bullet Hell" set changed? true]
  if not changed? and subweapon = "Bullet Hell" [set subweapon "Homing" set changed? true]
  ask patch 34 17 [set plabel subweapon]
end

;Lawrence
to buttonTAI
  set label title
  ifelse [inPRect? [coords] of myself] of cursor
  [ ask patches with [inPRect? [coords] of myself]
    [ set pcolor [hoverCol] of myself]
    set label-color baseCol
    if clicking? [set toDo action]]
  [ ask patches with [inPRect? [coords] of myself] 
    [ set pcolor [baseCol] of myself]
    set label-color hoverCol]
end





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;  turtle behaviors  ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Lawrence
to cursorAI
  setxy mouse-xcor mouse-ycor
end

;Alex
to playerAI
  face cursor
  let dist 0.8
  if distance cursor < 0.8 [set dist distance cursor]
  if can-fd? dist [fd dist]
  
  fireWeapon
  set cooldown cooldown - 1
  
  if flinchTimer > 0
  [ set hidden? not ((flinchTimer mod 3) = 0)]
  if flinchTimer = 0
  [ set hidden? false set flinching? false]
  set flinchTimer flinchTimer - 1
  
  if subcontroller = true
  [firesubweapon]
  set subcool subcool - 1
  set tracker tracker + 1
end

;Lawrence
to grazeEffect
  hatch-particles 4
  [ set heading random 360 
    set size random-float 0.6 + 0.2
    set speed random-float 0.7 + 0.4
    set deathTimer random 10 + 5]
  hatch-particles 4
  [ set shape "circle"
    set heading random 360 
    set size random-float 0.3 + 0.1
    set speed random-float 0.6 + 0.3
    set deathTimer random 5 + 10]
  set score score + 10
end

;Alex
To subchange
  set subcontroller not subcontroller
end

;Alex
To firesubweapon
  if subweapon = "Homing"
  [homing]
  if subweapon = "Charge Shot"
  [chargeshot]
  if subweapon = "Energy Sphere"
  [energysphere]
  if subweapon = "Spread Explode"
  [spreadexplode]
  if subweapon = "Flamethrower"
  [flamethrower]
  if subweapon = "Bullet Hell"
  [bullethell]
end

;Lawrence
to bomb
  if bombs > 0
  [ set bombs bombs - 1
    set bombed? 2
    ask bullets [bulletDeath]
    ask enemies [enemyDeath]
    ask bosses [set hp hp - 100]
    create-particles 200
    [ setxy (3 + random 22) (2 + random 26)
      set heading random 360 
      set size random-float 0.8 + 0.3
      set speed random-float 1.4 + 0.2
      set deathTimer random 10 + 5]
    create-particles 100
    [ setxy (3 + random 22) (2 + random 26)
      set shape "circle"
      set heading random 360 
      set size random-float 0.4 + 0.1
      set speed random-float 0.7 + 0.1
      set deathTimer random 5 + 10]]
end

;Lawrence
to fireWeapon
  if weapon = 0 [weapNormal]
  if weapon = 1 [weapShotgun]
  if weapon = 2 [weapVulcan]
end

;Lawrence
;Alex
to enemyAI
  if hp < 1 [enemyDeath]
  if move = 1 [eMove1]
  if move = 2 [eMove2]
  if move = 2.5 [eMove2.5]
  if move = 3 [eMove3]
  if ai = 1 [enemy1] ;point and shoot
  if ai = 2 [enemy2] ;8 direction shot
  if ai = 3 [enemy3] ;spray shot cooldown
  if ai = 4 [enemy4] ;spray shot
  if ai = 5 [enemy5] ;shotgun
  if ai = 6 [enemy6] ;mass target
  if ai = 7 [enemy7] ;spawner
  
  set spawnTime spawnTime - 1
end

;Lawrence
to bossAI
  if hp < 1 or countdown = 0 [nextPattern]
  if ai = 1001 [boss1001]
  if ai = 1002 [boss1002]
  if ai = 1003 [boss1003]
  if ai = 1004 [boss1004]
  if ai = 1005 [boss1005]
  if ai = 1006 [boss1006]
  if ai = 1007 [boss1007]
  if ai = 1008 [boss1008]
  if ai = 1009 [boss1009]
  if ai = 1010 [boss1010]
  if ai = 1501 [boss1501]
  if ai = 1502 [boss1502]
  if ai = 1503 [boss1503]
  set time time - 1
  set countdown countdown - 1
end

;Both
to bulletAI
  if ai = 1 [bullet1]
  if ai = 2 [bullet2]
  if ai = 501 [bullet501]
  if ai = 502 [bullet502]
  if ai = 503 [bullet503]
  ;if ai = 504 [bullet504]
  ;if ai = 505 [bullet505]
  if ai = 1001 [playerbullet1]
  if ai = 1002 [playerbullet2]
  if ai = 1003 [playerbullet3]
  if ai = 2001 [subweapon1]
  if ai = 2002 [subweapon2]
  if ai = 2002.5 [subweapon2.5]
  if ai = 2003 [subweapon3]
  if ai = 2003.5 [subweapon3.5]
  if ai = 2004 [subweapon4]
  if ai = 2005 [subweapon5]
  if ai = 2006 [subweapon6]
  
  ;enemy bullet hit detection
  if any? players in-radius hitbox with [not hidden?] and enemy? and not flinching?
  [ ask p1 [playerDeath]
    die]
  if any? players in-radius (hitbox + 1) with [not hidden?] and enemy? and not flinching? and graze? = 0
  [ ask p1 [grazeEffect]
    set graze? 1 set graze graze + 1]
  ;player bullet hit detection
  if any? enemies with [distance myself < ([hitbox] of myself + (size / 2))] and not enemy?
  [ask enemies with [distance myself < ([hitbox] of myself + (size / 2))]
     [set hp hp - [damageset] of myself]
     die]
  if any? bosses with [distance myself < ([hitbox] of myself + (size / 2))] and not enemy?
  [ask bosses with [distance myself < ([hitbox] of myself + (size / 2))]
     [set hp hp - [damageset] of myself]
     die]
end

;Lawrence
to bulletDeath
  set score score + 10
  hatch-fadetexts 1 [set label 10 set size 0 set heading 0 set deathTimer 15]
  die
end

;Lawrence
to playerDeath
  hatch-particles 50
  [ set heading random 360 
    set size random-float 1.4 + 0.4
    set speed random-float 2 + 0.3
    set deathTimer random 10 + 5]
  hatch-particles 20
  [ set shape "circle"
    set heading random 360 
    set size random-float 0.5 + 0.2
    set speed random-float 1 + 0.2
    set deathTimer random 5 + 10]
  set power power - 25
  if power < 0 [set power 0]
  hatch-powerups 4 [set heading (random 100 - 50) fd (5 + random 4) set ptype "power" set color red + 2.5]
  hatch-powerups 1 [set heading (random 100 - 50) fd (7 + random 6) set ptype "bigpower" set color red + 2.5 set size 1.5]
  set powerbonus 0
  set lives lives - 1
  set bombs 2
  set energy 200
  set flinching? true
  set flinchTimer 30
  if lives < 1 [set stage 0 hatch-UITs 1 [setxy 15 15.5 set size 0 set label "GAME OVER"]]
end

;Lawrence
to particleAI
  ifelse deathTimer > 0
  [ ifelse can-fd? speed [fd speed][die]
    set speed speed * 0.8
    set size size * 0.8
    set deathTimer deathTimer - 1]
  [die]
end

;Alex
;change
to explosionAI
  ifelse explodetimer > 0
  [set explodetimer explodetimer - 1
  ;This is not a rehash of the same code
    if any? players in-radius hitbox with [not hidden?] and enemy? and not flinching?
    [ ask p1 [playerDeath]
      die]
    if any? enemies with [distance myself < ([hitbox] of myself + (size / 2))] and not enemy?
    [ask enemies with [distance myself < ([hitbox] of myself + (size / 2))]
      [set hp hp - [damageset] of myself]]
    if any? bosses with [distance myself < ([hitbox] of myself + (size / 2))] and not enemy?
    [ask bosses with [distance myself < ([hitbox] of myself + (size / 2))]
      [set hp hp - [damageset] of myself]]
    if any? bullets with [distance myself < ([hitbox] of myself + (size / 2)) and enemy?]
    [ask bullets with [distance myself < ([hitbox] of myself + (size / 2)) and enemy?]
      [die]
    ]
  ]
  [die]
end

;Lawrence
to powerupAI
  if bombed? = 1 [set bomb? 1]
  ifelse ([ycor] of p1 > 21 and power = 128) or (bomb? = 1)
  [ face p1 ifelse can-fd? 0.8 [fd 0.8][die]]
  [ set heading 180 ifelse can-fd? 0.2 [fd 0.2][die]]
  let bonus 0
  if distance p1 < 1
  [ if ptype = "energy" 
    [ ifelse energy < 980 
      [ set energy energy + 20]
      [ set energy 1000]
      set bonus 200]
    if ptype = "point" 
    [ set point point + 1 
      ifelse ycor > 21 
      [ set bonus 100000]
      [ set bonus floor ((60000 * ((round ycor) - 1) / 20) + 10000)]]
    if ptype = "power" 
    [ ifelse power < 128 
      [ set power power + 1 set bonus 10]
      [ if powerbonus < 28 [set bonus ((10 ^ ((floor (powerbonus / 9)) + 1)) * (powerbonus mod 9) + 1)]
        if powerbonus = 28 [set bonus 12000]
        if powerbonus > 28 [set bonus 51200]
        set powerbonus powerbonus + 1]]
    if ptype = "bigpower" 
    [ if power < 120
      [ set power power + 8 set bonus 10]
      if power >= 120 and power < 128
      [ set power 128 set bonus 10]
      if power = 128
      [ if powerbonus < 28 [set bonus ((10 ^ ((floor (powerbonus / 9)) + 1)) * ((powerbonus mod 9) + 1))]
        if powerbonus = 28 [set bonus 12000]
        if powerbonus > 28 [set bonus 51200]
        set powerbonus powerbonus + 8]]
    if ptype = "bomb" 
    [ set bombs bombs + 1
      set bonus 100000]
    if ptype = "life" 
    [ set lives lives + 1
      set bonus 100000]
    set score score + bonus
    hatch-fadetexts 1 [set speed 0.1 set label bonus set size 0 set heading 0 set deathTimer 15]
    die]
end

to holderAI
  if ai = 1 [holder1]
end

to fadetextAI
  ifelse deathTimer = 0
  [die]
  [fd 0.1]
  set deathTimer deathTimer - 1
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;  enemy ai types  ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Lawrence
;Alex
to enemyDeath
  hatch-particles 20
  [ set heading random 360 
    set size random-float 1.4 + 0.4
    set speed random-float 2 + 0.3
    set deathTimer random 10 + 5]
  hatch-particles 10
  [ set shape "circle"
    set heading random 360 
    set size random-float 0.5 + 0.2
    set speed random-float 1 + 0.2
    set deathTimer random 5 + 10]
  set score score + getEnemyValue
  ifelse energy < (1000 - getEnemyValue / 10)
  [set energy energy + getEnemyValue / 10]
  [set energy 1000]
  let x random 100
  if x < 25
  [ let y random 100
    if y < 30 [hatch-powerups 1 [set ptype "energy" set shape "circle 2" set color orange + 2.5 set size 1]]
    if y >= 30 and y < 70 [hatch-powerups 1 [set ptype "point" set color blue  + 2.5 set size 1]]
    if y >= 70 and y < 95 [hatch-powerups 1 [set ptype "power" set color red + 2.5 set size 1]]
    if y >= 95 and y < 97 [hatch-powerups 1 [set ptype "bigpower" set color red + 2.5 set size 1.5]]
    if y >= 97 and y < 99 [hatch-powerups 1 [set ptype "bomb" set shape "star" set color green + 2.5 set size 1]]
    if y >= 99 [hatch-powerups 1 [set ptype "life" set shape "star" set color red + 2.5 set size 1]]]
  die
end

;Lawrence
to-report getEnemyValue
  if ai = 1 [report 100]
  if ai = 2 [report 300]
  if ai = 3 or ai = 4 [report 500]
  if ai = 5 [report 700]
  if ai = 6 [report 2000]
  if ai = 7 [report 2000]
end

;Lawrence
to eMove1
  ifelse can-fd? speed [fd speed][die]
end

;Alex
to eMove2
  ifelse can-fd? speed [fd speed rt turn][die]
end

;Alex
to eMove2.5
  ifelse can-fd? speed [fd speed lt turn][die]
end

;Alex
to eMove3
  if can-fd? 1
  [ setxy item 0 [xcor] of Emarkers with [(who mod 3) = [(who mod 3)] of myself]
    item 0 [ycor] of Emarkers with [(who mod 3) = [(who mod 3)] of myself]
    ask Emarkers [die]]
end

;Lawrence
;point at player, shoot
to enemy1
  if cooldown < 1
  [ hatch-bullets 1 [face p1 set shape "circle" set size 0.5 set hitbox 0.25 set enemy? true set ai 1 set color yellow]
    set cooldown 10]
  set cooldown cooldown - 1
end

;Lawrence
;8 direction shot
to enemy2
  if cooldown < 1
  [ hatch-bullets 8
    [ set shape "circle" set size 0.6 set hitbox 0.3 set enemy? true set ai 1 set color green
      set heading ((who mod 8) * 45)]
    set cooldown 10]
  set cooldown cooldown - 1
end

;Lawrence
;spray shot cooldown
to enemy3
  face p1
  if cooldown < 1
  [ set cooldown 15
    set ai 4]
  set cooldown cooldown - 1
end

;Lawrence
;spray shot
to enemy4
  ifelse cooldown < 1
  [ set cooldown 20
    set ai 3]
  [ hatch-bullets (random (cooldown / 2) + 1)
    [ set shape "circle" set size 0.4 set hitbox 0.1 set enemy? true set ai 1 set color red
      set graze? (random 4)
      lt random (([cooldown] of myself / 2) + 10)
      rt random (([cooldown] of myself / 2) + 10)]]
  set cooldown cooldown - 1
end

;Alex
;change
to enemy5
  if cooldown < 1
  [ hatch-bullets 6
    [set shape "circle" set size 0.6 set hitbox 0.3 set enemy? true set ai 1 set color blue set heading (150 + ((who mod 7) * 10))]
    set cooldown 8
  ]
  set cooldown cooldown - 1
end

to enemy6
  if cooldown < 1
  [ hatch-bullets 8
    [set shape "circle" set size 0.5 set hitbox 0.25 set enemy? true set heading ((who mod 8) * 45) fd 1
      set heading towards p1 set ai 2]
    set cooldown 12
  ]
  set cooldown cooldown - 1
end
  
to enemy7
  if cooldown < 1
  [ hatch-enemies 1
    [ set color orange set size 1 set heading 180 set hp 10 set move 1 set speed 0.3 set ai 4]
    set cooldown 10
  ]
  set cooldown cooldown - 1
end

;Alex
;change
;holders will help enemies make formations
;this didn't work btw
to holder1
   hatch-Emarkers 3
   [hide-turtle
     setxy 13 24
     set heading ((who mod 3) * 120 + (Etracker mod 36) * 10)
     fd 2]
end
  



;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;  boss ai types  ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Lawrence
to nextPattern
  hatch-powerups 1 [set ptype "bigpower" set color red + 2.5 set size 1.5]
  ifelse pattern != 0 
  [set pattern pattern - 1]
  [bossDeath]
  set cooldown 0
  set ai item pattern ailist
  set hp item pattern maxhp
  set time 100
  set countdown item pattern maxcountdown
  hatch-particles 25
  [ set heading random 360 
    set size random-float 1.4 + 0.4
    set speed random-float 2 + 0.3
    set deathTimer random 10 + 5]
  hatch-particles 15
  [ set shape "circle"
    set heading random 360 
    set size random-float 0.5 + 0.2
    set speed random-float 1 + 0.2
    set deathTimer random 5 + 10]
  ask enemies [enemyDeath]
  ask bullets [bulletDeath]
end

;Lawrence
to bossDeath
  hatch-particles 100
  [ set heading random 360 
    set size random-float 1.4 + 0.4
    set speed random-float 2 + 0.3
    set deathTimer random 10 + 5]
  hatch-particles 60
  [ set shape "circle"
    set heading random 360 
    set size random-float 0.5 + 0.2
    set speed random-float 1 + 0.2
    set deathTimer random 5 + 10]
  set score score + getBossValue
  ask enemies [enemyDeath]
  ask bullets [bulletDeath]
  die
end

;Both?
to-report getBossValue
  if stage = 1 and progress = checkpoint [report 100000] ;stage1 midboss
  if stage = 1 and progress = stageEnd   [report 100000] ;stage1 endboss
  if stage = 2 and progress = checkpoint [report 100000] ;stage2 midboss
  if stage = 2 and progress = stageEnd   [report 100000] ;etc
  if stage = 3 and progress = checkpoint [report 100000]
  if stage = 3 and progress = stageEnd   [report 100000]
  if stage = 4 and progress = checkpoint [report 100000]
  if stage = 4 and progress = stageEnd   [report 100000]
  if stage = 5 and progress = checkpoint [report 100000]
  if stage = 5 and progress = stageEnd   [report 100000]
  if stage = 6 and progress = checkpoint [report 100000]
  if stage = 6 and progress = stageEnd   [report 100000]
end

;Lawrence
to boss1001
  facexy 13 25
  if cooldown mod 5 = 0
  [ hatch-bullets 8
    [ set shape "circle" set size 0.6 set hitbox 0.3 set enemy? true set ai 1 set color green
      set heading ((who mod 8) * 45)]]
  if cooldown < 1
  [ set cooldown 15
    face p1
    set ai 1002]
  fd ((distancexy 13 25) / cooldown)
  set cooldown cooldown - 1
end

;Lawrence
to boss1002
  ifelse cooldown < 1
  [ set cooldown 10
    set ai 1003]
  [ if cooldown mod 2 = 0
    [ hatch-bullets 1 [face p1 set shape "circle" set size 0.5 set hitbox 0.25 set enemy? true set ai 1 set color yellow]]]
  set cooldown cooldown - 1
end

;Lawrence
to boss1003
  facexy 21 20
  if cooldown mod 5 = 0
  [ hatch-bullets 8
    [ set shape "circle" set size 0.6 set hitbox 0.3 set enemy? true set ai 1 set color green
      set heading ((who mod 8) * 45)]]
  if cooldown < 1
  [ set cooldown 15
    face p1
    set ai 1004]
  fd ((distancexy 21 20) / cooldown)
  set cooldown cooldown - 1
end

;Lawrence
to boss1004
  ifelse cooldown < 1
  [ set cooldown 10
    set ai 1005]
  [ if cooldown mod 2 = 0
    [ hatch-bullets 1 [face p1 set shape "circle" set size 0.5 set hitbox 0.25 set enemy? true set ai 1 set color yellow]]]
  set cooldown cooldown - 1
end

;Lawrence
to boss1005
  facexy 5 20
  if cooldown mod 5 = 0
  [ hatch-bullets 8
    [ set shape "circle" set size 0.6 set hitbox 0.3 set enemy? true set ai 1 set color green
      set heading ((who mod 8) * 45)]]
  if cooldown < 1
  [ set cooldown 15
    face p1
    set ai 1006]
  fd ((distancexy 5 20) / cooldown)
  set cooldown cooldown - 1
end

;Lawrence
to boss1006
  ifelse cooldown < 1
  [ set cooldown 10
    set ai 1001]
  [ if cooldown mod 2 = 0
    [ hatch-bullets 1 [face p1 set shape "circle" set size 0.5 set hitbox 0.25 set enemy? true set ai 1 set color yellow]]]
  set cooldown cooldown - 1
end

;Lawrence
to boss1007
  if cooldown mod 3 = 0
  [ hatch-bullets 8
    [ set shape "circle" set size 0.6 set hitbox 0.3 set enemy? true set ai 1 set color green
      set heading ((who mod 8) * 45)]]
  if cooldown < 1
  [ set cooldown 15
    face p1
    set ai 1008]
  fd ((distancexy destx desty) / cooldown)
  set cooldown cooldown - 1
end

;Lawrence
to boss1008
  set color red
  ifelse cooldown < 1
  [ set cooldown 10
    set destx (14 - random 10)
    set desty (26 - random 5)
    facexy destx desty 
    set ai 1009]
  [ if cooldown mod 2 = 0
    [ hatch-bullets (random (cooldown / 2) + 1)
      [ set shape "circle" set size 0.4 set hitbox 0.1 set enemy? true set ai 1 set color red
        set graze? (random 4)
        lt random (([cooldown] of myself / 2) + 10)
        rt random (([cooldown] of myself / 2) + 10)]]
  set cooldown cooldown - 1]
end

;Lawrence
to boss1009
  if cooldown mod 3 = 0
  [ hatch-bullets 8
    [ set shape "circle" set size 0.6 set hitbox 0.3 set enemy? true set ai 1 set color green
      set heading ((who mod 8) * 45)]]
  if cooldown < 1
  [ set cooldown 15
    face p1
    set ai 1010]
  fd ((distancexy destx desty) / cooldown)
  set cooldown cooldown - 1
end

;Lawrence
to boss1010
  ifelse cooldown < 1
  [ set cooldown 10
    set destx (random 9 + 14)
    set desty (26 - random 5)
    facexy destx desty 
    set ai 1007]
  [ if cooldown mod 2 = 0
    [ hatch-bullets (random (cooldown / 2) + 1)
      [ set shape "circle" set size 0.4 set hitbox 0.1 set enemy? true set ai 1 set color red
        set graze? (random 4)
        lt random (([cooldown] of myself / 2) + 10)
        rt random (([cooldown] of myself / 2) + 10)]]
  set cooldown cooldown - 1]
end

to boss1501
  if cooldown mod 6 = 0
  [ hatch-bullets 13
    [ set shape "circle" set size 0.5 set hitbox 0.25 set enemy? true set ai 1 set heading (towards p1 - 60 + ((who mod 13) * 10))
      ifelse who mod 2 = 0 [ set color blue][ set color green]]]
  if cooldown mod 10 = 0
  [ hatch-bullets 4
    [ set shape "arrow" set size 0.4 set hitbox 0.2 set delay 15 set color white set enemy? true set ai 501 set heading (towards p1 - 60 + ((who mod 4) * 40))]]
  set cooldown cooldown - 1
end

to boss1502
  if cooldown mod 6 = 0
  [ hatch-bullets 6 [setxy (random 23 + 2) 28 set size 0.5 set hitbox 0.25 set enemy? true set shape "circle" set color white set ai 502 set heading (160 + random 40)]]
  if cooldown mod 6 = 3
  [ hatch-bullets 6 [setxy (random 23 + 2) 28 set size 0.5 set hitbox 0.25 set enemy? true set shape "circle" set color blue + 3 set ai 1 set heading (160 + random 40)]]
  if cooldown mod 20 < 3
  [ hatch-bullets 3 [face p1 setxy (xcor - 1 + (who mod 3)) ycor set size 0.4 set hitbox 0.2 set enemy? true set shape "arrow" set color blue set ai 503]]
  set cooldown cooldown - 1
end

to boss1503
  set hp item pattern maxhp
  ask bullets [die]
  if time = 90
  [ hatch-fadetexts 1 [set speed 0 setxy 18 15 set label "Falling, Falling Snow" set size 0 set heading 0 set deathTimer 90]]
  if time < 1
  [ set ai 1502]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;  enemy shot types  ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Lawrence
;move forward 0.2
to bullet1
  ifelse can-fd? 0.2
  [fd 0.2]
  [die]
end

;Lawrence
to bullet501
  ifelse can-fd? 0.3
  [fd 0.3]
  [die]
  if delay < 1
  [set ai 502 face p1]
  set delay delay - 1
end

;Lawrence
to bullet502
  ifelse can-fd? 0.3
  [fd 0.3]
  [die]
end

;Lawrence
to bullet503
  ifelse can-fd? 0.5
  [fd 0.5]
  [die]
end

;Alex
;change
to bullet2
  ifelse can-fd? 0.7
  [fd 0.7]
  [die]
end





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;  player weapon types  ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Alex
;0
to weapNormal ;Choice of main weapon
  if mouse-down? and cooldown <= 0
    [hatch-bullets 1 
      [set enemy? false
        set heading 0
        set color yellow - 1.5
        set ai 1001
        set shape "circle"
        set size 0.7 * ((power / 128) + 1)
        set damageset (12 + (5 * (power / 128)))
        set hitbox 0.35 * ((power / 256) + 0.5)]
  set cooldown (ceiling (4 / ((power / 128) + 1)))]
end

;Alex
;(and then lawrence made it 5x shorter)
;1
;change
to weapShotgun
  if mouse-down? and cooldown <= 0
    [hatch-bullets 5
      [set enemy? false
        set heading (340 + ((who mod 5) * 10))
        set color yellow - 1.5
        set ai 1002
        set shape "circle"
        set size 0.7 * ((power / 128) + 1)
        set damageset 12 * ((power / 128) + 1)
        set hitbox 0.25 * ((power / 256) + 0.5)]
      set cooldown (ceiling (8 / ((power / 128) + 1)))]
end

;Alex
;2
;change
to weapVulcan
  if mouse-down? and cooldown <= 0
    [hatch-bullets 1
      [set enemy? false
        set heading 0
        set color yellow - 1.5
        set ai 1003
        set shape "circle"
        set size 0.5 * ((power / 128) + 1)
        set hitbox 0.25 * ((power / 256) + 0.5)
        set damageset 6 * ((power / 128) + 1)
        lt random 10
        rt random 10
      ]
      set cooldown (ceiling (2 / ((power / 128) + 1)))]
end

;Alex
;change
To homing  
  if subcool <= 0 and energy >= 40
    [ hatch-bullets 2
      [set enemy? false
      set shape "circle"
      set size 0.5
      set hitbox 0.25
      set color red - 1.5
      set damageset 16
      set heading ((who mod 2) * 180) + 90
      fd .75
      set heading 0
      set ai 2001]
      hatch-bullets 2
      [set enemy? false
      set shape "circle"
      set size 0.5
      set hitbox 0.25
      set color red - 1.5
      set damageset 16
      set heading ((who mod 2) * 180) + 90
      fd 1.5
      set heading 0
      set ai 2001]
      set subcool 3
      set energy energy - 40
    ]
    set subcontroller false
end

;Alex
;change
To chargeshot
  if subcool <= 10 and not any? bullets with [ai = 2002 and charge? = true]
  [hatch-bullets 1
    [set ai 2002
      set enemy? false
      set charge? true
      set color color - 1.5]
    set subcool 20
    ]
end

;Alex
;change
To energysphere
  if subcool <= 0 and not any? bullets with [charge? = true] and energy >= 100
  [hatch-bullets 3
    [set ai 2003
      set enemy? false
      set charge? true
      set hitbox size / 2
      set damageset 35
      set color green - 1.5
      set shape "circle"
      set heading ((who mod 3) * 120)
      fd 1]
    set energy energy - 100
  ]
end

;Alexz
;change
To spreadexplode
  if subcool <= 0 and energy >= 80
  [hatch-bullets 5
    [set ai 2004
      set enemy? false
      set size 0.5
      set hitbox 0.25
      set color yellow - 1.5
      set shape "circle"
      set heading (320 + ((who mod 5) * 20))
    ]
    set subcool 8
    set energy energy - 80
  ]
  set subcontroller false
end

;Alex
;change
To flamethrower
  ifelse energy >= 10
  [hatch-bullets 30
    [ set shape "circle" set size 0.4 set hitbox 0.2 set enemy? false set ai 2005 
      set color red - 1.5 set damageset 5 set heading 0
      lt random (20)
      rt random (20)]
    set energy energy - 10]
  [set subcontroller false]
end

;Alex
;change
To bullethell
  if energy >= 200 and subcool <= 0
  [hatch-bullets 40
    [set ai 2006
      set enemy? false
      set size 0.5
      set hitbox 0.25
      set color blue - 1.5
      set shape "circle"
      set heading ((who mod 40) * 9)
    ]
    set subcool 30
    set energy energy - 200
  ]
  set subcontroller false
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;  player shot types  ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Alex
to playerbullet1
  ;We need to fix this problem...(UGLY)
  ifelse can-fd? 1
  [ fd 0.5
    if any? enemies with [distance myself < ([hitbox] of myself + (size / 2))] and not enemy?
    [ask enemies with [distance myself < ([hitbox] of myself + (size / 2))]
      [set hp hp - [damageset] of myself]
    die]
    fd 0.5]
  [die]
end

;Alex
;change
to playerbullet2
  ifelse lengthmove < 30 and can-fd? 0.5
  [fd 0.5]
  [die]
  set lengthmove lengthmove + 1
end

;Alex
;change
to playerbullet3
  ifelse lengthmove < 30 and can-fd? 0.75
  [fd 0.75]
  [die]
  set lengthmove lengthmove + 1
end

;Alex
;change
to subweapon1
  ifelse can-fd? 0.5
  [ifelse (any? enemies in-radius 6 or any? bosses in-radius 6) and subcount < 5
    [face min-one-of turtles with [breed = enemies or breed = bosses] [distance myself]
      fd 0.5
      set subcount subcount + 1]
    [fd 0.5]
  ]
  [die]
end


;Alex
;change
to subweapon2
  if subcontroller = true
  [hide-turtle
    setxy [xcor] of p1 [ycor] of p1
    ifelse energy >= 0
    [set size size + 0.05
    set energy energy - 10]
  [set subcontroller false]]
  if subcontroller = false
  [show-turtle
   set hitbox size / 2
   set damageset 15 + ((size - 1) * 100)
   set heading 0
   set ai 2002.5
   set color blue
   set charge? false
  ]
end

;Alex
;change
to subweapon2.5
  ifelse can-fd? 1.5
  [fd 0.5
    if any? enemies with [distance myself < ([hitbox] of myself + (size / 2))] and not enemy?
    [ask enemies with [distance myself < ([hitbox] of myself + (size / 2))]
      [set hp hp - [damageset] of myself]
    die]
    fd 0.5
    if any? enemies with [distance myself < ([hitbox] of myself + (size / 2))] and not enemy?
    [ask enemies with [distance myself < ([hitbox] of myself + (size / 2))]
      [set hp hp - [damageset] of myself]
    die]
    fd 0.5]
  [die]
end

;Alex
to subweapon3
  ask p1
  [hatch-markers 3
    [hide-turtle
      set heading ((who mod 3) * 120 + (tracker mod 36) * 10)
      fd 1]
  ]
  ifelse energy >= 10
  [
  ifelse can-fd? 1
  [show-turtle
    setxy item 0 [xcor] of markers with [(who mod 3) = [(who mod 3)] of myself]
    item 0 [ycor] of markers with [(who mod 3) = [(who mod 3)] of myself]
    ask markers [die]]
  [hide-turtle
    setxy item 0 [xcor] of markers with [(who mod 3) = [(who mod 3)] of myself]
    item 0 [ycor] of markers with [(who mod 3) = [(who mod 3)] of myself]
    ask markers [die]
  ]
  ]
  [set subcontroller false]
  if subcontroller = false
  [set ai 2003.5
    set heading 0
    set charge? false]
end

;Alex
;change
to subweapon3.5
  ifelse can-fd? 1.5
  [fd 0.5
    if any? enemies with [distance myself < ([hitbox] of myself + (size / 2))] and not enemy?
    [ask enemies with [distance myself < ([hitbox] of myself + (size / 2))]
      [set hp hp - [damageset] of myself]
    die]
    fd 0.5
    if any? enemies with [distance myself < ([hitbox] of myself + (size / 2))] and not enemy?
    [ask enemies with [distance myself < ([hitbox] of myself + (size / 2))]
      [set hp hp - [damageset] of myself]
    die]
    fd 0.5]
  [die]
end

;Alex
;change
to subweapon4
  ifelse can-fd? 0.5
  [fd 0.5
    if any? enemies with [distance myself < ([hitbox] of myself + (size / 2))]
    or any? bosses with [distance myself < ([hitbox] of myself + (size / 2))]
    or subcount > 15
    [hatch-explosions 1
      [set size 2.5
      set hitbox 1.5
      set color red - 1.5
      set damageset 10
      set shape "circle"
      set explodetimer 15]
     die 
    ]    
   set subcount subcount + 1
  ]
  [hatch-explosions 1
      [set size 2.5
      set hitbox 1.5
      set color red - 1.5
      set damageset 10
      set shape "circle"
      set explodetimer 15]
     die ]
end

;Alex
;change
to subweapon5
  ifelse can-fd? 0.5 and subcount < 20
  [fd 0.5
    set subcount subcount + 1]
  [die]
end

;Alex
;change
To subweapon6
  ifelse can-fd? 0.5
  [fd 0.5
    if any? enemies with [distance myself < ([hitbox] of myself + (size / 2))]
    or any? bosses with [distance myself < ([hitbox] of myself + (size / 2))]
   [hatch-explosions 1
     [set size 1
       set shape "circle"
       set hitbox .5
       set damageset 8
       set explodetimer 8
     ] 
     die
   ]
  ]
  [hatch-explosions 1
    [set size 1
      set shape "circle"
      set hitbox .5
      set damageset 7
      set explodetimer 7
    ]
    die]
end





;;;;;;;;;;;;;;;;
;;;;;stages;;;;;
;;;;;;;;;;;;;;;;

;Lawrence
to runGameOver
  ask bullets [die]
  ask enemies [die]
  ask bosses [die]
  ask powerups [die]
  
  if progress = 0
  [ create-UITs 1 [setxy 15 15.5 set size 0 set label "LEVEL END"]
    set progress 1]
end

;Lawrence
to runScoreScreen
  if progress =  0 
  [ foreach ssln1Tlist [ask ? [show-turtle]]
    set stageEnd 100
    ask checkpointT [hide-turtle]]
  
  if progress = 30 
  [ let y length ssln2Tlist
    let z ((floor stage) * 1000)
    set y y - 1
    ask item y ssln2Tlist [set label (z mod 10)]
    set z floor (z / 10)
    while [z != 0]
    [ set y y - 1
      ask item y ssln2Tlist [set label (z mod 10)]
      set z floor (z / 10)]
    foreach ssln2Tlist [ask ? [show-turtle]]]
  
  if progress = 40 
  [ let y length ssln3Tlist
    let z (power * 100)
    set y y - 1
    ask item y ssln3Tlist [set label (z mod 10)]
    set z floor (z / 10)
    while [z != 0]
    [ set y y - 1
      ask item y ssln3Tlist [set label (z mod 10)]
      set z floor (z / 10)]
    foreach ssln3Tlist [ask ? [show-turtle]]]
  
  if progress = 50 
  [ let y length ssln4Tlist
    let z (graze * 10)
    set y y - 1
    ask item y ssln4Tlist [set label (z mod 10)]
    set z floor (z / 10)
    while [z != 0]
    [ set y y - 1
      ask item y ssln4Tlist [set label (z mod 10)]
      set z floor (z / 10)]
    foreach ssln4Tlist [ask ? [show-turtle]]]
  
  if progress = 60 
  [ let y length ssln5Tlist
    let z point
    set y y - 1
    ask item y ssln5Tlist [set label (z mod 10)]
    set z floor (z / 10)
    while [z != 0]
    [ set y y - 1
      ask item y ssln5Tlist [set label (z mod 10)]
      set z floor (z / 10)]
    foreach ssln5Tlist [ask ? [show-turtle]]]
  
  if progress = 70 
  [ let y length ssln6Tlist
    let z 0.5 + (difficulty * 0.5)
    set y y - 1
    ask item y ssln6Tlist [set label (10 * (z mod 1))]
    ask item (y - 1) ssln6Tlist [set label "."]
    ask item (y - 2) ssln6Tlist [set label floor z]
    foreach ssln6Tlist [ask ? [show-turtle]]]
  
  if progress = 80 
  [ let y length ssln7Tlist
    let z ((((stage - 0.5) * 1000) + (power * 100) + (graze * 10)) * point * (0.5 + (difficulty * 0.5)))
    set y y - 1
    ask item y ssln7Tlist [set label (z mod 10)]
    set z floor (z / 10)
    while [z != 0]
    [ set y y - 1
      ask item y ssln7Tlist [set label (z mod 10)]
      set z floor (z / 10)]foreach ssln7Tlist [ask ? [show-turtle]]
      foreach ssln7Tlist [ask ? [show-turtle]]]
  
  if progress = 99 [set score (score + ((((stage - 0.5) * 1000) + (power * 100) + (graze * 10)) * point * (0.5 + (difficulty * 0.5))))]
  if progress = 100 and clicking? [set progress progress + 1 foreach ssTlist [ask ? [hide-turtle]]]
end

;Alex: Stage
;Lawrence: Bosses
to runStageOne
  foreach ssTlist [ask ? [hide-turtle]]
  if progress = 0
    [ set bossSpawned? false
      set bossT nobody
      set stageEnd 800 ;change this to ticks to end of stage
      set checkpoint 300 ; change this to ticks to midboss
      ask checkpointT [show-turtle setxy (7 + (checkpoint * 18 / stageEnd)) 1]]
  
  ;spawn enemies at 10, 15, 20, 25, 30, 35, 40
  if progress = 10 or progress = 15 or progress = 20 or progress = 25 or progress = 30 or progress = 35 or progress = 40
  [ create-enemies 1 [ set color orange setxy 3 14 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 2]
    create-enemies 1 [ set color orange setxy 25 19 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 1]]

  if progress = 100
  [ create-enemies 1 [ set color orange setxy 6 28 set hp 10 set heading 180 set move 1 set speed 0.5 set ai 4]]
  if progress = 110
  [ create-enemies 1 [ set color orange setxy 15 28 set hp 10 set heading 180 set move 1 set speed 0.5 set ai 4]]
  if progress = 120
  [ create-enemies 1 [ set color orange setxy 3 28 set hp 10 set heading 180 set move 1 set speed 0.5 set ai 4]]
  if progress = 130
  [ create-enemies 1 [ set color orange setxy 20 28 set hp 10 set heading 180 set move 1 set speed 0.5 set ai 4]]
  if progress = 140
  [ create-enemies 1 [ set color orange setxy 9 28 set hp 10 set heading 180 set move 1 set speed 0.5 set ai 4]]
  if progress = 150
  [ create-enemies 1 [ set color orange setxy 5 28 set hp 10 set heading 180 set move 1 set speed 0.5 set ai 4]]
  if progress = 160
  [ create-enemies 1 [ set color orange setxy 23 28 set hp 10 set heading 180 set move 1 set speed 0.5 set ai 4]]
  if progress = 170
  [ create-enemies 1 [ set color orange setxy 14 28 set hp 10 set heading 180 set move 1 set speed 0.5 set ai 4]]
  if progress = 180
  [ create-enemies 1 [ set color orange setxy 4 28 set hp 10 set heading 180 set move 1 set speed 0.5 set ai 4]]
    
  ;midboss
  if progress = checkpoint and bossT = nobody
    [ ifelse not bossSpawned?
      [ create-bosses 1 
        [ set color orange setxy 13 25 set heading 180 set bossT self set size 3
          set pattern 1 ;change this to number of patterns - 1
          set ailist       (reverse (list 1001 1008)) ;change this to (reverse (list <ai of each pattern>))
          set maxhp        (reverse (list  250  400)) ;change this to (reverse (list <hp of each pattern>))
          set maxcountdown (reverse (list  900  600)) ;change this to (reverse (list <time limit of each pattern>))
          set hp item pattern maxhp set countdown item pattern maxcountdown set ai item pattern ailist]
        set bossSpawned? true]
      [set progress progress + 1 set bossSpawned? false]]
    
  if progress = 350 or progress = 360 or progress = 370 or progress = 380 or progress = 390 or progress = 400
  [ create-enemies 1 [ set color orange setxy 4 2 set heading 0 set hp 10 set move 2 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 23 2 set heading 0 set hp 10 set move 2.5 set speed 0.3 set ai 1]
  ]
  
  if progress = 500 or progress = 510 or progress = 520 or progress = 530 or progress = 540 or progress = 550
  [ create-enemies 1 [ set color orange setxy 4 26 set heading 180 set hp 10 set move 2.5 set speed 0.3 set ai 2]
    create-enemies 1 [ set color orange setxy 18 2 set heading 30 set hp 10 set move 2.5 set speed 0.3 set ai 1]
  ]
  
  if progress = 560 or progress = 570 or progress = 580 or progress = 590 or progress = 600
  [ create-enemies 1 [ set color orange setxy 4 26 set heading 180 set hp 10 set move 2.5 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 18 2 set heading 30 set hp 10 set move 2.5 set speed 0.3 set ai 2]
    create-enemies 1 [ set color orange setxy 23 16 set heading 270 set hp 10 set move 1 set speed 0.3 set ai 1]
  ]
  
  if progress = 610 or progress = 620 or progress = 630 or progress = 640 or progress = 650
  [ create-enemies 1 [ set color orange setxy 23 18 set heading 270 set hp 10 set move 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 4 26 set heading 90 set hp 10 set move 1 set speed 0.3 set ai 5]
  ]
    
  ;boss
  if progress = stageEnd and bossT = nobody
    [ ifelse not bossSpawned?
      [ create-bosses 1 
        [ set color orange setxy 13 25 set heading 180 set bossT self set size 3
          set pattern 1 ;change this to number of patterns - 1
          set ailist       (reverse (list 1501 1503)) ;change this to (reverse (list <ai of each pattern>))
          set maxhp        (reverse (list  450  600)) ;change this to (reverse (list <hp of each pattern>))
          set maxcountdown (reverse (list  600 1000)) ;change this to (reverse (list <time limit of each pattern>))
          set hp item pattern maxhp set countdown item pattern maxcountdown set ai item pattern ailist]
        set bossSpawned? true]
      [set progress progress + 1 set bossSpawned? false]]
end


;Alex
;change
to runStageTwo
  foreach ssTlist [ask ? [hide-turtle]]
  if progress = 0
    [ set bossSpawned? false
      set bossT nobody
      set stageEnd 1800 ;change this to ticks to end of stage
      set checkpoint 900 ; change this to ticks to midboss
      ask checkpointT [show-turtle setxy (7 + (checkpoint * 18 / stageEnd)) 1]]
  
  ;spawn enemies at 10, 15, 20
  if progress = 10
  [ create-enemies 1 [ set color orange setxy 5 28 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 5]]
  if progress = 15
  [ create-enemies 1 [ set color orange setxy 8 28 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 5]]
  if progress = 20
  [ create-enemies 1 [ set color orange setxy 23 16 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 2]]
  if progress = 25
  [ create-enemies 1 [ set color orange setxy 4 2 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 1]]
  if progress = 30
  [ create-enemies 1 [ set color orange setxy 12 2 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 1]]
  if progress = 35
  [ create-enemies 1 [ set color orange setxy 4 19 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 2]]
  if progress = 40
  [ create-enemies 1 [ set color orange setxy 23 28 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 1]]
  if progress = 45
  [ create-enemies 1 [ set color orange setxy 13 2 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 1]]
  if progress = 50
  [ create-enemies 1 [ set color orange setxy 5 28 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 5]]
  if progress = 55
  [ create-enemies 1 [ set color orange setxy 23 2 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 2]]
  
  if progress = 120
  [ create-enemies 1 [ set color orange setxy 11 2 set hp 10 set heading 0 set move 1 set speed 0.2 set ai 2]
    create-enemies 1 [ set color orange setxy 4 28 set hp 10 set heading 180 set move 1 set speed 0.1 set ai 1]]
  if progress = 140
  [ create-enemies 1 [ set color orange setxy 19 2 set hp 10 set heading 0 set move 1 set speed 0.2 set ai 2]
    create-enemies 1 [ set color orange setxy 24 28 set hp 10 set heading 180 set move 1 set speed 0.1 set ai 1]]
  if progress = 160
  [ create-enemies 1 [ set color orange setxy 4 2 set hp 10 set heading 0 set move 1 set speed 0.2 set ai 1]
    create-enemies 1 [ set color orange setxy 19 28 set hp 10 set heading 180 set move 1 set speed 0.1 set ai 5]]
  if progress = 180
  [ create-enemies 1 [ set color orange setxy 8 2 set hp 10 set heading 0 set move 1 set speed 0.2 set ai 1]
    create-enemies 1 [ set color orange setxy 12 28 set hp 10 set heading 180 set move 1 set speed 0.1 set ai 2]]
  if progress = 200
  [ create-enemies 1 [ set color orange setxy 23 2 set hp 10 set heading 0 set move 1 set speed 0.2 set ai 1]
    create-enemies 1 [ set color orange setxy 17 28 set hp 10 set heading 180 set move 1 set speed 0.1 set ai 5]]
  
  if progress = 279
  [ create-holders 1 [ hide-turtle setxy 13 25 set ai 1]]
  if progress = 280
  [ create-enemies 1 [ set color orange setxy 13 25 set hp 100 set heading 180 set size 3 set ai 6]
    create-enemies 1 [ set color orange setxy 17 25 set hp 100 set heading 180 set size 3 set ai 6]
    create-enemies 1 [ set color orange setxy 9 25 set hp 100 set heading 180 set size 3 set ai 6]
    create-enemies 1 [ set color orange setxy 3 13 set hp 10 set heading 0 set move 2 set turn 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 24 13 set hp 10 set heading 0 set move 2.5 set turn 1 set speed 0.3 set ai 1]
  ]
  if progress = 285 or progress = 290 or progress = 295 or progress = 300 or progress = 305
  [ create-enemies 1 [ set color orange setxy 3 13 set hp 10 set heading 0 set move 2 set turn 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 24 13 set hp 10 set heading 0 set move 2.5 set turn 1 set speed 0.3 set ai 1]
  ]
  if progress = 310 or progress = 315 or progress = 320 or progress = 325 or progress = 330 or progress = 335
  [ create-enemies 1 [ set color orange setxy 3 27 set hp 10 set heading 180 set move 2.5 set turn 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 24 27 set hp 10 set heading 180 set move 2 set turn 1 set speed 0.3 set ai 1]
  ]
  
  if progress = 420
  [ ask enemies with [ai = 6] [die]
    ask holders [die]
    ask markers [die]
    create-enemies 1 [ set color orange setxy 3 25 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 24 22 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 2]
    create-enemies 1 [ set color orange setxy 3 19 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 5]
  ]
  if progress = 430 or progress = 440 or progress = 450 or progress = 460 or progress = 470
  [ create-enemies 1 [ set color orange setxy 3 25 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 24 22 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 2]
    create-enemies 1 [ set color orange setxy 3 19 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 5]]
  
  if progress = 550
  [ create-enemies 1 [ set color orange setxy 3 26 set hp 30 set heading 180 set move 1 set speed 0.2 set ai 4]
    create-enemies 1 [ set color orange setxy 5 26 set hp 30 set heading 180 set move 1 set speed 0.2 set ai 4]
    create-enemies 1 [ set color orange setxy 7 26 set hp 30 set heading 180 set move 1 set speed 0.2 set ai 4]
    create-enemies 1 [ set color orange setxy 9 26 set hp 30 set heading 180 set move 1 set speed 0.2 set ai 4]
    create-enemies 1 [ set color orange setxy 11 26 set hp 30 set heading 180 set move 1 set speed 0.2 set ai 4]
    create-enemies 1 [ set color orange setxy 13 26 set hp 30 set heading 180 set move 1 set speed 0.2 set ai 4]
    create-enemies 1 [ set color orange setxy 15 26 set hp 30 set heading 180 set move 1 set speed 0.2 set ai 4]
    create-enemies 1 [ set color orange setxy 17 26 set hp 30 set heading 180 set move 1 set speed 0.2 set ai 4]
    create-enemies 1 [ set color orange setxy 19 26 set hp 30 set heading 180 set move 1 set speed 0.2 set ai 4]
    create-enemies 1 [ set color orange setxy 21 26 set hp 30 set heading 180 set move 1 set speed 0.2 set ai 4]
    create-enemies 1 [ set color orange setxy 23 26 set hp 30 set heading 180 set move 1 set speed 0.2 set ai 4]
  ]
  if progress = 560
  [ create-enemies 1 [ set color orange setxy 13 26 set hp 150 set heading 180 set size 3 set move 1 set speed 0.2 set ai 6]
  ]
  
  if progress = 660 or progress = 670 or progress = 680 or progress = 690 or progress = 700 or progress = 710
  [ create-enemies 1 [ set color orange setxy 23 26 set hp 100 set heading 270 set size 3 set move 1 set speed 0.2 set ai 6]
  ]
  
  ;midboss
  if progress = checkpoint and bossT = nobody
    [ ifelse not bossSpawned?
      [ create-bosses 1 
        [ set color orange setxy 13 25 set heading 180 set bossT self
          set pattern 0 ;change this to number of patterns - 1
          set ailist       (reverse (list 1001)) ;change this to (reverse (list <ai of each pattern>))
          set maxhp        (reverse (list  100)) ;change this to (reverse (list <hp of each pattern>))
          set maxcountdown (reverse (list  600)) ;change this to (reverse (list <time limit of each pattern>))
          set hp item pattern maxhp set countdown item pattern maxcountdown set ai item pattern ailist]
        set bossSpawned? true]
      [set progress progress + 1 set bossSpawned? false]]
    
  if progress = 950 or progress = 975 or progress = 1000 or progress = 1025 or progress = 1050 or progress = 1075 or progress = 1100 or progress = 1125 or progress = 1150
  [ create-enemies 1 [ set color orange setxy 23 26 set hp 100 set heading 270 set size 3 set move 1 set speed 0.15 set ai 7]
  ]
  
  if progress = 1350 or progress = 1355 or progress = 1360 or progress = 1365 or progress = 1370 or progress = 1375 or progress = 1380 or progress = 1385 or progress = 1390
  [ create-enemies 1 [ set color orange setxy 3 15 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 2]
    create-enemies 1 [ set color orange setxy 23 15 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 2]
    create-enemies 1 [ set color orange setxy 13 26 set hp 10 set heading 180 set move 1 set speed 0.3 set ai 5]
  ]
  
  if progress = 1475 or progress = 1500 or progress = 1525 or progress = 1550 or progress = 1575 or progress = 1600
  [ create-enemies 1 [ set color orange setxy 3 10 set hp 100 set heading 0 set size 3 set move 2 set turn 0.5 set speed 0.3 set ai 7]
    create-enemies 1 [ set color orange setxy 24 10 set hp 100 set heading 0 set size 3 set move 2.5 set turn 0.5 set speed 0.3 set ai 7]]
    
  ;boss
  if progress = stageEnd and bossT = nobody
    [ ifelse not bossSpawned?
      [ create-bosses 1 
        [ set color orange setxy 13 25 set heading 180 set bossT self
          set pattern 1 ;change this to number of patterns - 1
          set ailist       (reverse (list 1001 1001)) ;change this to (reverse (list <ai of each pattern>))
          set maxhp        (reverse (list  100  150)) ;change this to (reverse (list <hp of each pattern>))
          set maxcountdown (reverse (list  600  900)) ;change this to (reverse (list <time limit of each pattern>))
          set hp item pattern maxhp set countdown item pattern maxcountdown set ai item pattern ailist]
        set bossSpawned? true]
      [set progress progress + 1 set bossSpawned? false]]
end

;Alex
;change
to runStageThree
  foreach ssTlist [ask ? [hide-turtle]]
  if progress = 0
    [ set bossSpawned? false
      set bossT nobody
      set stageEnd 3000 ;change this to ticks to end of stage
      set checkpoint 1500 ; change this to ticks to midboss
      ask checkpointT [show-turtle setxy (7 + (checkpoint * 18 / stageEnd)) 1]]
  
  if progress = 60
  [ create-enemies 1 [ set color orange setxy 12 28 set hp 100 set heading 180 set size 3 set move 1 set speed 0.1 set ai 7]
    create-enemies 1 [ set color orange setxy 11 28 set hp 100 set heading 180 set size 3 set move 1 set speed 0.1 set ai 7]]  
  if progress = 100
  [ create-enemies 1 [ set color orange setxy 6 28 set hp 100 set heading 180 set size 3 set move 1 set speed 0.1 set ai 7]
  ]
  if progress = 140
  [ create-enemies 1 [ set color orange setxy 15 28 set hp 100 set heading 180 set size 3 set move 1 set speed 0.1 set ai 7]
  ]
  if progress = 180
  [ create-enemies 1 [ set color orange setxy 9 28 set hp 100 set heading 180 set size 3 set move 1 set speed 0.1 set ai 7]
  ]
  if progress = 220
  [ create-enemies 1 [ set color orange setxy 14 28 set hp 100 set heading 180 set size 3 set move 1 set speed 0.1 set ai 7]
     create-enemies 1 [ set color orange setxy 6 28 set hp 100 set heading 180 set size 3 set move 1 set speed 0.1 set ai 7]]
  if progress = 260
  [ create-enemies 1 [ set color orange setxy 9 28 set hp 150 set heading 180 set size 3 set move 1 set speed 0.1 set ai 6]]
  if progress = 300
  [ create-enemies 1 [ set color orange setxy 5 28 set hp 150 set heading 180 set size 3 set move 1 set speed 0.1 set ai 6]]
  if progress = 340
  [ create-enemies 1 [ set color orange setxy 23 28 set hp 150 set heading 180 set size 3 set move 1 set speed 0.1 set ai 6]]
  if progress = 380
  [ create-enemies 1 [ set color orange setxy 14 28 set hp 150 set heading 180 set size 3 set move 1 set speed 0.1 set ai 6]]
  if progress = 420
  [ create-enemies 1 [ set color orange setxy 4 28 set hp 150 set heading 180 set size 3 set move 1 set speed 0.1 set ai 6]]
  
  if progress = 600
  [ create-enemies 1 [ set color orange setxy 3 28 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 5]
    create-enemies 1 [ set color orange setxy 14 2 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 1]
    create-enemies 1 [ set color orange setxy 23 16 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 2]]
  if progress = 630
  [ create-enemies 1 [ set color orange setxy 23 28 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 5]
    create-enemies 1 [ set color orange setxy 14 2 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 1]
    create-enemies 1 [ set color orange setxy 23 16 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 2]]
  if progress = 660
  [ create-enemies 1 [ set color orange setxy 9 28 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 2]
    create-enemies 1 [ set color orange setxy 2 15 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 1]
    create-enemies 1 [ set color orange setxy 23 6 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 1]]
  if progress = 690
  [ create-enemies 1 [ set color orange setxy 3 2 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 1]
    create-enemies 1 [ set color orange setxy 23 19 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 2]
    create-enemies 1 [ set color orange setxy 5 28 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 2]]
  if progress = 720
  [ create-enemies 1 [ set color orange setxy 12 2 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 1]
    create-enemies 1 [ set color orange setxy 18 28 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 5]
    create-enemies 1 [ set color orange setxy 3 17 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 5]
    ]
  if progress = 750
  [ create-enemies 1 [ set color orange setxy 3 19 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 2]
    create-enemies 1 [ set color orange setxy 14 2 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 2]
    create-enemies 1 [ set color orange setxy 14 28 set hp 10 set heading towards p1 set move 1 set speed 0.4 set ai 5]
    ]
  if progress = 780
  [ create-enemies 1 [ set color orange setxy 23 28 set hp 60 set heading towards p1 set move 1 set speed 0.4 set ai 6]
    create-enemies 1 [ set color orange setxy 23 12 set hp 60 set heading towards p1 set move 1 set speed 0.4 set ai 6]]
  if progress = 810
  [ create-enemies 1 [ set color orange setxy 13 2 set hp 60 set heading towards p1 set move 1 set speed 0.4 set ai 6]
    create-enemies 1 [ set color orange setxy 4 2 set hp 60 set heading towards p1 set move 1 set speed 0.4 set ai 6]]
  if progress = 840
  [ create-enemies 1 [ set color orange setxy 5 28 set hp 60 set heading towards p1 set move 1 set speed 0.4 set ai 6]
    create-enemies 1 [ set color orange setxy 23 15 set hp 60 set heading towards p1 set move 1 set speed 0.4 set ai 6]]
  if progress = 870
  [ create-enemies 1 [ set color orange setxy 23 2 set hp 60 set heading towards p1 set move 1 set speed 0.4 set ai 6]
    create-enemies 1 [ set color orange setxy 3 21 set hp 60 set heading towards p1 set move 1 set speed 0.4 set ai 6]]
  
  if progress = 950 or progress = 955 or progress = 960 or progress = 965 or progress = 970 or progress = 975
  [ create-enemies 1 [ set color orange setxy 3 12 set hp 10 set heading 0 set move 2 set turn 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 23 12 set hp 10 set heading 0 set move 2.5 set turn 1 set speed 0.3 set ai 1]]
  if progress = 980 or progress = 985 or progress = 990 or progress = 995 or progress = 1000 or progress = 1005
  [ create-enemies 1 [ set color orange setxy 3 12 set hp 10 set heading 0 set move 2 set turn 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 23 12 set hp 10 set heading 0 set move 2.5 set turn 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 3 24 set hp 10 set heading 110 set move 2.5 set turn 0.5 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 23 24 set hp 10 set heading 250 set move 2 set turn 0.5 set speed 0.3 set ai 1]
  ]
  if progress = 1010 or progress = 1015 or progress = 1020 or progress = 1025 or progress = 1030 or progress = 1035
  [ create-enemies 1 [ set color orange setxy 3 24 set hp 10 set heading 110 set move 2.5 set turn 0.5 set speed 0.3 set ai 2]
    create-enemies 1 [ set color orange setxy 23 24 set hp 10 set heading 250 set move 2 set turn 0.5 set speed 0.3 set ai 2]
    create-enemies 1 [ set color orange setxy 3 28 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 5]
    create-enemies 1 [ set color orange setxy 23 28 set hp 10 set heading 180 set move 1 set speed 0.3 set ai 1]
  ]
  
  if progress = 1100
  [ create-enemies 1 [ set color orange setxy 13 28 set hp 80 set size 2 set heading 180 set move 1 set speed 0.1 set ai 6]]
  if progress = 1150
  [ create-enemies 1 [ set color orange setxy 10 28 set hp 80 set size 2 set heading 180 set move 1 set speed 0.1 set ai 6]
    create-enemies 1 [ set color orange setxy 16 28 set hp 80 set size 2 set heading 180 set move 1 set speed 0.1 set ai 6]
    ]
  if progress = 1100 or progress = 1110 or progress = 1120 or progress = 1130 or progress = 1140 or progress = 1150 or progress = 1160 or progress = 1170
  or progress = 1180 or progress = 1190 or progress = 1200 or progress = 1210 or progress = 1220 or progress = 1230 or progress = 1240 or progress = 1250
  or progress = 1260 or progress = 1270 or progress = 1280 or progress = 1290 or progress = 1300
  [ create-enemies 1 [ set color orange setxy 3 15 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 23 17 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 2]
  ]
  
    
  ;midboss
  if progress = checkpoint and bossT = nobody
    [ ifelse not bossSpawned?
      [ create-bosses 1 
        [ set color orange setxy 13 25 set heading 180 set bossT self
          set pattern 0 ;change this to number of patterns - 1
          set ailist       (reverse (list 1001)) ;change this to (reverse (list <ai of each pattern>))
          set maxhp        (reverse (list  100)) ;change this to (reverse (list <hp of each pattern>))
          set maxcountdown (reverse (list  600)) ;change this to (reverse (list <time limit of each pattern>))
          set hp item pattern maxhp set countdown item pattern maxcountdown set ai item pattern ailist]
        set bossSpawned? true]
      [set progress progress + 1 set bossSpawned? false]]
  
  if progress = 1600
  [ create-enemies 1 [ set color orange setxy 11 28 set hp 10 set heading 180 set move 1 set speed 0.2 set ai 2]
    create-enemies 1 [ set color orange setxy 3 14 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 23 18 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 5]]
  if progress = 1620
  [ create-enemies 1 [ set color orange setxy 14 28 set hp 10 set heading 180 set move 1 set speed 0.2 set ai 1]
    create-enemies 1 [ set color orange setxy 3 19 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 5]
    create-enemies 1 [ set color orange setxy 23 13 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 2]]
  if progress = 1640
  [ create-enemies 1 [ set color orange setxy 5 28 set hp 10 set heading 180 set move 1 set speed 0.2 set ai 2]
    create-enemies 1 [ set color orange setxy 3 24 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 5]
    create-enemies 1 [ set color orange setxy 23 15 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 1]]
  if progress = 1680
  [ create-enemies 1 [ set color orange setxy 18 28 set hp 10 set heading 180 set move 1 set speed 0.2 set ai 2]
    create-enemies 1 [ set color orange setxy 3 24 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 23 19 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 5]]
  if progress = 1700
  [ create-enemies 1 [ set color orange setxy 9 28 set hp 10 set heading 180 set move 1 set speed 0.2 set ai 5]
    create-enemies 1 [ set color orange setxy 3 15 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 23 12 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 2]]
  if progress = 1720
  [ create-enemies 1 [ set color orange setxy 9 28 set hp 10 set heading 180 set move 1 set speed 0.2 set ai 1]
    create-enemies 1 [ set color orange setxy 3 26 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 5]
    create-enemies 1 [ set color orange setxy 23 15 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 2]]
  if progress = 1740
  [ create-enemies 1 [ set color orange setxy 18 28 set hp 10 set heading 180 set move 1 set speed 0.2 set ai 5]
    create-enemies 1 [ set color orange setxy 3 24 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 5]
    create-enemies 1 [ set color orange setxy 23 14 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 5]]
  if progress = 1760
  [ create-enemies 1 [ set color orange setxy 5 28 set hp 10 set heading 180 set move 1 set speed 0.2 set ai 2]
    create-enemies 1 [ set color orange setxy 3 17 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 2]
    create-enemies 1 [ set color orange setxy 23 22 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 2]]
  if progress = 1780
  [ create-enemies 1 [ set color orange setxy 19 28 set hp 10 set heading 180 set move 1 set speed 0.2 set ai 1]
    create-enemies 1 [ set color orange setxy 3 16 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 23 18 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 1]]
  if progress = 1800
  [ create-enemies 1 [ set color orange setxy 11 28 set hp 10 set heading 180 set move 1 set speed 0.2 set ai 1]
    create-enemies 1 [ set color orange setxy 3 14 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 23 18 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 2]]
  if progress = 1820
  [ create-enemies 1 [ set color orange setxy 5 28 set hp 10 set heading 180 set move 1 set speed 0.2 set ai 1]
    create-enemies 1 [ set color orange setxy 3 24 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 5]
    create-enemies 1 [ set color orange setxy 23 16 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 2]]
  if progress = 1840
  [ create-enemies 1 [ set color orange setxy 7 28 set hp 10 set heading 0 set move 1 set speed 0.2 set ai 2]
    create-enemies 1 [ set color orange setxy 3 13 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 23 21 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 2]]
  if progress = 1860
  [ create-enemies 1 [ set color orange setxy 11 2 set hp 10 set heading 180 set move 1 set speed 0.2 set ai 5]
    create-enemies 1 [ set color orange setxy 3 14 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 5]
    create-enemies 1 [ set color orange setxy 23 18 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 1]]
  if progress = 1880
  [ create-enemies 1 [ set color orange setxy 18 28 set hp 10 set heading 180 set move 1 set speed 0.2 set ai 2]
    create-enemies 1 [ set color orange setxy 3 19 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 5]
    create-enemies 1 [ set color orange setxy 23 15 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 5]]
  if progress = 1900
  [ create-enemies 1 [ set color orange setxy 12 28 set hp 10 set heading 180 set move 1 set speed 0.2 set ai 5]
    create-enemies 1 [ set color orange setxy 3 17 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 2]
    create-enemies 1 [ set color orange setxy 23 23 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 1]]
  
  if progress >= 2000 and progress <= 2500 and (progress mod 20) = 0
  [ create-enemies 1 [ set color orange setxy 3 20 set hp 10 set heading 110 set move 2.5 set speed 0.3 set turn 0.5 set ai 1]
    create-enemies 1 [ set color orange setxy 23 20 set hp 10 set heading 250 set move 2 set speed 0.3 set turn 0.5 set ai 1]
    create-enemies 1 [ set color orange setxy 3 23 set hp 10 set heading 90 set move 1 set speed 0.3 set ai 1]
    create-enemies 1 [ set color orange setxy 23 25 set hp 10 set heading 270 set move 1 set speed 0.3 set ai 1]
  ]
  
  if progress = 2100
  [ create-enemies 1 [ set color orange setxy 13 28 set hp 100 set heading 180 set size 3 set ai 7]
  ]
  
  if progress >= 2700 and progress <= 2850 and (progress mod 50) = 0
  [ ask enemies with [ai = 7] [die]
     create-enemies 1 [ set color orange setxy 3 18 set hp 80 set size 2 set heading 90 set move 1 set speed 0.3 set ai 7]
    create-enemies 1 [ set color orange setxy 23 23 set hp 80 set size 2 set heading 270 set move 1 set speed 0.3 set ai 7]
  ]
  
  if progress = 2775
  [ create-enemies 1 [ set color orange setxy 5 28 set hp 100 set heading 180 set size 3 set ai 6]
    create-enemies 1 [ set color orange setxy 21 28 set hp 100 set heading 180 set size 3 set ai 6]
  ]  
    
  ;boss
  if progress = stageEnd and bossT = nobody
    [ ifelse not bossSpawned?
      [ create-bosses 1 
        [ set color orange setxy 13 25 set heading 180 set bossT self
          set pattern 1 ;change this to number of patterns - 1
          set ailist       (reverse (list 1001 1001)) ;change this to (reverse (list <ai of each pattern>))
          set maxhp        (reverse (list  100  150)) ;change this to (reverse (list <hp of each pattern>))
          set maxcountdown (reverse (list  600  900)) ;change this to (reverse (list <time limit of each pattern>))
          set hp item pattern maxhp set countdown item pattern maxcountdown set ai item pattern ailist]
        set bossSpawned? true]
      [set progress progress + 1 set bossSpawned? false]]
end

    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;reporters and crap;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Lawrence
;Turbo-click averted.
to-report clicking?
  report (not wasMouseDown?) and mouse-down?
end

;Lawrence
;Is turtle in this rectangle of patches?
to-report inPRect? [lcoords]
  ifelse (between? item 0 lcoords pxcor item 1 lcoords) and 
         (between? item 2 lcoords pycor item 3 lcoords)
  [report true]
  [report false]
end

;Lawrence
;Is a between n1 and n2?
to-report between? [n1 a n2]
  if a >= n1 and a <= n2 [report true]
  if a <= n1 and a >= n2 [report true]
  report false
end

;Lawrence
;Can turtle move forward without exiting game area?
to-report can-fd? [n]
  let ray 0
  let return false
  hatch 1 [hide-turtle fd n set ray self]
  if [inPRect? (list 2 25 1 28)] of ray
  [ set return true]
  ask ray [die]
  report return
end
@#$#@#$#@
GRAPHICS-WINDOW
100
10
750
521
-1
-1
16.0
1
12
1
1
1
0
0
0
1
0
39
0
29
1
1
1
ticks
30.0

BUTTON
3
117
66
150
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
3
152
66
185
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
13
295
66
323
debuggy\ncrap
11
0.0
1

MONITOR
8
425
65
470
NIL
progress
17
1
11

MONITOR
8
470
65
515
NIL
stageEnd
17
1
11

BUTTON
3
84
95
117
NIL
subchange
NIL
1
T
OBSERVER
NIL
Z
NIL
NIL
1

MONITOR
8
380
65
425
NIL
stage
17
1
11

BUTTON
5
195
70
228
Cheat
cheat
NIL
1
T
OBSERVER
NIL
C
NIL
NIL
1

MONITOR
8
335
65
380
Bullets
count bullets
17
1
11

BUTTON
2
52
65
85
NIL
bomb
NIL
1
T
OBSERVER
NIL
X
NIL
NIL
1

@#$#@#$#@
#Team Unstealthy Developurrs: Unstealthy Ninja and the Cat

## INSTRUCTIONS AND STUFF

Click setup and go once to start the model. 
Since there's no music, optionally load up http://r-a-d.io/ for giggles.

Click Start to play the game from stage one to the end. Level select to play a single level. The other buttons are self-explanatory.

Change between weapons by clicking the buttons on the right side.
Main weapons (click to fire): 
 .. Normal - Shoot in a straight line ahead
 .. Shotgun - Spread shot
 .. Vulcan - Inaccurate rapid fire
Subweapons (Z to fire): 
 .. Homing - Shots home into enemies
 .. Charge Shot - Press once to begin charging, again to fire a large shot
 .. Energy Sphere - Press once for bullets circling around player, again to fire
 .. Spread Explode - Short ranged area of effect damage over time
 .. Flamethrower - Short ranged bullet spray
 .. Bullet Hell - Bullets shoot in a circle around player

Select easy difficulty by clicking on any button.
Difficulties are unimplemented. The different buttons give undeserved score multipliers for increased difficulty that isn't there.

For level select, select a stage from 1-3. 4-6 don't exist.

Mouse to move, hold down mouse to fire the main weapon. Z fires the subweapon if enough energy is available. X uses a bomb that clears the screen of bullets and enemies and deals damage to bosses.

Killing enemies and bosses will award points and powerups. Enemies always drop powerups that are worth points and have varying effects, but bosses will always drop an 8Power.
 .. Circle - Energy
 .. Red square - Power
 .. Big red square - 8Power
 .. Blue square - Point
 .. Green star - Player
 .. Red star - Bomb

Power influences the damage, rate of fire, and shot size of the main weapon. Power maxes out at 128, after which additional powerups will give progressively higher score bonuses instead of weapon boosts. When power is maxed out, moving to the top part of the screen causes powerups to fly toward the player. When the player is hit and killed, a life is lost and 20 power.

Point items give score depending on how high up they are collected. Maximum points are awarded above the same line where max power causes powerups to fly to the player. Point items also act as a multiplier for the stage clear bonus.

The progress meter at the bottom tracks the player's progress through the stage. At the circular checkpoint, a midboss is supposed to appear, and at the end, a boss. Lawrence was too busy writing an English paper to make bosses for stages other than the first.

Bosses have a health bar shown at the top. To the left of the health bar is a number denoting how many additional health bars remain. To the right is a timer that denotes how much time is left until the boss immediately skips to the next healthbar. Each healthbar corresponds to a different attack pattern.

Additional points are gained by grazing bullets. Bullets can be grazed once each when they come close enough to the player that the player is nearly hit. Grazing is indicated by a blue particle effect around the player.

After a boss is defeated, a stage cleared screen appears and awards score based on the stage number, power, and graze. Point is used a multiplier. Clicking advances to the next stage.

.

## ALEX'S CHECKLIST

Checklist of things done:
- Mouse movement and attack controls: Check
- At least one stage, ending in a boss: Made 3, check.
- Enemies drop random powerups for increased score, firepower: Check. You never know if a bullet is hiding under it or not though.
- Score Tracking: Check
- Pretty Bullet Patterns: Not really pretty, but check.
- Run without lag due to bullet spam: Yeah, no… I was a nub regarding that.
- Save high score to file: Dunno, ask Lawrence
- Cap player movement and trail behind mouse if moving too fast: Check
- Score bonus for grazing bullets: Check
- Difficulty setting: Nope. But Easy is freaking difficult anyways. :P
- Multiple stages: Not as many as we wanted, but check.
- Sounds and music: Nope. We had some cool stuff too. :’(
- Turtle shapes that aren’t ugly: Flowers aren’t ugly, right?
- Legitimate storyline: Fell victim to the threat known as procrastination. On so many levels.
- Multiple Weapons: Perhaps too many. Check.

Completed: 8.5/15 -> Less than 60%

…Man, we suck at this. XD

## LAWRENCE'S COMPLAINING

Time now: 11:39PM. ffffffffffffff-------

So, what's wrong with this thing again? Well...
Most of the menu options do nothing, I didn't get to do many bosses, there's half as many stages as we'd hoped...
The game is ugly and has no sound, high score and difficulty are unimplemented, there's no dialogue or plot thingy...
Alex's stages are laggy and have way too many bullets... somehow...
The two bosses I did make suck a lot...
There's probably tons of bugs that we missed, I have no idea what most of Alex's code does, and he doesn't have a clue about mine either...
The game isn't a game so much as a half-assed semi-playable demo...
On that note, I probably left some profanities in comments somewhere, and the number of profanities uttered during the coding process was probably actually over nine thousand...
We challenged you to Starcraft instead of doing work...
The code is ugly and stupid (mfw bullet1, bullet501, etc.)...

And a whole lot of other stuff too. This thing is a piece of crap, isn't it?

...Yeah, seems like A+ material to me. Compress, upload, here we go.

.

## BUGS

Bullets slightly overlap edge of game area before dying
    ^everything overlaps the edge
can't get killed by an enemy if you hover right at the bullet spawn
A lot of other stuff.

## STUFF TO DO

A lot of things.
(cry)

## CREDITS

ZUN, for making the Touhou series
Lots of reference and stuff from this guy:
http://www.shrinemaiden.org/forum/index.php/topic,9598.0/nowap.html

## CHANGELOG


### v01.09.13 
#### Lawrence
- game area colored by patches in main game screen
    (no menus or ui or other screens yet)
    bullets die before exiting game area
    player locked into game area
- player follows invisible turtle at cursor at fixed speed
- setup spawns 3 enemies and player
- support for different enemy shot patterns
    pattern set by enemies-own ai variable
- support for different bullet types
    type set by bullets-own ai variable
- function written to return true at start of click
    for future menu code
- game runs setup when player is hit
    (temporary until actual functions get written)
- probably other things too
    boring reporter functions, etc.

#### Alex
- made useless variables and breeds that didn't get used yet
- did history project

.


### v01.10.13 

#### Lawrence
- poorly thought out bare bones support for menu transitions
    (slightly better thought out now)
- superOCD organized code
- inPRect? reporter now uses list of coordinates instead of four arguments
- temporary weapon cycle button thingy
- enemies now have hitboxes dependent on size instead of just the center of the turtle
    (player hitbox is still the point at center: intended behavior)

#### Alex
- player can now shoot at things
    (enemies don't die yet)
- multiple weapon types

.

### v01.15.13 
#### Lawrence
- stage progression, kind of
- probably some menu stuff and level select
- enemies die

#### Alex
- subweapons
- removed useless breed that never got used

.

### v01.16.13 
Starting to actually look like a game now?

#### Lawrence
- in-game UI exists and kind of works
    (most variables non-functional and still no code for end of stage)
- menus rejiggered with the most ugly and verbose code possible ; ;
- lots of placeholders

#### Alex
- did research chem project
- moral support (aka shipping)

.

### v01.17.13
#### Lawrence
- probably buggy half-done boss code slapped together with plywood and elmer's glue

#### Alex
- took a shower

.

### v01.18.13
#### Lawrence
- enemies move, woo

#### Alex
- charge shot subweapon
- tweaked subweapons
- finished toshiba project, hell yeah

.

### v1.20.13
super panic mode, activate
#### Lawrence
- grazing
- powerups
- bosses actually work properly now
- score screen thingy
- probably other things while making stage changes work
- bombs
- Bosses in general

#### Alex
- Even more subweapons
- Jesus Christ that's a lot of subweapons
- explosions breed
- Stages in general

.

### v[FINAL]
#### Lawrence
- Bosses, kind of.
- English essay

#### Alex
- Stages
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 1.0 0.0
0.0 1 1.0 0.0
0.2 0 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
