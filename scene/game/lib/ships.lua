------------------------------------------------------------------------------------------------
-- The Ships module.
--
-- @module  ships
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
local lasers   = require 'scene.game.lib.lasers'

-- ------------------------------------------------------------------------------------------ --
--                                 LOCALISED VARIABLES                                        --	
-- ------------------------------------------------------------------------------------------ --

local mSin = math.sin
local mCos = math.cos
local mRad = math.rad

-- ------------------------------------------------------------------------------------------ --
--                                 PRIVATE METHODS                                            --	
-- ------------------------------------------------------------------------------------------ --
local vertices = { 
	mCos( mRad( 0 ) ) , mSin(  mRad( 0 ) ), 
	mCos( mRad( 120 ) ), mSin( mRad( 120 ) ), 
	mCos( mRad( 240 ) ), mSin( mRad( 240 ) ), 
}

local function vector2DFromAngle( angle )
	return { x=mCos( mRad( angle ) ), y=mSin( mRad( angle ) ) }
end	

-- ------------------------------------------------------------------------------------------ --
--                                 PUBLIC METHODS                                             --	
-- ------------------------------------------------------------------------------------------ --

local function addTrail( group )
	-- Create tail
	local tail   = display.newPolygon( group.parent, group.x, group.y, vertices )
	tail:scale( -0.4, 0.4 )
	tail:translate( group.radius * mCos( mRad( group.rotation + 180 ) ), group.radius * mSin( mRad( group.rotation  + 180 ) ) )
	tail:rotate( group.rotation )

	transition.to( tail, { xScale=0, yScale=0, alpha=0, onComplete=display.remove } )
end	

------------------------------------------------------------------------------------------------
-- Constructor function of Ships module.
--
--- @param options The table with all options for the ship.
--
-- - `x`:		 		the center x position of the ship
-- - `y`: 		 		the center y position of the ship
-- - `isAccelerating`:  the boolean value indciating that the ship is accelerated
-- - `rotationSpeed`: the rotation angle by frame
-- - `radius`: 			the radius of the smallest circle containing the ship (triangle)
--
-- @return The ship ship.
------------------------------------------------------------------------------------------------
function M.new( options )
	-- Get the current scene group
	local parent = display.currentStage

	-- Default options for ship
	options = options or {}

	local x               = options.x               or 0
	local y               = options.y               or 0
	local velocity        = options.velocity        or { x=0, y=0 }
	local isAccelerating  = options.isAccelerating  or false
	local rotationSpeed   = options.rotationSpeed   or 0
	local radius          = options.radius          or 25
	
	for i=1, #vertices do vertices[i] = vertices[i] * radius end	

	-- Create equilateral triangle ship
	local ship  = display.newPolygon( parent, 0, 0, vertices )
	-- Set appearance
	local black 	 = { 0, 0, 0 }
	ship.fill 		 = black
	ship.strokeWidth = 3
	-- Set Position
	ship.x = x
	ship.y = y
	-- Add basic properties
	ship.rotationSpeed  = rotationSpeed
	ship.isAccelerating = isAccelerating
	ship.velocity 		= velocity
	ship.lasers 		= {}
	ship.radius 		= radius
	
	function ship:setRotation( angle )
		self.rotationSpeed = angle
	end	

	function ship:setAccelerate( value )
		self.isAccelerating = value
	end	

	function ship:accelerate()
		local force = vector2DFromAngle( self.rotation  )
		force.x = force.x * 0.007 
		force.y = force.y * 0.007

		self.velocity.x = self.velocity.x + force.x
		self.velocity.y = self.velocity.y + force.y
	end	

	function ship:turn( dt )
		self:rotate( self.rotationSpeed * dt )
	end	

	function ship:update( dt )
		if self.isAccelerating then
			self:accelerate()
			--self.tail.isVisible = true
			addTrail( parent )
		else
			--self.tail.isVisible = false	
		end

		self:translate( self.velocity.x * dt, self.velocity.y * dt )	
		self.velocity.x = self.velocity.x * 0.99
		self.velocity.y = self.velocity.y * 0.99

	end	

	function ship.fire()
		local x = ship.x + mCos(mRad(ship.rotation)) * ship.radius
		local y = ship.y + mSin(mRad(ship.rotation)) * ship.radius
		local laser = lasers.new( { x=x, y=y, heading=ship.rotation } )
		ship.lasers[#ship.lasers + 1] = laser
	end

	function ship:edges()
		if  self.x > screen.RIGHT + self.radius then
	    	self.x = -self.radius + screen.LEFT
	    elseif self.x < -self.radius + screen.LEFT then
	    	self.x = screen.RIGHT + self.radius
	    end

	    if self.y > screen.BOTTOM + self.radius then
	    	self.y = -self.radius + screen.TOP
	    elseif self.y < -self.radius + screen.TOP then
	      self.y = screen.BOTTOM + self.radius
	    end
	end

	-- Keyboard control
	local lastEvent = {}
	local function key( event )

		local phase = event.phase
		local name = event.keyName

		if ( phase == lastEvent.phase ) and ( name == lastEvent.keyName ) then return false end  -- Filter repeating keys

		if phase == 'down' then
			if 'right' == name then
				ship:setRotation( 0.1 )
			elseif 'left' == name then
				ship:setRotation( -0.1 )
			elseif 'up' == name then
				ship:setAccelerate( true )
			elseif 'space' == name then
				ship.fire()
			end

		elseif phase == 'up' then
			ship:setRotation( 0 )
			ship:setAccelerate( false )
		end

		lastEvent = event
	end
	
	local function touch( event )
		local phase = event.phase
		if phase == 'ended' then

			ship.fire()

		end
	end	

	function ship:finalize()
		-- On remove, cleanup ship, or call directly for non-visual
		Runtime:removeEventListener( 'key', key )
		Runtime:removeEventListener( 'touch', touch )
	end

	-- Add a finalize listener (for display objects only, comment out for non-visual)
	ship:addEventListener( 'finalize' )

	-- Add our key/joystick listeners
	Runtime:addEventListener( 'key', key )	
	Runtime:addEventListener( 'touch', touch )

	return ship
end	

return M