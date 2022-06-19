return {
	Name = "give-coins",
	Aliases = {"give-coins"},
	Description = "Gives the target player(s) a specified amount of coins.",
	Group = "Admin",
	Args = {
		{
			Type = "players",
			Name = "recipiant",
			Description = "The players to give money",
		},
		{
			Type = "number",
			Name = "amount",
			Description = "The coins amount",
		}
	},
}