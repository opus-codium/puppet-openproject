# XXX: Packaging Issues
# The followind files do not belong to the "right" user AFAIAC:
# - /db/schema.rb
# - /frontend/node_modules
#
# /db/schema.rb reason:
# Migrating the database requires write access to /tmp/cache
# (so migrate  as user 'openproject', not 'deploy').
#
# /frontend/node_modules reason:
# - npm installs programs with invalid permissions (rwxrwxrw-), so  must be run as the user who will precompile the assets
# - precompiling assets requires write permissions to /tmp/cache
# (so npm install and precompile assets as user 'openproject', not 'deploy').
define openproject (
  $path,
  $secret_key_base,
  $database_host,
  $database_name,
  $database_user ,
  $database_password,
  $user = 'openproject',
  $group = 'openproject',
) {
  include deploy
  include bundle
  include phantomjs

  file { '/srv/www':
    ensure => directory,
    owner  => 0,
    group  => 0,
    mode   => '0755',
  }

  file { $path:
    ensure => directory,
    owner  => $::deploy::user,
    group  => $::deploy::group,
    mode   => '0755',
  }

  file { ["${path}/tmp/cache", "${path}/tmp/pids", "${path}/tmp/sessions", "${path}/tmp/sockets", "${path}/files"]:
    ensure  => directory,
    owner   => $user,
    group   => $group,
    mode    => '0755',
    require => Vcsrepo[$path],
  }

  file { ["${path}/config.ru", "${path}/log/production.log"]:
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0644',
    require => Vcsrepo[$path],
    notify  => Apache::Vhost[$name],
  }

  user { $user:
    ensure => present,
    home   => $path,
  }

  vcsrepo { $path:
    ensure   => present,
    provider => 'git',
    source   => 'https://github.com/opf/openproject.git',
    revision => 'stable/5',
    user     => $::deploy::user,
    depth    => 1,
    require  => File[$path],
    notify   => Bundle::Install[$path],
  }

  package { 'nodejs-legacy':
    ensure => installed,
  }

  package { ['zlib1g-dev', 'libmagickcore-dev', 'libmagickwand-dev', 'libpq-dev']:
    ensure => installed,
    before => Bundle::Install[$path],
  }

  bundle::install { $path:
    without => 'mysql mysql2 docker development test therubyracer',
    mode    => 'local',
    notify  => Npm::Install[$path],
  }

  file { ["${path}/frontend/node_modules", "${path}/app/assets/javascripts", "${path}/app/assets/javascripts/bundles", "${path}/public", "${path}/public/assets", "${path}/frontend", "${path}/frontend/bower_components" ]:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
    require => Vcsrepo[$path],
  }

  npm::install { $path:
    require => [Package['nodejs-legacy'], File["${path}/frontend/node_modules"], File["${path}/app/assets/javascripts/bundles"]],
    user    => $user,
    group   => $group,
    notify  => [Bundle::Exec['openproject db:migrate db:seed'], Bundle::Exec['openproject assets:precompile']]
  }

  file { "${path}/db/schema.rb":
    ensure => file,
    owner  => $user,
    group  => $group,
    mode   => '0644',
  }

  postgresql::server::db { $database_name:
    user     => $database_user,
    password => postgresql_password($database_user, $database_password),
    notify   => Bundle::Exec['openproject db:migrate db:seed'],
  }

  bundle::exec { 'openproject db:migrate db:seed':
    path        => $path,
    command     => 'rake db:migrate db:seed',
    user        => $user,
    group       => $group,
    timeout     => 600,
    environment => ['RAILS_ENV=production', 'LANG=fr_FR.UTF-8'],
    require     => [File["${path}/db/schema.rb"], File["${path}/config/database.yml"], Postgresql::Server::Db[$database_name]],
  }

  bundle::exec { 'openproject assets:precompile':
    path        => $path,
    command     => 'rake assets:precompile',
    user        => $user,
    group       => $group,
    timeout     => 600,
    environment => ['RAILS_ENV=production'],
    require     => [File["${path}/app/assets/javascripts/bundles"], File["${path}/public/assets"]],
    notify      => Apache::Vhost[$name],
  }

  file { "${path}/config/database.yml":
    ensure  => file,
    owner   => $user,
    group   => $group,
    mode    => '0400',
    content => template('openproject/database.yml.erb'),
    require => Vcsrepo[$path],
  }

  file { "${path}/config/configuration.yml":
    ensure => file,
    owner  => $::deploy::user,
    group  => $::deploy::group,
    mode   => '0644',
    source => 'puppet:///modules/openproject/configuration.yml',
    notify => Apache::Vhost[$name],
    require => Vcsrepo[$path],
  }

  apache::vhost { $name:
    port           => 443,
    ssl            => true,
    manage_docroot => false,
    docroot        => "${path}/public",
    default_vhost  => true,
    setenv         => [
      "SECRET_KEY_BASE ${secret_key_base}",
    ],
    directories    => [
      { 'path'         => "${path}/public",
        options        => 'None',
        allow_override => 'None',
      }
    ],
  }

  concat { "${path}/Gemfile.plugins":
    ensure  => present,
    owner   => $::deploy::user,
    group   => $::deploy::group,
    require => Vcsrepo[$path],
    notify  => Bundle::Install[$path],
  }

  concat::fragment { "${path}/Gemfile.plugins-orig":
    target  => "${path}/Gemfile.plugins",
    source => 'puppet:///modules/openproject/Gemfile.plugins',
    order   => '001',
  }
}
