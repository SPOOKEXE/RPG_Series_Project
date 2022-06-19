local Module = {}

function Module:ToVector3int16( baseVector3 )
	return Vector3int16.new( baseVector3.X * 100, baseVector3.Y * 100, baseVector3.Z * 100 )
end

function Module:ToVector3( baseVector3int16 )
	return Vector3.new( baseVector3int16.X, baseVector3int16.Y, baseVector3int16.Z )  / 100
end

function Module:CFrameToVector3s( CFValue )
	return CFValue.Position, CFValue.LookVector
end

function Module:CFrameToVector3int16s( CFValue )
	return Module:ToVector3int16( CFValue.Position ), Module:ToVector3int16( CFValue.LookVector )
end

function Module:Vector3sToCFrame( Position, Direction )
	return CFrame.new( Position, Direction )
end

function Module:Vector3int16sToCFrame( PositionInt16, DirectionInt16 )
	local Position = Module:ToVector3(PositionInt16)
	local Direction = Module:ToVector3(DirectionInt16)
	return Module:Vector3sToCFrame(Position, Direction)
end

return Module