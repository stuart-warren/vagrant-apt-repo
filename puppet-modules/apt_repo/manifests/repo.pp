# Class: apt_repo
#
#
class apt_repo::repo(
        $gpgpubkey       = $apt_repo::params::gpgpubkey,
        $gpgseckey       = $apt_repo::params::gpgseckey,
        $gpgid           = $apt_repo::params::gpgid,
        $sourceslist     = $apt_repo::params::sourceslist,
        $reponame        = $apt_repo::params::reponame,
        $repodesc        = $apt_repo::params::repodesc,
        $email           = $apt_repo::params::email,
        $debpath         = $apt_repo::params::debpath,
        $customcomponent = $apt_repo::params::customcomponent
    ) inherits apt_repo::params {

    exec { 'apt-get update':
        command => '/usr/bin/apt-get update',
    }

    # Create list of packages
    $packages = [ 'puppet',
                  'reprepro',
                  'vim',
                  'apache2',
                  'dpkg-sig',]

    # Install list of packages above
    package { $packages:
        ensure   => installed,
        require  => [Exec['apt-get update']],
    }

    service { 'apache2':
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      require    => Package['apache2'],
    }

    file { '/root/ubuntu.gpg.key':
        ensure => present,
        source => $gpgpubkey,
    }

    file { '/root/ubuntu.sec.gpg.key':
        ensure => present,
        source => $gpgseckey,
        mode   => '0600',
    }

    exec { 'import pgp key':
        command => '/usr/bin/gpg --import /root/ubuntu.gpg.key',
        creates => '/root/.gnupg/pubring.gpg',
        require => File['/root/ubuntu.gpg.key'],
    }

    exec { 'import secpgp key':
        command => '/usr/bin/gpg --allow-secret-key-import --import /root/ubuntu.sec.gpg.key',
        creates => '/root/.gnupg/secring.gpg',
        require => File['/root/ubuntu.sec.gpg.key'],
    }

    $repodirectories = ['/var/www/repos',
                        '/var/www/repos/apt',
                        '/var/www/repos/apt/ubuntu',
                        '/var/www/repos/apt/debian'
                        ]

    file { $repodirectories:
        ensure  => directory,
        require => [Package['apache2'],
                    Package['reprepro'],
                    Exec['import pgp key'],
                    Exec['import secpgp key']],
    }

    file { 'base repo ubuntu':
        ensure  => directory,
        path    => ['/var/www/repos/apt/ubuntu/conf'],
        require => File['/var/www/repos/apt/ubuntu'],
    }

    file { 'base repo debian':
        ensure  => directory,
        path    => ['/var/www/repos/apt/debian/conf'],
        require => File['/var/www/repos/apt/debian'],
    }

    file { '/etc/apache2/conf.d/repos':
        ensure  => present,
        source  => 'puppet:///modules/apt_repo/repos.conf',
        require => Package['apache2'],
        notify  => Service['apache2'],
    }

    file { '/etc/apache2/sites-available/default':
        ensure  => present,
        content => template('apt_repo/apache2-default.conf.erb'),
        require => Package['apache2'],
        notify  => Service['apache2'],
    }

    file { '/var/www/repos/apt/ubuntu/conf/distributions':
        ensure  => present,
        content => template('apt_repo/ubuntu-distributions.conf.erb'),
        require => File['base repo ubuntu'],
    }

    file { '/var/www/repos/apt/ubuntu/conf/options':
        ensure  => present,
        source  => 'puppet:///modules/apt_repo/ubuntu-options.conf',
        require => File['base repo ubuntu'],
    }

    file { '/var/www/repos/apt/debian/conf/distributions':
        ensure  => present,
        content => template('apt_repo/debian-distributions.conf.erb'),
        require => File['base repo debian'],
    }

    file { '/var/www/repos/apt/debian/conf/options':
        ensure  => present,
        source  => 'puppet:///modules/apt_repo/debian-options.conf',
        require => File['base repo debian'],
    }

    file { '/var/www/repos/apt/index.html':
        ensure  => present,
        content => template('apt_repo/index.html.erb'),
        require => File['base repo ubuntu'],
    }

    exec { 'export public key':
        command  => "/usr/bin/gpg --armor --output /var/www/repos/apt/ubuntu/repo.gpg.key --export $gpgid",
        creates  => '/var/www/repos/apt/ubuntu/repo.gpg.key',
        require  => File['base repo ubuntu'],
    }

    file { '/usr/local/sbin/genpackages.sh':
        ensure  => file,
        content => template('apt_repo/genpackages.sh.erb'),
        mode    => '0755',
    }

    file { '/etc/cron.hourly/genpackages.sh':
        ensure   => link,
        target   => '/usr/local/sbin/genpackages.sh',
        require  => File['/usr/local/sbin/genpackages.sh'],
    }

}
