use strict;
use warnings;
use Test::More 0.88;
use Test::Warnings ($ENV{AUTHOR_TESTING} ? () : ':no_end_test'), 'warning';
use Test::Fatal;

use Class::Method::Modifiers;

{
    sub foo ($) { scalar @_ }

    my $after;
    after foo => sub { $after = @_ };

    is eval q{ foo( @{[10, 20]} ) }, 1,
        'after wrapped sub maintains prototype';
    is $after, 1,
        'after modifier applied';
}

{
    my $bar;
    my $guff;
    sub bar ($) :lvalue { $guff = @_; $bar }

    my $after;
    after bar => sub { $after = @_ };

    eval q{ bar( @{[10, 20]} ) = 5 };
    is $guff, 1,
        'after wrapped lvalue sub maintains prototype';
    is $bar, 5,
        'after wrapped lvalue sub maintains lvalue';
    is $after, 1,
        'after modifier applied';
}

{
    sub bog ($) { scalar @_ }

    my $around;
    my $warn = warning {
        around bog => sub ($$) {
            my $orig = shift;
            $around = @_;
            $orig->(@_);
        };
    };

    is eval q{ bog( @{[5, 6]}, @{[10, 11]} ) }, 2,
        'around wrapped lvalue sub takes modifier prototype';
    is $around, 2,
        'around modifier applied';
    like $warn, qr/Prototype mismatch/,
        'changing prototype throws warning';
}

done_testing;
# vim: set ts=8 sts=4 sw=4 tw=115 et :
