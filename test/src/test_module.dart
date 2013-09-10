// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice_test;

class MyModule extends Module {
  configure() {
    bind(MyClass).toInstance(new MyClass());
    bind(MyOtherClass).toBuilder(() => new MyOtherClass());
    bind(MyClassToInject).toType(MyClassToInject);
    
    // named
    namedBind(MyClass, "MySpecialClass").toType(MySpecialClass);
  }
}

class MyClassToInject {
  // constructors
  @inject
  MyClassToInject.inject(MyClass constructorParameterToInject) {
    injections["constructorParameterToInject"] = constructorParameterToInject;
  }
  
  // setters
  @inject
  set setterToInject(MyClass setterToInject) => injections["setterToInject"] = setterToInject;
  
  @inject
  set _setterToInject(MyClass setterToInject) => injections["_setterToInject"] = setterToInject;
 
  set setterNotToInject(MyClass setterNotToInject) => injections["setterNotToInject"] = setterNotToInject;
  set _setterNotToInject(MyClass setterNotToInject) => injections["_setterNotToInject"] = setterNotToInject;
  
  // TODO named setter injection
  
  // instance variables
  @inject
  MyClass variableToInject;
  
  @inject
  MyOtherClass _variableToInject;
  
  MyClass variableNotToInject;
  MyOtherClass _variableNotToInject;
  
  @inject
  @Named("MySpecialClass")
  MyClass namedVariableToInject;
  
  @inject
  @Named("MySpecialClass")
  MyClass _namedVariableToInject;
  
  // Map to trace injections from setters or constructors
  Map injections = new Map();
  
  bool assertInjections() {
    // constructors
    var constructorsInjected = (injections[r'constructorParameterToInject'] != null);
    
    // variables
    var variablesToInject = (variableToInject != null && _variableToInject != null);
    var variablesNotToInject = (variableNotToInject == null && _variableNotToInject == null);
    var variablesInjected = variablesToInject && variablesNotToInject;
    
    // setters
    var settersToInject = (injections[r'setterToInject'] != null && injections[r'_setterToInject'] != null);
    var settersNotToInject = (injections[r'setterNotToInject'] == null && injections[r'_setterNotToInject'] == null);
    var settersInjected = settersToInject && settersNotToInject;
    
    // named
    return constructorsInjected && variablesInjected && settersInjected;
  }
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


