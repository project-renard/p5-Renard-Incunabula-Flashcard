#!/usr/bin/env perl

use Test::Most tests => 1;
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

done_testing;
