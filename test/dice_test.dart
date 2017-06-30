// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

library dice_test;

@MirrorsUsed(
    metaTargets: const [ Inject],
    symbols: const ['inject', 'Named'])
import 'dart:mirrors';

import 'package:test/test.dart';
import 'package:dice/dice.dart';

import 'config.dart';
part 'src/test_module.dart';

main() {
    configLogging();

    group('injector -', () {
        final myModule = new MyModule();
        var injector = new Injector(myModule);

        test('> Simple', () {
            final MyClassToInject obj = injector.getInstance(MyClassToInject);

            expect(obj, isNotNull);
            expect(obj, new isInstanceOf<MyClassToInject>());
        }); // end of 'Simple' test

        test('inject singleton', () {
            var instances = [injector.getInstance(MyClass), injector.getInstance(MyClass)];
            expect(instances, everyElement(isNotNull));
            expect(instances.first.getName(), equals('MyClass'));
            expect(identical(instances[0], instances[1]), isTrue, reason: 'must be singleton');
        });

        test('inject instance', () {
            var instances = [injector.getInstance(MyOtherClass), injector.getInstance(MyOtherClass)];
            expect(instances, everyElement(isNotNull));
            expect(instances, everyElement(predicate((e) => e.getName() == 'MyOtherClass', '')));
            expect(identical(instances[0], instances[1]), isFalse, reason: 'must be new instances');
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
            var mySpecialClass = injector.getInstance(MyClass, named: "MySpecialClass");
            expect(myClass is MyClass, isTrue);
            expect(myClass is! MySpecialClass, isTrue);
            expect(mySpecialClass is MyClass, isTrue);
            expect(mySpecialClass is MySpecialClass, isTrue);
        });

        test('get registrations', () {
            var registrations = injector.registrations;
            expect(registrations, isNotNull);
            expect(() => registrations[new TypeMirrorWrapper(reflectType(MyClass), null,null)] = new Registration(MyClass),
                throwsUnsupportedError);
        });

        test('asSingleton', () {
            final MySingletonClass singleton1 = injector.getInstance(MySingletonClass);
            final MySingletonClass singleton2 = injector.getInstance(MySingletonClass);

            expect(singleton1.instanceID, 1);
            expect(singleton2.instanceID, 1);
            expect(singleton1.hashCode, singleton2.hashCode);
        }); // end of 'asSingleton' test

        test('asSingleton II', () {
            final singletonModule = new MySingletonModule();
            var sInjector = new Injector(singletonModule);

            var instances = [sInjector.getInstance(AnotherSingletonClass), sInjector.getInstance(AnotherSingletonClass)
            ];
            expect(instances, everyElement(isNotNull));
            expect(instances.first.getName(), equals('AnotherSingletonClass'));
            expect(identical(instances[0], instances[1]), isTrue, reason: 'must be singleton');
            expect(instances[0].hashCode, instances[1].hashCode);
        }); // end of 'asSingleton' test

        test('asSingleton III', () {
            final sInjector = new Injector()
                ..unregister(AnotherSingletonClass)
                ..register(AnotherSingletonClass).asSingleton();

            final AnotherSingletonClass singleton1 = sInjector.getInstance(AnotherSingletonClass);
            final AnotherSingletonClass singleton2 = sInjector.getInstance(AnotherSingletonClass);

            expect(singleton1.hashCode, singleton2.hashCode);
        }); // end of '' test

        test('MultiModule', () {
            final myMultiModule = new MyModuleForInstallation();
            var multiInjector = new Injector(myMultiModule);

            final MySingletonClass singleton = multiInjector.getInstance(MySingletonClass);

            // installed Module overwrites the definition of MySingletonClass
            expect(singleton, new isInstanceOf<MySpecialSingletonClass2>());
        }); // end of '' test

        test('Class injection', () {
            final Injector metaInjector = new Injector();

            metaInjector.register(MyClass).toType(MetaTestClass);

            final MyClass mc = metaInjector.getInstance(MyClass);
            expect(mc, new isInstanceOf<MetaTestClass>());
        });

        test('annotatedWith', () {
            final annotationInjector = new Injector()
                ..register(String,annotatedWith: UrlGoogle ).toInstance("http://www.google.com/")
            ;

            final String url = annotationInjector.getInstance(String,annotatedWith: UrlGoogle);
            expect(url,"http://www.google.com/");
        });

        test('CTOR injection', () {
            final ctorInjector = new Injector()
                ..register(String,annotatedWith: UrlGoogle ).toInstance("http://www.google.com/")
                ..register(String,named: "language" ).toInstance("dart")
                ..register(MyClass).toType(CTORInjection)
            ;
            final MyClass mc = ctorInjector.getInstance(MyClass);
            expect(mc,isNotNull);
            expect(mc.getName(),"CTORInjection - http://www.google.com/ (dart)");
        });

        test('CTOR injection - optional param', () {
            final ctorInjector = new Injector()
                ..register(String,annotatedWith: UrlGoogle ).toInstance("http://www.google.com/")
                ..register(MyClass).toType(CTOROptionalInjection)
            ;
            final MyClass mc = ctorInjector.getInstance(MyClass);
            expect(mc,isNotNull);
            expect(mc.getName(),"CTORInjection - http://www.google.com/ (C++)");
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
                ..register(YourClass)..register(MyOtherClass)
                ..register(MyClass, named: 'test').toType(MySpecialClass);

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

            var myNamedClass = injector.getInstance(MyClass, named: 'test');
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
            var constructors = injector.injectableConstructors(classMirror).toList().map((c) =>
                symbolAsString(c.simpleName));
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
            var expected = [
                'variableToInject',
                '_variableToInject',
                'namedVariableToInject',
                '_namedVariableToInject',
                'url1',
                'url2',
                'url3'
            ];
            expect(variables, unorderedEquals(expected));
        });
    });
}
