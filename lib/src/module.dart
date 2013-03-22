// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice;

/**
 * Associates types with their concrete instances returned by the [Injector]
 */
abstract class Module {
  /**
   * Bind a type implementation to this [Module]
   */
  Binder bind(Type type) {
    // TODO what happens if type is already bound ? (check guice)
    var binder = new Binder();
    _bindings[type] = binder;
    return binder;
  }
  
  /**
   * Configure type/instace bindings used in this module
   */
  configure();
  
  /**
   * Get a reference to the [Injecor] that loads classes using this [Module]. 
   * 
   * **Note** may return null if no injector is yet created
   */
  Injector injector;
  
  bool _hasBindingFor(Type type) => _bindings.containsKey(type);
  
  Binder _getBindingFor(Type type) => _bindings[type];
  
  final Map<Type, Binder> _bindings = new Map<Type, Binder>();
}


