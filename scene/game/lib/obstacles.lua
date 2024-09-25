------------------------------------------------------------------------------------------------
-- The Obstacles module.
--
-- @module  obstacles
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

local mSin = math.sin
local mCos = math.cos
local mRad = math.rad
local mRandom = math.random

-- ------------------------------------------------------------------------------------------ --
--                                 PRIVATE METHODS                                            --	
-- ------------------------------------------------------------------------------------------ --

local function vector2DFromAngle( angle )
	return { x=mCos( mRad( angle ) ), y=mSin( mRad( angle ) ) }
end	

-- ------------------------------------------------------------------------------------------ --
--                                 PUBLIC METHODS                                             --	
-- ------------------------------------------------------------------------------------------ --

------------------------------------------------------------------------------------------------
-- Constructor function of Obstacles module.
--
--- @param options The table with all options for the obstacles.
--
-- - `x`:		 the center x position of the ship
-- - `y`: 		 the center y position of the ship
-- - `radius`:   the radius of the smallest circle containing the obstacle (polygon)
-- - `velocity`: the table with `x` and `y` fields
--
-- @return The obstacle instance.
------------------------------------------------------------------------------------------------
function M.new( options )
	-- Get the current scene group
	local parent = display.currentStage

	-- Default options for instance
	options = options or {}

	local x        = options.x      or mRandom( screen.LEFT, screen.RIGHT )
	local y        = options.y      or mRandom( screen.TOP, screen.BOTTOM )
	local radius   = options.radius or mRandom( 18, 25 )
	local velocity = options.velocity or { x=mRandom() / 12, y=mRandom() / 12 }

	local vertices = {}
	local verticesNum = mRandom( 5, 10 )
	local angle = 360 / verticesNum
	for i=1, verticesNum do
		vertices[2 * i - 1] = mCos(  mRad( angle * i ) ) * mRandom( 0.5 * radius, 1.5 * radius )
		vertices[2 * i] = mSin(  mRad( angle * i ) ) * mRandom( 0.5 * radius, 1.5 * radius )
	end	

	local instance = display.newPolygon( parent, x, y, vertices )
	local black = { 0, 0, 0 }
	instance.fill = black
	instance.strokeWidth = 3
	instance.velocity = velocity
	instance.radius = radius

	function instance:update( dt )
		self:translate( self.velocity.x * dt, self.velocity.y  * dt )	
	end	

	function instance:breakup()
		local newAsteroids = {
			M.new( { x=self.x, y=self.y, radius=self.radius * 0.5 } ),
			M.new( { x=self.x, y=self.y, radius=self.radius * 0.5 } )
		}

		return newAsteroids
	end

	function instance:edges()
		if  self.x > screen.RIGHT + self.radius then
	    	self.x = -self.radius + screen.LEFT
	    elseif self.x < -self.radius +screen.LEFT then
	    	self.x = screen.RIGHT + self.radius
	    end

	    if self.y > screen.BOTTOM + self.radius then
	    	self.y = -self.radius + screen.TOP
	    elseif self.y < -self.radius + screen.TOP then
	      self.y = screen.BOTTOM + self.radius
	    end
	end

	return instance
end	

return M