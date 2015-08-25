// Copyright (c) 2013-2015, the dice project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

// Modified for d17 by Adam Stark <llamadonica@gmail.com>

part of d17_test;

class MyModule extends Module {
  configure() {
    register(MyClass).toInstance(new MyClass());
    register(MyOtherClass).toBuilder(() => new MyOtherClass());
    register(MyClassToInject);
    register(MyFunction).toFunction(MyFunctionToInject);
    register(MyClassFunction).toFunction(new MyClass().getName);
    register(MyContainer);

    // named
    register(MyClass, "MySpecialClass").toType(MySpecialClass);

    registerAdapter(MyInterface, MyClass);
    registerAdapter(MyInterface, MySpecialClass).toType(MyAdaptor);
  }
}

class YourModule extends Module {
  configure() {
    register(YourClass).toType(YourClass);
  }
}

class MyContainer {
  @InjectAdapter(MyClass, name: "MySpecialClass")
  MyInterface interface;
}

class MyInterface {
  String get name => null;
}

class MyAdaptor extends MyInterface {
  @Inject(name: "MySpecialClass", isAdaptee: true)
  MySpecialClass myClass;

  String get name => '-' + myClass.getName() + '-';
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
  
  @Inject(name: 'MySpecialClass')
  MyClass namedVariableToInject;
  
  @Inject(name: 'MySpecialClass')
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
    // TODO && injections[r'_setterToInject'] != null
    var settersToInject = (injections[r'setterToInject'] != null);
    var settersNotToInject = (injections[r'setterNotToInject'] == null && injections[r'_setterNotToInject'] == null);
    var settersInjected = settersToInject && settersNotToInject;
    
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

class YourClass {
  String getName() => "YourClass";
}

MyFunctionToInject() => "MyFunction";

typedef String MyFunction();
typedef String MyClassFunction();


