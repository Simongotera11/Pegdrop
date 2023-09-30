

display.setStatusBar( display.HiddenStatusBar )

-- Screen Coordinates
centerX = display.contentCenterX
centerY = display.contentCenterY
screenLeft = display.screenOriginX
screenWidth = display.contentWidth - screenLeft * 2
screenRight = screenLeft + screenWidth
screenTop = display.screenOriginY
screenHeight = display.contentHeight - screenTop * 2
screenBottom = screenTop + screenHeight
display.contentWidth = screenWidth
display.contentHeight = screenHeight


local physics = require("physics")
physics.start()
physics.setGravity(0,9.8)
physics.setDrawMode("normal")
-- Audio variables
local refe = audio.loadSound("audio/referee.mp3")
local goal = audio.loadSound("audio/goal.mp3")
local goal2 = audio.loadSound("audio/goal2.mp3")
local kick = audio.loadSound("audio/kick.mp3")

-- backgrounds 
local bg = display.newImage("graphics/titlepage.png",centerX,centerY)
bg.width = screenWidth
bg.height= screenHeight
local btn 
local function clean()
    transition.to(bg,{alpha = 0, time = 2000})
    bg = nil
    setScreen()
    return true
end 

bg:addEventListener("tap",clean)

local bg2= display.newImage("graphics/bg.png",centerX,centerY)
bg2.width = screenWidth
bg2.height = screenHeight
bg2.alpha =0

-- Game variables 
local ball
local wall
local atemp =0
local atempText
local wall2
local floor
local level =1
local score = 0
local scoreText 
local target 
local leveltext
local xCord
local yCord
local w
local json = require("json")
local saveTable = {}
local loadTable = {}
local filename = "gameSave.txt"


local function fileExists()
  local ok = false
  
  path = system.pathForFile( filename, system.DocumentsDirectory)
  local f=io.open(path,"r")
  
  if f~=nil then
    io.close(f)
    ok = true
  end
  
  return ok
end

local function saveState()
  local path = system.pathForFile( filename,system.DocumentsDirectory)
  local file = io.open( path, "w" )
  
  saveTable.level = level
  saveTable.score = score
  saveTable.atemp = atemp
  
  local contents = json.encode( saveTable )
  file:write( contents )
  io.close( file )
end

local function loadSavedState()
  local path = system.pathForFile( filename,system.DocumentsDirectory)
  local file = io.open( path, "r" )
  local contents = file:read( "*a" )
  
  loadTable = json.decode( contents )
  io.close( file )

  level = loadTable.level
  score = loadTable.score
  atemp = loadTable.atemp
end

local pegGrp =  display.newGroup()

local function lockpeg(event)
  for i = 1,pegGrp.numChildren do
    pegGrp[i].move = true
  end
  return true
end 


local function drop(self,event)
  lockpeg()
  w= event.target.x
  self.bodyType = "dynamic"
  return true
end


local function resetBall()
  
    local function moveBall()
      ball.x, ball.y = w,screenTop+50
      ball.bodyType="static"
    end
    transition.to (ball,{time = 250, alpha=0, onComplete = moveBall})
    transition.to (ball,{delay= 500, time=500, alpha=1})
    for i = 1,pegGrp.numChildren do
      pegGrp[i].move = false
      pegGrp[i].hit = false
      pegGrp[i].alpha = 1
    end
end

local function collisionProcces(self, event)
  local finalscore

  local function newPegs()
    if btn then 
      display.remove(btn)
    end 
    generatePegs(level)
  end
  
  local function peghi()
    local ok = true
    for i = 1, pegGrp.numChildren do 
      if pegGrp[i].hit == false then
        ok = false
      end
    end  
    return ok
  end
  
  if event.phase == "began" then
     
    if event.other.name =="wall" then
      audio.play(refe)
      atemp = atemp + 1
      atempText.text = "attemp: "..atemp
      resetBall()
      
    elseif event.other.name == "target" then
      atemp = atemp +1
      atempText.text = "attemp: "..atemp
     local go = peghi()
      if go == false then
        audio.play(refe)
      end 
    
      if go == true then
         
        while (pegGrp.numChildren >0) do
          display.remove(pegGrp[1])
        end
        if event.phase == "began" then 
          if level <10 then
            audio.play(goal)
            level = level + 1
            score = score + (15*level)/atemp
            scoreText.text = "score: "..score
            leveltext.text = "level: "..level
            timer.performWithDelay(2000,newPegs)
            atemp = 0
            atempText.text = "attemp: "..atemp
          elseif level == 10 then
            finalscore = score
            audio.play(goal2)
            level = 1
            score = 0
            w= centerX
            leveltext.text = "level: "..level
            scoreText.text = "level: "..score
            atempText.text = "attemp: "..atemp
            btn = display.newImage("graphics/win.png",centerX,centerY)
            
            btn.width= screenWidth
            btn.height= screenHeight
            btn.tap = newPegs
            btn:addEventListener("tap",btn)
            atemp = 0
            atempText.text = "attemp: "..atemp
          end
        end
       
     end
     resetBall()
      
    elseif event.other.name == "peg" then
        event.other.alpha = 0.6
        event.other.hit = true
        audio.play(kick)
    end
  end
  return true
