use Renard::Incunabula::Common::Setup;
package Renard::Incunabula::Flashcard::Scheduler::Anki::SchedV1;
# ABSTRACT: Implementation of the Anki scheduler v1

use Moo;
use Time::Piece;
use Time::Seconds;

=attr day_cutoff

A L<Time::Piece> for when on the current day to stop the scheduler.

Defaults to 23:00 local time.

=cut
has day_cutoff => (
	is => 'ro',
	default => sub {
		my $now = localtime;
		my $day = $now->truncate( to => 'day' );
		return $day + 23 * ONE_HOUR;
	},
);

=method pop_card

Returns a card from the scheduler.

=cut
method pop_card() {
	undef;
}

1;
