// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

library dice_test;

import 'dart:mirrors';

import 'package:test/test.dart';
import 'package:dice/dice.dart';

part 'src/test_module.dart';

main() {
  group('injector -', () {
    final myModule = new MyModule();
    var injector = new Injector(myModule);

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

    test('inject function', () {
      var func = injector.getInstance(MyFunction);
      expect(func, isNotNull);
      expect(func(), equals('MyFunction'));
    });

    test('inject function in class', () {
      var func = injector.getInstance(MyClassFunction);
      expect(func, isNotNull);
      expect(func(), equals('MyClass'));
    });

    test('getInstance', () {
      var instance = injector.getInstance(MyClassToInject);
      expect(instance, isNotNull);
      expect(instance, new isInstanceOf<MyClassToInject>());
      expect((instance as MyClassToInject).assertInjections(), isTrue);
    });

    test('resolveInjections', () {
      var instance = new MyClassToInject.inject(new MyClass());
      expect((instance as MyClassToInject).assertInjections(), isFalse);
      var resolvedInstance = injector.resolveInjections(instance);

      expect((resolvedInstance as MyClassToInject).assertInjections(), isTrue);
      expect(identical(resolvedInstance, instance), isTrue);
    });

    test('named injections', () {
      var myClass = injector.getInstance(MyClass);
      var mySpecialClass = injector.getInstance(MyClass, "MySpecialClass");
      expect(myClass is MyClass, isTrue);
      expect(myClass is! MySpecialClass, isTrue);
      expect(mySpecialClass is MyClass, isTrue);
      expect(mySpecialClass is MySpecialClass, isTrue);
    });

    test('get registrations', () {
      var registrations = injector.registrations;
      expect(registrations, isNotNull);
      expect(() => registrations[new TypeMirrorWrapper(reflectType(MyClass), null)] = new Registration(MyClass), throwsUnsupportedError);
    });
  });

  group('modules - ', () {
    final yourModule = new YourModule();
    final myModule = new MyModule();

    test('multiple modules', () {
      var injector = new Injector.fromModules([myModule, yourModule]);

      var myClass = injector.getInstance(MyClass);
      var yourClass = injector.getInstance(YourClass);

      expect(myClass, new isInstanceOf<MyClass>());
      expect(yourClass, new isInstanceOf<YourClass>());
    });

    test('register runtime', () {
      var injector = new Injector(myModule);
      expect(() => injector.getInstance(YourClass), throwsArgumentError);

      injector.register(YourClass).toType(YourClass);
      expect(injector.getInstance(YourClass), new isInstanceOf<YourClass>());
    });

    test('unregister runtime', () {
      var injector = new Injector();
      injector
        ..register(MyClass).toType(MySpecialClass)
        ..register(YourClass)
        ..register(MyOtherClass)
        ..register(MyClass, 'test').toType(MySpecialClass);

      var myClass = injector.getInstance(MyClass);
      var yourClass = injector.getInstance(YourClass);
      var myOtherClass = injector.getInstance(MyOtherClass);

      expect(myClass, new isInstanceOf<MySpecialClass>());
      expect(yourClass, new isInstanceOf<YourClass>());
      expect(myOtherClass, new isInstanceOf<MyOtherClass>());

      injector.unregister(MyClass);
      injector.unregister(YourClass);
      injector.unregister(MyOtherClass);

      expect(() => injector.getInstance(MyClass), throwsArgumentError);
      expect(() => injector.getInstance(YourClass), throwsArgumentError);
      expect(() => injector.getInstance(MyOtherClass), throwsArgumentError);

      var myNamedClass = injector.getInstance(MyClass, 'test');
      expect(myNamedClass, new isInstanceOf<MySpecialClass>());
    });

    test('join injectors', () {
      var injector1 = new Injector(myModule);
      var injector2 = new Injector(yourModule);
      var joinedInjector = new Injector.fromInjectors([injector1, injector2]);

      var myClass = joinedInjector.getInstance(MyClass);
      var yourClass = joinedInjector.getInstance(YourClass);

      expect(myClass, new isInstanceOf<MyClass>());
      expect(yourClass, new isInstanceOf<YourClass>());
    });
  });

  group('internals -', () {
    var injector = new InjectorImpl(new MyModule());
    var classMirror = reflectClass(MyClassToInject);

    test('new instance of MyClass', () {
      var instance = injector.getInstance(MyClass);
      expect(instance, isNotNull);
      expect(instance, new isInstanceOf<MyClass>());
    });

    test('new instance of MyClassToInject', () {
      var instance = injector.getInstance(MyClassToInject);
      expect(instance, isNotNull);
      expect(instance, new isInstanceOf<MyClassToInject>());
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
