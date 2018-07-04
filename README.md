# Assets generator

Automatically generate resized and optimized iOS and Android images

## Features

From a folder of images, the script automatically generate a properly resized and optimized set of images. The generated `Assets.xcssets` for iOS and `res` folder for Android will be easily pluggable into respective projects.

### Android support for drawable states:

If an image has a `_pressed` prefix, then a `selector_*.xml` drawable is automatically generated. It supports `_activated` and `_selected` prefixes in addition to the pressed state.

## Dependencies

[minimagick](https://github.com/minimagick/minimagick)
```
brew install imagemagick
```

[image_optim](https://github.com/toy/image_optim)
```
brew install advancecomp gifsicle jhead jpegoptim jpeg optipng pngcrush pngquant jonof/kenutils/pngout
brew install svgo
```

## Setup

Assuming the dependencies are installed, install the bundles
```
bundle install
```

## Running
```
./generate.sh [input_folder] [resolution: @3x|@4x]
```

### Output

Output is generated inside the [input_folder] under `iOS` and `Android` folders.

## TODOs
[ ] Instructions to integrate in Xcode project
[ ] Auto-generated swift file to contain easy `UIImage` access
[ ] Gradle integration
