define openproject::plugin (
  $git,
  $branch = undef,
  $directory,
) {
  if $branch {
    $content = "gem '${name}', git: '${git}', branch: '${branch}'\n"
  }
  else {
    $content = "gem '${name}', git: '${git}', tag: CORE_VERSION\n"
  }
  concat::fragment { "${directory}-${name}":
    target  => "${directory}/Gemfile.plugins",
    content => $content,
    order   => '010',
    notify  => Bundle::Install[$directory],
  }
}
