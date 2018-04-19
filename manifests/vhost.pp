class openproject::vhost {
  include openproject

  include apache
  include apache::mod::passenger
  apache::vhost { $::openproject::servername:
    port           => 443,
    ssl            => true,
    manage_docroot => false,
    docroot        => "${::openproject::path}/public",
    default_vhost  => true,
    setenv         => [
      "SECRET_KEY_BASE ${::openproject::secret_key_base}",
    ],
    directories    => [
      {
        'path'         => "${::openproject::path}/public",
        options        => 'None',
        allow_override => 'None',
      },
    ],
  }
}
