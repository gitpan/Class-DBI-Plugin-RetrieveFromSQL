package Class::DBI::Plugin::RetrieveFromSQL;

use strict;
use warnings;
use vars qw($VERSION);
$VERSION = '0.01';

sub import {
    my $class = shift;
    my $pkg   = caller(0);
    
    no strict 'refs';
    my $super = $pkg->can('retrieve_from_sql');
    *{"$pkg\::retrieve_from_sql"} = sub {
        my $self = shift;
        my $sql  = shift;
        my @vals = @_;

        if (ref $vals[0] ne 'HASH') {
            return $self->$super($sql, @vals)
        } else {
            my $h_ref = $vals[0];
            my @args;
            $sql =~ s{:([A-Za-z][A-Za-z0-9]*)}{push @args, $$h_ref{$1}; '?'}ge;
            return $self->$super($sql, @args);
        }
    };
}

1;
__END__

=head1 NAME

Class::DBI::Plugin::RetrieveFromSQL - readable retrieve_from_sql plugin for Class::DBI

=head1 SYNOPSIS

  package Music::CD;
  use base qw(Class::DBI);
  use Class::DBI::Plugin::RetrieveFromSQL;

  package Main;
  my @cds = Music::CD->retrieve_from_sql(qq{
    artist =    :artist AND
    title  like :title  AND
    year   <=   :year
    ORDER BY year
    LIMIT 2,3
  }, {artist => 'Ozzy Osbourne', title => '%Crazy', year => 1986});

  # This does the equivalent of:
  my @cds = Music::CD->retrieve_from_sql(qq{
    artist =    ? AND
    title  like ?  AND
    year   <=   ?
    ORDER BY year
    LIMIT 2,3
  }, 'Ozzy Osbourne', '%Crazy', 1986);

=head1 DESCRIPTION

Class::DBI::Plugin::RetrieveFromSQL makes your retrieve_from_sql more readable!

When using many arguments in retrieve_from_sql, it hardly to read.
If you use this plugin, you can use the hash!

=head1 AUTHOR

MATSUNO Tokuhiro E<lt>tokuhirom at mobilefactory.jpE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Class::DBI>, ActiveRecord

=cut
