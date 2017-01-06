package Validator::NumericComparisonTest;

use strict;
use warnings;

use Test::More;
use eventMacro::Data;
use eventMacro::Validator::NumericComparison;

sub test {
	my ( $pattern, $neg, $zero, $pos ) = @_;
	my $v = eventMacro::Validator::NumericComparison->new( $pattern );
	ok $v->parsed;
	ok !!$neg eq !!$v->validate( -1 );
	ok !!$zero eq !!$v->validate( 0 );
	ok !!$pos eq !!$v->validate( 1 );
}

sub start {
	
	subtest 'op checks' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '10' );
		ok $v->parsed;
		is ($v->{op}, '==');

		$v = eventMacro::Validator::NumericComparison->new( '== 10' );
		ok $v->parsed;
		is ($v->{op}, '==');

		$v = eventMacro::Validator::NumericComparison->new( '= 10' );
		ok $v->parsed;
		is ($v->{op}, '==');

		$v = eventMacro::Validator::NumericComparison->new( '! 10' );
		ok $v->parsed;
		is ($v->{op}, '!=');

		$v = eventMacro::Validator::NumericComparison->new( '!= 10' );
		ok $v->parsed;
		is ($v->{op}, '!=');

		$v = eventMacro::Validator::NumericComparison->new( '> 10' );
		ok $v->parsed;
		is ($v->{op}, '>');

		$v = eventMacro::Validator::NumericComparison->new( '< 10' );
		ok $v->parsed;
		is ($v->{op}, '<');

		$v = eventMacro::Validator::NumericComparison->new( '<= 10' );
		ok $v->parsed;
		is ($v->{op}, '<=');

		$v = eventMacro::Validator::NumericComparison->new( '>= 10' );
		ok $v->parsed;
		is ($v->{op}, '>=');
	};
	
	subtest 'no max value number' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '10' );
		ok $v->parsed;
		ok (!$v->{min_is_var});
		ok (!$v->{min_is_pct});
		is ($v->{min}, $v->{max});
		is ($v->{min_is_var}, $v->{max_is_var});
		is ($v->{min_is_pct}, $v->{max_is_pct});
	};

	subtest 'simple number' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '< 10' );
		ok $v->parsed;
		ok $v->validate( 9 );
		ok !$v->validate( 10 );
		ok !$v->validate( 11 );

		$v = eventMacro::Validator::NumericComparison->new( '<= 10' );
		ok $v->parsed;
		ok $v->validate( 9 );
		ok $v->validate( 10 );
		ok !$v->validate( 11 );

		$v = eventMacro::Validator::NumericComparison->new( '== 10' );
		ok $v->parsed;
		ok !$v->validate( 9 );
		ok $v->validate( 10 );
		ok !$v->validate( 11 );

		$v = eventMacro::Validator::NumericComparison->new( '!= 10' );
		ok $v->parsed;
		ok $v->validate( 9 );
		ok !$v->validate( 10 );
		ok $v->validate( 11 );

		$v = eventMacro::Validator::NumericComparison->new( '>= 10' );
		ok $v->parsed;
		ok !$v->validate( 9 );
		ok $v->validate( 10 );
		ok $v->validate( 11 );

		$v = eventMacro::Validator::NumericComparison->new( '> 10' );
		ok $v->parsed;
		ok !$v->validate( 9 );
		ok !$v->validate( 10 );
		ok $v->validate( 11 );

		$v = eventMacro::Validator::NumericComparison->new( '< 10' );
		ok $v->parsed;
		ok $v->validate( 9 );
		ok $v->validate( 10 );
		ok !$v->validate( 11 );
	};
	
	subtest 'max value number' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '10..20' );
		ok $v->parsed;
		ok (!$v->{min_is_var});
		ok (!$v->{min_is_pct});
		ok (!$v->{max_is_var});
		ok (!$v->{max_is_pct});
		isnt ($v->{min}, $v->{max});
	};

	subtest 'range' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '< 10..20' );
		ok $v->parsed;
		ok $v->validate( 9 );
		ok !$v->validate( 10 );
		ok !$v->validate( 20 );
		ok !$v->validate( 21 );

		$v = eventMacro::Validator::NumericComparison->new( '<= 10..20' );
		ok $v->parsed;
		ok $v->validate( 9 );
		ok $v->validate( 10 );
		ok $v->validate( 20 );
		ok !$v->validate( 21 );

		$v = eventMacro::Validator::NumericComparison->new( '== 10..20' );
		ok $v->parsed;
		ok !$v->validate( 9 );
		ok $v->validate( 10 );
		ok $v->validate( 20 );
		ok !$v->validate( 21 );

		$v = eventMacro::Validator::NumericComparison->new( '!= 10..20' );
		ok $v->parsed;
		ok $v->validate( 9 );
		ok !$v->validate( 10 );
		ok !$v->validate( 20 );
		ok $v->validate( 21 );

		$v = eventMacro::Validator::NumericComparison->new( '>= 10..20' );
		ok $v->parsed;
		ok !$v->validate( 9 );
		ok $v->validate( 10 );
		ok $v->validate( 20 );
		ok $v->validate( 21 );

		$v = eventMacro::Validator::NumericComparison->new( '> 10..20' );
		ok $v->parsed;
		ok !$v->validate( 9 );
		ok !$v->validate( 10 );
		ok !$v->validate( 20 );
		ok $v->validate( 21 );
	};
	
	subtest 'no max value number percent' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '<10%' );
		ok $v->parsed;
		ok (!$v->{min_is_var});
		ok ($v->{min_is_pct});
		is ($v->{min}, $v->{max});
		is ($v->{min_is_var}, $v->{max_is_var});
		is ($v->{min_is_pct}, $v->{max_is_pct});
	};
	
	subtest 'max value number percent' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '10%..20%' );
		ok $v->parsed;
		ok (!$v->{min_is_var});
		ok ($v->{min_is_pct});
		ok (!$v->{max_is_var});
		ok ($v->{max_is_pct});
		isnt ($v->{min}, $v->{max});
	};
	
	subtest 'max value number percent and no percent mix' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '10..20%' );
		ok $v->parsed;
		ok (!$v->{min_is_var});
		ok (!$v->{min_is_pct});
		ok (!$v->{max_is_var});
		ok ($v->{max_is_pct});
		isnt ($v->{min}, $v->{max});
		
		$v = eventMacro::Validator::NumericComparison->new( '10%..20' );
		ok $v->parsed;
		ok (!$v->{min_is_var});
		ok ($v->{min_is_pct});
		ok (!$v->{max_is_var});
		ok (!$v->{max_is_pct});
		isnt ($v->{min}, $v->{max});
	};

	subtest 'percent' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '<10%' );
		ok $v->parsed;

		ok $v->validate( 4.9, 50 );
		ok !$v->validate( 5,  50 );
		ok !$v->validate( 10, 50 );
		ok $v->validate( 19.9, 200 );
		ok !$v->validate( 20, 200 );
		ok !$v->validate( 40, 200 );

		$v = eventMacro::Validator::NumericComparison->new( '10%..20%' );
		ok $v->parsed;

		ok !$v->validate( 4.9, 50 );
		ok $v->validate( 5,  50 );
		ok $v->validate( 10, 50 );
		ok !$v->validate( 10.1, 50 );
		ok !$v->validate( 19.9, 200 );
		ok $v->validate( 20, 200 );
		ok $v->validate( 40, 200 );
		ok !$v->validate( 40.1, 200 );
		
		$v = eventMacro::Validator::NumericComparison->new( '50..10%' );
		ok $v->parsed;
		
		ok $v->validate( 50, 500 );
		ok $v->validate( 75, 1000 );
		ok !$v->validate( 25, 1000 );
		ok !$v->validate( 110, 1000 );
		ok !$v->validate( 1.5, 20 );
		ok !$v->validate( 10, 20000 );
		ok $v->validate( 100, 20000 );
		ok $v->validate( 1999, 20000 );
		ok $v->validate( 2000, 20000 );
		ok !$v->validate( 2001, 20000 );
		ok !$v->validate( 49, 20000 );
		ok $v->validate( 50, 20000 );
		ok $v->validate( 51, 20000 );
		
		$v = eventMacro::Validator::NumericComparison->new( '20%..10000' );
		ok $v->parsed;
		
		ok !$v->validate( 1999, 10000 );
		ok $v->validate( 2000, 10000 );
		ok $v->validate( 2001, 10000 );
		ok !$v->validate( 15, 100 );
		ok $v->validate( 21, 100 );
		ok !$v->validate( 9999, 50000 );
		ok $v->validate( 10000, 50000 );
		ok !$v->validate( 10001, 50000 );
	};
	
	subtest 'no max value var' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '> $bar' );
		ok $v->parsed;
		ok ($v->{min_is_var});
		ok (!$v->{min_is_pct});
		ok (!defined $v->{min});
		ok (!defined $v->{max});
		is ($v->{var_name_min}, $v->{var_name_max});
		is ($v->{min_is_var}, $v->{max_is_var});
		is ($v->{min_is_pct}, $v->{max_is_pct});
	};
	
	subtest 'max value var' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '$foo..$bar' );
		ok $v->parsed;
		ok ($v->{min_is_var});
		ok (!$v->{min_is_pct});
		ok ($v->{max_is_var});
		ok (!$v->{max_is_pct});
		ok (!defined $v->{min});
		ok (!defined $v->{max});
		isnt ($v->{var_name_min}, $v->{var_name_max});
	};
	
	subtest 'max value number and var mix' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '10..$bar' );
		ok $v->parsed;
		ok (!$v->{min_is_var});
		ok (!$v->{min_is_pct});
		ok ($v->{max_is_var});
		ok (!$v->{max_is_pct});
		ok (defined $v->{min});
		ok (!defined $v->{max});
		
		
		$v = eventMacro::Validator::NumericComparison->new( '$foo..20' );
		ok $v->parsed;
		ok ($v->{min_is_var});
		ok (!$v->{min_is_pct});
		ok (!$v->{max_is_var});
		ok (!$v->{max_is_pct});
		ok (!defined $v->{min});
		ok (defined $v->{max});
	};

	subtest 'variable_simple' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '< $foo' );
		ok $v->parsed;

		ok (!defined $v->{min});
		ok (!defined $v->{max});
		ok ($v->{min_is_var});
		ok ($v->{max_is_var});
		is ($v->{var_name_min}, 'foo');
		
		$v->update_vars( 'foo', 10 );
		
		is ($v->{min}, 10);
		is ($v->{max}, 10);
		
		ok $v->validate( 9 );
		ok !$v->validate( 10 );
		ok !$v->validate( 11 );
		$v->update_vars( 'foo', 11 );
		ok $v->validate( 9 );
		ok $v->validate( 10 );
		ok !$v->validate( 11 );

		$v = eventMacro::Validator::NumericComparison->new( '$foo .. $bar' );
		ok $v->parsed;

		ok (!defined $v->{min});
		ok (!defined $v->{max});
		ok ($v->{min_is_var});
		ok ($v->{max_is_var});
		
		is ($v->{var_name_min}, 'foo');
		is ($v->{var_name_max}, 'bar');
		
		$v->update_vars( 'foo', 10 );
		$v->update_vars( 'bar', 20 );
		
		is ($v->{min}, 10);
		is ($v->{max}, 20);
		
		ok !$v->validate( 9 );
		ok $v->validate( 10 );
		ok $v->validate( 20 );
		ok !$v->validate( 21 );
		
		$v = eventMacro::Validator::NumericComparison->new( '10..$bar' );
		ok $v->parsed;
		
		$v->update_vars( 'bar', 9 );
		ok !$v->validate( 9 );
		ok !$v->validate( 10 );
		ok !$v->validate( 11 );
		
		$v->update_vars( 'bar', 10 );
		ok !$v->validate( 9 );
		ok $v->validate( 10 );
		ok !$v->validate( 11 );
		
		$v->update_vars( 'bar', 11 );
		ok !$v->validate( 9 );
		ok $v->validate( 10 );
		ok $v->validate( 11 );
		
		$v->update_vars( 'bar', 100 );
		ok !$v->validate( 9 );
		ok $v->validate( 10 );
		ok $v->validate( 50 );
		ok $v->validate( 99 );
		ok $v->validate( 100 );
		ok !$v->validate( 101 );
		
		$v = eventMacro::Validator::NumericComparison->new( '$foo..20' );
		ok $v->parsed;
		
		$v->update_vars( 'foo', 30 );
		ok !$v->validate( 9 );
		ok !$v->validate( 10 );
		ok !$v->validate( 11 );
		
		$v->update_vars( 'foo', 10 );
		ok !$v->validate( 9 );
		ok $v->validate( 10 );
		ok $v->validate( 11 );
		
		$v->update_vars( 'foo', 20 );
		ok !$v->validate( 19 );
		ok $v->validate( 20 );
		ok !$v->validate( 21 );
		
		$v->update_vars( 'foo', 5 );
		ok !$v->validate( 4 );
		ok $v->validate( 5 );
		ok $v->validate( 10 );
		ok $v->validate( 19 );
		ok $v->validate( 20 );
		ok !$v->validate( 21 );
	};
	
	subtest 'max value var percent and var no percent mix' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '$foo .. $bar' );
		ok $v->parsed;
		ok ($v->{min_is_var});
		ok (!$v->{min_is_pct});
		ok ($v->{max_is_var});
		ok (!$v->{max_is_pct});
		
		$v->update_vars( 'foo', '50' );
		$v->update_vars( 'bar', '10%' );
		
		ok (!$v->{min_is_pct});
		ok ($v->{max_is_pct});
		
		ok $v->validate( 50, 500 );
		ok $v->validate( 75, 1000 );
		ok !$v->validate( 25, 1000 );
		ok !$v->validate( 110, 1000 );
		ok !$v->validate( 1.5, 20 );
		ok !$v->validate( 10, 20000 );
		ok $v->validate( 100, 20000 );
		ok $v->validate( 1999, 20000 );
		ok $v->validate( 2000, 20000 );
		ok !$v->validate( 2001, 20000 );
		ok !$v->validate( 49, 20000 );
		ok $v->validate( 50, 20000 );
		ok $v->validate( 51, 20000 );
		
		$v->update_vars( 'foo', '20%' );
		$v->update_vars( 'bar', '10000' );
		
		ok ($v->{min_is_pct});
		ok (!$v->{max_is_pct});
		
		ok !$v->validate( 1999, 10000 );
		ok $v->validate( 2000, 10000 );
		ok $v->validate( 2001, 10000 );
		ok !$v->validate( 15, 100 );
		ok $v->validate( 21, 100 );
		ok !$v->validate( 9999, 50000 );
		ok $v->validate( 10000, 50000 );
		ok !$v->validate( 10001, 50000 );
		
	};
	
	subtest 'variable_percent' => sub {
		my $v = eventMacro::Validator::NumericComparison->new( '< $foo' );
		ok $v->parsed;

		ok (!$v->{min_is_pct});
		
		$v->update_vars( 'foo', '10%' );
		
		ok ($v->{min_is_pct});
		
		ok $v->validate( 4.9, 50 );
		ok !$v->validate( 5,  50 );
		ok !$v->validate( 10, 50 );
		ok $v->validate( 19.9, 200 );
		ok !$v->validate( 20, 200 );
		ok !$v->validate( 40, 200 );
		
		$v = eventMacro::Validator::NumericComparison->new( '$foo .. $bar' );
		ok $v->parsed;

		ok (!$v->{min_is_pct});
		ok (!$v->{max_is_pct});
		
		$v->update_vars( 'foo', '10%' );
		$v->update_vars( 'bar', '20%' );
		
		ok ($v->{min_is_pct});
		ok ($v->{max_is_pct});
		
		ok !$v->validate( 4.9, 50 );
		ok $v->validate( 5,  50 );
		ok $v->validate( 10, 50 );
		ok !$v->validate( 10.1, 50 );

		ok !$v->validate( 19.9, 200 );
		ok $v->validate( 20, 200 );
		ok $v->validate( 40, 200 );
		ok !$v->validate( 40.1, 200 );
	};
}

1;
