#!/usr/bin/env perl

use Test::Most tests => 3;
use Modern::Perl;
use List::UtilsBy qw(nsort_by);

use Time::Seconds;
use aliased 'Renard::Incunabula::Flashcard::Scheduler::SuperMemo::SM2' => 'SM2';
use aliased 'Renard::Incunabula::Flashcard::Scheduler::SuperMemo::SM2::Param' => 'Param';
use aliased 'Renard::Incunabula::Flashcard::Scheduler::SuperMemo::SM2::Response' => 'Response';

my $Card = Moo::Role->create_class_with_roles(
	'Renard::Incunabula::Flashcard::Model::Card',
	SM2->CARD_ROLE,
);

subtest "Parameter testing" => sub {
	subtest "Minimum EF" => sub {
		is SM2->new->process_param(
			Param->new(
				easiness_factor => SM2->MINIMUM_EASINESS_FACTOR - 0.3,
			),
			3
		)->easiness_factor,
		SM2->MINIMUM_EASINESS_FACTOR;
	};

	subtest 'EF decrease' => sub {
		is SM2->new->process_param(
			Param->new(
				easiness_factor => 2.5,
			),
			3  # quality < 4 decreases EF
		)->easiness_factor,
		2.36;
	};

	subtest 'EF increase' => sub {
		is SM2->new->process_param(
			Param->new(
				easiness_factor => 2.5,
			),
			5  # quality > 4 increases EF
		)->easiness_factor,
		2.6;
	};

	subtest 'Initial steps' => sub {
		is SM2->new->process_param(
			Param->new(
				repetitions => 0,
			),
			Response->new('correct_difficult'),
		)->interval,
		SM2->INTERVAL_REPETITION_STEP_1,
		'first repetition';

		is SM2->new->process_param(
			Param->new(
				repetitions => 1,
			),
			3
		)->interval,
		SM2->INTERVAL_REPETITION_STEP_2,
		'second repetition';
	};

	subtest 'Low quality response resets repetitions and interval' => sub {
		my $sm2 = SM2->new;
		my $p = $sm2->process_param(
			Param->new(
				repetitions => 5,
				interval => 20 * ONE_DAY,
			),
			2
		);

		is $p->repetitions, 0;
		is $p->interval, SM2->INTERVAL_REPETITION_STEP_1, 'low quality gives one day interval';

		is(
			($p = $sm2->process_param( $p , 3 ))->interval,
			SM2->INTERVAL_REPETITION_STEP_1,
			'then another one day interval' );

		is $sm2->process_param( $p , 3 )->interval,
			SM2->INTERVAL_REPETITION_STEP_2,
			'then six day interval';
	};

	subtest 'Low quality response sets the interval to one day twice in a row' => sub {
		my $p = SM2->new->process_param(
			Param->new(
				repetitions => 5,
				interval => 20 * ONE_DAY,
			),
			2
		);

		is $p->repetitions, 0;
		is $p->interval, SM2->INTERVAL_REPETITION_STEP_1;
	};

	subtest 'Quality of 4 does not change easiness' => sub {
		my $p = SM2->new->process_param(
			Param->new(
				repetitions => 2,
				interval => 6 * ONE_DAY,
				easiness_factor => 3,
			),
			4
		);

		is $p->interval, 3 * 6 * ONE_DAY, '18 days';
		is $p->easiness_factor, 3, 'easiness factor is the same as before';
	};

	subtest 'Quality of 4 repeated' => sub {
		my $p = Param->new;
		my $sm2 = SM2->new;

		is(($p = $sm2->process_param($p, 4))->interval,  1 * ONE_DAY, 'interval =  1 day' ); # INTERVAL_REPETITION_STEP_1
		is(($p = $sm2->process_param($p, 4))->interval,  6 * ONE_DAY, 'interval =  6 days'); # INTERVAL_REPETITION_STEP_2
		is(($p = $sm2->process_param($p, 4))->interval, 15 * ONE_DAY, 'interval = 15 days');
		is(($p = $sm2->process_param($p, 4))->interval, 38 * ONE_DAY, 'interval = 38 days');
		is(($p = $sm2->process_param($p, 4))->interval, 95 * ONE_DAY, 'interval = 95 days');
	};
};

