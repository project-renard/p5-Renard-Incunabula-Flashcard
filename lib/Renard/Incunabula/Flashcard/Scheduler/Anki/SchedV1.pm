use Renard::Incunabula::Common::Setup;
package Renard::Incunabula::Flashcard::Scheduler::Anki::SchedV1;
# ABSTRACT: Implementation of the Anki scheduler v1

use Moo;
use Time::Piece;
use Time::Seconds;

has day_cutoff => (
	is => 'ro',
	default => sub {
		my $now = localtime;
		my $day = $now->truncate( to => 'day' );
		return $day + 23 * ONE_HOUR;
	},
);

method pop_card() {
	undef;
}

1;
