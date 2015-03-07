#!/bin/bash
#define_interface shell
get "Put your name:" "" "Can you put your name in the text box?"
name="$retvar"
yesno "Your name is $name?"
if [ $retvar = 0 ]; then
  put "Name defined as $name" 0
else
  put "Name isn't defined" 3
  exit
fi

menu "How print" <<EOF
"orange" "Print in orange `cecho orange "$name"`"
"blue" "Print in blue `cecho darkblue "$name"`"
EOF

case "$retvar" in
  0)
    cecho orange "\n$name\n";;
  1)
    cecho darkblue "\n$name\n";;
esac

exit
