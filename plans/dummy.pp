# @summary A plan created with bolt plan new.
# @param targets The targets to run on.
plan puppet_dsc::dummy (
  TargetSpec $targets = 'localhost'
) {
  apply_prep($targets)
  apply($targets) {
    dsc_psrepository { 'Trust PSGallery':
      dsc_name               => 'PSGallery',
      dsc_ensure             => 'Present',
      dsc_installationpolicy => 'Trusted',
    }

    dsc_psmodule { 'Install BurntToast for notifications':
      dsc_name   => 'BurntToast',
      dsc_ensure => 'Present',
    }
  }
}
