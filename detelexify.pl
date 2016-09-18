use strict;
use vars qw($VERSION %IRSSI);

$VERSION = '0.1';
%IRSSI = (
    authors	=> 'Joel "Zouppen" Lehtonen',
    contact	=> 'joel.lehtonen+telex@iki.fi',
    name	=> 'telexclean',
    description	=> 'Alters nickname prefixes coming from a Telegram gateway to real nicknames',
    license	=> 'GPLv3',
    url		=> 'https://zouppen.iki.fi/projektit/telex',
    changed	=> '2016-09-17',
);

# Identities of Telegram gateways
my %telex_nicks = (
    '~Telex@stream2.magnetismi.fi' => 1,
    'joell@moskova.liittovaltio.fi' => 1,
    );

sub privmsg {
    my ($server, $data, $nick, $address) = @_;
    # Check if ident matches the Telegram gateway.
    if ( $telex_nicks{$address} ) {
	my ($chan, $real_nick, $real_msg) = ($data =~ /([^ ]*) :\[([^\[]*)\] (.*)/);

	# Check if content matches.
	if (defined $chan && defined $real_nick && defined $real_msg) {
	    print($real_msg);
	    if ($real_msg eq '<left_chat_participant>') {
		# Produce part event and suppress the message
		Irssi::signal_emit("event part", $server, $chan, $real_nick, $address);
		Irssi::signal_stop();
	    } else {
		# Always join even if we didn't see the join msg
		Irssi::signal_emit("event join", $server, $chan, $real_nick, $address);
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
