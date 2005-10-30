use ExtUtils::MakeMaker;
WriteMakefile(
        'NAME'         => 'Class::DBI::Plugin::RetrieveFromSQL',
        'VERSION_FROM' => 'lib/Class/DBI/Plugin/RetrieveFromSQL.pm', # finds $VERSION
        'PREREQ_PM'    => {
                Test::More => 0.32,
        },
);
