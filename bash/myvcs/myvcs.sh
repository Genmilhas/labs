#!/bin/bash
file=$2
function init {
    if [ -r $file ]
    then
        if [ -a .$file ]
        then
            if [ -d .$file ]
            then
                echo "Repo already exists"
            else
                echo "File named .$2 exists"
            fi
        else
            mkdir .$file
            echo "Creating zero revision"
            echo "0" > ".$file/count"
        fi
    else
        echo "$file doesn't exist"
    fi
}
function check {
    if [ ! -r $file ]
    then
        echo "$file doesn't exist"
        exit 1
    fi
 
    if [ ! -d ".$file" ]
    then
        echo "Repo doesn't exist"
        exit 2
    fi
 
    if [ ! -r ".$file/count" ]
    then
        echo "Repo is broken"
        exit 3
    fi
}
function commit {
    check
   
    count=`cat .$file/count`
    let "count=count+1"
    echo "$count" > ".$file/count"

    if [ $count -eq 1 ]
    then
        cp $file  ".$file/HEAD"
        exit
    fi
    
    diff -u ".$file/HEAD" "$file" > ".$file/$count"
    cp $file ".$file/HEAD"
}
function status {
    check
   
    if [ cmp -s $file ".$file/HEAD" ]
    then
        echo "Status: modified"
        exit 1
    else
        echo "Status: stable"
        exit 2
    fi
}
function difference {
    check
   
    diff -u $file ".$file/HEAD"
}
 
function update {
    check
    
    cp ".$file/HEAD" $file 
    revision=$1
    count=`cat .$file/count`
    if [ $revision -gt $count ]  || [ 1 -gt $revision ]
    then
        echo "Wrong revision number"
        exit
    fi
    i=$count

    while [ $i -gt $revision ]
    do
        if [ ! -r ".$file/$i" ]
        then
            echo "Repo is broken"
            exit
        fi
        patch -uR $file ".$file/$i"
        echo "Updated"
        let "i=i-1"
    done
}
case $1 in
    'init')
        echo "Init called"
        init
        ;;
    "commit")
        echo "Commit called"
        commit
        ;;
    "status")
        echo "Status called"
        status
        ;;
    "diff")  
        echo "Diff called"
        difference
        ;;
    "update")
        echo "Update called"
        update $3
        ;;
    *)  
        echo "Incorrect command"
        ;;
esac
