// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice_test;

// TODO move to example folder and make bigger unit test (check guice)
class MyModule extends Module {
  @override 
  configure() {
    bind(MyClass).toInstance(new MyClass());
    bind(MyOtherClass).toBuilder(() => new MyOtherClass());
    bind(MyFunction).toInstance(_myFunction);
    bind(MyClassToInject).toClassMirror(reflect(new MyClassToInject()).type);
  }
  
  String _myFunction() => "MyFunction";
}

class MyClass {
  String getName() => "MyClass";
}

class MyOtherClass {
  String getName() => "MyOtherClass";
}

class MyClassToInject {
  // Map to trace injections from setters or constructors
  Map injections = new Map();
  
  MyClass variableNotToInject;
  MyClass _variableNotToInject;
  MyClass $variableToInject;
  MyClass _$variableToInject;
  
  MyClassToInject();
  MyClassToInject.inject(this.$variableToInject);
  MyClassToInject.notInject(this.$variableToInject, int other);
  MyClassToInject.injectComplex(this.$variableToInject, MyClass $injectableParameter, {MyClass $optionalInject});
  
  set setterToInject(MyClass $setterToInject) => injections['setterToInject'] = $setterToInject;
  set _setterToInject(MyClass $setterToInject) => injections['_setterToInject'] = $setterToInject;
  set $setterToInject(MyClass setterToInject) => injections['\$setterToInject'] = setterToInject;
  set _$setterToInject(MyClass setterToInject) => injections['_\$setterToInject'] = setterToInject;
  set setterNotToInject(MyClass setterNotToInject) => injections['setterNotToInject'] = setterNotToInject;
  set _setterNotToInject(MyClass setterNotToInject) => injections['_setterNotToInject'] = setterNotToInject;
}

typedef String MyFunction();


