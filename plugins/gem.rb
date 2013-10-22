# encoding: utf-8

gem_activated = false

# Yes, it makes no sense, but I want have it anyway. For more Spass am Geraet!
desc 'gem', '>gem', 'The chat gem is working as intended.'
hear 'gem', :prefix => '>' do |message, params|
  if gem_activated
    post 'Gem Deactivated'
  else
    scr = rand 100

    if scr >= 99
      post 'Perfect Gem Activated'
    elsif scr >= 90
      post 'Moooooooo!'
    else
      post 'Gem Activated'
    end
  end
  gem_activated = !gem_activated
end
