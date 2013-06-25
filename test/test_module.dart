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
  MyClassToInject.inject(this.variableToInject);
  MyClassToInject.notInject(this.variableToInject, int other);
  MyClassToInject.injectComplex(this.variableToInject, @Inject MyClass injectableParameter, {@Inject MyOtherClass optionalInject});
  
  set setterParameterToInject(@Inject MyClass setterParameterToInject) => injections["setterParameterToInject"] = setterParameterToInject;
  set _setterParameterToInject(@Inject MyClass setterParameterToInject) => injections["_setterParameterToInject"] = setterParameterToInject;
  
  @Inject
  set setterToInject(MyClass setterToInject) => injections["setterToInject"] = setterToInject;
  @Inject
  set _setterToInject(MyClass setterToInject) => injections["_setterToInject"] = setterToInject;
 
  set setterNotToInject(MyClass setterNotToInject) => injections["setterNotToInject"] = setterNotToInject;
  set _setterNotToInject(MyClass setterNotToInject) => injections["_setterNotToInject"] = setterNotToInject;
  
  MyClass variableNotToInject;
  MyOtherClass _variableNotToInject;
  
  @Inject
  MyClass variableToInject;
  @Inject
  MyOtherClass _variableToInject;
  
  @Inject
  @Named("MySpecialClass")
  MyClass namedVariableToInject;
  @Inject
  @Named("MySpecialClass")
  MyClass _namedVariableToInject;
  
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


