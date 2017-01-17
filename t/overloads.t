use strict;
use warnings;
use Test::More 0.88;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';

{
  package Foo;
  use overload '""' => sub { "stringy" };
  use Class::Method::Modifiers;

  sub new { bless \(my $s = $_[1]), $_[0] }

  around '(""' => sub {
    my $orig = shift;
    my $self = shift;
    $self->$orig(@_) . ' around';
  };
}

my $o = Foo->new;
is "$o", 'stringy around',
  'can around stringy overload methods';

done_testing;
