use strict;
use warnings;
use Test::More 0.88;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';

my $method_name = '$#%^$@!#%#^$@$';
my @symtab_entries;
{
  package Class;
  use Class::Method::Modifiers;
  {
    no strict 'refs';
    *{'Class::'.$method_name} = sub { "welp" };
  }
  Class->can('can');
  @symtab_entries = sort keys %Class::;

  around $method_name => sub { $_[0]->()." around" };
}

is +Class->$method_name, 'welp around',
  'around non-identifier method works';

is_deeply [sort keys %Class::], \@symtab_entries,
  'no extra symbol table entries created';

done_testing;
