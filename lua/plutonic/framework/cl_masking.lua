
--- Starts a mask to draw a model to the stencil buffer, this is used for sights
-- @param ent The entity to draw to the stencil buffer
-- @realm client
Plutonic.Framework.Mask = function(ent)
	render.SetStencilReferenceValue( 0 )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()

	render.SetStencilEnable( true )
	render.SetStencilWriteMask( 0xF0 )
	render.ClearStencilBufferRectangle( 0, 0, ScrW(), ScrH(), 0x0F )
	render.SetStencilCompareFunction( STENCIL_NEVER )
	render.SetStencilTestMask( 0x00 )
	render.SetStencilFailOperation( STENCIL_INCR )

	-- Draw the model to the stencil buffer
	ent:DrawModel()
	
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0x1F )
	render.SetStencilCompareFunction( STENCIL_EQUAL )
end

--- Ends a mask
-- @realm client
Plutonic.Framework.UnMask = function()
    render.SetStencilEnable( false )
end