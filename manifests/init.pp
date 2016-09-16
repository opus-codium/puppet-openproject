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
class openproject (
  $path,
  $servername,
  $secret_key_base,
  $database_host,
  $database_name,
  $database_user ,
  $database_password,
  $version,
  $user = 'openproject',
  $group = 'openproject',
  $deploy_user = 'deploy',
  $deploy_group = 'deploy',
) {
  include bundle
  include phantomjs

  include openproject::packages
  include openproject::user
  include openproject::repo
  include openproject::setup
  include openproject::db
  include openproject::bundle
  include openproject::npm
  include openproject::migrate
  include openproject::assets
  include openproject::vhost

  Class['openproject::packages'] ->
  Class['openproject::user'] ->
  Class['openproject::repo'] ->
  Class['openproject::setup'] ->
  Class['openproject::db'] ->
  Class['openproject::bundle'] ->
  Class['openproject::npm'] ->
  Class['openproject::migrate'] ->
  Class['openproject::assets'] ->
  Class['openproject::vhost']

  Class['openproject::repo'] ~>
  Class['openproject::bundle'] ~>
  Class['openproject::npm'] ~>
  Class['openproject::migrate']

  Class['openproject::npm'] ~>
  Class['openproject::assets'] ~>
  Class['openproject::vhost']

  Class['openproject::db'] ~>
  Class['openproject::migrate']

  file { '/srv/www':
    ensure => directory,
    owner  => 0,
    group  => 0,
    mode   => '0755',
  }
}
