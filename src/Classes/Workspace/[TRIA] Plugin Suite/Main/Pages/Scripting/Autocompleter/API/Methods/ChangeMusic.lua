return {
	Name = "ChangeMusic",
	Arguments = "ChangeMusic(musicId: number, volume: number, startTick: number): ()",
	Branches = nil,
	Documentation = {
		value = "Changes the map music, allowing for a custom sound ID, volume and starting position. This can be used to splice songs together or to jump to other parts in the same song."
	},
	CodeSample = [[-- Jump ahead 50 seconds in the audio '123456789'  
MapLib:ChangeMusic(123456789, 0.5, 50)  ]]
}
