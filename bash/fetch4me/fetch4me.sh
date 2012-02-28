#!/bin/bash -e

USAGE_INFO="Usage: fetch4me [-w <dir>] [-r <referer>] (<url>)*"
trap "exit" SIGHUP


DIR=`echo ~`
QQEDIR=$DIR/.fetch4me
GETELEMFUNC="wget"
if [ -f "~/.fetch4merc" ]
then
    if [ -r "~/.fetch4merc" ]
    then
        echo "sourced"
        source ~/.fetch4merc
    fi
else
    echo "QQEDIR=""" > ~/.fetch4merc
    echo "GETELEMFUNC="wget"" > ~/.fetch4merc
fi

REFERAL=""
std=0
URL=( )
daemon=0

parseURLs()
{
    for ur in ${URL[@]}
    do
        ffile="$ur_$REFERAL"
        echo -n "$ur|$REFERAL" > "$ffile.req"
    done
}

while getopts ":w:r:d" optname
do
    case $optname in
    "w")
        echo "Directory changed to $OPTARG"
        QQEDIR=$OPTARG
        ;;
    "r")
        echo "Referal set to $OPTARG"
        REFERAL=$OPTARG
        ;;
    "d")
        echo "Daemonization"
        daemon=1
        ;;
    esac
done

while getopts ":" url
do
    URL=( "${URL[@]}" "$url" )
done

##
if [ $daemon -eq 1 ]
then
    echo "Daemon Directory: $QQEDIR"
    mkdir -p $QQEDIR
    
    touch "$QQEDIR/.daemon.pid"    
    echo -n "$$" > "$QQEDIR/.daemon.pid"    
    
    if [ -f "$QQEDIR/.queue" ]
    then
        if [ -r "$QQEDIR/.queue" ]
        then
            while read line
            do
                declare -i pos=`expr index "$line" "|"`
                dlrURLs=( "${dlrURLs[@]}" "${line:0:$[pos - 1]}" )
                dlrREFs=( "${dlrREFs[@]}" "${line:$pos}" )
            done < "$QQEDIR/.queue"
        fi
    fi
    
    cur=0
    count=${#dlURLs[@]}
    
    while true
    do
        if ls "$QQEDIR" | grep ".req$" >/dev/null 2>&1
        then
            reqLIST=`ls "$QQEDIR" | grep ".req$"`
            for req in $reqLIST
            do
                reqq=`cat "$qqedir/$drf"`
                echo "$reqq" >> "$QQEDIR/.queue"
                rm "$QQEDIR/$req"
                declare -i splitPos=`expr index "$drfContent" "|"`
                dlURLs[$count]=${drfContent:0:$[splitPos - 1]}
                dlRefs[$count]=${drfContent:$splitPos}
            done
        fi
        
        if [ $cur -lt $count ]
        then
            curREF=${dlrREFs[$cur]}
            curURL=${dlrURLs[$cur]}
            
            mkdir -p "$DIR/Downloads/fetched4you/${curRef//"/"/_}"
            
            #.status goes here
            
            #.status ends here
            $GETELEMFUNC -O "$DIRDownloads/fetched4you/${curREF//"/"/_}/${curURL//"/"/_}" -c --referer="$curREF" "$curURL" >/dev/null 2>&1
            
            time=`date +%s`
            echo "$time $curREF $curURL" >> "$QQEDIR/.finished"
            
            f=0
            echo -n "" > "$QQEDIR/.queue_tmp"
            while read line
            do
                if [ $f -e 0 ]
                then
                    f=1
                else
                    echo "$line" >> "$QQEDIR/.queue_tmp"
                fi
            done < "$qqedir/.queue"
            
            $cur=$[cur+1]
        fi
        
        sleep 5
    done
    echo "wtf??"
fi
##


PID="none"

if [ -f "$QQEDIR/.daemon.pid" ]
then
    if [ -r "$QQEDIR/.daemon.pid" ]
    then
        PID=`cat "$QQEDIR/.daemon.pid"`
    fi
fi


if ps | grep "^$PID$" >/dev/null 2>&1
then
    if [ ${$URL} -eq 0 ]
    then
        #no urls given error
        exit 1
    fi

    parseURLs
else
    parseURLs
    echo "Launching daemon, daemon state $daemon"
    ./fetch4me.sh -d -w "$QQEDIR"&
fi

exit 0

