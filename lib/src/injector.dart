// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice;

/**
 * Resolve types to their implementing classes
 */
class Injector {
  Injector(this._module) {
    _module.configure();
    _module.injector = this;
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
    // TODO use reflection to resolve sub dependencies when dart:mirrors support access to meta information
    return binder._builder();
  }
  
  Module _module;
}

/**
 * Used to annotate constructors, methods and fields of your classes where [Injector] should resolve values
 */
const inject = const _Inject();

class _Inject {
  const _Inject();
}


