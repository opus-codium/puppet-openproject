class openproject::bundle {
  include openproject

  bundle::install { $openproject::path:
    without => [
      'development',
      'docker',
      'mysql',
      'mysql2',
      'test',
      'therubyracer',
    ],
  }
}
