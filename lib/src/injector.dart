// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice;

/** Resolve types to their implementing classes */
abstract class Injector {
  factory Injector(module) => new InjectorImpl(module);
  
  /** Get new instance of [type] with all dependencies resolved */
  dynamic getInstance(Type type);
  
  /** Resolve injetions in existing Object (does not create a new instance) */
  Object resolveInjections(Object obj);
  
  /** Get the module used to configure this injector */
  Module get module;
}

/** Implementation of [Injector]. */
class InjectorImpl implements Injector {
  InjectorImpl(this._module) {
    _module.configure();
  }
  
  @override
  dynamic getInstance(Type type) {
    var typeMirror = reflectClass(type);
    return _getInstanceFor(typeMirror);
  }
  
  @override
  Object resolveInjections(Object obj) {
    var instanceMirror = reflect(obj);
    return _resolveInjections(instanceMirror);
  }
  
  @override
  Module get module => _module;
  
  dynamic _getInstanceFor(TypeMirror tm) {
    if(!_module._hasBindingFor(tm)) {
      throw new ArgumentError("no instance registered for type ${symbolAsString(tm.simpleName)}");
    }
    
    InstanceMirror im;
    var binder = _module._getBindingFor(tm);
    var obj = binder._builder(); 
    if(obj is Type) {
      im = _newInstance(reflectClass(obj));
    } else {
      im = reflect(obj);
    }
    return _resolveInjections(im);
  }
  
  dynamic _resolveInjections(InstanceMirror im) {
    im = _injectSetters(im);
    im = _injectVariables(im);
    return im.reflectee;
  }
  
  // create a new instance of classMirror and inject it
  InstanceMirror _newInstance(ClassMirror classMirror) {
    // Look for an injectable constructor
    var constructors = injectableConstructors(classMirror).toList();
    // that has the greatest number of parameters to inject, optional included
    MethodMirror constructor = constructors.fold(null, (MethodMirror p, MethodMirror e) => 
            p == null || _injectableParameters(p).length < _injectableParameters(e).length ? e : p);
    var constructorArgs = constructor.parameters.map((pm) => _getInstanceFor(pm.type)).toList();  
    
    return classMirror.newInstance(constructor.constructorName, constructorArgs);
  }
  
  InstanceMirror _injectSetters(InstanceMirror instanceMirror) {
    var setters = injectableSetters(instanceMirror.type);
    setters.forEach((MethodMirror setter) { 
      var instanceToInject = _getInstanceFor(_firstParameter(setter));
      // set the resolved injection on the instance mirror we are injecting into
      instanceMirror.setField(_methodName(setter), instanceToInject);
    }); 
    return instanceMirror;
  }
  
  InstanceMirror _injectVariables(InstanceMirror instanceMirror) {
    var variables = injectableVariables(instanceMirror.type);
    variables.forEach((VariableMirror variable) { 
      var instanceToInject = _getInstanceFor(variable.type);
      // set the resolved injection on the instance mirror we are injecting into
      instanceMirror.setField(variable.simpleName, instanceToInject); 
    });
    return instanceMirror;
  }
  
  /** Returns constructors that could be injected */
  Iterable<MethodMirror> injectableConstructors(ClassMirror classMirror) {
    var constructors = classMirror.constructors.values.where(_injectable);
    if(constructors.isEmpty) {
      // use the default constructor if no excplit injectable exists 
      constructors = classMirror.constructors.values.where((MethodMirror m) => m.parameters.isEmpty);
      if(constructors.isEmpty) {
        throw new StateError("no injectable constructors exists for ${classMirror}");
      }
    }
    return constructors;
  }

  /** Returns setters that need injection */
  Iterable<MethodMirror> injectableSetters(ClassMirror classMirror) => 
      // TODO figure out how to inject into private setters
      classMirror.setters.values.where(_injectable);

  /** Returns variables that need injection */
  Iterable<VariableMirror> injectableVariables(ClassMirror classMirror) => 
      classMirror.variables.values.where(_injectable);

  /** Returns true if the declared [element] is injectable */
  bool _injectable(DeclarationMirror element) => 
      element.metadata.any((InstanceMirror im) => im.reflectee is Inject);
  
  /** Returns method name from [MethodMirror] */
  Symbol _methodName(MethodMirror method) {
    var name = symbolAsString(method.simpleName);
    var symbolName = name.substring(0, name.length - 1);
    return stringAsSymbol(symbolName);
  }
  
  /** Returns [TypeMirror] for first parameter in method */
  TypeMirror _firstParameter(MethodMirror method) => 
      method.parameters[0].type;
  
  /** Returns parameters (including optional) that can be injected */
  Iterable<ParameterMirror> _injectableParameters(MethodMirror method) => 
      method.parameters.where((pm) => _module._hasBindingFor(pm.type));
  
  final Module _module;
}

