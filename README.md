# Animefie

An Android application for animefying all your selfies completely built in Flutter!

## Demo

https://user-images.githubusercontent.com/7613470/143511542-02669f5c-d85c-4727-90e0-6b048123c89c.mp4

## How to Install

I have only tested this on my personal Pixel 3a XL device that is running Android 12, so I can't guarantee it will work on other devices or OS versions. If you have any issues, please let me know!

Here are the steps to install:

1. Make sure you have the latest version of [Flutter installed](https://flutter.dev/docs/get-started/install/). I recommend using the [VS Code extension](https://docs.flutter.dev/development/tools/vs-code) for Flutter as it has a lot of niceties for working with Flutter.
2. Download this repository: `git clone https://github.com/ncoop57/animefie`
3. Navigate to the `animefie` folder in your terminal of choice
4. Connect your device to your computer via USB.
5. Run `flutter run` in the `animefie` folder.

That's it! This should install the app on your device and launch it so that you can start taking selfies! Animefies will be saved to your `Pictures` folder on your device.

## About the Project

This project uses the awesome AnimeGANv2 pytorch model from [@bryandlee](https://github.com/bryandlee/animegan2-pytorch) to generate anime faces from your selfies. The model is hosted using the awesome [HuggingFace Spaces](https://huggingface.co/spaces) API by [@akhaliq](https://huggingface.co/spaces/akhaliq/AnimeGANv2). Thanks to the awesome [gradio](https://www.gradio.app/) library that HuggingFace Spaces allows you to use for hosting a model and allows for an easy to use endpoint that this app takes advantage of. The app it self is written entirely in Dart using the Flutter framework and uses the awesome example flutter camera app project from [@jagrut-18](https://github.com/jagrut-18/flutter_camera_app) and some other amazing people (it is crazy how hard handling things like device orientation for a camera app can be so that the image its saved in the correct orientation).