package FlagController::Wx;

use strict;
use Data::Dumper;
use base 'Wx::Panel';
use Wx ':everything';
use Wx::Event qw/EVT_SIZE EVT_TOGGLEBUTTON EVT_BUTTON/;
use Log qw(message);

use Translation qw/T TF/;

use constant {
    BUTTON_WIDTH => 100,
    BUTTON_HEIGHT => 26,
    BUTTON_BORDER => 2,
};

sub new {
    my ($class, $parent, $id) = @_;
    my $self = $class->SUPER::new ($parent, $id);
    my $hooks = Plugins::addHooks (
        ["flagControllerButton", sub { $self->onButtonChange(@_) }],
        ["flagControllerToggleButton", sub { $self->onToggleButtonChange(@_) }]
    );

    EVT_SIZE ($self, \&_onSize);

    $self->SetSizer (my $sizer = new Wx::BoxSizer (wxVERTICAL));
    $sizer->Add ($self->{grid} = new Wx::GridSizer (0, 0, BUTTON_BORDER, BUTTON_BORDER), 0);
    $sizer->AddStretchSpacer;

    return $self;
}
sub _onSize {
    my ($self) = @_;
    my $cols = int + ($self->GetSize->GetWidth + BUTTON_BORDER) / (BUTTON_WIDTH + BUTTON_BORDER);
    unless (defined $self->{cols} && $self->{cols} == $cols) {
        $self->{grid}->SetCols ($self->{cols} = $cols);
        $self->GetSizer->Layout;
    }
}
sub setFlags {
    my ($self, $commands, $options) = @_;
    # @TODO: Apply DRY principle
    $self->{commands} = $commands;
    $self->{options} = $options;
    if (my $total = keys %{$self->{options}}) {
        for (my ($i, $e) = (0, 0); $i < $total; $e++) {
            next unless defined $self->{options}{$e};
            my $cmd = $self->{options}{$e}{command};
            $self->{button}->{$cmd} = new Wx::ToggleButton(
                $self, wxID_ANY, $self->{options}{$e}{display}, wxDefaultPosition, [BUTTON_WIDTH, BUTTON_HEIGHT]
            );
            $self->{button}->{$cmd}->SetToolTip ($cmd);
            {
                EVT_TOGGLEBUTTON($self, $self->{button}->{$cmd}->GetId, sub { Commands::run("f $cmd") });
            }
            $self->{grid}->Add($self->{button}->{$cmd});
            $i++;
        };
    }
    if (my $total = keys %{$self->{commands}}) {
        for (my ($i, $e) = (0, 0); $i < $total; $e++) {
            next unless defined $self->{commands}{$e};
            my $cmd = $self->{commands}{$e}{command};
            $self->{button}->{$cmd} = new Wx::Button(
                $self, wxID_ANY, $self->{commands}{$e}{display}, wxDefaultPosition, [BUTTON_WIDTH, BUTTON_HEIGHT]
            );
            $self->{button}->{$cmd}->SetToolTip ($cmd);
            {
                EVT_BUTTON($self, $self->{button}->{$cmd}->GetId, sub { Commands::run("f $cmd") });
            }
            $self->{grid}->Add($self->{button}->{$cmd});
            $i++;
        };
    }
    $self->GetSizer->Layout;
    $self->Thaw;
}
sub onToggleButtonChange {
    my ($self, undef, $args) = @_;
    $self->{button}->{$args->{arg}}->SetValue($args->{isset});
}
sub onButtonChange {
    my ($self, undef, $args) = @_;
    if ($args->{arg} eq 'clear') {
        if (my $total = keys %{$self->{commands}}) {
            for (my ($i, $e) = (0, 0); $i < $total; $e++) {
                next unless defined $self->{commands}{$e};
                $self->{button}->{$self->{options}{$e}{command}}->SetValue(0);
                $i++;
           }
        }
    }
}
sub debugger {
    # &debugger(1);
    my $datetime = localtime time;
    message Dumper($_[0])."\n";
    # message "[MCA] $datetime: $_[0].\n";
}
1;
