class openproject::packages {
  include openproject

  package { 'nodejs-legacy':
    ensure => installed,
  }

  package { ['zlib1g-dev', 'libmagickcore-dev', 'libmagickwand-dev', 'libpq-dev']:
    ensure => installed,
    before => Bundle::Install[$::openproject::path],
  }
}
