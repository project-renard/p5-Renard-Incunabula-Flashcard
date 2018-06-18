use Renard::Incunabula::Common::Setup;
package Renard::Incunabula::Flashcard::Scheduler::SuperMemo::SM2::Response;
# ABSTRACT: Quality of response

=head1 DESCRIPTION

=begin :list

* correct_perfect      : 5 - perfect response
* correct_hesitation   : 4 - correct response after a hesitation
* correct_difficult    : 3 - correct response recalled with serious difficulty
* incorrect_easy       : 2 - incorrect response; where the correct one seemed easy to recall
* incorrect_remembered : 1 - incorrect response; the correct one remembered
* blackout             : 0 - complete blackout.

=end :list

=cut

=head1 PREDICATES

=method is_blackout
=method is_correct_difficult
=method is_correct_hesitation
=method is_correct_perfect
=method is_incorrect_easy
=method is_incorrect_remembered

=cut


use Class::Type::Enum values => {
	blackout             => 0,
	incorrect_remembered => 1,
	incorrect_easy       => 2,
	correct_difficult    => 3,
	correct_hesitation   => 4,
	correct_perfect      => 5,
};

1;
