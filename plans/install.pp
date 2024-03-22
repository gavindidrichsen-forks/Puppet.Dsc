# @summary Install the Puppet DSC module on target server
# @param targets The targets to run on.
plan puppet_dsc::install (
  TargetSpec $targets = 'localhost'
) {
  # pass in only the $Name required parameter, i.e., no $UpperCase parameter included
  $options = {
    'pwsh_params' => {
      'Full' => true,
    },
  }
  run_script(
    'puppet_dsc/scripts/install.ps1',
    $targets,
    $options,
  )
}
