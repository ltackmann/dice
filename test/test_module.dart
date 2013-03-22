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
  }
  
  String _myFunction() => "MyFunction";
}

class MyClass {
  String getName() => "MyClass";
}

class MyOtherClass {
  String getName() => "MyOtherClass";
}

typedef String MyFunction();


