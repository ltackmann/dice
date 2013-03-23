// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

library dice_test;

import "../lib/dice.dart";
import "dart:async";
import "dart:mirrors";
import "package:meta/meta.dart";
import "package:unittest/unittest.dart";

part "test_classes.dart";
part "test_module.dart";

main() {
  group("dice inject -", () {
    var injector = new Injector(new MyModule());
    
    test("singleton", () {
      injector.getInstance(MyClass).then(expectAsync1((instance) {
        expect(instance, isNotNull);
        expect(instance.getName(), equals("MyClass"));
        injector.getInstance(MyClass).then(expectAsync1((secondInstance) {
          expect(identical(instance, secondInstance), isTrue, reason:"must be singleton");
        }));
      }));
    });
    
    test("instance", () {
      injector.getInstance(MyOtherClass).then(expectAsync1((instance) {
        expect(instance, isNotNull);
        expect(instance.getName(), equals("MyOtherClass"));
        expect(identical(instance, injector.getInstance(MyOtherClass)), isFalse, reason:"must be new instance");
      }));
    });
    
    test("function", () {
      injector.getInstance(MyFunction).then(expectAsync1((func) {
        expect(func, isNotNull);
        expect(func(), equals("MyFunction"));
      }));
    });
    
    test("class mirror", () {
      injector.getInstance(MyClassToInject).then(expectAsync1((MyClassToInject instance) {
        expect(instance, isNotNull);
        expect(instance, new isInstanceOf<MyClassToInject>('MyClassToInject'));
        expect(instance.$variableToInject, isNotNull);
        expect(instance._$variableToInject, isNotNull);
        expect(instance.injections['\$setterToInject'], isNotNull);
        expect(instance.injections['_\$setterToInject'], isNotNull);
        // FIXME: Until parameters names are supported (returns TODO:unnamed)
        // expect(instance.injections['setterToInject'], isNotNull);
        // expect(instance.injections['_setterToInject'], isNotNull);
      }));
    });
    
  });
  
  group("annotation injection", () {
    // TODO test annotations
  });
  
  group("Members to inject -", () {
    InjectorImpl injector = new InjectorImpl(new MyModule());
    
    ClassMirror classMirror = reflect(new MyClassToInject()).type;

    test("new instance of MyClass", () {
      ClassMirror classMirror = reflect(new MyClass()).type;
      injector.newInstance(classMirror).then(expectAsync1((InstanceMirror instance) {
        expect(instance, isNotNull);
        expect(instance.reflectee, isNotNull);
        expect(instance.reflectee, new isInstanceOf<MyClass>('MyClass'));
      }));
    });

    test("new instance of MyClassToInject", () {
      ClassMirror classMirror = reflect(new MyClassToInject()).type;
      injector.newInstance(classMirror).then(expectAsync1((InstanceMirror instance) {
        expect(instance, isNotNull);
        expect(instance.reflectee, isNotNull);
        expect(instance.reflectee, new isInstanceOf<MyClassToInject>('MyClassToInject'));
      }));
    });
    
    test("constructors", () {
      var c = classMirror.constructors;
      Iterable<MethodMirror> constructors = injector.injectableConstructors(classMirror).toList();
      Iterable<MethodMirror> expected = [c["MyClassToInject"]];
      // FIXME: should be this but parameters names are not supported yet (returns TODO:unnamed)
      // Iterable<MethodMirror> expected = [c["MyClassToInject"], c["MyClassToInject.inject"], c["MyClassToInject.injectComplex"]];
      
      expect(constructors, unorderedEquals(expected));
    });
    
    test("setters", () {
      var s = classMirror.setters;
      Iterable<MethodMirror> setters = injector.injectableSetters(classMirror).toList();
      Iterable<MethodMirror> expected = [s["\$setterToInject="], s["_\$setterToInject="]];
      // FIXME: should be this but parameters names are not supported yet (returns TODO:unnamed)
      // Iterable<MethodMirror> expected = [s["setterToInject="], s["_setterToInject="], s["\$setterToInject="], s["_\$setterToInject="]];
      
      expect(setters, unorderedEquals(expected));
    });
    
    test("variables", () {
      var v = classMirror.variables;
      Iterable<VariableMirror> variables = injector.injectableVariables(classMirror).toList();
      Iterable<VariableMirror> expected = [v["\$variableToInject"], v["_\$variableToInject"]];
      
      expect(variables, unorderedEquals(expected));
    });
  });
}

