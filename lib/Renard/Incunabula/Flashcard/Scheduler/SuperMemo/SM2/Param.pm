use Renard::Incunabula::Common::Setup;
package Renard::Incunabula::Flashcard::Scheduler::SuperMemo::SM2::Param;
# ABSTRACT: SM-2 algorithm parameters

use Moo;
use MooX::StrictConstructor;

use constant INITIAL_EASINESS_FACTOR => 2.5;

=attr interval

This is the inter-repetition interval (I(n)).

It is the interval to use from the previous time the card was answered to time
that the next repetition is due. This is in seconds and is usually rounded up
to the closest day.

From SuperMemo 2 description:

  I(n) - inter-repetition interval after the n-th repetition (in days)

=cut
has interval => (
	is => 'rw',
	default => sub { 0 },
);

=attr repetitions

The count of number of repetitions done (n).

=cut
has repetitions => (
	is => 'rw',
	default => sub { 0 },
);

=attr easiness_factor

The easiness factor (EF) for the item where a lower EF indicates a more
difficult item.

From SuperMemo 2 description:

  EF - easiness factor reflecting the easiness of memorizing and retaining a given item in memory (later called the E-Factor).


=cut
has easiness_factor => (
	is => 'rw',
	default => sub { INITIAL_EASINESS_FACTOR },
);

1;

=begin :header

=begin stopwords

EF

=end stopwords

=end :header

=cut
