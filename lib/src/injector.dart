// Copyright (c) 2013-2015, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice;

/** Resolve types to their implementing classes */
abstract class Injector {
  factory Injector([Module module = null]) => new InjectorImpl(module);
  
  factory Injector.fromModules(List<Module> modules) => new InjectorImpl(new _ModuleContainer(modules));
  
  factory Injector.fromInjectors(List<Injector> injectors) {
    var injector = new InjectorImpl();
    injectors.forEach((ijtor) =>
      ijtor.registrations.forEach((typeMirrorWrapper, registration) {
      if(!injector._registrations.containsKey(typeMirrorWrapper)) {
        injector._registrations[typeMirrorWrapper] = registration;
      }
    })
    );
    return injector;
  }
  
  /** register a [type] with [name] (optional) to an implementation */
  Registration register(Type type, [String name]);
  
  /** unregister a [type] and [name] (optional), returns [true] if registration has been removed*/
  bool unregister(Type type, [String name]);

  /** Get new instance of [type] with [name] (optional) and all dependencies resolved */
  dynamic getInstance(Type type, [String name]);
  
  /** Resolve injetions in existing Object (does not create a new instance) */
  Object resolveInjections(Object obj);
  
  /** Get unmodifiable map of registrations */
  Map<TypeMirrorWrapper, Registration> get registrations;
}

/** Implementation of [Injector]. */
class InjectorImpl implements Injector {
  final Map<TypeMirrorWrapper, Registration> _registrations = new Map<TypeMirrorWrapper, Registration>();
  
  InjectorImpl([module = null]) {
    if (module != null) {
      module.configure();
      _registrations.addAll(module._registrations);
    }
  }
  
  @override
  Registration register(Type type, [String name = null]) {
    var registration = new Registration(type);
    var typeMirrorWrapper = new TypeMirrorWrapper.fromType(type, name);
    _registrations[typeMirrorWrapper] = registration;
    return registration;
  }
  
  @override
  bool unregister(Type type, [String name = null]) {
    return _removeRegistrationFor(reflectType(type), name) != null;
  }
  
  bool _hasRegistrationFor(TypeMirror type, String name) => _registrations.containsKey(new TypeMirrorWrapper(type, name));
  
  Registration _getRegistrationFor(TypeMirror type, String name) => _registrations[new TypeMirrorWrapper(type, name)];
  
  Registration _removeRegistrationFor(TypeMirror type, String name) => _registrations.remove(new TypeMirrorWrapper(type, name));
  
  @override
  dynamic getInstance(Type type, [String name = null]) {
    var typeMirror = reflectType(type);
    return _getInstanceFor(typeMirror, name);
  }
  
  @override
  Object resolveInjections(Object obj) {
    var instanceMirror = reflect(obj);
    return _resolveInjections(instanceMirror);
  }
  
  @override
  Map<TypeMirrorWrapper, Registration> get registrations => new UnmodifiableMapView(_registrations);
  
  dynamic _getInstanceFor(TypeMirror tm, [String name = null]) {
    if(!_hasRegistrationFor(tm, name)) {
      throw new ArgumentError("no instance registered for type ${symbolAsString(tm.simpleName)}");
    }
    
    var registration = _getRegistrationFor(tm, name);
    var obj = registration._builder(); 
    InstanceMirror im = (obj is Type) ? _newInstance(reflectClass(obj)) : reflect(obj);
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
    setters.forEach((setter) { 
      var instanceToInject = _getInstanceFor(_firstParameter(setter));
      // set the resolved injection on the instance mirror we are injecting into
      instanceMirror.setField(_methodName(setter), instanceToInject);
    }); 
    return instanceMirror;
  }
  
  InstanceMirror _injectVariables(InstanceMirror instanceMirror) {
    var variables = injectableVariables(instanceMirror.type);
    variables.forEach((variable) {
      var instanceToInject = _getInstanceFor(variable.type, _injectionName(variable));
      // set the resolved injection on the instance mirror we are injecting into
      instanceMirror.setField(variable.simpleName, instanceToInject); 
    });
    return instanceMirror;
  }
  
  /** Returns setters that can be injected */
  Iterable<DeclarationMirror> injectableSetters(ClassMirror classMirror) {
    return injectableDeclarations(classMirror).where(_isSetter);  
  }
  
  /** Returns variables that can be injected */
  Iterable<DeclarationMirror> injectableVariables(ClassMirror classMirror) {
    return injectableDeclarations(classMirror).where(_isVariable);  
  }
  
  /** Returns constructors that can be injected */
  Iterable<DeclarationMirror> injectableConstructors(ClassMirror classMirror) {
    var constructors = injectableDeclarations(classMirror).where(_isConstructor);
    if(constructors.isEmpty) {
      // no excplit injectable constructor exists use the default constructor instead 
      constructors = classMirror.declarations.values.where((DeclarationMirror m) => _isConstructor(m) && (m as MethodMirror).parameters.isEmpty);
      if(constructors.isEmpty) {
        throw new StateError("no injectable constructors exists for ${classMirror}");
      }
    }
    return constructors;
  }
  
  /** Returns injectable instance members such as variables, setters, constructors that need injection */
  Iterable<DeclarationMirror> injectableDeclarations(ClassMirror classMirror) => 
      classMirror.declarations.values.where(_isInjectable);

  /** Returns true if [mirror] is annotated with [Inject] */
  bool _isInjectable(DeclarationMirror mirror) => 
      mirror.metadata.any((InstanceMirror im) => im.reflectee is Inject);
  
  /** Returns true if [declaration] is annotated with [Inject] with a name */
  bool _isNamed(DeclarationMirror declaration) => _namedAnnotationOf(declaration) != null;
  
  /** Returns true if [declaration] is a constructor */
  bool _isConstructor(DeclarationMirror declaration) => declaration is MethodMirror && declaration.isConstructor;
  
  /** Returns true if [declaration] is a variable */
  bool _isVariable(DeclarationMirror declaration) => declaration is VariableMirror;
  
  /** Returns true if [declaration] is a setter */
  bool _isSetter(DeclarationMirror declaration) => declaration is MethodMirror && declaration.isSetter;
  
  /** Returns name of injection or null if it's unamed */
  String _injectionName(DeclarationMirror declaration) {
    var namedMirror = _namedAnnotationOf(declaration);
    if(namedMirror == null) {
      return null;
    }
    return namedMirror.name;
  }
  
  /** Get [Inject] annotation for [declaration]. Returns null is non exists */
  Inject _namedAnnotationOf(DeclarationMirror declaration) {
    var namedMirror = declaration.metadata.firstWhere((InstanceMirror im) => im.reflectee is Inject, orElse: () => null);
    if(namedMirror != null && namedMirror.reflectee.name != null) {
      return (namedMirror.reflectee as Inject);
    }
    return null;
  }
  
  /** Returns method name from [MethodMirror] */
  Symbol _methodName(MethodMirror method) {
    var name = symbolAsString(method.simpleName);
    var symbolName = (name[0] == "_") ? name.substring(1, name.length - 1) : name.substring(0, name.length - 1);
    // TODO fix print("name $name symbol $symbolName");
    return stringAsSymbol(symbolName);
  }
  
  /** Returns [TypeMirror] for first parameter in method */
  TypeMirror _firstParameter(MethodMirror method) => 
      method.parameters[0].type;
  
  /** Returns parameters (including optional) that can be injected */
  Iterable<ParameterMirror> _injectableParameters(MethodMirror method) => 
      // TODO support named parameters
      method.parameters.where((pm) => _hasRegistrationFor(pm.type, null));

}

