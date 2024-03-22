# @summary Verify connection to windows running a simple powershell script
# @param targets The targets to run on.
plan puppet_dsc::verify_connection (
  TargetSpec $targets = 'localhost'
) {
  # pass in only the $Name required parameter, i.e., no $UpperCase parameter included
  $options = {
    'pwsh_params' => {
      'Name' => 'Bobby',
      'Verbose' => true,
    },
    '_run_as' => 'user',
  }
  run_script(
    'puppet_dsc/scripts/sanity_test/print_some_input_parameters.ps1',
    $targets,
    $options,
  )
}
