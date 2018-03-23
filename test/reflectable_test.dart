/*
 * Copyright (c) 2018, Michael Mitterer (office@mikemitterer.at),
 * IT-Consulting and Development Limited.
 *
 * All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

library dice_test;

import 'package:reflectable/reflectable.dart';
import 'dice_test.reflectable.dart';

import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:dice/dice.dart';

import 'resources/test_module.dart';

import 'config.dart';

main() {
    final Logger _logger = new Logger('dice_test.reflectable_test');

    configLogging(defaultLogLevel: Level.ALL);
    initializeReflectable();

    group('Basics', () {
        test('> Make instance', () {
            // Simulate "Registration"
            final registration = Registration(MyClassToInject);

            final Type type = registration.builder();

            final TypeMirror typeMirror = inject.reflectType(type);
            expect(typeMirror,isNotNull);

            expect(typeMirror, new isInstanceOf<ClassMirror>());
            final ClassMirror classMirror = typeMirror as ClassMirror;

            _logger.fine("runtimeTime: ${type.runtimeType} type: ${type}");
            
            classMirror.declarations.forEach((final String key, final DeclarationMirror dm) {
                _logger.fine("K $key, D $dm");
            });

            final Object object = classMirror.newInstance("namedCTOR", []);
            expect(object,isNotNull);

            expect(object, new isInstanceOf<MyClassToInject>());
        }); // end of 'Make instance' test

      test('> Original type', () {
          final Type type  = MyClassToInject;

          expect(type.toString(), "MyClassToInject");

          final TypeMirror typeMirror = inject.reflectType(type);

          expect(typeMirror,isNotNull);
          expect(typeMirror.reflectedType, MyClassToInject);

          expect(typeMirror.qualifiedName, "test.resources.MyClassToInject");

      }); // end of 'Original type' test

    });
}
