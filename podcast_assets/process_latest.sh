#!/bin/bash

# Get most recent .mp4 file in the video directory
unset -v latest
for file in video/*.mp4; do
  [[ $file -nt $latest ]] && latest=$file
done

echo $latest
echo "Process this file? (Y/n)"
read confirmation

# Y, y, or enter will confirm; all else will exit
if [ "$confirmation" == "y" ] || [ "$confirmation" == "Y" ] || [ -z "$confirmation" ]; then
	echo "Processing "$latest""
else
	echo "Not what you wanted? touch [filename] to update its timestamp."
	exit 1
fi

# Turn any spaces in filename into underscores
# YouTube's filename will probably have spaces, generated from the
# human-friendly video title.
mv "$latest" "${latest// /_}"

# Get the base filename, without directory or .mp4 extension
filename=$(basename "${latest// /_}" .mp4)

echo "Base filename is "$filename""

# Convert to mp3 and write into audio/ directory
ffmpeg -i video/"${filename}".mp4 -f mp3 -ab 192000 -vn "${filename}".mp3

# Run ruby script to prompt user for episode title and description
# and edit .mp3 metadata accordingly
ruby update_metadata.rb

# Move mp3 into audio/ directory
mv "${filename}".mp3 audio/"${filename}".mp3

# Change current working directory to audio/ so that dropcaster will be happy
cd audio/

# Generate updated RSS feed
dropcaster --channel-template=local_channel_template.html.erb > index.rss

# Push to GitHub
echo "What would you like your git commit message to be?"
read message

git add . ; git commit -m"$message" ; git push origin gh-pages
