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
-- - `rotationByFrame`: the rotation angle by frame
-- - `radius`: 			the radius of the smallest circle containing the ship (triangle)
--
-- @return The ship instance.
------------------------------------------------------------------------------------------------
function M.new( options )

	-- Get the current scene
	local scene = composer.getScene( composer.getSceneName( 'current' ) )
	local parent = scene.view

	-- Default options for instance
	options = options or {}

	local x               = options.x               or 0
	local y               = options.y               or 0
	local velocity        = options.velocity        or { x=0, y=0 }
	local isAccelerating  = options.isAccelerating  or false
	local rotationByFrame = options.rotationByFrame or 0
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
	instance.rotationByFrame = rotationByFrame
	instance.isAccelerating = isAccelerating
	instance.velocity = velocity
	instance.lasers = {}

	function instance:setRotation( angle )

		self.rotationByFrame = angle

	end	

	function instance:setAccelerate( value )

		self.isAccelerating = value

	end	

	function instance:accelerate()

		local force = vector2DFromAngle( self.rotation  )
		force.x = force.x * 0.1 
		force.y = force.y * 0.1

		self.velocity.x = self.velocity.x + force.x
		self.velocity.y = self.velocity.y + force.y

	end	

	function instance:turn( value )

		self.rotation = self.rotation + self.rotationByFrame

	end	

	function instance:update()

		if self.isAccelerating then

			self:accelerate()

		end
		
		self.x = self.x + self.velocity.x 
		self.y = self.y + self.velocity.y	

		self.velocity.x = self.velocity.x * 0.99
		self.velocity.y = self.velocity.y * 0.99

	end	

	function instance.fire()
		
		local laser = lasers.new( { x=instance.x, y=instance.y, heading=instance.rotation } )	
		instance.lasers[#instance.lasers + 1] = laser

	end

	-- Keyboard control
	local lastEvent = {}
	local function key( event )

		local phase = event.phase
		local name = event.keyName

		if ( phase == lastEvent.phase ) and ( name == lastEvent.keyName ) then return false end  -- Filter repeating keys

		if phase == 'down' then

			if 'right' == name then

				instance:setRotation( 1 )

			elseif 'left' == name then

				instance:setRotation( -1 )

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