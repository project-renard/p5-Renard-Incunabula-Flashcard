#!/usr/bin/env perl

use Test::Most tests => 2;
use Renard::Incunabula::Common::Setup;

use Renard::Incunabula::Flashcard::Scheduler::Anki::SchedV1;
use Time::Seconds;

fun get_scheduler() {
	my $sched = Renard::Incunabula::Flashcard::Scheduler::Anki::SchedV1->new;
}

subtest "Clock" => sub {
	my $sched = get_scheduler();
	ok $sched->day_cutoff - Time::Piece->localtime >= ONE_HOUR,
		'Unit tests run is greater than an hour of cutoff';
};

subtest "Empty schedule" => sub {
	my $sched = get_scheduler();
	ok !defined $sched->pop_card, 'No card scheduled returns undef';
};

done_testing;
