use strict;
use warnings;
use Test::More;

{
  package WithLvalue;
  my $f;
  sub lvalue_method :lvalue { $f }

  sub other_method { 1 }
}

{
  package Around;
  use Class::Method::Modifiers;
  our @ISA = qw(WithLvalue);

  around lvalue_method => sub :lvalue {
    my $orig = shift;
    $orig->(@_);
  };

  my $d;
  around other_method => sub :lvalue {
    $d;
  };
}

Around->lvalue_method = 5;
is(Around->lvalue_method, 5);

Around->other_method = 5;
is(Around->other_method, 5);

done_testing;