end 

local function dragBall(self,event)
  local sw = event.target.x
	if event.phase == "began"  then 
		self.oldx = self.x
		--self.oldy=self.y
		display.getCurrentStage():setFocus(self)
		self.hasFocus=true
	elseif self.hasFocus then
    
		if event.phase == "moved" then
      if self.x < screenLeft +20  then 
        self.x = screenLeft+20
      elseif self.x > screenRight-20 then
        self.x = screenRight-20
      else 
      self.x = event.x - event.xStart + self.oldx 
      end 
			--self.y = event.y - event.yStart + self.oldy
  elseif event.phase =="ended" or event.phase == "cancelled" then
			display.getCurrentStage():setFocus(nil)
			self.hasFocus = false
		end
	end

end

local function movePeg(self,event)
  if self.move == false then
    if event.phase == "began" then
      self.oldx = self.x
      self.oldy=self.y
      display.getCurrentStage():setFocus(self)
      self.hasFocus=true
    elseif self.hasFocus then
      if event.phase == "moved" then
        if self.x  < screenLeft+50  then 
          self.x = screenLeft+50
        elseif self.x >screenRight-50 then
          self.x = screenRight-50
        elseif self.y > screenBottom-100 then
          self.y = screenBottom-100
        elseif self.y < screenTop+300 then
          self.y = screenTop +300
        else 
          self.x = (event.x - event.xStart) + self.oldx      
          self.y = (event.y - event.yStart) + self.oldy 
        end
    elseif (event.phase =="ended" or event.phase == "cancelled") then 
          display.getCurrentStage():setFocus(nil)
          self.hasFocus = false
      end
    end
  end  
end

function generatePegs(howMany)
  local peg 
  for i = 1, howMany+1 do 
    xCord= math.random(screenLeft+100,screenRight-100)
    yCord = math.random(screenTop+200,screenBottom - 200)
    peg = display.newImage("graphics/flag.png",xCord,yCord)
    peg.name = "peg"
    peg.hit = false
    peg.move = false
 
    physics.addBody(peg,"static",{radius = 60})
    peg.touch = movePeg
    peg:addEventListener("touch",peg)
    pegGrp:insert(peg)
    peg= nil
  end
end  
  
function setScreen(event)
  if btn then 
    display.remove(btn)
  end
  bg2.alpha = 1
  wall = display.newRect(screenLeft,centerY, 10,screenHeight)
  wall.name = "wall"
  physics.addBody(wall,"static")
  leveltext = display.newText("level: "..level,screenLeft+120,screenTop +20,native.systemFont,55)
  leveltext.fill = {1,0,0}
  scoreText = display.newText("score: "..score,centerX-15,screenTop +20,native.systemFont,55)
  scoreText.fill = {1,0,0}
  atempText = display.newText("attempt: "..atemp,centerX+250,screenTop+20,native.systemFont,55)
  atempText.fill = {1,0,0}
  wall2 = display.newRect(screenRight,centerY, 10,screenHeight)
  wall2.name = "wall"
  physics.addBody(wall2,"static")
  floor = display.newRect(centerX,screenBottom,screenWidth,10)
  floor.name = "wall"
  physics.addBody(floor,"static")
  ball = display.newImage("graphics/ball.png",centerX,screenTop+150)
  ball.name = "ball"
  physics.addBody(ball,"static", {radius = 30})
  ball.touch = dragBall
  ball.tap = drop
  ball.collision = collisionProcces
  ball:addEventListener("collision",ball)
  ball:addEventListener("tap",ball)
  ball:addEventListener("touch", ball)
  ball:scale(0.8,0.8)
  target = display.newImage("graphics/target.png",centerX,screenBottom-30)
  target:scale(1.3,0.9)
  target.name = "target"
  physics.addBody(target,"static")
  generatePegs(level)
  return true
end

local function onSystemEvent( event )
  if event.type == "applicationExit"  then
    --print("application Exit")
    saveState()
  elseif event.type == "applicationStart"  then
    if fileExists() then
      --print("file exists... LOADING")
      loadSavedState()
    end
  end
  
end

Runtime:addEventListener( "system", onSystemEvent )


