package eventMacro::Automacro;

use strict;
use Globals;
use Log qw(message error warning debug);
use Utils;

use eventMacro::Condition;
use eventMacro::Data;

sub new {
	my ($class, $name, $conditions, $parameters) = @_;
	my $self = bless {}, $class;
	
	$self->{name} = $name;
	
	$self->{conditionList} = new eventMacro::Lists;
	$self->{event_type_condition_index} = undef;
	$self->{hooks} = {};
	$self->{variables} = {};
	$self->create_conditions_list( $conditions );
	
	$self->{number_of_false_conditions} = $self->{conditionList}->size;
	if (defined $self->{event_type_condition_index}) {
		$self->{number_of_false_conditions}--;
	}
	
	$self->{parameters} = {};
	$self->set_parameters( $parameters );
	
	return $self;
}

sub get_hooks {
	my ($self) = @_;
	return $self->{hooks};
}

sub get_variables {
	my ($self) = @_;
	return $self->{variables};
}

sub get_name {
	my ($self) = @_;
	return $self->{name};
}

sub set_timeout_time {
	my ($self, $time) = @_;
	$self->{parameters}{time} = $time;
}

sub disable {
	my ($self) = @_;
	$self->{parameters}{disabled} = 1;
	debug "[eventMacro] Disabling ".$self->get_name()."\n", "eventMacro", 2;
	return 1;
}

sub enable {
	my ($self) = @_;
	$self->{parameters}{disabled} = 0;
	debug "[eventMacro] Enabling ".$self->get_name()."\n", "eventMacro", 2;
	return 1;
}

sub get_parameter {
	my ($self, $parameter) = @_;
	return $self->{parameters}{$parameter};
}

sub set_parameters {
	my ($self, $parameters) = @_;
	foreach (keys %{$parameters}) {
		my $key = $_;
		my $value = $parameters->{$_};
		$self->{parameters}{$key} = $value;
	}
	#all parameters must be defined
	if (!defined $self->{parameters}{'timeout'})  {
		$self->{parameters}{'timeout'} = 0;
	}
	if (!defined $self->{parameters}{'delay'})  {
		$self->{parameters}{'delay'} = 0;
	}
	if (!defined $self->{parameters}{'run-once'})  {
		$self->{parameters}{'run-once'} = 0;
	}
	if (!defined $self->{parameters}{'disabled'})  {
		$self->{parameters}{'disabled'} = 0;
	}
	if (!defined $self->{parameters}{'overrideAI'})  {
		$self->{parameters}{'overrideAI'} = 0;
	}
	if (!defined $self->{parameters}{'orphan'})  {
		$self->{parameters}{'orphan'} = $config{eventMacro_orphans};
	}
	if (!defined $self->{parameters}{'macro_delay'})  {
		$self->{parameters}{'macro_delay'} = $timeout{eventMacro_delay}{timeout};
	}
	if (!defined $self->{parameters}{'priority'})  {
		$self->{parameters}{'priority'} = 0;
	}
	if (!defined $self->{parameters}{'exclusive'})  {
		$self->{parameters}{'exclusive'} = 0;
	}
	if (!defined $self->{parameters}{'repeat'})  {
		$self->{parameters}{'repeat'} = 1;
	}
	$self->{parameters}{time} = 0;
}

sub create_conditions_list {
	my ($self, $conditions) = @_;
	foreach (keys %{$conditions}) {
		my $module = $_;
		my $conditionsText = $conditions->{$_};
		eval "use $module";
		foreach my $newConditionText ( @{$conditionsText} ) {
			my $cond = $module->new( $newConditionText );
			$self->{conditionList}->add( $cond );
			foreach my $hook ( @{ $cond->get_hooks() } ) {
				push ( @{ $self->{hooks}{$hook} }, $cond->{listIndex} );
			}
			foreach my $variable ( @{ $cond->get_variables() } ) {
				push ( @{ $self->{variables}{$variable} }, $cond->{listIndex} );
			}
			if ($cond->condition_type == EVENT_TYPE) {
				$self->{event_type_condition_index} = $cond->{listIndex};
			}
		}
	}
}

sub has_event_type_condition {
	my ($self) = @_;
	return defined $self->{event_type_condition_index};
}

sub get_event_type_condition_index {
	my ($self) = @_;
	return $self->{event_type_condition_index};
}

sub check_state_type_condition {
	my ($self, $condition_index, $event_name, $args) = @_;
	
	my $condition = $self->{conditionList}->get($condition_index);
	
	my $pre_check_status = $condition->is_fulfilled;
	
	$condition->validate_condition_status($event_name,$args);
	
	my $pos_check_status = $condition->is_fulfilled;
	
	debug "[eventMacro] Checking condition '".$condition->get_name()."' of index '".$condition->{listIndex}."' in automacro '".$self->{name}."', fulfilled value before: '".$pre_check_status."', fulfilled value after: '".$pos_check_status."'.\n", "eventMacro", 3;
	
	if ($pre_check_status == 1 && $condition->is_fulfilled == 0) {
		$self->{number_of_false_conditions}++;
	} elsif ($pre_check_status == 0 && $condition->is_fulfilled == 1) {
		$self->{number_of_false_conditions}--;
	}
}

sub check_event_type_condition {
	my ($self, $event_name, $args) = @_;
	
	my $condition = $self->{conditionList}->get($self->{event_type_condition_index});
	
	my $return = $condition->validate_condition_status($event_name, $args);
	
	debug "[eventMacro] Checking event type condition '".$condition->get_name()."' of index '".$condition->{listIndex}."' in automacro '".$self->{name}."', fulfilled value: '".$return."'.\n", "eventMacro", 3;

	return $return;
}

sub are_conditions_fulfilled {
	my ($self) = @_;
	$self->{number_of_false_conditions} == 0;
}

sub is_disabled {
	my ($self) = @_;
	return $self->{parameters}{disabled};
}

sub is_timed_out {
	my ($self) = @_;
	return 1 unless ( $self->{parameters}{'timeout'} );
	return 1 if ( timeOut( { timeout => $self->{parameters}{'timeout'}, time => $self->{parameters}{time} } ) );
	return 0;
}

sub can_be_run {
	my ($self) = @_;
	return 1 if ($self->are_conditions_fulfilled && !$self->is_disabled && $self->is_timed_out);
	return 0;
}

1;