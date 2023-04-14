#!/bin/bash

HandleNullArgumentError()
{
    echo "Argument not filled. usage mode: ./HtmlParser.sh [host]"
    echo "Example ./HtmlParser.sh [https://www.fbi.gov/]"
}

declare -a verifiedUrls=()

function verifyIfElementExistsOnArray() {
    local elemento="$1"
    local encontrado=false
    
    for valor in "${@:2}"
    do
        if [ "$valor" == "$elemento" ]; then
            encontrado=true
            break
        fi
    done
    
    [ "$encontrado" = true ] && return 0 || return 1
}

function DoPingOnUrl()
{
    linkReplaced="$(echo "$1" | sed -e 's#^http://##;' | sed -e 's#^https://##;')"
    output="$(ping -c1 $linkReplaced | cut -d " " -z -f3 | tr -d '\0' | sed -e 's/(//' | sed -e 's/)//')"
    echo "$output"
}

function FindHtmlOnPages() {
    local url="$1"
    shift

    for link in $(timeout 5 wget -qO- "$url" | grep "href" | cut -d '"' -f2 | grep http)
    do
        if verifyIfElementExistsOnArray "$link" "${verifiedUrls[@]}"; then
            continue
        else
            strToWrite="Verificando URL: $link - $(DoPingOnUrl $url)"
            echo "$strToWrite"
            WriteInformationsOnFile "$strToWrite"
            verifiedUrls+=("$link")
            FindHtmlOnPages $link "${verifiedUrls[@]}"
        fi
    done
}

WriteInformationsOnFile()
{
    echo $1 >> urls.txt
}

if [ -z "$1" ]
then
    HandleNullArgumentError
else
    FindHtmlOnPages $1
    echo "Finalizado!"
fi
