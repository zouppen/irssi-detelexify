<!-- -*- mode: markdown; coding: utf-8 -*- -->
# irssi-detelexify

Make Telegram gateway users to look like IRC users in irssi

Instead of

```
12:35 < Telex> [Michael] tehdäänpä sit näin :)
```

you will get

```
12:35 < Michael> tehdäänpä sit näin :)
```

This script also handles joins and parts as when people join and leave
the channel. It makes the people visible on that channel for easy
tab-completion of the nicks.

## Installation

Place [detelexify.pl](detelexify.pl) under `~/.irssi/scripts/autorun/`
on your irssi server. Edit the script by adding your Telegram gateway
idents to the array `%telex_nicks`. Then run the script in irssi:

	/run ~/.irssi/scripts/autorun/detelexify.pl

Enjoy!

## Security and privacy

The script currently has no channel and network limits for the
Telegram gateway bots. They can act as any user on the channels they
are joined into. #3

The nicks joined into that channel are not present in your IRC network
in real. Therefore you need to be careful when sending private
messages to those nicks. The messages will be received by someone else
if there's such nickname in the same network. #4

There is no way to distinguish the person if he/she is joined the
channel via Telegram and real IRC. That's the idea of this script, the
same nickname may be used on both networks and it produces no nickname
pollution if you are using both networks.

Please submit a patch if you fix any of these issues
