stage { 'repos':
  before => Stage['main'],
}

class { [
  'dc_profile::apt::apt',
  'dc_profile::apt::dpkg',
  'dc_profile::apt::repos',
  'dc_profile::auth::rootpw',
]:
  stage => 'repos',
}

contain dc_profile::mon::icinga_client
contain dc_profile::util::external_facts