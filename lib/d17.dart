// Copyright (c) 2013-2015, the dice project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

// Modified for d17 by Adam Stark <llamadonica@gmail.com>

/** Lightweight dependency injection framework for Dart. */
library d17;

@MirrorsUsed(symbols: const ['inject', 'Inject', 'InjectAdapter'])
import 'dart:mirrors';
import 'dart:collection';

part 'src/annotations.dart';
part 'src/Registration.dart';
part 'src/injector.dart';
part 'src/mirror_util.dart';
part 'src/module.dart';
