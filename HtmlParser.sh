#!/bin/bash


HandleNullArgumentError()
{
    echo "Argument dont filled usage mode: ./HtmlParser.sh [host]"
    echo "Example ./HtmlParser.sh https://www.fbi.com.br"
}

FindHtmlOnPage()
{
   wget -q0- $1 | grep "href" | cut -d '"' -f2 | grep https | grep http
}


if[ $1 -z ] then
    HandleNullArgumentError
fi
