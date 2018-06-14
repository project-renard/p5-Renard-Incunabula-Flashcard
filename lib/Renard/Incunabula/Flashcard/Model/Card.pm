use Renard::Incunabula::Common::Setup;
package Renard::Incunabula::Flashcard::Model::Card;
# ABSTRACT: A model for a card

use Moo;

=attr data

Data for the card model.

=cut
has data => (
	is => 'ro',
);

1;
