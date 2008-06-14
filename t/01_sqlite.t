use strict;
use warnings;
use Test::More;
$| = 1;

BEGIN {
    eval "use Class::DBI::Test::SQLite; use DBD::SQLite;";
    plan $@ ? (skip_all => 'needs Class::DBI::Test::SQLite, DBD::SQLite for testing') : (tests => 6);
}

{
    package User;
    use base qw/Class::DBI::Test::SQLite/;
    use Class::DBI::Plugin::RetrieveFromSQL;
    __PACKAGE__->set_table('user');
    __PACKAGE__->columns(All     => qw(name tel address));

    sub create_sql {
        q{
            name    VARCHAR(255) NOT NULL,
            tel     VARCHAR(255) NOT NULL,
            address VARCHAR(255) NOT NULL
        }
    }

    sub set_data {
        my $class = shift;
        $class->create({
            name    => 'tony',
            tel     => '052-2222-5325',
            address => 'meguro',
        });
        $class->create({
            name    => 'tetsu',
            tel     => '532-5222-2222',
            address => 'shimokitazawa',
        });
    }
}

package main;

ok(User->set_data, 'set_data');

my $user = User->retrieve_from_sql(
    q{name = :name AND tel = :tel AND :tel != "532-5222-2222"},
    {name => 'tony', tel => '052-2222-5325',}
)->first;
ok($user, 'retrieve_from_sql');
is($user->address, 'meguro', 'address ok');

my $user_orig = User->retrieve_from_sql('name = ? AND tel = ?', 'tony', '052-2222-5325')->first;
ok($user_orig, 'retrieve_from_sql original');
is($user_orig->address, 'meguro', 'address ok');

eval {
    my $user = User->retrieve_from_sql(
        q{name = :nam}, {name => 'hoge'}
    )->first;
};
like($@, qr(nam is not exists in hash), "error detect");
