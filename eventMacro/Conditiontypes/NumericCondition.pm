package eventMacro::Conditiontypes::Conditiontypes::NumericCondition;

use strict;

use base 'eventMacro::Condition';

sub _parse_syntax {
	my ( $self, $condition_code ) = @_;
	my $validator = $self->{validator} = eventMacro::Validator::NumericComparison->new( $condition_code );
	push @{ $self->{variables} }, $validator->variables;
	$validator->parsed;
}

sub validate_condition_status {
	my ( $self ) = @_;
	my $result = $self->{validator}->validate( $self->_get_val, $self->_get_ref_val );
	return $result if ($self->is_event_only);
	$self->{is_Fulfilled} = $result;
}

# Get the value to compare.
sub _get_val {
	1;
}

# Get the reference value to do percentage comparisons with.
sub _get_ref_val {
	undef;
}

1;
