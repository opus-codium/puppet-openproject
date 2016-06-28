class openproject::setup {
  include deploy
  include openproject

  $version = $::openproject::version

  file { ["${::openproject::path}/.config", "${::openproject::path}/.local", "${::openproject::path}/.npm", "${::openproject::path}/tmp/cache", "${::openproject::path}/tmp/pids", "${::openproject::path}/tmp/sessions", "${::openproject::path}/tmp/sockets", "${::openproject::path}/files"]:
    ensure => directory,
    owner  => $::openproject::user,
    group  => $::openproject::group,
    mode   => '0755',
  }

  file { ["${::openproject::path}/config.ru", "${::openproject::path}/log/production.log"]:
    ensure => file,
    owner  => $::openproject::user,
    group  => $::openproject::group,
    mode   => '0644',
  }

  file { ["${::openproject::path}/.cache", "${::openproject::path}/frontend/node_modules", "${::openproject::path}/app/assets/javascripts", "${::openproject::path}/app/assets/javascripts/bundles", "${::openproject::path}/public", "${::openproject::path}/public/assets", "${::openproject::path}/frontend", "${::openproject::path}/frontend/bower_components" ]:
    ensure => directory,
    owner  => $::deploy::user,
    group  => $::openproject::group,
    mode   => '0775',
  }

  file { "${::openproject::path}/config/database.yml":
    ensure  => file,
    owner   => $::openproject::user,
    group   => $::openproject::group,
    mode    => '0400',
    content => template('openproject/database.yml.erb'),
  }

  file { "${::openproject::path}/config/configuration.yml":
    ensure => file,
    owner  => $::deploy::user,
    group  => $::deploy::group,
    mode   => '0644',
    source => 'puppet:///modules/openproject/configuration.yml',
  }

  concat { "${::openproject::path}/Gemfile.plugins":
    ensure  => present,
    owner   => $::deploy::user,
    group   => $::deploy::group,
  }

  concat::fragment { "${::openproject::path}/Gemfile.plugins-orig":
    target  => "${::openproject::path}/Gemfile.plugins",
    content => template('openproject/Gemfile.plugins.erb'),
    order   => '001',
  }
}
