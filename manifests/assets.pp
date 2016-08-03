class openproject::assets {
  include openproject

  bundle::exec { 'openproject assets:precompile':
    cwd         => $::openproject::path,
    command     => 'rake assets:precompile',
    user        => $::openproject::user,
    group       => $::openproject::group,
    timeout     => 600,
    environment => ['RAILS_ENV=production'],
    refreshonly => true,
  }
}
