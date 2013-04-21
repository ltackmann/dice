// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice;

/** Associates types with their concrete instances returned by the [Injector] */
abstract class Module {
  /** Bind a type implementation to this [Module] */
  Binder bind(Type type) {
    // TODO what happens if type is already bound ? (check guice)
    var binder = new Binder();
    _bindings[new TypeMirrorWrapper.fromType(type)] = binder;
    return binder;
  }
  
  /** Configure type/instace bindings used in this module */
  configure();
  
  bool _hasBindingFor(TypeMirror type) => _bindings.containsKey(new TypeMirrorWrapper(type));
  
  Binder _getBindingFor(TypeMirror type) => _bindings[new TypeMirrorWrapper(type)];
  
  final Map<TypeMirrorWrapper, Binder> _bindings = new Map<TypeMirrorWrapper, Binder>();
}


