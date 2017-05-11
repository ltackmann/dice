// Copyright (c) 2017, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of dice;

/// Used to annotate constructors, methods and fields of your classes where [Injector] should resolve values
const inject = const Inject();
class Inject {
  const Inject();
}

/// Compatibility to di-package
const injectable = const Injectable();
class Injectable {
    const Injectable();
}

/// Used in conjunction with [Inject] to select a specific named target for injection
class Named {
  const Named(this.name);

  final String name;
}
