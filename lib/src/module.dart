// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dice;

/**
 * Associates types with their concrete instances returned by the [Injector]
 */
abstract class Module {
  // TODO parent modules like guice 
  Module(): _bindings = new Map<Type, Binder>();
  
  Binder bind(Type type) {
    var binder = new Binder();
    _bindings[type] = binder;
    return binder;
  }
  
  configure();
  
  bool _hasBindingFor(Type type) => _bindings.containsKey(type);
  
  Binder _getBindingFor(Type type) => _bindings[type];
  
  Map<Type, Binder> _bindings;
}


