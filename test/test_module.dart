// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice_test;

class MyModule extends Module {
  configure() {
    bind(MyClass).toInstance(new MyClass());
    bind(MyOtherClass).toBuilder(() => new MyOtherClass());
    // TODO bind(MyFunction).toFunction(_myFunction);
    bind(MyClassToInject).toType(MyClassToInject);
  }
  
  String _myFunction() => "MyFunction";
}

class MyClassToInject {
  // constructors
  @Inject
  MyClassToInject.inject(MyClass constructorParameterToInject) {
    injections["constructorParameterToInject"] = constructorParameterToInject;
  }
  
  // setters
  @Inject
  set setterToInject(MyClass setterToInject) => injections["setterToInject"] = setterToInject;
  
  //@Inject
  //set _setterToInject(MyClass setterToInject) => injections["_setterToInject"] = setterToInject;
 
  set setterNotToInject(MyClass setterNotToInject) => injections["setterNotToInject"] = setterNotToInject;
  set _setterNotToInject(MyClass setterNotToInject) => injections["_setterNotToInject"] = setterNotToInject;
  
  // TODO named setter injection
  
  // instance variables
  @Inject
  MyClass variableToInject;
  
  @Inject
  MyOtherClass _variableToInject;
  
  MyClass variableNotToInject;
  MyOtherClass _variableNotToInject;
  
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

class MySpecialClass implements MyClass {
  String getName() => "MySpecialClass";
}

typedef String MyFunction();


