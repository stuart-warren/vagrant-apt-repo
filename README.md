vagrant-apt-repo
================

Vagrant/puppet setup to create a test Ubuntu apt repository using reprepro

# Generate a pair of gpg keys (if you add a passphrase you may need to make changes)
# Set some defauts up in apt_repo::params
# Configure others in base.pp

Currently every hour cron will refresh repository with all debs from $debpath