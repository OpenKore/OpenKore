package eventMacro::Condition::FreeStatPoints;

use strict;

use base 'eventMacro::Conditiontypes::NumericConditionState';

use Globals qw( $char );

sub _hooks {
	['packet/stat_info','packet/stats_info'];
}

sub _get_val {
	$char->{points_free};
}

sub validate_condition {
	my ( $self, $callback_type, $callback_name, $args ) = @_;
	
	if ($callback_type eq 'hook') {
		return if $callback_name eq 'packet/stat_info' && $args && $args->{type} != 9;
	} elsif ($callback_type eq 'variable') {
		$self->SUPER::update_validator_var($callback_name, $args);
	}
	$self->SUPER::validate_condition;
}

sub get_new_variable_list {
	my ($self) = @_;
	my $new_variables;
	
	$new_variables->{".FreeStatPointsLast"} = $char->{points_free};
	
	return $new_variables;
}

1;
