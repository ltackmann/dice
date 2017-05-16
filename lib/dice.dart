// Copyright (c) 2017, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

/** Lightweight dependency injection framework for Dart. */
library dice;

@MirrorsUsed(
    metaTargets: const [ Inject, Injectable ],
    symbols: const ['inject', 'injectable', 'Named'])
import 'dart:mirrors';
import 'dart:collection';

import 'package:logging/logging.dart';

part 'src/annotations.dart';
part 'src/assert_messages.dart';
part 'src/injector.dart';
part 'src/mirror_util.dart';
part 'src/module.dart';
part 'src/Registration.dart';
