Slack with Developer mode 
```
[System.Environment]::SetEnvironmentVariable('SLACK_DEVELOPER_MENU', 'true', 'Process')
& $env:LOCALAPPDATA\slack\app-4.16.1\slack.exe
```

Block Kit Builder (customize slack message)
```json
{
	"blocks": [
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "*Indique um Colega para Ganhar um Badge de Reconhecimento!* 💚"
			}
		},
		{
			"type": "image",
			"title": {
				"type": "plain_text",
				"text": "Todos Juntos"
			},
			"image_url": "https://domain.com/image.png",
			"alt_text": "Image Alt Text"
		},
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "Estamos ansiosos para ouvir as vossas nomeações e celebrar juntos as incríveis realizações da nossa equipa em *Platform Live Engineering*."
			}
		},
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "Vamos mostrar o quanto valorizamos uns aos outros e como estamos todos a contribuir para o nosso sucesso coletivo. 💪"
			}
		},
		{
			"type": "section",
			"text": {
				"type": "mrkdwn",
				"text": "*Categorias disponíveis:*\n\n- *Booster:* _Criou ferramentas ou estabeleceu processos que aumentaram a produtividade da equipa._\n\n- *Hero:* _Prestou ajuda crucial quando um membro da equipa pediu socorro._\n\n- *Enthusiast:* _Trabalhou noutra equipa para contribuir para um objetivo da equipa de Live Engineering._\n\n- *Guru:* _Forneceram estratégia e orientação enquanto dava mentoria à equipa._\n\n- *Researcher:* _Investigou tópicos que poderiam suavizar o trabalho da equipa._"
			}
		},
		{
			"type": "actions",
			"elements": [
				{
					"type": "button",
					"text": {
						"type": "plain_text",
						"text": "💚 Votar!"
					},
					"url": "https://sites.google.com/meu-site"
				}
			]
		}
	]
}
```
https://app.slack.com/block-kit-builder/T044BCGQ4#%7B%22blocks%22:%5B%7B%22type%22:%22section%22,%22text%22:%7B%22type%22:%22mrkdwn%22,%22text%22:%22*Indique%20um%20Colega%20para%20Ganhar%20um%20Badge%20de%20Reconhecimento!*%20%F0%9F%92%9A%22%7D%7D,%7B%22type%22:%22image%22,%22title%22:%7B%22type%22:%22plain_text%22,%22text%22:%22Todos%20Juntos%22%7D,%22image_url%22:%22https://domain.com/image.png%22,%22alt_text%22:%22Image%20Alt%20Text%22%7D,%7B%22type%22:%22section%22,%22text%22:%7B%22type%22:%22mrkdwn%22,%22text%22:%22Estamos%20ansiosos%20para%20ouvir%20as%20vossas%20nomea%C3%A7%C3%B5es%20e%20celebrar%20juntos%20as%20incr%C3%ADveis%20realiza%C3%A7%C3%B5es%20da%20nossa%20equipa%20em%20*Platform%20Live%20Engineering*.%22%7D%7D,%7B%22type%22:%22section%22,%22text%22:%7B%22type%22:%22mrkdwn%22,%22text%22:%22Vamos%20mostrar%20o%20quanto%20valorizamos%20uns%20aos%20outros%20e%20como%20estamos%20todos%20a%20contribuir%20para%20o%20nosso%20sucesso%20coletivo.%20%F0%9F%92%AA%22%7D%7D,%7B%22type%22:%22section%22,%22text%22:%7B%22type%22:%22mrkdwn%22,%22text%22:%22%20*Categorias%20dispon%C3%ADveis:*%5Cn%5Cn*%20*Booster:*%20_Criou%20ferramentas%20ou%20estabeleceu%20processos%20que%20aumentaram%20a%20produtividade%20da%20equipa._%5Cn%5Cn*%20*Hero:*%20_Prestou%20ajuda%20crucial%20quando%20um%20membro%20da%20equipa%20pediu%20socorro._%5Cn%5Cn-%20*Enthusiast:*%20_Trabalhou%20noutra%20equipa%20para%20contribuir%20para%20um%20objetivo%20da%20equipa%20de%20Live%20Engineering._%5Cn%5Cn-%20*Guru:*%20_Forneceram%20estrat%C3%A9gia%20e%20orienta%C3%A7%C3%A3o%20enquanto%20dava%20mentoria%20%C3%A0%20equipa._%5Cn%5Cn-%20*Researcher:*%20_Investigou%20t%C3%B3picos%20que%20poderiam%20suavizar%20o%20trabalho%20da%20equipa._%22%7D%7D,%7B%22type%22:%22actions%22,%22elements%22:%5B%7B%22type%22:%22button%22,%22text%22:%7B%22type%22:%22plain_text%22,%22text%22:%22%F0%9F%92%9A%20Votar!%22%7D,%22url%22:%22https://sites.google.com/.com/meu-site
