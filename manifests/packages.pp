class openproject::packages {
  include openproject

  ensure_packages(['zlib1g-dev', 'libmagickcore-dev', 'libmagickwand-dev', 'libpq-dev'], {
    ensure => installed,
    before => Bundle::Install[$::openproject::path],
  })
}
