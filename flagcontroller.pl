package flagcontroller;

use Plugins;
use Commands; #Commands::cmdUseSkill
use Data::Dumper;

use Log qw(message);
use Globals;

Plugins::register('flagcontroller', '', \&on_unload, \&on_reload);

my $hooks = Commands::register(
    ['f', 'Global flag hash controller', \&commandHandler]
);

sub commandHandler {
    if (!defined $_[1]) {
        message "Usage: f [print|reset|me|pt|emp]\n"; return;
    }
    my ($arg, @params) = split(/\s+/, $_[1]);
    if ($arg eq 'reset') {
        for (keys %flags){
            delete $flags{$_};
        };
    }
    elsif ($arg eq 'print') {
        for (keys %flags){
            &debugger($_);
        };
    }
    else {
        # if flag is emp, set/unset it on mon_control
        # so the bot wont try to attack it constinously.
        my $isset = 0;
        for (keys %flags){
            if($_ eq $arg ) {
                $isset = 1;
            }
        };
        if($isset eq 0) {
            $flags{$arg} = 1;
        }
        else {
            delete $flags{$arg};
        }
    }
}

sub on_unload {
    Commands::unregister($hooks);
}

sub on_reload {
    message "Reloading...\n";
}

sub debugger {
    my $datetime = localtime time;
    # message Dumper($_[0])."\n";
    message "[MCA] $datetime: $_[0].\n";
}

return 1;
