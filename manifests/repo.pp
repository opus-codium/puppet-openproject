class openproject::repo {
  include openproject

  file { $::openproject::path:
    ensure => directory,
    owner  => $::openproject::deploy_user,
    group  => $::openproject::deploy_group,
    mode   => '0755',
  }

  vcsrepo { $::openproject::path:
    ensure   => present,
    provider => 'git',
    source   => 'https://github.com/opf/openproject.git',
    revision => "v${::openproject::version}",
    user     => $::openproject::deploy_user,
    depth    => 1,
  }

  File[$::openproject::path] ->
  Vcsrepo[$::openproject::path]
}
