#!/bin/bash

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

cd /home/jabbot/kruemel

# Load secret keys and password.
. env.sh

exec ruby -Ijabbot/lib tweeps.rb
