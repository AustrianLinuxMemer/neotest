#!/bin/bash
image_path=$1
width=$2
height=$3
if [[ -z $image_path || -z $width ]]; then
    echo "Usage: $0 <image_path> width [height]"
    exit 1
else
    if [[ ! $width =~ ^[0-9]+$ || ! $height =~ ^[0-9]+$ ]]; then
        echo "width/height must be numbers"
        exit 1
    fi
    if [[ -z $height ]]; then
        head -c $(("$width"*"$width")) /dev/urandom | ffmpeg -f rawvideo -pixel_format gray -video_size "$width"x"$width" -i - -frames:v 1 "$image_path"
    else
        head -c $(("$width"*"$height")) /dev/urandom | ffmpeg -f rawvideo -pixel_format gray -video_size "$width"x"$height" -i - -frames:v 1 "$image_path"
    fi
fi


