------------------------------------------------------------------------------------------------
-- The Game module.
--
-- @module  game
-- @author Łukasz Durniat
-- @license MIT
-- @copyright Łukasz Durniat, Mar-2018
------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------ --
--                                 REQUIRED MODULES                                             --                
-- ------------------------------------------------------------------------------------------ --
 
local composer  = require 'composer' 
local ships     = require 'scene.game.lib.ships' 
local obstacles = require 'scene.game.lib.obstacles' 
local deltatime = require 'scene.game.lib.deltatime'

-- ------------------------------------------------------------------------------------------ --
--                                 MODULE DECLARATION                                       --                 
-- ------------------------------------------------------------------------------------------ --

local scene = composer.newScene()

-- ------------------------------------------------------------------------------------------ --
--                                 LOCALISED VARIABLES                                        --   
-- ------------------------------------------------------------------------------------------ --

-- ------------------------------------------------------------------------------------------ --
--                                 PRIVATE METHODS                                            --   
-- ------------------------------------------------------------------------------------------ --

local function concat ( tableA, tableB )
   for k, v in pairs( tableB ) do 
      tableA[ #tableA + 1 ] = v 
   end

   return tableA
end 

-- ------------------------------------------------------------------------------------------ --
--                                 PUBLIC METHODS                                             --   
-- ------------------------------------------------------------------------------------------ --

local ship
local asteroids = {}   

function scene:create( event )
   local sceneGroup = self.view
 
   local _CX = display.contentCenterX
   local _CY = display.contentCenterY
   -- Create new ship 
   ship = ships.new( { x=_CX, y=_CY } )

   for i=1, 10 do
      -- Create asteroids
      asteroids[i] = obstacles.new()
   end
end

-- In every frame we update position of ship, asteroids and lasers. 
-- Also we detect collision between lasers and asteroids.
local function enterFrame( event )
   local laser, asteroid
   local dt = deltatime.getTime()
      
   ship:edges()
   ship:turn( dt )
   ship:update( dt )

   local isShipDestroyed = false
   for i=1, #asteroids do
      asteroid = asteroids[i]
      asteroid:update( dt )
      asteroid:edges()
      isShipDestroyed = ship:detectCollision(asteroid) or isShipDestroyed
   end

   local lasers = ship.lasers
   for i=#lasers, 1, -1 do
      laser = lasers[i]

      -- Check if laser goes out of the screen
      if not laser:offScreen() then
         laser:update( dt )

         for j=#asteroids, 1, -1 do
            asteroid = asteroids[j]
            -- Detect collision
            if laser:hit( asteroid ) then
               if asteroid.radius > 15 then
                  local newAsteroids = asteroid:breakup()
                  concat( asteroids, newAsteroids )
               end   

               -- Remove asteroid
               table.remove( asteroids, j )
               display.remove( asteroid )

               -- Remove laser
               table.remove( lasers, i )
               display.remove( laser )

               break
            end   
         end 
      else
         -- Remove laser
         table.remove( lasers, i )
         display.remove( laser )
      end     
   end
end 
 
function scene:show( event )
   local sceneGroup = self.view
   local phase = event.phase
 
   if phase == 'will' then
      -- Add listener
      Runtime:addEventListener( 'enterFrame', enterFrame )
   elseif phase == 'did' then

   end
end
 
function scene:hide( event )
   local sceneGroup = self.view
   local phase = event.phase
 
   if phase == 'will' then

   elseif phase == 'did' then
      -- Remove listener
      Runtime:removeEventListener( 'enterFrame', enterFrame )
   end
end

function scene:destroy( event )
 
end
 
scene:addEventListener( 'create', scene )
scene:addEventListener( 'show', scene )
scene:addEventListener( 'hide', scene )
scene:addEventListener( 'destroy', scene )
 
return scene