------------------------------------------------------------------------------------------------
-- The Ships module.
--
-- @module  ships
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

local function vector2DFromAngle( angle )

	return { x=mCos( mRad( angle ) ), y=mSin( mRad( angle ) ) }
	
end	

-- ------------------------------------------------------------------------------------------ --
--                                 PUBLIC METHODS                                             --	
-- ------------------------------------------------------------------------------------------ --

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
-- @return The ship instance.
------------------------------------------------------------------------------------------------
function M.new( options )

	-- Get the current scene group
	local parent = display.currentStage

	local _T = display.screenOriginY
	local _B = display.viewableContentHeight - display.screenOriginY
	local _L = display.screenOriginX
	local _R = display.viewableContentWidth - display.screenOriginX

	-- Default options for instance
	options = options or {}

	local x               = options.x               or 0
	local y               = options.y               or 0
	local velocity        = options.velocity        or { x=0, y=0 }
	local isAccelerating  = options.isAccelerating  or false
	local rotationSpeed   = options.rotationSpeed   or 0
	local radius          = options.radius          or 25

	-- Isosceles triangle
	local vertices = { 
		mCos(  mRad( 0 ) ) * 1.5, mSin(  mRad( 0 ) ) * 1.5, 
		mCos( mRad( 120 ) ), mSin( mRad( 120 ) ), 
		mCos( mRad( 240 ) ), mSin( mRad( 240 ) ), 
	}
	for i=1, #vertices do vertices[i] = vertices[i] * radius end	

	local instance = display.newPolygon( parent, x, y, vertices )
	local black = { 0, 0, 0 }
	instance.fill = black
	instance.strokeWidth = 3

	-- Add basic properties
	instance.rotationSpeed = rotationSpeed
	instance.isAccelerating = isAccelerating
	instance.velocity = velocity
	instance.lasers = {}
	instance.radius = radius

	function instance:setRotation( angle )

		self.rotationSpeed = angle

	end	

	function instance:setAccelerate( value )

		self.isAccelerating = value

	end	

	function instance:accelerate()

		local force = vector2DFromAngle( self.rotation  )
		force.x = force.x * 0.007 
		force.y = force.y * 0.007

		self.velocity.x = self.velocity.x + force.x
		self.velocity.y = self.velocity.y + force.y

	end	

	function instance:turn( dt )

		self:rotate( self.rotationSpeed * dt )

	end	

	function instance:update( dt )

		if self.isAccelerating then self:accelerate() end

		self:translate( self.velocity.x * dt, self.velocity.y * dt )	
		self.velocity.x = self.velocity.x * 0.99
		self.velocity.y = self.velocity.y * 0.99

	end	

	function instance.fire()
		
		local laser = lasers.new( { x=instance.x, y=instance.y, heading=instance.rotation } )	
		instance.lasers[#instance.lasers + 1] = laser

	end

	function instance:edges()
	
		if  self.x > _R + self.radius then
	    
	    	self.x = -self.radius + _L
	    
	    elseif self.x < -self.radius + _L then

	    	self.x = _R + self.radius
	    
	    end

	    if self.y > _B + self.radius then

	    	self.y = -self.radius + _T

	    elseif self.y < -self.radius + _T then

	      self.y = _B + self.radius

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

				instance:setRotation( 0.1 )

			elseif 'left' == name then

				instance:setRotation( -0.1 )

			elseif 'up' == name then

				instance:setAccelerate( true )

			elseif 'space' == name then

				instance.fire()

			end

		elseif phase == 'up' then
			
			instance:setRotation( 0 )
			instance:setAccelerate( false )

		end

		lastEvent = event

	end
	
	local function touch( event )

		local phase = event.phase
		if phase == 'ended' then

			instance.fire()

		end

	end	

	function instance:finalize()

		-- On remove, cleanup instance, or call directly for non-visual
		Runtime:removeEventListener( 'key', key )
		Runtime:removeEventListener( 'touch', touch )

	end

	-- Add a finalize listener (for display objects only, comment out for non-visual)
	instance:addEventListener( 'finalize' )

	-- Add our key/joystick listeners
	Runtime:addEventListener( 'key', key )	
	Runtime:addEventListener( 'touch', touch )

	return instance
	
end	

return M