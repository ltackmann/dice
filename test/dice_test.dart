// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

library dice_test;

import 'dart:async';
import 'dart:mirrors';

import 'package:unittest/unittest.dart';
import 'package:dice/dice.dart';

part 'test_module.dart';

main() {
  group('injector injection -', () {
    var injector = new Injector(new MyModule());
    
    test('singleton', () {
      var futures = [injector.getInstance(MyClass), injector.getInstance(MyClass)]; 
      Future.wait(futures).then(expectAsync1((List<MyClass> instances) {
        expect(instances, everyElement(isNotNull));
        expect(instances.first.getName(), equals('MyClass'));
        expect(identical(instances[0], instances[1]), isTrue, reason:'must be singleton');
      }));
    });
    
    test('instance', () {
      var futures = [injector.getInstance(MyOtherClass), injector.getInstance(MyOtherClass)]; 
      Future.wait(futures).then(expectAsync1((List<MyOtherClass> instances) {
        expect(instances, everyElement(isNotNull));
        expect(instances, everyElement(predicate((e) => e.getName() == 'MyOtherClass', '')));
        expect(identical(instances[0], instances[1]), isFalse, reason:'must be new instances');
      }));
    });
    
    test('function', () {
      injector.getInstance(MyFunction).then(expectAsync1((func) {
        expect(func, isNotNull);
        expect(func(), equals('MyFunction'));
      }));
    });
    
    test('type', () {
      injector.getInstance(MyClassToInject).then(expectAsync1((MyClassToInject instance) {
        expect(instance, isNotNull);
        expect(instance, new isInstanceOf<MyClassToInject>('MyClassToInject'));
        expect(instance.$variableToInject, isNotNull);
        // TODO expect(instance._$variableToInject, isNotNull);
        expect(instance.injections[r'$setterToInject'], isNotNull);
        // TODO expect(instance.injections[r'_$setterToInject'], isNotNull);
        // FIXME: Until parameters names are supported (returns TODO:unnamed)
        // expect(instance.injections['setterToInject'], isNotNull);
        // expect(instance.injections['_setterToInject'], isNotNull);
      }));
    });
    
  });
  
  group('annotation injection', () {
    // TODO test annotations
  });
  
  group('internals -', () {
    var injector = new InjectorImpl(new MyModule());
    var classMirror = reflect(new MyClassToInject()).type;

    test('new instance of MyClass', () {
      ClassMirror classMirror = reflect(new MyClass()).type;
      injector.newInstance(classMirror).then(expectAsync1((InstanceMirror instance) {
        expect(instance, isNotNull);
        expect(instance.reflectee, isNotNull);
        expect(instance.reflectee, new isInstanceOf<MyClass>('MyClass'));
      }));
    });

    test('new instance of MyClassToInject', () {
      ClassMirror classMirror = reflect(new MyClassToInject()).type;
      injector.newInstance(classMirror).then(expectAsync1((InstanceMirror instance) {
        expect(instance, isNotNull);
        expect(instance.reflectee, isNotNull);
        expect(instance.reflectee, new isInstanceOf<MyClassToInject>('MyClassToInject'));
      }));
    });
    
    test('constructors', () {
      Iterable<MethodMirror> constructors = injector.injectableConstructors(classMirror).toList().map((c) => symbolAsString(c.simpleName));
      Iterable<MethodMirror> expected = ['MyClassToInject'];
      // FIXME: should be this but parameters names are not supported yet (returns TODO:unnamed)
      // Iterable<MethodMirror> expected = [c['MyClassToInject'], c['MyClassToInject.inject'], c['MyClassToInject.injectComplex']];
      
      expect(constructors, unorderedEquals(expected));
    });
    
    test('setters', () {
      Iterable<MethodMirror> setters = injector.injectableSetters(classMirror).toList().map((s) => symbolAsString(s.simpleName));
      Iterable<MethodMirror> expected = [r'$setterToInject='];
      // TODO , r'_$setterToInject='
      // FIXME: should be this but parameters names are not supported yet (returns TODO:unnamed)
      // Iterable<MethodMirror> expected = [s['setterToInject='], s['_setterToInject='], s[r'$setterToInject='], s[r'_$setterToInject=']];
      
      expect(setters, unorderedEquals(expected));
    });
    
    test('variables', () {
      Iterable<VariableMirror> variables = injector.injectableVariables(classMirror).toList().map((v) => symbolAsString(v.simpleName));
      Iterable<VariableMirror> expected = [r'$variableToInject', r'_$variableToInject'];
      expect(variables, unorderedEquals(expected));
    });
  });
}


