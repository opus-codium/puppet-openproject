class openproject::npm {
  include openproject

  npm::install { $::openproject::path:
    user  => $::openproject::user,
    group => $::openproject::group,
    home  => $::openproject::path,
  }
}
