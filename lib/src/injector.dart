// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice;


/**
 * Resolve types to their implementing classes
 */
abstract class Injector {
  factory Injector(module) => new InjectorImpl(module);
  
  Future<dynamic> getInstance(Type type);
}
/**
 * Implementation of [Injector].
 */
class InjectorImpl implements Injector {
  Module _module;

  InjectorImpl(this._module) {
    _module.configure();
  }
  
  Future<dynamic> getInstance(Type type) {
    if(!_module._hasBindingFor(type)) {
      /*
       * TODO when dart:mirrors support it change this code to create new instance from type 
       * and use reflection to resolve its sub dependencies
       */
      throw new ArgumentError("no instance registered for type $type");
    }
    
    var binder = _module._getBindingFor(type);
    // TODO use reflection to resolve sub dependencies when dart:mirrors support access to meta information
    // TODO avoid circular references using a cache or injecting proxies
    var instance = binder._builder();
    instance = inject(instance);
    return instance;
  }
  
  Future<dynamic> inject(dynamic instance) {
    return (instance is ClassMirror ? newInstance(instance) : new Future.immediate(reflect(instance)))
        .then(injectSetters)
        .then(injectVariables)
        .then((InstanceMirror instanceMirror) => instanceMirror.reflectee);
  }
  
  Future<InstanceMirror> newInstance(ClassMirror classMirror) {
    // Look for an injectable constructor
    var constructors = injectableConstructors(classMirror);
    // that has the greatest number of parameters to inject, optional included
    MethodMirror constructor = constructors.reduce(null, 
        (MethodMirror p, MethodMirror e) => 
            p == null || p.parameters.where(injectable).length < e.parameters.where(injectable).length ? e : p);
    String constructorName = constructor.simpleName.replaceFirst(classMirror.simpleName, "").replaceFirst(".", "");
    
    // TODO parameters injection
    return classMirror.newInstance(constructorName, []);
  }
  
  Future<InstanceMirror> injectSetters(InstanceMirror instanceMirror) {
      var setters = injectableSetters(instanceMirror.type);
      // FIXME We are not able to get Type from a TypeMirror yet
      var futures = setters.map((s) => inject(s.parameters[0].type).then((instance) => 
          instanceMirror.setField(s.simpleName.substring(0, s.simpleName.length - 1), reflect(instance)))); 
      // setters.forEach((s) => instanceMirror.invoke(s.simpleName, [getInstance(s.returnType)])); 
      return Future.wait(futures).then((_) => instanceMirror);
  }
  
  Future<InstanceMirror> injectVariables(InstanceMirror instanceMirror) {
      var variables = injectableVariables(instanceMirror.type);
      // FIXME We are not able to get Type from a TypeMirror yet
      var futures = variables.map((v) => inject(v.type).then((instance) => 
          instanceMirror.setField(v.simpleName, reflect(instance)))); 
      // variables.forEach((v) => instanceMirror.setField(v.simpleName, getInstance(v.type)));
      return Future.wait(futures).then((_) => instanceMirror);
  }
  
  /** Returns constructors that could be injected */
  Iterable<MethodMirror> injectableConstructors(ClassMirror classMirror) =>
      // All non optional parameters should be injectable
      classMirror.constructors.values.where((m) => m.parameters.where((p) => !p.isOptional).every(injectable));

  /** Returns setters that need injection */
  Iterable<MethodMirror> injectableSetters(ClassMirror classMirror) => 
      classMirror.setters.values.where((m) => injectable(m) || m.parameters.every(injectable));

  /** Returns variables that need injection */
  Iterable<VariableMirror> injectableVariables(ClassMirror classMirror) => 
      classMirror.variables.values.where(injectable);

  /** Returns true if the declared [element] is injectable */
  bool injectable(DeclarationMirror element) => element.simpleName.startsWith('\$') || element.simpleName.startsWith('_\$');
}

/**
 * Used to annotate constructors, methods and fields of your classes where [Injector] should resolve values
 */
const inject = const _Inject();

class _Inject {
  const _Inject();
}
