##################################
# App::AudioFileChecksum::Logger #
##################################
package App::AudioFileChecksum::Logger;

=head1 NAME

App::AudioFileChecksum::Logger

=head1 SYNOPSIS

 my $log = App::AudioFileChecksum::Logger->new( config => $config );
 $log->info(q(This is a 'Log::Log4perl' object));

 # in other modules...
 my $log = Log::Log4perl->get_logger(""); # "" means "root logger"
 $log->info(q(This is the same 'Log::Log4perl' object));

=head1 DESCRIPTION

Creates a L<Log::Log4perl> object, which is global to the current running Perl
script.  The log object can be retrieved in other modules via the construct
C<my $log = Log::Log4perl-E<gt>get_logger("");>

=cut

### System modules
use strictures 1; # strict + warnings
use Log::Log4perl qw(get_logger :no_extra_logdie_message);

=head2 Methods

=over

=item new(config => $config)

Creates a L<App::AudioFileChecksum::Logger> object.  The required
L<App::AudioFileChecksum::Config> object is used to to determine how to
configure the L<Log::Log4perl> object.  Returns a
L<App::AudioFileChecksum::Logger> object, or calls C<die> if there is some
kind of error creating the L<Log::Log4perl> object.

Required arguments:

=over

=item config

A L<App::AudioFileChecksum::Config> object.  Used to configure the
L<Log::Log4perl> object that is created by this method.

=back

=cut

sub new {
    my $self = shift;
    my %args = @_;

    die q(Missing required argument 'config') unless ( exists $args{config} );
    my $cfg = $args{config};
    die q(Required argument 'config' not an App::AudioFileChecksum::Config object)
        unless ( ref($cfg) eq q(App::AudioFileChecksum::Config) );

    my $log_conf;
    # Set the default log level; the Logfile/Screen appenders will add their
    # bits to this directive, so don't use a newline (\n) here
    if ( $cfg->defined(q(debug)) ) {
        $log_conf = qq(log4perl.rootLogger = DEBUG, );
    } elsif ( $cfg->defined(q(verbose)) ) {
        $log_conf = qq(log4perl.rootLogger = INFO, );
    } else {
        $log_conf = qq(log4perl.rootLogger = WARN, );
    }

    my $log_conversion_pattern =  qq|[%6r] %p{1} %4L (%M{1}) %m%n|;
    # Explanation of log output pattern options:
    # - %r: number of milliseconds elapsed since program start
    # - %p{1}: first letter of event priority
    # - %4L: line number where log statement was used, four numbers wide
    # - %M{1}: Name of the method name where logging request was issued
    # - %m: message
    # - %n: newline
    # old log output patterns:
    #. qq( = %d %p %m%n\n)
    #. qq(= %d{HH.mm.ss} %p -> %m%n\n);

    if ( $cfg->defined(q(logfile)) ) {
        # tell the root logger which appender to use by appending it to the
        # existing contents of $log_conf
        $log_conf .= qq( Logfile\n);
        $log_conf .= qq(log4perl.appender.Logfile = )
            . qq(Log::Log4perl::Appender::File\n);
        $log_conf .= qq(log4perl.appender.Logfile.filename = )
            . $cfg->get(q(logfile)) . qq(\n);
        $log_conf .= qq(log4perl.appender.Logfile.utf8 = 1\n)
            . qq(log4perl.appender.Logfile.layout = PatternLayout\n)
            . q(log4perl.appender.Logfile.layout.ConversionPattern )
            . qq(= $log_conversion_pattern\n);

    } else {
        # tell the root logger which appender to use by appending it to the
        # existing contents of $log_conf
        $log_conf .= qq( Screen\n);

        # Check for log colorization
        if ( -t STDOUT || $cfg->defined(q(colorize)) ) {
            $log_conf .= qq(log4perl.appender.Screen = )
                . qq(Log::Log4perl::Appender::ScreenColoredLevels\n);
        } else {
           $log_conf .= qq(log4perl.appender.Screen = )
                . qq(Log::Log4perl::Appender::Screen\n);
        }

        # More log4perl.appender.Screen options
        $log_conf .= qq(log4perl.appender.Screen.stderr = 1\n)
            . qq(log4perl.appender.Screen.utf8 = 1\n)
            . qq(log4perl.appender.Screen.layout = PatternLayout\n)
            . q(log4perl.appender.Screen.layout.ConversionPattern )
            . qq(= $log_conversion_pattern\n);
    }

    # create a logger object, and prime the logfile for this session
    Log::Log4perl::init( \$log_conf );
    my $log = get_logger(""); # "" = root logger
    return $log;
}

=back

=head1 AUTHOR

Brian Manning, C<< <brian at xaoc dot org> >>

=head1 BUGS

Please report any bugs or feature requests to the GitHub issue tracker for
this project:

C<< <https://github.com/spicyjack/App-AudioFileChecksum/issues> >>.

=head1 SUPPORT

You can find documentation for this script with the perldoc command.

    perldoc App::AudioFileChecksum::Logger

=head1 COPYRIGHT & LICENSE

Copyright (c) 2014 Brian Manning, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

# fin!
# vim: set shiftwidth=4 tabstop=4
1;
