use strict;
use vars qw($VERSION %IRSSI);

$VERSION = '0.1.3';
%IRSSI = (
    authors	=> 'Joel "Zouppen" Lehtonen',
    contact	=> 'joel.lehtonen+telex@iki.fi',
    name	=> 'detelexify',
    description	=> 'Alters nickname prefixes coming from a Matrix or Telegram gateway to real nicknames',
    license	=> 'GPLv3',
    url		=> 'https://github.com/zouppen/irssi-detelexify',
    changed	=> '2025-10-04',
);

# Known restrictions: There is currently no way to limit the network
# or the channels that the telex_nicks is allowed to operate. You need
# to trust it in that sense that if that identity is on your channel,
# it may inject any message from anybody and you won't notice
# it.
#
# TODO: Channel and network limits for each bot and configuration
#       without changing the sources


# Identities of Telegram gateways
my @telex_nicks = (
    '*!mx@irc.hacklab.fi',
    );

sub find_mask {
    my ( $server, $nick, $address ) = @_;
    foreach my $mask (@telex_nicks) {
        if ( $server->mask_match_address($mask, $nick, $address) ) {
            return 1;
        }
    }
    return 0;
}

sub privmsg {
    my ($server, $data, $nick, $address) = @_;
    # Check if ident matches the Telegram gateway.
    if ( find_mask($server, $nick, $address) ) {
	my ($chan, $real_nick, $real_msg) = ($data =~ /([^ ]*) :<([^>]*)> (.*)/);

	# Check if content matches.
	if (defined $chan && defined $real_nick && defined $real_msg) {
	    if ($real_msg eq '<left_chat_participant>') {
		# Produce part event and suppress the message
		Irssi::signal_emit("event part", $server, $chan, $real_nick, $address);
		Irssi::signal_stop();
	    } else {
		# Join a participant if it's not already joined
		if (!defined $server->channel_find($chan)->nick_find($real_nick)) {
		    Irssi::signal_emit("event join", $server, $chan, $real_nick, $address);
		}

		# Then process the actual message
		if ($real_msg eq '<new_chat_participant>') {
		    # Suppress the join message
		    Irssi::signal_stop();
		} else {
		    # Incoming message. Mangle the nick and message
		    my $real_data = $chan.' :'.$real_msg;
		    Irssi::signal_continue($server, $real_data, $real_nick, $address);
		}
	    }
	}
    }
}

Irssi::signal_add('event privmsg', 'privmsg');
