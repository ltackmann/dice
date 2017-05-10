// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

@TestOn("!chrome")
library dice_vm_only_test;

@MirrorsUsed(
    metaTargets: const [ Inject ],
    symbols: const ['inject', 'Named'])
import 'dart:mirrors';

import 'package:test/test.dart';
import 'package:dice/dice.dart';

import 'config.dart';

class MyModule extends Module {

    configure() {
        register(MyFunction).toFunction(MyFunctionToInject);
        register(MyClassFunction).toFunction(new MyClass().getName);
    }
}

@Inject()
MyFunctionToInject() => "MyFunction";

@Inject()
typedef String MyFunction();

@Inject()
typedef String MyClassFunction();

class MyClass {
    String getName() => "MyClass";
}


// These tests don't work in Chrome (compiled to JS)
main() {
    configLogging();

    group('injector -', () {
        final myModule = new MyModule();
        var injector = new Injector(myModule);

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
    });
}
