class repose_idea(
  $version = '2018.2.5',
  $build = '182.4892.20',
  $base_url = 'https://download.jetbrains.com/idea',
) {

  #downloads and explodes the given version
  archive{ "idea-$version":
    ensure          => present,
    path            => "/tmp/ideaIU-${version}.tar.gz",
    extract         => true,
    extract_path    => '/opt',
    creates         => "/opt/idea-IU-${build}",
    source          => "${base_url}/ideaIU-${version}.tar.gz",
    checksum_verify => false,
  }

  #links it for conveince
  file {'idea-symlink':
    path    => '/opt/idea',
    ensure  => link,
    target  => "/opt/idea-IU-${build}",
    require => Archive["idea-${version}"]
  }

  #adds it to the path
  file {'/etc/profile.d/append-idea-path.sh':
    mode    => '0644',
    content => 'PATH=$PATH:/opt/idea/bin',
    require => File['idea-symlink'],
  }
}
