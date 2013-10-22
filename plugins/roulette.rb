# encoding: utf-8

$last_chamber = -1
$loaded_chamber = rand 6

desc 'roulette', '>roulette', 'Do you wanna live or die?'
hear('roulette', :prefix => '>') do |message, params|
  $last_chamber += 1
  if $loaded_chamber == $last_chamber
    post "*BANG* Hey, who put a blank in here?!"
    $loaded_chamber = rand 6
    $last_chamber = -1
    post "/me reloads and spins the chambers."
  else
    post "*click*"
  end
end
