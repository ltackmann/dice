// Copyright (c) 2013, the Dice project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice;

/** Associates types with their concrete instances returned by the [Injector] */
abstract class Module {
  /** Bind [type] to an implementation */
  Binder bind(Type type) => namedBind(type, null);
  
  /** Bind [name] [type] to an implementation */
  Binder namedBind(Type type, String name) {
    var binder = new Binder();
    var typeMirrorWrapper = new TypeMirrorWrapper.fromType(type, name);
    _bindings[typeMirrorWrapper] = binder;
    return binder;
  }
  
  /** Configure type/instace bindings used in this module */
  configure();
  
  bool _hasBindingFor(TypeMirror type, String name) => _bindings.containsKey(new TypeMirrorWrapper(type, name));
  
  Binder _getBindingFor(TypeMirror type, String name) => _bindings[new TypeMirrorWrapper(type, name)];
  
  final Map<TypeMirrorWrapper, Binder> _bindings = new Map<TypeMirrorWrapper, Binder>();
}

/**
 * Combines several [Module] into single one, allowing to inject
 * a class from one module into a class from another module.
 */
class _ModuleContainer extends Module {
  _ModuleContainer(List<Module> this._modules);

  @override
  configure() {
    _modules.fold(_bindings, (acc, module) {
      module.configure();
      return acc..addAll(module._bindings);
    });
  }

  List<Module> _modules;
}
