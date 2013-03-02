// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

library dice_test;

import "../lib/dice.dart";
import "package:meta/meta.dart";
import "package:unittest/unittest.dart";

part "test_module.dart";

main() {
  group("injector injection", () {
    var injector = new Injector(new TestModule());
    
    test("instance", () {
      var instance = injector.getInstance(TestClass);
      expect(instance, isNotNull);
      expect(instance.hello, equals("Test Class"));
    });
    
    test("function", () {
      var instance = injector.getInstance(TestFunction);
      expect(instance, isNotNull);
      expect(instance(), equals("Test Function"));
    });
  });
  
  group("annotation injection", () {
    // TODO test annotations
  });
}

