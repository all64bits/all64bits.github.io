#!/usr/bin/env bash

# Build a website using Hugo, using markdown content provided via an external
# repo.
# Dependencies:
# - Hugo
# - yq (snap package)

content_repo="$1"
content_repo_checkempty="true"

rm -rf "./content/post"
mkdir -p "./content/post"

# Recurse through content_repo and for all *.md files which contain
# 'public: true', but not 'private: true' in the yaml front matter, then copy
# to website content.
shopt -s globstar nullglob
for file in "$content_repo"/**/*.md
do
  if yq '.public == true' "$file" --front-matter=extract | grep -q true && \
    yq '.private == true' "$file" --front-matter=extract | grep -q false
  then
    echo "Found post: $(basename "$file")"
    post_title="$(yq '.title' "$file" --front-matter=extract)"
    zkid="$(yq '.zk_number' "$file" --front-matter=extract)"
    sed -i "/# $post_title/d" "$file"
    if [ "$zkid" == '3' ]; then
    cp "$file" "./content/3.md"
    else
    cp "$file" "./content/post/$zkid.md"
    fi
    content_repo_checkempty="false"
  fi
done

if [ "$content_repo_checkempty" == "false" ]; then

  hugo server -D --baseUrl="100.122.119.29" --bind="0.0.0.0"
fi
