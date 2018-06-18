use Renard::Incunabula::Common::Setup;
package Renard::Incunabula::Flashcard::Model::Card::Role::Scheduler::SuperMemo::SM2;
# ABSTRACT: A role for holding SM2 scheduling data

use Moo::Role;

use Renard::Incunabula::Common::Types qw(InstanceOf);
use Renard::Incunabula::Flashcard::Scheduler::SuperMemo::SM2::Param;

=attr sm2_data

The parameters for the SM2 scheduling algorithm.

See L<Renard::Incunabula::Flashcard::Scheduler::SuperMemo::SM2>.

=cut
has sm2_data => (
	is => 'rw',
	isa => InstanceOf['Renard::Incunabula::Flashcard::Scheduler::SuperMemo::SM2::Param'],
	lazy => 1,
	builder => sub {
		Renard::Incunabula::Flashcard::Scheduler::SuperMemo::SM2::Param->new;
	},
);

1;
