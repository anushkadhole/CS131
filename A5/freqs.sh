#!/usr/bin/env bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 tweets.tsv network.txt"
    exit 1
fi

tweets="$1"
network="$2"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

LC_ALL=C awk '{print $2}' "$network" | sort -u > "$tmpdir/users"

printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
"hashtag_H" \
"user(userB ID in subgraphB network)" \
"relative_frequency_H_in_subgraphB" \
"frequency_H_in_subgraphB" \
"frequency_H_overall" \
"count_H_in_subgraphB" \
"count_tweets_in_subgraphB" \
"count_H_entire_dataset" \
"count_tweets_entire_dataset"

LC_ALL=C awk -F '\t' -v userfile="$tmpdir/users" '
BEGIN {
    while ((getline u < userfile) > 0)
        wanted[u] = 1
    close(userfile)
}
{
    userB = $2
    total_tweets++

    tag_count = split($4, tags, ",")

    for (i = 1; i <= tag_count; i++) {
        tag = tags[i]
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", tag)
            gsub(/^"|"$/, "", tag)
        if (tag != "")
            overall[tag]++
    }

    if (userB in wanted) {
        subgraph_tweets[userB]++

        for (i = 1; i <= tag_count; i++) {
            tag = tags[i]
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", tag)
            gsub(/^"|"$/, "", tag)
            if (tag != "")
                subgraph_count[userB SUBSEP tag]++
        }
    }
}
END {
    for (key in subgraph_count) {
        split(key, parts, SUBSEP)

        userB = parts[1]
        tag = parts[2]

        count_subgraph = subgraph_count[key]
        tweets_subgraph = subgraph_tweets[userB]
        count_overall = overall[tag]
        tweets_overall = total_tweets

        frequency_subgraph = count_subgraph / tweets_subgraph
        frequency_overall = count_overall / tweets_overall
        relative_frequency = frequency_subgraph / frequency_overall

        printf "%s\t%s\t%.12g\t%.12g\t%.12g\t%d\t%d\t%d\t%d\n", \
            tag, userB, relative_frequency, frequency_subgraph, \
            frequency_overall, count_subgraph, tweets_subgraph, \
            count_overall, tweets_overall
    }
}
' "$tweets" "$network" |
LC_ALL=C sort -t "$(printf '\t')" -k3,3nr -k1,1 -k2,2
