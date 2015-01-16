$LANG="en"
$I18N = {
  "en" => {
    :usage => "Usage: templater <templater.erb> <data.json>",
    :insufficient_args_error => "Insufficient arguments!\n%s\n",
    :template_load_error => "Could not load template file %s",
    :data_load_error => "Could not load data file %s",
    :data_parse_error => "Error parsing %s; %s",
    :template_error => "You have an error in your ERB template!\n%s",
    :reserved_key_error => "Your template data contains the following invalid keys: %s\n\nDue to technical constraints you may not use any of these keys.\nWe hope to remove this restriction in the future"
  }
}

def _(k)
  $I18N[$LANG][k] || $I18N["en"][k] || k  
end
