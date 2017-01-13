use strict;
use warnings;
use Test::More 0.88;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';

my @seen;

subtest 'method name' => sub {
  @seen = ();

  my @expected = ("Child::++ before 2",
		    "Child::++ before 1",
		       "Child::++ around 2 before",
			 "Child::++ around 1 before",
			   "Parent::++",
			 "Child::++ around 1 after",
		       "Child::++ around 2 after",
		    "Child::++ after 1",
		  "Child::++ after 2",
		 );

  my $child = Child->new; $child++;

  is_deeply(\@seen, \@expected, "multiple before/around/after called in the right order");
};

subtest 'coderef' => sub {

  @seen = ();

  my @expected = ("Child::-- before 2",
		    "Child::-- before 1",
		       "Child::-- around 2 before",
			 "Child::-- around 1 before",
			   "Parent::--",
			 "Child::-- around 1 after",
		       "Child::-- around 2 after",
		    "Child::-- after 1",
		  "Child::-- after 2",
		 );

  my $child = Child->new; $child--;

  is_deeply(\@seen, \@expected, "multiple before/around/after called in the right order");
};


BEGIN {
    package Parent;

    use overload
        '++' => 'plus',
	'--' => sub { push @seen, __PACKAGE__ . "::--" };

    sub new { bless {}, shift }

    sub plus
    {
        push @seen, __PACKAGE__ . "::++";
    }
}

BEGIN {
    package Child;
    our @ISA = 'Parent';
    use Class::Method::Modifiers;

    for ( qw[ ++ -- ] ) {

        my $op = $_;

	before $op => sub
	{
	    push @seen, __PACKAGE__ . "::$op before 1";
	};

	before $op => sub
	{
	    push @seen, __PACKAGE__ . "::$op before 2";
	};

	around $op => sub
	{
	    my $orig = shift;
	    push @seen, __PACKAGE__ . "::$op around 1 before";
	    $orig->();
	    push @seen, __PACKAGE__ . "::$op around 1 after";
	};

	around $op => sub
	{
	    my $orig = shift;
	    push @seen, __PACKAGE__ . "::$op around 2 before";
	    $orig->();
	    push @seen, __PACKAGE__ . "::$op around 2 after";
	};

	after $op => sub
	{
	    push @seen, __PACKAGE__ . "::$op after 1";
	};

	after $op => sub
	{
	    push @seen, __PACKAGE__ . "::$op after 2";
	};

    }

}

done_testing;
