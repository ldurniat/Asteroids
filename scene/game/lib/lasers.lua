------------------------------------------------------------------------------------------------
-- The Lasers module.
--
-- @module  lasers
-- @author Łukasz Durniat
-- @license MIT
-- @copyright Łukasz Durniat, Mar-2018
------------------------------------------------------------------------------------------------

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

	local _T  = display.screenOriginY
	local _B  = display.viewableContentHeight - display.screenOriginY
	local _L  = display.screenOriginX
	local _R  = display.viewableContentWidth - display.screenOriginX

	-- Get the current scene
	local scene = composer.getScene( composer.getSceneName( 'current' ) )
	local parent = scene.view

	-- Default options for instance
	options = options or {}

	local x        = options.x        or 0
	local y        = options.y        or 0
	local velocity = options.velocity or vector2DFromAngle( options.heading  or 0 )

	velocity.x = velocity.x * 3
	velocity.y = velocity.y * 3

	local instance = display.newRect( parent, x, y, 5, 5 )
	local black = { 0, 0, 0 }
	instance.fill = black
	instance.strokeWidth = 3
	instance.velocity = velocity

	function instance:update()
	
		self.x = self.x + self.velocity.x 
		self.y = self.y + self.velocity.y	

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

		if self.x > _R or self.x < _L then

      		return true
    	end
	    if self.y > _B or self.y < _T then

	      return true
	    
	    end

	    return false

	end	

	return instance
	
end	

return M