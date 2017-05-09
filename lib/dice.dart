// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

/** Lightweight dependency injection framework for Dart. */
library dice;

@MirrorsUsed(
    metaTargets: const [ Inject ],
    symbols: const ['inject', 'Named'])
import 'dart:mirrors';
import 'dart:collection';

part 'src/annotations.dart';
part 'src/Registration.dart';
part 'src/injector.dart';
part 'src/mirror_util.dart';
part 'src/module.dart';
