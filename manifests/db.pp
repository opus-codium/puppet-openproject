class openproject::db {
  include openproject

  include postgresql::server

  postgresql::server::db { $::openproject::database_name:
    user     => $::openproject::database_user,
    password => postgresql_password($::openproject::database_user, $::openproject::database_password),
  }
}
