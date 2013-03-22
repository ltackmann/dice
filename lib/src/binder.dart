// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice;

/**
 * Collects configuration information (primarily bindings) which will be used to create an [Injector].
 */
class Binder {
  // support more bindings as need arrises https://code.google.com/p/google-guice/wiki/Bindings
  
  /**
   * Bind type to a single object instance that will always be returned
   */
  toInstance(var instance) {
    _builder = () => instance;
  }
  
  /**
   * Bind type to a [InstanceBuilder] that will build the returned instances
   */
  toBuilder(TypeBuilder builder) {
    _builder = builder;
  }
  
  TypeBuilder _builder;
}

/**
 * Function that builds instance of a bound types
 */
typedef dynamic TypeBuilder();

