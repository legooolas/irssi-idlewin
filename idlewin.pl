# Idle window setup (initially based on 'hilightwin.pl')

# TODO :
#
# - add colours
#  - add formats for different message types and channels
#   - some alignment (should only be needed on the dest->target, as test is
#     already coloured and aligned?)
# * channel allow list
#  - option to allow/disallow messages (should allow them always really)
# - add dccmsgs?
# - add time to start of lines  :)
# - add chatnet, and append this to the channel name for coloring purposes?
#  $server->{chatnet}

use Irssi;
use vars qw($VERSION %IRSSI); 
$VERSION = "0.1";
%IRSSI = (
    authors	=> "Legooolas",
    contact	=> "irssi-idlewin\@icmfp.com",
    name	=> "idlewin",
    description	=> "Print messages to selected channel(s) to idle window",
    license	=> "GNU GPLv2",
    url		=> "http://icmfp.com/irssi/",
    changed	=> "2003/02/27"
);


# Taken from people.pl...
our @colors = qw(r g y b m c R G Y B M C);

sub compute_color($) {
    my ($text) = @_;
    my $sum = 0;
    foreach my $ch (split //, $text) {
        $sum += ord $ch;
    }
    return '%' . $colors[$sum % @colors];
}
# end section taken from people.pl...

sub sig_printtext {
  my ($dest, $text, $stripped) = @_;

  if (($dest->{level} & (MSGLEVEL_PUBLIC|MSGLEVEL_HILIGHT|MSGLEVEL_MSGS|MSGLEVEL_ACTIONS)) &&
      ($dest->{level} & MSGLEVEL_NOHILIGHT) == 0) {
    $window = Irssi::window_find_name('idle');


    # TODO : other-than-public formats differently?

    my $enabled_channels = Irssi::settings_get_str('idlewin_enabled_channels');

    if(($dest->{level} & (MSGLEVEL_MSGS|MSGLEVEL_HILIGHT)) ||
       ($dest->{target} =~ m/$enabled_channels/i)) {
      # TODO : theme format variable?

      my $theme = Irssi::current_theme();
      my $chan_color = compute_color($dest->{target});

      # Hack: # find %'s and double them
      #       This fixes colors expanding when things like %g are said..
      $text =~ s/\%/\%\%/;

      my $format = $theme->format_expand("{idlewin_message $chan_color $dest->{target}}", Irssi::EXPAND_FLAG_IGNORE_REPLACES);

      #$window->printformat(MSGLEVEL_NEVER, 'idlewin_message',
      #		    $chan_color, $dest->{target}, $text) if ($window);

      # Note : MSGLEVEL_CLIENTCRAP adds the time, but also adds active highlight
      #        to statusbar (which we don't want for an idling window..)

      $window->print($format." ".$text, MSGLEVEL_NEVER) if ($window);
      return;
    }
  }
}

$window = Irssi::window_find_name('idle');
Irssi::print("Create a window named 'idle'") if (!$window);
#Irssi::window_create('idle') if (!$window);

Irssi::signal_add('print text', 'sig_printtext');
Irssi::settings_add_str('idlewin', 'idlewin_enabled_channels', "^#(foo|bar)\$");
    #my $enabled_channels = "^#(test|foo|bar)\$";
#Irssi::theme_register([
#  'idlewin_message', '$0$[-11]1%n $2-'
#]);

