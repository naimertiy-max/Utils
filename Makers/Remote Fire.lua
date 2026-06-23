local RemotePath = game.ReplicatedStorage.GrabEvents.CreateGrabLine
if not RemotePath or not RemotePath:IsA("RemoteEvent") then
    warn("RemoteEvent inválido ou não encontrado")
    return
end
RemotePath:FireAllClients()