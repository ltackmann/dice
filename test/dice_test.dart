// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

library dice_test;

import "../lib/dice.dart";
import "package:meta/meta.dart";
import "package:unittest/unittest.dart";

part "test_classes.dart";
part "test_module.dart";

main() {
  group("injector injection", () {
    var injector = new Injector(new MyModule());
    
    test("singleton", () {
      var instance = injector.getInstance(MyClass);
      expect(instance, isNotNull);
      expect(instance.getName(), equals("MyClass"));
      expect(identical(instance, injector.getInstance(MyClass)), isTrue, reason:"must be singleton");
    });
    
    test("instance", () {
      var instance = injector.getInstance(MyOtherClass);
      expect(instance, isNotNull);
      expect(instance.getName(), equals("MyOtherClass"));
      expect(identical(instance, injector.getInstance(MyOtherClass)), isFalse, reason:"must be new instance");
    });
    
    test("function", () {
      var func = injector.getInstance(MyFunction);
      expect(func, isNotNull);
      expect(func(), equals("MyFunction"));
    });
  });
  
  group("annotation injection", () {
    // TODO test annotations
  });
}

