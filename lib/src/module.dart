// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice;

/**
 * Associates types with their concrete instances returned by the [Injector]
 */
abstract class Module {
  // TODO parent/child modules like guice 
  Module(): _bindings = new Map<Type, Binder>();
  
  Binder bind(Type type) {
    // TODO what happens if type is already bound ? (check guice)
    var binder = new Binder();
    _bindings[type] = binder;
    return binder;
  }
  
  configure();
  
  bool _hasBindingFor(Type type) => _bindings.containsKey(type);
  
  Binder _getBindingFor(Type type) => _bindings[type];
  
  Map<Type, Binder> _bindings;
}


