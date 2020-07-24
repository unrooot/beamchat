return function(_, targets)
	for _,target in pairs(targets) do
		for _,v in pairs(target.Character:GetChildren()) do
			if v:IsA("ForceField") then
				v:Destroy()
			end
		end
	end
end