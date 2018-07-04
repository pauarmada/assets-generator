#! /bin/bash

# Let's exit on errors
set -e

CYAN='\033[1;36m'
RED='\033[1;31m'
LIGHTGRAY='\033[0;37m'
NC='\033[0m' # No Color

src=$1
resolution=$2

if [[ $# -eq 0 ]] ; then
    echo -e "${RED}Usage: ${LIGHTGRAY}$0 [input_folder] [resolution: @3x|@4x]${NC}"
    echo "       input_folder   Source folder for the images."
    echo "       resolution     Input resolution of the source images. Images will be resized based on this setting."
    exit 1
fi

if [ ! -d "$src" ]; then
    echo -e "${RED}Invalid folder: ${LIGHTGRAY}$src folder does not exist${NC}"
    exit 1
fi

if [ "$resolution" = "@3x" ]; then
    multiplier=4
    divider=3
elif [ "$resolution" = "@3x" ]; then
    multiplier=1
    divider=1
else
    echo -e "${RED}Invalid parameter: ${LIGHTGRAY}Please enter '@3x' or '@4x' for the resolution${NC}"
    exit 1
fi

ios=$src/iOS/Assets.xcassets
android=$src/Android/

# Generate iOS folders
rm -rf $ios
mkdir -p $ios

# Generate Android folders
rm -rf $android
mkdir -p $android

drawable=$android/res/drawable
drawable_hdpi=$android/res/drawable-hdpi
drawable_xhdpi=$android/res/drawable-xhdpi
drawable_xxhdpi=$android/res/drawable-xxhdpi

mkdir -p $drawable
mkdir -p $drawable_hdpi
mkdir -p $drawable_xhdpi
mkdir -p $drawable_xxhdpi

echo ""
echo -e "${CYAN}Generating Folders${NC}"
for img in $src/*.png;
do
    echo ""
    echo -e "${LIGHTGRAY}Converting $img${NC}"
    filename=${img##*/}
    file=${filename%.*}
    ext=${filename##*.}

    # iOS

    iosFolder=$ios/$file.imageset/
    json=$iosFolder/Contents.json
    filename2x=$iosFolder/$file@2x.$ext
    filename3x=$iosFolder/$file@3x.$ext

    mkdir $iosFolder
    bundle exec convert $img -resize $(( multiplier * 50 / divider ))% $filename2x
    bundle exec convert $img -resize $(( multiplier * 75 / divider ))% $filename3x

    echo "{" > $json
    echo "  \"images\" : [" >> $json
    echo "    {" >> $json
    echo "      \"idiom\" : \"universal\"," >> $json
    echo "      \"filename\" : \"$file@2x.$ext\"," >> $json
    echo "      \"scale\" : \"2x\"" >> $json
    echo "    }," >> $json
    echo "    {" >> $json
    echo "      \"idiom\" : \"universal\"," >> $json
    echo "      \"filename\" : \"$file@3x.$ext\"," >> $json
    echo "      \"scale\" : \"3x\"," >> $json
    echo "    }" >> $json
    echo "  ]," >> $json
    echo "  \"info\" : {" >> $json
    echo "    \"version\" : 1," >> $json
    echo "    \"author\" : \"xcode\"" >> $json
    echo "  }," >> $json
    echo "}" >> $json

    echo -e "Generated $file.imageset"

    ## Android

    pressedIcon=$file
    pressedIcon+="_pressed"

    pressed=$pressedIcon
    pressed+="."
    pressed+=$ext

    bundle exec convert $img -resize $(( multiplier * 50 / divider ))% $drawable_hdpi/$filename
    bundle exec convert $img -resize $(( multiplier * 75 / divider ))% $drawable_xhdpi/$filename
    bundle exec convert $img -resize $(( multiplier * 100 / divider ))% $drawable_xxhdpi/$filename

    if [ -f "$src/$pressed" ]; then
      echo "<?xml version=\"1.0\" encoding=\"utf-8\"?>" > $drawable/selector_$file.xml
      echo "<selector xmlns:android=\"http://schemas.android.com/apk/res/android\">" >> $drawable/selector_$file.xml
      echo "    <item android:state_pressed=\"true\" android:drawable=\"@drawable/$pressedIcon\"/>" >> $drawable/selector_$file.xml

      activatedIcon=$file
      activatedIcon+="_activated"

      activated=$activatedIcon
      activated+="."
      activated+=$ext

      if [ -f "$src/$activated" ]; then
        echo "    <item android:state_activated=\"true\" android:drawable=\"@drawable/$activatedIcon\"/>" >> $drawable/selector_$file.xml
      fi

      selectedIcon=$file
      selectedIcon+="_selected"

      selected=$selectedIcon
      selected+="."
      selected+=$ext

      if [ -f "$src/$selected" ]; then
        echo "    <item android:state_selected=\"true\" android:drawable=\"@drawable/$selectedIcon\"/>" >> $drawable/selector_$file.xml
      fi

      echo "    <item android:drawable=\"@drawable/$file\"/>" >> $drawable/selector_$file.xml
      echo "</selector>" >> $drawable/selector_$file.xml
    fi

    echo -e "Generated Android drawables"
done

echo ""
echo -e "${CYAN}Optimizing images${NC}"
bundle exec image_optim "$ios" --recursive
bundle exec image_optim "$android" --recursive