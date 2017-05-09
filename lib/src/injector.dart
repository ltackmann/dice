// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of dice;

/// Resolve types to their implementing classes
abstract class Injector {
    factory Injector([Module module = null]) => new InjectorImpl(module);

    factory Injector.fromModules(List<Module> modules) => new InjectorImpl(new _ModuleContainer(modules));

    factory Injector.fromInjectors(List<Injector> injectors) {
        var injector = new InjectorImpl();
        injectors.forEach((ijtor) =>
            ijtor.registrations.forEach((typeMirrorWrapper, registration) {
                if (!injector._registrations.containsKey(typeMirrorWrapper)) {
                    injector._registrations[typeMirrorWrapper] = registration;
                }
            })
        );
        return injector;
    }

    /// register a [type] with [named] (optional) to an implementation
    Registration register(Type type, { final String named = null, final Type annotatedWidth: null });

    // Compatibility with di:package
    //Registration bind(Type type, [String name]) => register(type,name);

    /** unregister a [type] and [named] (optional), returns [true] if registration has been removed*/
    bool unregister(Type type, { final String named: null, final Type annotatedWidth: null });

    /** Get new instance of [type] with [named] (optional) and all dependencies resolved */
    dynamic getInstance(Type type, { final String named: null, final Type annotatedWidth: null });

    /** Resolve injections in existing Object (does not create a new instance) */
    Object resolveInjections(Object obj);

    /** Get unmodifiable map of registrations */
    Map<TypeMirrorWrapper, Registration> get registrations;
}

/** Implementation of [Injector]. */
class InjectorImpl implements Injector {
    final Logger _logger = new Logger('dice.InjectorImpl');

    final Map<TypeMirrorWrapper, Registration> _registrations = new Map<TypeMirrorWrapper, Registration>();

    InjectorImpl([module = null]) {
        if (module != null) {
            module.configure();
            _registrations.addAll(module._registrations);
        }
    }

    @override
    Registration register(Type type, { final String named: null, final Type annotatedWidth: null }) {
        var registration = new Registration(type);
        var typeMirrorWrapper = new TypeMirrorWrapper.fromType(type, named, annotatedWidth);
        _registrations[typeMirrorWrapper] = registration;
        return registration;
    }

    @override
    bool unregister(Type type, { final String named: null, final Type annotatedWidth: null }) {
        return _removeRegistrationFor(reflectType(type), named, annotatedWidth != null ? reflectType(type) : null) !=
            null;
    }

    bool _hasRegistrationFor(TypeMirror type, String name, TypeMirror annotation) =>
        _registrations.containsKey(new TypeMirrorWrapper(type, name, annotation));

    Registration _getRegistrationFor(TypeMirror type, String name, TypeMirror annotation) =>
        _registrations[new TypeMirrorWrapper(type, name, annotation)];

    Registration _removeRegistrationFor(TypeMirror type, String name, TypeMirror annotation) {
        final Registration registration = _registrations.remove(new TypeMirrorWrapper(type, name, annotation));

        // Remove reference to our instance if there is one
        registration._instance = null;
        return registration;
    }

    @override
    dynamic getInstance(Type type, { final String named: null, final Type annotatedWidth: null }) {
        var typeMirror = reflectType(type);
        return _getInstanceFor(typeMirror, named, annotatedWidth);
    }

    @override
    Object resolveInjections(Object obj) {
        var instanceMirror = reflect(obj);
        return _resolveInjections(instanceMirror);
    }

    @override
    Map<TypeMirrorWrapper, Registration> get registrations => new UnmodifiableMapView(_registrations);

    dynamic _getInstanceFor(TypeMirror tm, [ final String named = null, final Type annotatedWidth = null ]) {
        final annotationTypeMirror = annotatedWidth != null ? reflectType(annotatedWidth) : null;
        if (!_hasRegistrationFor(tm, named, annotationTypeMirror)) {
            throw new ArgumentError(
                "no instance registered for type ${symbolAsString(tm.simpleName)}, "
                    "named: $named, "
                    "annotatedWith: $annotatedWidth");
        }

        var registration = _getRegistrationFor(tm, named, annotationTypeMirror);

        // Check if we want a singleton
        if (registration._asSingleton && registration._instance != null) {
            // If we have one - return it
            return registration._instance;
        }

        var obj = registration._builder();

        InstanceMirror im = (obj is Type) ? _newInstance(reflectClass(obj)) : reflect(obj);
        final instance = _resolveInjections(im);

        if (registration._asSingleton) {
            // Remember the instance
            registration._instance = instance;
        }
        return instance;
    }

    dynamic _resolveInjections(InstanceMirror im) {
        im = _injectSetters(im);
        im = _injectVariables(im);
        return im.reflectee;
    }

    /// create a new instance of classMirror and inject it
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
            // typed-Annotation has priority - if we have one ignore a named-Annotation
            final InstanceMirror typedAnnotation = _injectionType(variable);
            final Type type = typedAnnotation != null ? typedAnnotation.reflectee.runtimeType : null;

            // Only if we have no typed-Annotation
            final String namedAnnotation = typedAnnotation == null ? _injectionName(variable) : null;

            final instanceToInject = _getInstanceFor(variable.type, namedAnnotation, type);

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
        if (constructors.isEmpty) {
            // no explict injectable constructor exists use the default constructor instead
            constructors = classMirror.declarations.values.where((DeclarationMirror m) =>
            _isConstructor(m) &&
                (m as MethodMirror).parameters.isEmpty);
            if (constructors.isEmpty) {
                throw new StateError("no injectable constructors exists for ${classMirror}");
            }
        }
        return constructors;
    }

    /** Returns injectable instance members such as variables, setters, constructors that need injection */
    Iterable<DeclarationMirror> injectableDeclarations(ClassMirror classMirror) =>
        classMirror.declarations.values.where(_isInjectable);

    /** Returns true if [mirror] is annotated with [Inject] */
    bool _isInjectable(DeclarationMirror mirror) {
        return mirror.metadata.any((final InstanceMirror im) {
            return im.reflectee is Inject;
        });
    }

    /** Returns true if [declaration] is a constructor */
    bool _isConstructor(DeclarationMirror declaration) => declaration is MethodMirror && declaration.isConstructor;

    /** Returns true if [declaration] is a variable */
    bool _isVariable(DeclarationMirror declaration) => declaration is VariableMirror;

    /** Returns true if [declaration] is a setter */
    bool _isSetter(DeclarationMirror declaration) => declaration is MethodMirror && declaration.isSetter;

    /** Returns name of injection or null if it's unamed */
    String _injectionName(DeclarationMirror declaration) {
        var namedMirror = _namedAnnotationOf(declaration);
        if (namedMirror == null) {
            return null;
        }
        return namedMirror.name;
    }

    /// Returns the first annotation after @inject or null if it's unannotated
    InstanceMirror _injectionType(final DeclarationMirror declaration) {
        return declaration.metadata.firstWhere((final InstanceMirror im) {
            //print("T ${im.reflectee}");
            return (im.reflectee is! Inject &&
                im.reflectee is! Named &&
                im.reflectee is! Injectable);
        }, orElse: () => null);
    }

    /** Get [Named] annotation for [declaration]. Returns null is non exists */
    Named _namedAnnotationOf(DeclarationMirror declaration) {
        var namedMirror = declaration.metadata.firstWhere((InstanceMirror im) => im.reflectee is Named,
            orElse: () => null);
        if (namedMirror != null) {
            return (namedMirror.reflectee as Named);
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
    method.parameters.where((pm) => _hasRegistrationFor(pm.type, null, null));

}
