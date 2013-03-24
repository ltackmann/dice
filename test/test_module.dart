// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice_test;

class MyModule extends Module {
  configure() {
    bind(MyClass).toInstance(new MyClass());
    bind(MyOtherClass).toBuilder(() => new MyOtherClass());
    bind(MyFunction).toFunction(_myFunction);
    bind(MyClassToInject).toType(new MyClassToInject());
  }
  
  String _myFunction() => "MyFunction";
}

class MyClassToInject {
  MyClassToInject();
  MyClassToInject.inject(this.$variableToInject);
  MyClassToInject.notInject(this.$variableToInject, int other);
  MyClassToInject.injectComplex(this.$variableToInject, MyClass $injectableParameter, {MyOtherClass $optionalInject});
  
  set setterParameterToInject(MyClass $setterParameterToInject) => injections["setterParameterToInject"] = $setterParameterToInject;
  set _setterParameterToInject(MyClass $setterParameterToInject) => injections["_setterParameterToInject"] = $setterParameterToInject;
  
  set $setterToInject(MyClass setterToInject) => injections[r"$setterToInject"] = setterToInject;
  set _$setterToInject(MyClass setterToInject) => injections[r"_$setterToInject"] = setterToInject;
 
  set setterNotToInject(MyClass setterNotToInject) => injections["setterNotToInject"] = setterNotToInject;
  set _setterNotToInject(MyClass setterNotToInject) => injections["_setterNotToInject"] = setterNotToInject;
  
  MyClass variableNotToInject;
  MyOtherClass _variableNotToInject;
  MyClass $variableToInject;
  MyOtherClass _$variableToInject;
  // Map to trace injections from setters or constructors
  Map injections = new Map();
}

class MyClass {
  String getName() => "MyClass";
}

class MyOtherClass {
  String getName() => "MyOtherClass";
}

typedef String MyFunction();


