#!/usr/bin/env bash



if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"

    echo
    echo Usage:
    echo $0 "input_PDF owner_password  user_password"

else

    INPUT="$1"
    p1=$2
    p2=$3

    pdftk $INPUT output _out1.pdf owner_pw $p1 user_pw $p2
    echo "The output file is _out1.pdf"

fi


