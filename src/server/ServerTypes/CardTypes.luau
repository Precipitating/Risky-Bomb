local CardTypes = {}

export type CardData = {
	KeyName: string,
	Name: string,
	Description: string,
	ImageID: string,
	UseType: number,
	Use: (Player, number) -> (),
}

return CardTypes
