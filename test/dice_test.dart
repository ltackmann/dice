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
  group('injection -', () {
    var injector = new Injector(new MyModule());
    
    test('singleton', () {
      var instances = [injector.getInstance(MyClass), injector.getInstance(MyClass)]; 
      expect(instances, everyElement(isNotNull));
      expect(instances.first.getName(), equals('MyClass'));
      expect(identical(instances[0], instances[1]), isTrue, reason:'must be singleton');
    });
    
    test('instance', () {
      var instances = [injector.getInstance(MyOtherClass), injector.getInstance(MyOtherClass)]; 
      expect(instances, everyElement(isNotNull));
      expect(instances, everyElement(predicate((e) => e.getName() == 'MyOtherClass', '')));
      expect(identical(instances[0], instances[1]), isFalse, reason:'must be new instances');
    });
    
    skip_test('function', () {
      var func = injector.getInstance(MyFunction);
      expect(func, isNotNull);
      expect(func(), equals('MyFunction'));
    });
    
    test('type', () {
      var instance = injector.getInstance(MyClassToInject);
      expect(instance, isNotNull);
      expect(instance, new isInstanceOf<MyClassToInject>('MyClassToInject'));
      // variables
      expect(instance.variableToInject, isNotNull);
      // TODO expect(instance._$variableToInject, isNotNull);
      // setters
      expect(instance.injections[r'setterToInject'], isNotNull);
      // TODO expect(instance.injections[r'_$setterToInject'], isNotNull);
      // FIXME: Until parameters names are supported (returns TODO:unnamed)
      // expect(instance.injections['setterToInject'], isNotNull);
      // expect(instance.injections['_setterToInject'], isNotNull);
    });
    
    test('named injections', () {
      // THROW error on injection if multiple instances is registered and @Named is not used
    });
  });
  
  group('internals -', () {
    var injector = new InjectorImpl(new MyModule());
    var classMirror = reflectClass(MyClassToInject);

    test('new instance of MyClass', () {
      var instance = injector.getInstance(MyClass);
      expect(instance, isNotNull);
      expect(instance, new isInstanceOf<MyClass>('MyClass'));
    });

    test('new instance of MyClassToInject', () {
      var instance = injector.getInstance(MyClassToInject);
      expect(instance, isNotNull);
      expect(instance, new isInstanceOf<MyClassToInject>('MyClassToInject'));
    });
    
    test('constructors', () {
      var constructors = injector.injectableConstructors(classMirror).toList().map((c) => symbolAsString(c.simpleName));
      var expected = ['MyClassToInject.inject'];
      
      expect(constructors, unorderedEquals(expected));
    });
    
    test('setters', () {
      var setters = injector.injectableSetters(classMirror).toList().map((s) => symbolAsString(s.simpleName));
      var expected = ['setterToInject='];
      // TODO , '_setterToInject='
      // FIXME: should be this but parameters names are not supported yet (returns TODO:unnamed)
      // Iterable<MethodMirror> expected = [s['setterToInject='], s['_setterToInject='], s[r'$setterToInject='], s[r'_$setterToInject=']];
      
      expect(setters, unorderedEquals(expected));
    });
    
    test('variables', () {
      var variables = injector.injectableVariables(classMirror).toList().map((v) => symbolAsString(v.simpleName));
      var expected = ['variableToInject', '_variableToInject', 'namedVariableToInject', '_namedVariableToInject'];
      expect(variables, unorderedEquals(expected));
    });
  });
}



