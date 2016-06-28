class openproject::migrate {
  include openproject

  bundle::exec { 'openproject db:migrate db:seed':
    path        => $::openproject::path,
    command     => 'rake db:migrate db:seed',
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

  Bundle::Exec['openproject db:migrate db:seed'] ->
  File["${::openproject::path}/db/schema.rb"]
}
