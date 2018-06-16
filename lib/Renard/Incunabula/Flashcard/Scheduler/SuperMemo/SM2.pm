use Renard::Incunabula::Common::Setup;
package Renard::Incunabula::Flashcard::Scheduler::SuperMemo::SM2;
# ABSTRACT: Implementation of SM-2 algorithm

use Moo;
use MooX::HandlesVia;

use Renard::Incunabula::Common::Types qw(ArrayRef ConsumerOf);

use Time::Piece;
use Time::Seconds;
use Math::Round;
use List::AllUtils qw(max);

use constant CARD_ROLE => 'Renard::Incunabula::Flashcard::Model::Card::Role::Scheduler::SuperMemo::SM2';

use constant INTERVAL_REPETITION_STEP_1 => 1 * ONE_DAY;
use constant INTERVAL_REPETITION_STEP_2 => 6 * ONE_DAY;
use constant MINIMUM_EASINESS_FACTOR => 1.3;

has _review_queue => (
	is => 'ro',
	default => sub { [] },
	isa => ArrayRef[ConsumerOf[ CARD_ROLE ]],
	handles_via => 'Array',
	handles => {
		_add_to_review_queue => 'push',
		_remove_from_review_queue => 'shift',
		review_count => 'count',
	}
);

has _done_queue => (
	is => 'ro',
	default => sub { [] },
	isa => ArrayRef[ConsumerOf[ CARD_ROLE ]],
	handles_via => 'Array',
	handles => {
		_add_to_done_queue => 'push',
	}
);


=method get_card

Returns a card from the scheduler.

=cut
method get_card() {
	$self->_remove_from_review_queue;
}

=method add_card

Adds card to review queue.

=cut
method add_card( $card ) {
	if( ! $card->does( CARD_ROLE ) ) {
		Role::Tiny->apply_roles_to_object( $card, CARD_ROLE );
	}

	$self->_add_to_review_queue( $card );
}

=method answer_card

Answers the card and places it on either the review queue or done queue based
on the response.

=cut
method answer_card( $card, $response ) {
	# After each repetition session of a given day repeat again all items
	# that scored below four in the quality assessment. Continue the
	# repetitions until all of these items score at least four.
	$card->sm2_data(
		$self->process_param( $card->sm2_data, $response )
	);

	if( $response < 4 ) {
		$self->_add_to_review_queue( $card );
	} else {
		$self->_add_to_done_queue( $card );
	}
}

=method process_param

Given algorithm parameters and a response, returns the next algorithm parameters.

=cut
method process_param( $param, $quality ) {
	my $new_param = Renard::Incunabula::Flashcard::Scheduler::SuperMemo::SM2::Param->new;

	$quality = 0 + $quality if( ref $quality && $quality->isa('Renard::Incunabula::Flashcard::Scheduler::SuperMemo::SM2::Response') );

	if( $quality >= 3 ) {
		if( $param->repetitions == 0 ) {
			# First repetition:
			#   I(1) = 1.
			$new_param->interval( INTERVAL_REPETITION_STEP_1 );
		} elsif( $param->repetitions == 1 ) {
			# Second repetition:
			#   I(2) = 6.
			$new_param->interval( INTERVAL_REPETITION_STEP_2 );
		} else {
			# Repetitions greater than the second:
			#   I(n) = I(n-1) * EF where n > 2.
			my $interval_raw = $param->interval * $param->easiness_factor;
			# Round interval up to the next highest day.
			my $interval_round_day = Math::Round::nhimult( ONE_DAY, $interval_raw );

			$new_param->interval( $interval_round_day )
		}

		# increment repetitions
		$new_param->repetitions( $param->repetitions + 1 );
	} elsif( $quality < 3 ) {
		$new_param->repetitions( 0 );
		$new_param->interval( INTERVAL_REPETITION_STEP_1 );
	}

	# when $quality == 4, the easiness_factor does not change
	$new_param->easiness_factor( $param->easiness_factor + (0.1 - (5 - $quality) * (0.08 + (5 - $quality ) * 0.02)) );
	# easiness_factor must be at least MINIMUM_EASINESS_FACTOR
	$new_param->easiness_factor( max(MINIMUM_EASINESS_FACTOR, $new_param->easiness_factor) );

	$new_param;
}

1;
=head1 SEE ALSO

=begin :list

* L<SuperMemo 2: Algorithm|https://www.supermemo.com/english/ol/sm2.htm>

* L<SuperMemo 2: Delphi source code|https://www.supermemo.com/english/ol/sm2source.htm>

=end :list

=cut
