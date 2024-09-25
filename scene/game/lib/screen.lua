------------------------------------------------------------------------------------------------
-- The Screen module.
--
-- @module  screen
-- @author Łukasz Durniat
-- @license MIT
-- @copyright Łukasz Durniat, Sep-2024
------------------------------------------------------------------------------------------------

-- ------------------------------------------------------------------------------------------ --
--                                 MODULE DECLARATION	                                      --						
-- ------------------------------------------------------------------------------------------ --

local M = {
	DECLARED_SCREEN_WIDTH = display.contentWidth,
	DECLARED_SCREEN_WIDTH = display.contentHeight,
	TOTAL_SCREEN_WIDTH	  = display.actualContentWidth,
	TOTAL_SCREEN_HEIGHT   = display.actualContentHeight, 
	CENTER_X 		      = display.contentCenterX,
	CENTER_Y		      = display.contentCenterY,
	UNUSED_WIDTH	      = display.actualContentWidth - display.contentWidth,
	UNUSED_HEIGHT	      = display.actualContentHeight - display.contentHeight,
	LEFT		          = display.contentCenterX - display.actualContentWidth * 0.5,
	TOP	                  = display.contentCenterY - display.actualContentHeight * 0.5,
	RIGHT 		          = display.contentCenterX + display.actualContentWidth * 0.5,
	BOTTOM 		          = display.contentCenterY + display.actualContentHeight * 0.5,
}

return M