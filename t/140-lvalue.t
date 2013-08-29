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

Around->lvalue_method = 1;
is(Around->lvalue_method, 1, 'around on an lvalue attribute is maintained');

Around->other_method = 2;
is(Around->other_method, 2, 'around adding an lvalue attribute works');

{
  package Before;
  use Class::Method::Modifiers;
  our @ISA = qw(WithLvalue);

  before lvalue_method => sub {};
}

Before->lvalue_method = 3;
is(Before->lvalue_method, 3, 'before maintains lvalue attribute');

{
  package After;
  use Class::Method::Modifiers;
  our @ISA = qw(WithLvalue);

  after lvalue_method => sub {};
}

After->lvalue_method = 4;
is(After->lvalue_method, 4, 'after maintains lvalue attribute');

done_testing;
