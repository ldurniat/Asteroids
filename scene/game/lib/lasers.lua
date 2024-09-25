------------------------------------------------------------------------------------------------
-- The Lasers module.
--
-- @module  lasers
-- @author Łukasz Durniat
-- @license MIT
-- @copyright Łukasz Durniat, Mar-2018
------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------ --
--                                 REQUIRED MODULES 	                                      --						
-- ------------------------------------------------------------------------------------------ --

local screen = require("scene.game.lib.screen")

-- ------------------------------------------------------------------------------------------ --
--                                 MODULE DECLARATION	                                      --						
-- ------------------------------------------------------------------------------------------ --

local M = {}

-- ------------------------------------------------------------------------------------------ --
--                                 REQUIRED MODULES	                                          --						
-- ------------------------------------------------------------------------------------------ --

local composer = require 'composer' 

-- ------------------------------------------------------------------------------------------ --
--                                 LOCALISED VARIABLES                                        --	
-- ------------------------------------------------------------------------------------------ --

local mSin    = math.sin
local mCos    = math.cos
local mRad    = math.rad
local mRandom = math.random
local mSqrt   = math.sqrt

-- ------------------------------------------------------------------------------------------ --
--                                 PRIVATE METHODS                                            --	
-- ------------------------------------------------------------------------------------------ --

local function vector2DFromAngle( angle )
	return { x=mCos( mRad( angle ) ), y=mSin( mRad( angle ) ) }
end	

local function distance( x1, y1, x2, y2 ) 
	return mSqrt( ( x1 - x2 ) * ( x1 - x2 ) + ( y1 - y2 ) * ( y1 - y2 ) ) 
end	

-- ------------------------------------------------------------------------------------------ --
--                                 PUBLIC METHODS                                             --	
-- ------------------------------------------------------------------------------------------ --

------------------------------------------------------------------------------------------------
-- Constructor function of Ships module.
--
-- @param options The table with all options for the ship.
--
-- - `x`:		 the center x position of the ship
-- - `y`: 		 the center y position of the ship
-- - `velocity`: the table with `x` and `y` fields
--
-- @return The new laser instance.
------------------------------------------------------------------------------------------------
function M.new( options )
	-- Get the current scene group
	local parent = display.currentStage

	-- Default options for instance
	options = options or {}

	local x        = options.x        or 0
	local y        = options.y        or 0
	local velocity = options.velocity or vector2DFromAngle( options.heading  or 0 )

	velocity.x = velocity.x * 0.3
	velocity.y = velocity.y * 0.3

	local instance = display.newRect( parent, x, y, 5, 5 )
	local black = { 0, 0, 0 }
	instance.fill = black
	instance.strokeWidth = 3
	instance.velocity = velocity

	function instance:update( dt )
		self:translate( self.velocity.x  * dt, self.velocity.y  * dt )
	end

	function instance:hit( asteroid )
		local distanceFromObstacle = distance( self.x, self.y, asteroid.x, asteroid.y )
		if distanceFromObstacle < asteroid.radius then
			return true
		else
			return false
		end	
	end

	function instance:offScreen()
		if self.x > screen.RIGHT or self.x < screen.LEFT then

      		return true
    	end
	    if self.y > screen.BOTTOM or self.y < screen.TOP then
	      return true
	    end

	    return false
	end	

	return instance
end	

return M