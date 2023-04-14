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
    ping -c1 $1 | cut -d " " -f3 -z | sed -e 's/(//' | sed -e 's/)//'
}

function FindHtmlOnPages() {
    local url="$1"
    shift

    for link in $(timeout 5 wget -qO- "$url" | grep "href" | cut -d '"' -f2 | grep http)
    do
        if verifyIfElementExistsOnArray "$link" "${verifiedUrls[@]}"; then
            echo "URL já verificada: $link"
        else
            echo "Verificando URL: $link $(DoPingOnUrl $url)"
            verifiedUrls+=("$link")
            FindHtmlOnPages $link "${verifiedUrls[@]}"
        fi
    done
}

WriteInformationsOnFile()
{
    for valor in "${verifiedUrls[@]}"
    do
        echo $valor >> url.txt
    done
}

if [ -z "$1" ]
then
    HandleNullArgumentError
else
    FindHtmlOnPages $1
    WriteInformationsOnFile
    echo "Finalizado"
fi
