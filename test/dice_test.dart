// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

library dice_test;

import 'dart:mirrors';

import 'package:unittest/unittest.dart';
import 'package:dice/dice.dart';

part 'src/test_module.dart';

main() {
  group('injector -', () {
    final module = new MyModule();
    var injector = new Injector(module);
    
    test('inject singleton', () {
      var instances = [injector.getInstance(MyClass), injector.getInstance(MyClass)]; 
      expect(instances, everyElement(isNotNull));
      expect(instances.first.getName(), equals('MyClass'));
      expect(identical(instances[0], instances[1]), isTrue, reason:'must be singleton');
    });
    
    test('inject instance', () {
      var instances = [injector.getInstance(MyOtherClass), injector.getInstance(MyOtherClass)]; 
      expect(instances, everyElement(isNotNull));
      expect(instances, everyElement(predicate((e) => e.getName() == 'MyOtherClass', '')));
      expect(identical(instances[0], instances[1]), isFalse, reason:'must be new instances');
    });
    
    skip_test('inject function', () {
      var func = injector.getInstance(MyFunction);
      expect(func, isNotNull);
      expect(func(), equals('MyFunction'));
    });
    
    test('getInstance', () {
      var instance = injector.getInstance(MyClassToInject);
      expect(instance, isNotNull);
      expect(instance, new isInstanceOf<MyClassToInject>('MyClassToInject'));
      expect((instance as MyClassToInject).assertInjections(), isTrue);
    });
    
    test('resolveInjections', () {
      var instance = new MyClassToInject.inject(new MyClass());
      expect((instance as MyClassToInject).assertInjections(), isFalse);
      var resolvedInstance = injector.resolveInjections(instance);
      
      expect((resolvedInstance as MyClassToInject).assertInjections(), isTrue);
      expect(identical(resolvedInstance, instance), isTrue);
    });
    
    test('get module', () {
      var moduleUsed = injector.module;
      expect(moduleUsed, isNotNull);
      expect(identical(moduleUsed, module), isTrue);
    });
    
    test('named injections', () {
      var myClass = injector.getInstance(MyClass);
      var mySpecialClass = injector.getNamedInstance(MyClass, "MySpecialClass");
      expect(myClass is MyClass, isTrue);
      expect(myClass is! MySpecialClass, isTrue);
      expect(mySpecialClass is MyClass, isTrue);
      expect(mySpecialClass is MySpecialClass, isTrue);
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
      var expected = ['setterToInject=', '_setterToInject='];
      
      expect(setters, unorderedEquals(expected));
    });
    
    test('variables', () {
      var variables = injector.injectableVariables(classMirror).toList().map((v) => symbolAsString(v.simpleName));
      var expected = ['variableToInject', '_variableToInject', 'namedVariableToInject', '_namedVariableToInject'];
      expect(variables, unorderedEquals(expected));
    });
  });
}



