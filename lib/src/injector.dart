// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dice;

/**
 * Builds the graphs of objects that make up your application
 * 
 * TODO write a more customer friendly description
 */
class Injector {
  Injector(this._module) {
    _module.configure();
  }
  
  dynamic getInstance(Type type) {
    if(!_module._hasBindingFor(type)) {
      /*
       * TODO when dart:mirrors support it change this code to create new instance from type 
       * and use reflection to resolve its sub dependencies
       */
       throw new ArgumentError("no instance registered for type $type");
    }
    
    var binder = _module._getBindingFor(type);
    // TODO use reflection to resolve sub dependencies
    return binder._instance;
  }
  
  Module _module;
}

/**
 * Used to annotate members of your classes (constructors, methods and fields) where the [Injector] should inject values
 */
const inject = const _Inject();

class _Inject {
  const _Inject();
}


