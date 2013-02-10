# Class: apt-repo::params
#
#
class apt_repo::params {
    # resources
    # Path to signing keys
    $gpgpubkey       = 'puppet:///modules/apt_repo/key/ubuntu.gpg.key'
    $gpgseckey       = 'puppet:///modules/apt_repo/key/ubuntu.sec.gpg.key'
    # ID of GPG key used for signing
    $gpgid           = 'XXXXXXXX'
    # Path to sources.list file client should create
    $sourceslist    = '/etc/apt/sources.list.d/custom.sources.list'
    # Name of repo (index.html)
    $reponame        = 'Custom'
    $repodesc        = 'Apt repository for Custom'
    # Repo support email
    $email           = 'custom@custom.com'
    # Path to packages to sign
    $debpath         = '/vagrant_packages/'
    # Name of custom debian component to add packages to 
    $customcomponent = 'custom'

## See http://docs.puppetlabs.com/guides/parameterized_classes.html
#   $packages = $operatingsystem ? {
#      /(?i-mx:ubuntu|debian)/        => 'apache2',
#      /(?i-mx:centos|fedora|redhat)/ => 'httpd',
#   }
}