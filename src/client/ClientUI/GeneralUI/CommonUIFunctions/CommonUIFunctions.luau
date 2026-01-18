local CommonUIFunctions = {}

-- used to dynamically calculate how far/close object should be, so the viewport object is in frame.
-- this is used to prevent manual position offsetting
function CommonUIFunctions.CameraLookAtObject(camera: Camera, object: MeshPart)
	local size = object.Size
	local maxDimension = math.max(size.X, size.Y, size.Z)
	camera.CFrame = CFrame.new(0, 0, maxDimension * 1.3)
end

return CommonUIFunctions
