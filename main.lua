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

    screenHeight = love.graphics.getHeight()
    screenWidth = love.graphics.getWidth()

    zombies={}

    bullets={}

end

function love.update(dt)

    if love.keyboard.isDown("d") then
        if player.x<screenWidth then
            player.x = player.x + player.speed*dt
        end
    end

    if love.keyboard.isDown("a") then
        if player.x>0 then
            player.x = player.x - player.speed*dt
        end
    end

    if love.keyboard.isDown("w") then
        if player.y > 0 then
            player.y = player.y - player.speed*dt
        end
    end

    if love.keyboard.isDown("s") then
        if player.y < screenHeight then
            player.y = player.y + player.speed*dt
        end
    end

    for i,z in ipairs(zombies) do
        z.x = z.x + (math.cos(playerZombieAngle(z))*z.speed*dt)
        z.y = z.y + (math.sin(playerZombieAngle(z))*z.speed*dt)

        if distanceBetween(z.x,z.y,player.x,player.y)<30 then
            for i,z in ipairs(zombies) do
                zombies[i]=nil
            end
        end
    end

    for i,b in ipairs(bullets) do
        b.x = b.x + (math.cos(b.direction)*b.speed*dt)
        b.y = b.y + (math.sin(b.direction)*b.speed*dt)

       --for i,z in ipairs(zombies) do
           -- if distanceBetween(b.x,b.y,z.x,z.y)<30 then
           -- zombies[i]=nil
           -- end
      -- end
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

end

function love.draw()
    love.graphics.draw(sprites.background,0,0)
    love.graphics.draw(sprites.player,player.x ,player.y,playerMouseAngle(),nil,nil, sprites.player:getWidth()/2,sprites.player:getHeight()/2)

    for i,z in ipairs(zombies) do 
        love.graphics.draw(sprites.zombie,z.x,z.y,playerZombieAngle(z),nil,nil,sprites.zombie:getWidth()/2,sprites.zombie:getHeight()/2)

    end

    for i,b in ipairs(bullets) do 
        love.graphics.draw(sprites.bullet,b.x,b.y,nil,1/2,1/2,sprites.bullet:getWidth()/2,sprites.bullet:getHeight()/2)

    end
end

-- Check if space is pressed to spawn Zombie 
function love.keypressed(key)
    if key == "space" then
        spawnZombie()
    
    end
end

-- Check if Left mouse is clicked to spawn Bullet

function love.mousepressed( x, y, button, istouch, presses )
    if button==1 then
        spawnBullet()
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

