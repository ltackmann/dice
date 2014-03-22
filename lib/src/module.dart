// Copyright (c) 2013, the Dice project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice;

/** Associates types with their concrete instances returned by the [Injector] */
abstract class Module {
  /** Register a [type] to an implementation */
  Registration register(Type type) => namedRegister(type, null);
  
  /** register a [type] with [name] to an implementation */
  Registration namedRegister(Type type, String name) {
    var registration = new Registration();
    var typeMirrorWrapper = new TypeMirrorWrapper.fromType(type, name);
    _registrations[typeMirrorWrapper] = registration;
    return registration;
  }
  
  /** Configure type/instace registrations used in this module */
  configure();
  
  bool _hasRegistrationFor(TypeMirror type, String name) => _registrations.containsKey(new TypeMirrorWrapper(type, name));
  
  Registration _getRegistrationFor(TypeMirror type, String name) => _registrations[new TypeMirrorWrapper(type, name)];
  
  final Map<TypeMirrorWrapper, Registration> _registrations = new Map<TypeMirrorWrapper, Registration>();
}

/**
 * Combines several [Module] into single one, allowing to inject
 * a class from one module into a class from another module.
 */
class _ModuleContainer extends Module {
  _ModuleContainer(List<Module> this._modules);

  @override
  configure() {
    _modules.fold(_registrations, (acc, module) {
      module.configure();
      return acc..addAll(module._registrations);
    });
  }

  List<Module> _modules;
}
