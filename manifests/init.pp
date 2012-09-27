class phantomjs($version = "1.7.0" ) {

    if $::architecture == "amd64" or $::architecture == "x86_64" {
        $platid = "x86_64"
    } else {
        $platid = "x86"
    }

    $suffix = "${version}-linux-${platid}"
    $filename = "phantomjs-${suffix}.tar.bz2"
    $phantom_src_path = "/usr/local/src/phantomjs-${version}/"
    $phantom_bin_path = "/opt/phantomjs/"

    file { $phantom_src_path : ensure => directory }

    exec { "download-${filename}" :
        command => "/usr/bin/wget https://phantomjs.googlecode.com/files/${filename} -O ${filename}",
        cwd => $phantom_src_path,
        creates => "${phantom_src_path}${filename}",
        require => File[$phantom_src_path]
    }

    exec { "extract-${filename}" :
        command     => "/bin/tar xvf ${filename} -C /opt/",
        creates     => "/opt/phantomjs-${suffix}/",
        cwd         => $phantom_src_path,
        require     => Exec["download-${filename}"],
    }

    file { "/opt/phantomjs" :
        target  => "/opt/phantomjs-${suffix}",
        ensure  => link,
        require => Exec["extract-${filename}"],
    }

    file { "/usr/local/bin/phantomjs" :
        target => "${phantom_bin_path}/bin/phantomjs",
        ensure => link,
        require     => File["/opt/phantomjs"],
    }

    exec { "nuke-old-version-on-upgrade" :
        command => "/bin/rm -Rf /opt/phantomjs /usr/local/bin/phantomjs",
        unless => "/usr/bin/test -f /usr/local/bin/phantomjs && /usr/local/bin/phantomjs --version | grep ${version}",
        # Commented out because it causes a cyclic dependency
        # before => Exec["download-${filename}"]
    }
}

