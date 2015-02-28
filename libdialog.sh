#!/bin/bash
# Created by Ricardo Biehl
# License GPL General Public License of GNU

# INFO ->
#  Functions:
#>    define_interface  "shell/dialog/Xdialog"
#>    get  "<text_to_show>"  "<initial_text>"  "<help_text>"
#>    put  "<text_to_show>"  <icon_number>
#>    yesno  "<text_to_show>"  "<help_text>"
#>    menu  "<text_to_show>"  "<menu_list>"
#         *Model to make menu_list:
#           cat << EOF >&1
#               "<return_name>"  "<item_description>"
#               "<return_name>"  "<item_description>"
#           EOF
#           menu "<text_to_show>" $?
# INFO <-

########################################
#FUNCTION TO PUT COLOR TEXT IN TERMINAL#
########################################
cecho(){
  case "$1" in
    "darkblue")
      echo -en "\e[34m$2\e[0m";;
    "green")
      echo -en "\e[32m$2\e[0m";;
    "orange")
      echo -en "\e[33m$2\e[0m";;
    "red")
      echo -en "\e[31m$2\e[0m";;
    "white")
      echo -en "\e[0m$2\e[0m";;
    esac
}

##############################
#FUNCTION TO DEFINE INTERFACE#
##############################
define_interface(){
  case "$1" in
    "dialog")
    INTERFACE="dialog"
    DIALOG="dialog"
    CMDHELP="--hline";;
    "xdialog")
    INTERFACE="xdialog"
    DIALOG="Xdialog"
    CMDHELP="--help";;
    "shell")
    INTERFACE="shell"
    DIALOG="#"
    CMDHELP="#";;
    *)
      echo "ERROR: #001" >/dev/stderr
      exit 1;;
  esac
}
##########################
#FUNCTION TO RECEIVE TEXT#
##########################
get(){
  case "$INTERFACE" in
  "shell")
    clear
    echo -e "*`echo -n "$NAME_CURRENT_WINDOW" | tr [:alnum:] \#`*"
    echo -e "`cecho orange "$NAME_CURRENT_WINDOW"`"
    echo -e "*`echo -n "$NAME_CURRENT_WINDOW" | tr [:alnum:] \#`*"
    
    echo -e "\n\n"
    
    echo -e "[ \e[32m$1\e[0m ]"
    echo -en "\e[32m->\e[0m"
    read retvar;;
  *)
    local text_help
    if [ -z "$3" ]; then
        text_help="No help for it!"
    else
        text_help=$3
    fi
    
    $DIALOG --title "$NAME_CURRENT_WINDOW" \
    $CMDHELP "$text_help" \
    --inputbox "$1" 0 0 "$2" \
    2>$TMP/$REPLY
    case "$?" in
        0)
            retvar="`cat $TMP/$REPLY`";;
        1)
            exit 1;;
        255)
            $CMDX;;
    esac;;
  esac
  
  echo "$retvar"
}
######################
#FUNCTION TO PUT TEXT#
######################
put(){
  case "$INTERFACE" in
  "shell")
    clear
    echo -e "*`echo -n "$NAME_CURRENT_WINDOW" | tr [:alnum:] \#`*"
    echo -e "`cecho orange "$NAME_CURRENT_WINDOW"`"
    echo -e "*`echo -n "$NAME_CURRENT_WINDOW" | tr [:alnum:] \#`*"
    
    echo -e "\n\n"
    
    echo -e "$1"
    echo -e "\n\n"
    echo "[OK] -- press ENTER"
    read;;
  *)
    local ICON
    if [ "$DIALOG" = "Xdialog" ]; then
        case $2 in
            0)
	ICON="--icon ./$ICON_YES";;
            1)
	ICON="--icon ./$ICON_NOT";;
            2)
	ICON="--icon ./$ICON_WARNING";;
        esac
    else
        unset ICON
    fi
    $DIALOG --title "$NAME_CURRENT_WINDOW" \
    $ICON \
    --msgbox "$1" 0 0
    case $? in
        0)
            retvar=0;;
        1)
            retvar=1;;
        255)
            $CMDX;;
    esac;;
  esac
  echo "$retvar";
}
###########################
#FUNCTION TO SELECT YES/NO#
###########################
yesno(){
  case "$INTERFACE" in
    "shell")
      clear
      echo -e "*`echo -n "$NAME_CURRENT_WINDOW" | tr [:alnum:] \#`*"
      echo -e "`cecho orange "$NAME_CURRENT_WINDOW"`"
      echo -e "*`echo -n "$NAME_CURRENT_WINDOW" | tr [:alnum:] \#`*"
      
      echo -e "\n\n"
      echo -e "$1"
      echo -e "\n\n"
      echo "[Yes] -- type 'y'/'Y'"
      echo "[No] -- type 'n'/'N'"
      local answer
      read $answer
      case "$answer" in
        "y"|"Y")
          retvar=0;;
        "n"|"N")
          retvar=1;;
      esac;;
    *)
        $DIALOG --title "$NAME_CURRENT_WINDOW" \
        $CMDHELP "$2" \
        --yesno "$1" 0 0
        status="$?"
        case $status in
                0)
                        retvar=0;;
                1)
                        retvar=1;;
                255)
                        $CMDX;;
        esac;;
  esac
  
  echo "$retvar";
}
#########################
#FUNCTION TO MENU SELECT#
#########################
menu(){
  case "$INTERFACE" in
    "shell")
      clear
      echo -e "*`echo -n "$NAME_CURRENT_WINDOW" | tr [:alnum:] \#`*"
      echo -e "`cecho orange "$NAME_CURRENT_WINDOW"`"
      echo -e "*`echo -n "$NAME_CURRENT_WINDOW" | tr [:alnum:] \#`*"
      
      echo -e "\n\n"
      echo -e "$1"
      echo "- - - - - - - - - - - - - - - - - - - -"
      nl -v0
      ;;
    *)
      $DIALOG --title "$NAME_CURRENT_WINDOW" \
      --menu "$1" 0 0 0 \
      $2 \
      2>$TMP/$REPLY
      status="$?"
      case $status in
        0)
          retvar="`cat $TMP/$REPLY`";;
        1)
          retvar=1;;
        255)
          $CMDX;;
      esac;;
  esac
  
  echo "$retvar";
}

