class openproject::user {
  include openproject

  user { $::openproject::user:
    ensure => present,
    home   => $::openproject::path,
    system => true,
    groups => ['git'],
  }
}
