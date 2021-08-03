function love.load()
    sprites={}
    sprites.background = love.graphics.newImage('sprites/background.png')
    sprites.bullet = love.graphics.newImage('sprites/bullet.png')
    sprites.player = love.graphics.newImage('sprites/player.png')
    sprites.zombie = love.graphics.newImage('sprites/zombie.png')

    player={}
    player.x=love.graphics.getWidth()/2
    player.y=love.graphics.getHeight()/2
    player.speed=180
    player.injured=false
    player.injuredSpeed=270

    screenHeight = love.graphics.getHeight()
    screenWidth = love.graphics.getWidth()

    zombies={}

    bullets={}

    gameState=1
    maxTime=2
    timer=maxTime

    score=0
    highscore=0
    
    

    myFont=love.graphics.newFont(30)

end

function love.update(dt)

    if gameState==2 then
        local moveSpeed = player.speed

        if player.injured then
            moveSpeed = player.injuredSpeed
        end

        if love.keyboard.isDown("d") then
            if player.x<screenWidth then
                player.x = player.x + moveSpeed*dt
            end
        end

        if love.keyboard.isDown("a") then
            if player.x>0 then
                player.x = player.x - moveSpeed*dt
            end
        end

        if love.keyboard.isDown("w") then
            if player.y > 0 then
                player.y = player.y - moveSpeed*dt
            end
        end

        if love.keyboard.isDown("s") then
            if player.y < screenHeight then
                player.y = player.y + moveSpeed*dt
            end
        end
    end

    for i,z in ipairs(zombies) do
        z.x = z.x + (math.cos(playerZombieAngle(z))*z.speed*dt)
        z.y = z.y + (math.sin(playerZombieAngle(z))*z.speed*dt)

        if distanceBetween(z.x,z.y,player.x,player.y)<30 then
                        -- if the player is not injured, set injured to true
            -- and also set the zombie that touched him to 'dead'
            if player.injured == false then
                player.injured = true
                z.dead = true
            -- otherwise, if the player was injured on collision,
            -- destroy all zombies and go back to gameState 1
            else
                for i,z in ipairs(zombies) do
                    zombies[i] = nil
                    gameState = 1
                    player.injured = false
                    player.x = love.graphics.getWidth()/2
                    player.y = love.graphics.getHeight()/2
                end
            end
        end

    end




    for i,b in ipairs(bullets) do
        b.x = b.x + (math.cos(b.direction)*b.speed*dt)
        b.y = b.y + (math.sin(b.direction)*b.speed*dt)
    end

    for i=#bullets,1,-1 do
        local b = bullets[i]
        if b.x < 0 or b.y < 0 or b.x>screenWidth or b.y>screenHeight then
            table.remove(bullets,i)

        end
    end

    for i,z in ipairs(zombies) do
        for j,b in ipairs(bullets) do
            if distanceBetween(z.x,z.y,b.x,b.y)<20 then
                z.dead=true
                b.dead=true
                score=score+1
            end
        end
    end

    for i=#zombies,1,-1 do
        local z = zombies[i]
        if z.dead==true then
            table.remove(zombies,i)
        end
    end

    for i=#bullets,1,-1 do
        local z = bullets[i]
        if z.dead==true then
            table.remove(bullets,i)
        end
    end

    if gameState==2 then
        timer=timer-dt
        if timer<=0 then
            spawnZombie()
            maxTime=0.95*maxTime
            timer=maxTime
            
        end
    end

end

function love.draw()
    love.graphics.setFont(myFont)
    love.graphics.draw(sprites.background,0,0)
    
    if player.injured==true then
        love.graphics.setColor(1,0,0)
    end
    
    love.graphics.draw(sprites.player,player.x ,player.y,playerMouseAngle(),nil,nil, sprites.player:getWidth()/2,sprites.player:getHeight()/2)

    love.graphics.setColor(1,1,1)
    love.graphics.printf("score:"..score,0,love.graphics.getHeight()-100,love.graphics.getWidth(),"center")
    love.graphics.printf("Highscore:"..highscore,0,10,love.graphics.getWidth(),"center")

    for i,z in ipairs(zombies) do 
        love.graphics.draw(sprites.zombie,z.x,z.y,playerZombieAngle(z),nil,nil,sprites.zombie:getWidth()/2,sprites.zombie:getHeight()/2)

    end

    for i,b in ipairs(bullets) do 
        love.graphics.draw(sprites.bullet,b.x,b.y,nil,1/2,1/2,sprites.bullet:getWidth()/2,sprites.bullet:getHeight()/2)

    end
    if gameState==1 then
        love.graphics.printf("Click anywhere to begin",0,50,love.graphics.getWidth(),"center")
    end

end

-- Check if Left mouse is clicked to spawn Bullet

function love.mousepressed( x, y, button, istouch, presses )
    if button==1 and gameState==2 then
        spawnBullet()
    elseif button==1 and gameState==1 then
        gameState=2
        maxTime=2
        timer=maxTime
        score=0
    end

end

-- Get angle between mouse and player 
function playerMouseAngle()
    return math.atan2(love.mouse.getY() - player.y  , love.mouse.getX() - player.x)
end

-- Get angle between player and zombie 
function playerZombieAngle(enemy)
    return math.atan2(player.y - enemy.y ,player.x - enemy.x)
end

--To calculate distance betweeen zombie and player --
function distanceBetween(x1,y1,x2,y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

-- spawn Zombie 
function spawnZombie()
    local zombie={}
   
    zombie.x=0
    zombie.y=0
    zombie.speed=140
    zombie.dead=false
    table.insert(zombies,zombie)

    local side=math.random(1,4)

    if side==1 then
        zombie.x=-30
        zombie.y=math.random(0,love.graphics.getHeight())
    

    elseif side==2 then
        zombie.x=love.graphics.getWidth()+30
        zombie.y=math.random(0,love.graphics.getHeight())
    

    elseif side==3 then
        zombie.x=math.random(0,love.graphics.getWidth())
        zombie.y=-30
    

    elseif side==4 then
        zombie.x = math.random(0,love.graphics.getWidth())
        zombie.y = love.graphics.getHeight()+30
    end
    

end

--Spawn Bullet
function spawnBullet()
    local bullet={}
    bullet.x=player.x
    bullet.y=player.y
    bullet.speed=500
    bullet.dead=false
    bullet.direction = playerMouseAngle()
    table.insert(bullets,bullet)
end