##########

add_replys(){
  count=0
  while [ "$count" != "3" ]; do
    REPLY[$count]="`mktemp -p $TMP`"
    REPLY[$count]="`basename ${REPLY[$count]}`"
    echo >$TMP/${REPLY[$count]};
    count=$((count+1))
  done
}

del_replys(){
  count=0
  while [ "$count" != "3" ]; do
    if [ ! -z "${REPLY[$count]}" ]; then
      rm $TMP/${REPLY[$count]}
      count=$((count+1))
    fi
  done
}

#########
#DEFINES#
#########
NAME_CURRENT_WINDOW="WINDOW"
if [ -z $NAME_SCRIPT ]; then
  CMDX="exit 0"
else
  CMDX="killall $NAME_SCRIPT"
fi
unset retvar

TMP="/tmp"

ICON_YES="/tmp/yes.xpm"
ICON_NOT="/tmp/not.xpm"
ICON_WARNING="/tmp/warning.xpm"

add_replys
############
#DIALOG DEF#
############
if [ -z "$DISPLAY" ]; then
  if [ -x "/usr/bin/dialog" ]; then
    define_interface dialog
  else
    define_interface shell
  fi
else
  if [ -x "/usr/local/bin/Xdialog" ]; then
    define_interface xdialog
  else
    del_replys
    echo "ERROR: #003"
    exit 1
  fi
fi

if [ -x "$1" ]; then
  echo "executing script $1"
  . $1
else
  del_replys
  echo "ERROR: #002"
  exit 1
fi

del_replys
exit
