class openproject::bundle {
  include openproject

  bundle::install { $openproject::path:
    without => 'mysql mysql2 docker development test therubyracer',
    mode    => 'local',
  }
}
