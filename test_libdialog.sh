#!/bin/bash

get "Put your name:" "" "Can you put your name in the text box?"
name="$retvar"
yesno "Your name is $name?"
if [ $retvar = 0 ]; then
  put "Name defined as $name" 0
else
  put "Name isn't defined" 3
fi
