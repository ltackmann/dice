// Copyright (c) 2013-2015, the dice project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

// Modified for d17 by Adam Stark <llamadonica@gmail.com>

part of d17;

/** Used to annotate constructors, methods and fields of your classes where [Injector] should resolve values */

abstract class NameableInject {
  String get name;
}

const inject = const Inject();
class Inject implements NameableInject {
  const Inject({String this.name, bool this.isAdaptee: false});

  final String name;
  final bool isAdaptee;
}

class InjectAdapter implements NameableInject {
  const InjectAdapter(Type this.adapteeType, {String this.name, String this.adapterName});

  final String name;
  final Type adapteeType;
  final String adapterName;
}