subtest "Queue testing" => sub {
	my $sm2 = SM2->new;
	$sm2->add_card( $Card->new( data => 1 ) );
	$sm2->add_card( $Card->new( data => 2 ) );
	$sm2->add_card( $Card->new( data => 3 ) );

	my $card_repetitions;

	my $c;
	is $sm2->review_count, 3, 'start with 3 cards';

	is( ($c = $sm2->get_card)->data, 1, 'first card is next in queue' );
	is $sm2->review_count, 2, 'count is 2 while answering';
	note 'answer with 4';
	$sm2->answer_card( $c, 4 );
	is $sm2->review_count, 2, 'removes the first card from queue';
	note 'Card 1 repetitions is increased';
	$card_repetitions->{$c->data}++;

	is( ($c = $sm2->get_card)->data, 2, 'second card is next in queue' );
	is $sm2->review_count, 1, 'count is 1 while answering';
	note 'answer with 1';
	$sm2->answer_card( $c, 1 );
	is $sm2->review_count, 2, 'put back in queue';
	note 'Card 2 repetitions remains 0';
	$card_repetitions->{$c->data} = 0;

	is( ($c = $sm2->get_card)->data, 3, 'third card is next in queue');
	is $sm2->review_count, 1, 'count is 1 while answering';
	note 'answer with 2';
	$sm2->answer_card( $c, 2 );
	is $sm2->review_count, 2, 'put back in queue';
	note 'Card 3 repetitions remains 0';
	$card_repetitions->{$c->data} = 0;

	is( ($c = $sm2->get_card)->data, 2, 'second card is next in queue (reappears)');
	is $sm2->review_count, 1, 'count is 1 while answering';
	note 'answer with 2';
	$sm2->answer_card( $c, 2 );
	is $sm2->review_count, 2, 'put back in queue';
	note 'Card 2 repetitions remains 0';
	$card_repetitions->{$c->data} = 0;

	is( ($c = $sm2->get_card)->data, 3, 'third card is next in queue (reappears)');
	is $sm2->review_count, 1, 'count is 1 while answering';
	note 'answer with 5';
	$sm2->answer_card( $c, 5 );
	is $sm2->review_count, 1, 'removes the third card from queue';
	note 'Card 3 repetitions increases';
	$card_repetitions->{$c->data}++;

	is( ($c = $sm2->get_card)->data, 2, 'second card is next in queue (reappears)');
	is $sm2->review_count, 0, 'count is 0 while answering';
	note 'answer with 3';
	$sm2->answer_card( $c, 3 );
	is $sm2->review_count, 1, 'put back in queue';
	note 'Card 2 repetitions increases';
	$card_repetitions->{$c->data}++;

	is( ($c = $sm2->get_card)->data, 2, 'second card is next in queue (reappears)');
	is $sm2->review_count, 0, 'count is 0 while answering';
	note 'answer with 5';
	$sm2->answer_card( $c, 5 );
	is $sm2->review_count, 0, 'removes the second card from queue';
	note 'Card 2 repetitions increases';
	$card_repetitions->{$c->data}++;

	ok( ! defined($c = $sm2->get_card), 'now queue is empty');

	my %got_repetitions = map { $_->data => $_->sm2_data->repetitions } @{ $sm2->_done_queue };
	cmp_deeply \%got_repetitions, $card_repetitions, 'card repetitions are as expected';

	is_deeply
		[ map { $_->data } nsort_by { $_->sm2_data->easiness_factor } @{ $sm2->_done_queue } ],
		[ 2, 3, 1],
		'expected cards in order from most difficult to easiest';

	#use DDP; p $sm2, class => { expand => 'all' };#DEBUG
};

subtest "SM2 data role" => sub {
	my $sm2 = SM2->new;

	subtest 'Add card without the SM2 data role' => sub {
		$sm2->add_card( Renard::Incunabula::Flashcard::Model::Card->new( data => 1 ) );

		my $c = $sm2->get_card;
		is $c->data, 1, 'got the card back';
		ok $c->sm2_data->isa('Renard::Incunabula::Flashcard::Scheduler::SuperMemo::SM2::Param'), 'has SM2 parameters';
		is $c->sm2_data->repetitions, 0, 'starts with no repetitions';
		is $c->sm2_data->easiness_factor, Param->INITIAL_EASINESS_FACTOR, 'starts with default EF';
	};

	subtest 'Add card with prepopulated SM2 data' => sub {
		$sm2->add_card( $Card->new( data => 2, sm2_data => Param->new( easiness_factor => 2.0 ) ) );
		my $c = $sm2->get_card;
		is $c->data, 2, 'got the card back';
		is $c->sm2_data->easiness_factor, 2.0, 'the easiness factor is the same';
	};
};

done_testing;
