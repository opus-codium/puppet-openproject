class openproject::migrate {
  include openproject

  bundle::exec { 'openproject db:migrate':
    cwd         => $::openproject::path,
    command     => 'rake db:migrate',
    user        => $::openproject::user,
    group       => $::openproject::group,
    timeout     => 600,
    environment => ['RAILS_ENV=production', 'LANG=fr_FR.UTF-8'],
  }

  file { "${::openproject::path}/db/schema.rb":
    ensure => file,
    owner  => $::openproject::user,
    group  => $::openproject::group,
    mode   => '0644',
  }

  Bundle::Exec['openproject db:migrate'] ->
  File["${::openproject::path}/db/schema.rb"]
}
