use strict;
use warnings;
use Test::More;
$| = 1;

BEGIN {
    eval "use DBD::SQLite";
    plan $@ ? (skip_all => 'needs DBD::SQLite for testing') : (tests => 9);
}

{
    package User;
    use base qw(Class::DBI);
    use strict;
    use warnings;
    use Class::DBI::Plugin::RetrieveFromSQL;

    use File::Temp qw/tempfile/;
    my (undef, $DB) = tempfile();
    my @DSN = ('Main', "dbi:SQLite:dbname=$DB", '', '', { AutoCommit => 1 });

    END { unlink $DB if -e $DB }

    __PACKAGE__->set_db(@DSN);
    __PACKAGE__->table('user');
    __PACKAGE__->columns(All     => qw(name tel address));

    sub create_table {
        my $class = shift;
        $class->db_Main->do(q{
            CREATE TABLE user (
                name    VARCHAR(255) NOT NULL,
                tel     VARCHAR(255) NOT NULL,
                address VARCHAR(255) NOT NULL
            )
        });
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

ok(User->create_table, 'create table');
ok(User->can('db_Main'), 'set_db()');
is(User->__driver, "SQLite", "Driver set correctly");
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
