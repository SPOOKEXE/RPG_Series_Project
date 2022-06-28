local Players = game:GetService('Players')
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')
ReplicatedAssets.Interface.Parent = LocalPlayer:WaitForChild('PlayerGui')
