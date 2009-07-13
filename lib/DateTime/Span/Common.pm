package DateTime::Span::Common;

use Moose;
use Moose::Util::TypeConstraints;

subtype 'DayName'
      => as Str
      => where {
	  /Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday/ ;
         };


has 'week_start_day' => (isa => 'DayName', is => 'rw', default => 'Sunday') ;

use DateTime;
use DateTime::Span;

sub set_eod {
    my($self, $dt)=@_;

    $dt->set(hour => 23, minute => 59,  second => 59);
}

# now, but with HH:MM::SS = 23:59:59
sub DateTime::nowe {

    my $now = DateTime->now;
    $now->set_eod;

}

sub DateTime::Span::datetimes {
    my ($datetime_span)=@_;

    ($datetime_span->start, $datetime_span->end);
}

sub DateTime::Span::from_array {
    my ($self, $start,$end)=@_;

    warn "$start , $end";

    DateTime::Span->from_datetimes( start => $start, end => $end ) ;
}


sub today {

    my $now = DateTime->nowe;
    my $sod = DateTime->now->truncate(to => 'day');


    DateTime::Span->from_datetimes( start => $sod, end => $now ) ;
}

sub yesterday {
    my $t = today;

    my @a = map { $_->subtract(days => 1) } ($t->datetimes) ;
    
    DateTime::Span->from_array(@a);
}

sub this_week {
    my($self)=@_;

    my $now = DateTime->nowe;
    my $sow = DateTime->now->truncate(to => 'day');

    return today if $sow->day_name eq $self->week_start_day ;

    while ($sow->day_name ne $self->week_start_day) {

	$sow->subtract(days => 1) ;

    }

    DateTime::Span->from_datetimes( start => $sow, end => $now ) ;
}

sub last_week {
    my ($self)=@_;

    my ($sow, undef) = $self->this_week->datetimes;
   
    my $eow = $sow->clone;

    $sow->subtract(days => 7) ;

    $eow->subtract(days => 1) ;
    $eow->set(hour => 23, minute => 59, second => 59);


    DateTime::Span->from_datetimes( start => $sow, end => $eow ) ;
}

sub this_month {

    my ($self)=@_;

    my ($som, $nowe) = $self->today->datetimes;
   
    $som->set(day => 1);

    DateTime::Span->from_datetimes( start => $som, end => $nowe ) ;
}

sub this_year {
    my($self)=@_;

    my ($soy, $nowe) = $self->this_month->datetimes;
   
    $soy->set(day => 1, month => 1);

    DateTime::Span->from_datetimes( start => $soy, end => $nowe ) ;
}

sub last_year {
    my($self)=@_;

    my ($soy, $eoy) = $self->this_year->datetimes;
   
    $soy->subtract(years => 1);

    $eoy->subtract(years => 1);
    $eoy->set(month => 12, day => 31);

    DateTime::Span->from_datetimes( start => $soy, end => $eoy ) ;
}





=head1 NAME

DateTime::Span::Common - create common DateTime::Span instances

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

    use DateTime::Span::Common;

    my $x = DateTime::Span::Common->new;


    my $dts = $x->today;
    $dts = $x->yesterday;
    $dts = $x->this_week;
    $dts = $x->last_week;
    $dts = $x->this_month;
    $dts = $x->last_month;
    $dts = $x->year_to_date;
    $dts = $x->last_year;

    my $sth = $dbh->prepare('SELECT * FROM table WHERE order_date BETWEEN ? AND ?');
    $sth->execute($dts->datetimes);

=head1 DESCRIPTION

DateTime::Span::Common is a module which provides a L<DateTime::Span|DateTime::Span> object for a 
number of common date spans. It also provides a few convenience methods which I found useful in 
developing this module.

=head1 METHODS

=head2 new

When constructing a DateTime::Span::Common object, you may change the day on which the week is 
presumed to start from Sunday to any other day in the week:

   my $dtsc = DateTime::Span::Common->new(week_start_day => 'Monday');

=head2 today

Returns a L<DateTime::Span> object covering the current day.

=head2 yesterday

Returns a L<DateTime::Span> object covering yesterday.

=head2 this_week

Returns a L<DateTime::Span> object covering this week, respective of C<< $self->week_start_day >> .

=head2 last_week

Returns a L<DateTime::Span> object covering last week, respective of C<< $self->week_start_day >> .

=head2 this_month

Returns a L<DateTime::Span> object covering this month to date.

=head2 this_year

Returns a L<DateTime::Span> object covering this year to date.

=head2 last_year

Returns a L<DateTime::Span> object covering last year to date.

=head1 Internal Methods

=head2 set_eod

This method is used for end of day calculations. It sets a L<DateTime|DateTime> object's day, minute, and second 
fields by default. You can override it for your own purposes in your subclass as necessary.

=head2 DateTime::Span::datetimes

The public methods of this module return a L<Datetime::Span> instance. Oftentimes you will want the start and end of the span 
in an array. This method gives it to you:

   my $datetime_span = DateTime::Span::Common->new->this_year;
   my $sth = $dbh->prepare('SELECT * FROM table WHERE order_date BETWEEN ? AND ?');
   $sth->execute($datetime_span->datetimes);

=head2 DateTime::Span::from_array

This method creates a L<DateTime::Span> instance from an array:

  my @data = some_api_result();
  my $dts = DateTime::Span->from_array(@data);



=head1 AUTHOR

Terrence Brannon, C<< <metaperl at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-datetime-span-common at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DateTime-Span-Common>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DateTime::Span::Common


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DateTime-Span-Common>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DateTime-Span-Common>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DateTime-Span-Common>

=item * Search CPAN

L<http://search.cpan.org/dist/DateTime-Span-Common/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2009 Terrence Brannon, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of DateTime::Span::Common
