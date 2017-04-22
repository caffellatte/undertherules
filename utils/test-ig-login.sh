#!/bin/bash

COOKIES='../cookie.txt'
USER_AGENT="Mozilla/5.0"

curl -X GET 'https://www.instagram.com/graphql/query/?query_id=17851374694183129&after=&first=20&id=3033620400' --verbose --user-agent $USER_AGENT --cookie $COOKIES --cookie-jar $COOKIES
