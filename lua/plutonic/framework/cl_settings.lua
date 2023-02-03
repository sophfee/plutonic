Plutonic.Static = {}
Plutonic.Static.CachedSettings = {}
Plutonic.Static.Dirty = false

function Plutonic.Framework.InvalidateControlCache()
	Plutonic.Static.CachedSettings = {}
	Plutonic.Static.Dirty = true -- We rebuild the cache on the next frame, and as needed.
end

function Plutonic.Framework.GetControl_Data( name )
	if ( Plutonic.Static.CachedSettings[ name ] == nil ) then
		Plutonic.Static.CachedSettings[ name ] = cookie.GetString( "p0c0s0::" .. name, "" )
	end
	return Plutonic.Static.CachedSettings[ name ] or ""
end

function Plutonic.Framework.GetControl_Bool( name, default )
	local Control_Data = Plutonic.Framework.GetControl_Data( name )
	if ( Control_Data == "" ) then
		Plutonic.Static.CachedSettings[ name ] = default
		return (default)
	end
	return (Control_Data == "1")
end

function Plutonic.Framework.GetControl_Number( name, default )
	local Control_Data = Plutonic.Framework.GetControl_Data( name )
	if ( Control_Data == "" || tonumber(Control_Data) == nil ) then
		Plutonic.Static.CachedSettings[ name ] = default
		return (default)
	end
	return tonumber( Control_Data )
end

function Plutonic.Framework.GetControl_String( name, default )
	local Control_Data = Plutonic.Framework.GetControl_Data( name )
	if ( Control_Data == "" ) then
		Plutonic.Static.CachedSettings[ name ] = default
		return (default)
	end
	return Control_Data
end

function Plutonic.Framework.SetControl( name, value )
	Plutonic.Static.CachedSettings[ name ] = value
	cookie.Set( "p0c0s0::" .. name, value )
end

function Plutonic.Framework.SetControl_Bool( name, value )
	Plutonic.Framework.SetControl( name, (value and "1" or "0") )
end

function Plutonic.Framework.SetControl_Number( name, value )
	Plutonic.Framework.SetControl( name, tostring(value) )
end

function Plutonic.Framework.SetControl_String( name, value )
	Plutonic.Framework.SetControl( name, tostring(value) )
end