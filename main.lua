------------------------------------------------------------------------------------------------
-- The start point for game.
--
-- @script  main
-- @author Łukasz Durniat
-- @license MIT
-- @copyright Łukasz Durniat, Mar-2018
------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------ --
--                                 REQUIRED MODULES	                                          --						
-- ------------------------------------------------------------------------------------------ --

local composer = require( 'composer' ) 

-- ------------------------------------------------------------------------------------------ --
--                                 LOCALISED VARIABLES                                        --	
-- ------------------------------------------------------------------------------------------ --

-- ------------------------------------------------------------------------------------------ --
--                                 PRIVATE METHODS                                            --	
-- ------------------------------------------------------------------------------------------ --

-- ------------------------------------------------------------------------------------------ --
--                                 PUBLIC METHODS                                             --	
-- ------------------------------------------------------------------------------------------ --

-- Removes status bar on iOS
-- https://docs.coronalabs.com/api/library/display/setStatusBar.html
display.setStatusBar( display.HiddenStatusBar ) 

-- Removes bottom bar on Android 
if system.getInfo( 'androidApiLevel' ) and system.getInfo( 'androidApiLevel' ) < 19 then
	native.setProperty( 'androidSystemUiVisibility', 'lowProfile' )
else
	native.setProperty( 'androidSystemUiVisibility', 'immersiveSticky' ) 
end

-- Go to the game screen
composer.gotoScene( 'scene.game' )
