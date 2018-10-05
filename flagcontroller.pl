package FlagController;

use Plugins;
use Commands; #Commands::cmdUseSkill
use Data::Dumper;
use Translation qw/T TF/;
use Log qw(message);
use Globals;

Plugins::register('FlagController', '', \&on_unload, \&on_reload);

my $commands = Commands::register(
    ['f', 'Global flag hash controller', \&commandHandler]
);
my $plugins = Plugins::addHooks(
    ["start3", \&onstart3, undef]
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

sub onstart3 {
#    if (
#        $interface->isa ('Interface::Wx')
#        && $interface->{viewMenu}
#        && $interface->can ('addMenu')
#        && $interface->can ('openWindow')
#    ) {
#        $interface->addMenu ($interface->{viewMenu}, T('Combo Interface'), sub {
#            $interface->openWindow (T('Combos'), 'FlagController::Wx::Interface', 1);
#        }, T('Statistcs of combos by AnotherCombo Plugin'));
#    }
}

sub on_unload {
    Plugins::unregister($plugins);
    Commands::unregister($commands);
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
