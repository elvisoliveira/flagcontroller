package FlagController;

our $plugin_folder = $Plugins::current_plugin_folder;

use Plugins;
use Commands; # Commands::cmdUseSkill
use Data::Dumper;
use Translation qw/T TF/;
use Log qw(message);
use Globals;

use lib $Plugins::current_plugin_folder;

Plugins::register('FlagController', '', \&on_unload, \&on_reload);

my $commands = Commands::register(
    ['f', 'Global flag hash controller', \&commandHandler]
);
my $plugins = Plugins::addHooks(
    # ['AI_pre', \&on_ai],
    ["start3", \&onstart3, undef]
);
my %commands = (
    0 => {
        command => "ls",
        display => "List Commands"
    },
    1 => {
        command => "clear",
        display => "Reset Commands"
    },
    2 => {
        command => "party",
        display => "Party Buffs"
    },
    3 => {
        command => "self",
        display => "Self Buffs"
    },
    4 => {
        command => "keep",
        display => "Protect Stones"
    },
    5 => {
        command => "keepme",
        display => "Safety Wall Me"
    },
    6 => {
        command => "war",
        display => "War"
    }
);
my %temp;

sub commandHandler {
    if (!defined $_[1]) {
        message "Usage: f [command]\n"; return;
    }
    my ($arg, @params) = split(/\s+/, $_[1]);
    if ($arg eq 'clear') {
        for (keys %flags){
            delete $flags{$_};
        };
        Plugins::callHook('FlagController', { arg => $arg, isset => undef });
    }
    elsif ($arg eq 'ls') {
        if (%flags) {
            for (keys %flags){
                &debugger($_);
            };
        }
        else {
            &debugger("Flags variable is Empty");
        }
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
        Plugins::callHook('FlagController', { arg => $arg, isset => $isset });
    }
}

sub onstart3 {
    if (
        $interface->isa ('Interface::Wx')
        && $interface->{viewMenu}
        && $interface->can ('addMenu')
        && $interface->can ('openWindow')
    ) {
        $interface->addMenu ($interface->{viewMenu}, T('FlagController'), sub {
            my ($page, $window) = $interface->openWindow (T('Tasks'), 'FlagController::Wx', 1);
            if ($window) {
                $window->setFlags(\%commands);
            };
            return ($page, $window);
        }, T('Tasks assigned by FlagController Plugin'));
    }
}

sub on_ai {
    %temp = %flags if (!%temp);
    for (keys %temp){
        Plugins::callHook('FlagController', { arg => $_, isset => 1 }) if(!exists($flags{$_}));
    };
    %temp = %flags;
}

sub on_unload {
    # Plugins::unregister($plugins);
    Commands::unregister($commands);
}

sub on_reload {
    # message "Reloading...\n";
}

sub debugger {
    # &debugger(1);
    my $datetime = localtime time;
    message Dumper($_[0])."\n";
    # message "[MCA] $datetime: $_[0].\n";
}

return 1;
