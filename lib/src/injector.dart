// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice;

/** Resolve types to their implementing classes */
abstract class Injector {
  factory Injector(module) => new InjectorImpl(module);
  
  Future<dynamic> getInstance(Type type);
}

/** Implementation of [Injector]. */
class InjectorImpl implements Injector {
  Module _module;

  InjectorImpl(this._module) {
    _module.configure();
  }
  
  Future<dynamic> getInstance(Type type) => getInstanceFromTypeMirror(reflectClass(type));

  Future<dynamic> getInstanceFromTypeMirror(TypeMirror type) {
    if(!_module._hasBindingFor(type)) {
      throw new ArgumentError("no instance registered for type $type");
    }
    
    var binder = _module._getBindingFor(type);
    // TODO use reflection to resolve sub dependencies when dart:mirrors support access to meta information
    // TODO avoid circular references using a cache or injecting proxies
    var instance = binder._builder();
    instance = resolveInjections(instance);
    return instance;
  }
  
  Future<dynamic> resolveInjections(dynamic instance) {
    return (instance is ClassMirror ? newInstance(instance) : new Future.value(reflect(instance)))
        .then(injectSetters)
        .then(injectVariables)
        .then((InstanceMirror instanceMirror) => instanceMirror.reflectee);
  }
  
  Future<InstanceMirror> newInstance(ClassMirror classMirror) {
    // Look for an injectable constructor
    var constructors = injectableConstructors(classMirror);
    // that has the greatest number of parameters to inject, optional included
    MethodMirror constructor = constructors.fold(null, (MethodMirror p, MethodMirror e) => 
            p == null || injectableParameters(p).length < injectableParameters(e).length ? e : p);
    // TODO String constructorName = constructor.simpleName.replaceFirst(classMirror.simpleName, "").replaceFirst(".", "");
    var constructorName = constructor.simpleName;
    
    // TODO parameters injection
    return classMirror.newInstanceAsync(constructor.constructorName, []);
  }
  
  Future<InstanceMirror> injectSetters(InstanceMirror instanceMirror) {
      var setters = injectableSetters(instanceMirror.type);
      // FIXME We are not able to get Type from a TypeMirror yet
      var futures = setters.map((MethodMirror setter) => 
          getInstanceFromTypeMirror(firstParameter(setter))
            // use the resolved injections as setter values
            .then((instance) => instanceMirror.setFieldAsync(methodName(setter), reflect(instance)))); 
      // setters.forEach((s) => instanceMirror.invoke(s.simpleName, [getInstance(s.returnType)])); 
      return Future.wait(futures).then((_) => instanceMirror);
  }
  
  Future<InstanceMirror> injectVariables(InstanceMirror instanceMirror) {
      var variables = injectableVariables(instanceMirror.type);
      // FIXME We are not able to get Type from a TypeMirror yet
      var futures = variables.map((VariableMirror variable) => 
          getInstanceFromTypeMirror(variable.type)
            // use the resolved injections as variable values
            .then((instance) => instanceMirror.setFieldAsync(variable.simpleName, reflect(instance)))); 
      return Future.wait(futures).then((_) => instanceMirror);
  }
  
  /** Returns constructors that could be injected */
  Iterable<MethodMirror> injectableConstructors(ClassMirror classMirror) =>
      // All non optional parameters are injectable
      classMirror.constructors.values.where((m) => m.parameters.where((p) => !p.isOptional).every(injectable));

  /** Returns setters that need injection */
  Iterable<MethodMirror> injectableSetters(ClassMirror classMirror) => 
      // TODO figure out how to inject into private setters
      classMirror.setters.values.where((m) => injectable(m) || m.parameters.every(injectable)).where((s) => !s.isPrivate);

  /** Returns variables that need injection */
  Iterable<VariableMirror> injectableVariables(ClassMirror classMirror) => 
      classMirror.variables.values.where(injectable);

  /** Returns true if the declared [element] is injectable */
  bool injectable(DeclarationMirror element) => 
      symbolAsString(element.simpleName).startsWith(r'$') || symbolAsString(element.simpleName).startsWith(r'_$');
  
  /** Returns method name from [MethodMirror] */
  Symbol methodName(MethodMirror method) {
    var name = symbolAsString(method.simpleName);
    var symbolName = name.substring(0, name.length - 1);
    return stringAsSymbol(symbolName);
  }
  
  /** Returns [TypeMirror] for first parameter in method */
  TypeMirror firstParameter(MethodMirror method) => 
      method.parameters[0].type;
  
  /** Returns parameters (including optional) that need injection */
  Iterable<ParameterMirror> injectableParameters(MethodMirror method) => 
      method.parameters.where(injectable);
}

