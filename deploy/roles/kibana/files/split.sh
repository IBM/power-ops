rm -rf import
for i in dashboards visualizations searches; do
  mkdir -p import/$i
  jq -cr 'keys[] as $k | "\($k)\n\(.[$k]._source)"' $i.json | while read -r key; do
    fname=$(jq --raw-output ".[$key]._id" $i.json)
    read -r item
    echo "$item" | jq '' > "import/$i/$fname.json"
  done
done
