#!/usr/bin/env perl

use Test::Most tests => 1;
use Modern::Perl;
use aliased 'Renard::Incunabula::Flashcard::Model::Card' => 'Card';

subtest "Create card" => sub {
	ok Card->new;
};

done_testing;
