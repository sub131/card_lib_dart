<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

Card Library written in Dart for a customizable deck of cards. Standard 52
card deck can be generated, as well as a non-standard decks that could 
include different groups, different values, battle cards, etc.

## Features

Create a custom named deck or use the defaults provided

## Getting started

Install VSCode and Flutter extension, run Flutter Doctor.

## Usage

```dart
import 'package:wwwy/game.dart';
import 'package:wwwy/card.dart';

var cardDeck = DefaultCardDeck();
var deck = cardDeck.createDeck();
```

## Additional information

See GitHub site [card_lib_dart](https://github.com/sub131/card_lib_dart) for more information

## License 

This project is licensed under the terms of the MIT license.