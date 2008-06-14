package Class::DBI::Plugin::RetrieveFromSQL;
use strict;
use warnings;
our $VERSION = '0.03';

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
            my %hargs = %{$vals[0]};
            my @args;
            $sql =~ s{:([A-Za-z_][A-Za-z0-9_]*)}{
                die "$1 is not exists in hash" if !exists $hargs{$1};
                push @args, $hargs{$1};
                '?'
            }ge;
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
    (artist =    :artist OR artist2 = :artist) AND
    title  like :title  AND
    year   <=   :year
    ORDER BY year
    LIMIT 2,3
  }, {artist => 'Ozzy Osbourne', title => '%Crazy', year => 1986});

  # This does the equivalent of:
  my @cds = Music::CD->retrieve_from_sql(qq{
    (artist =   ?  OR artist2 = ?) AND
    title  like ?  AND
    year   <=   ?
    ORDER BY year
    LIMIT 2,3
  }, 'Ozzy Osbourne', 'Ozzy Osbourne', '%Crazy', 1986);

=head1 DESCRIPTION

Class::DBI::Plugin::RetrieveFromSQL makes your retrieve_from_sql more readable!

When using many arguments in retrieve_from_sql, it hardly to read.
If you use this plugin, you can use the hash!

=head1 AUTHOR

MATSUNO Tokuhiro E<lt>tokuhiro at mobilefactory.jpE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Class::DBI>, ActiveRecord

=cut
