// Copyright (c) 2017, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed
// by a Apache license that can be found in the LICENSE file.

part of dice;

/// Helper for finding the right annotation
class _Annotation {
    final String name;
    final Type type;

    factory _Annotation.fromMirror(final InjectorImpl injector, final VariableMirror variable) {

        // typed-Annotation has priority - if we have one ignore a named-Annotation
        final InstanceMirror typedAnnotation = injector._injectionType(variable);
        final Type annotation = typedAnnotation != null ? typedAnnotation.reflectee.runtimeType : null;

        // Only if we have no typed-Annotation
        final String name = typedAnnotation == null ? injector._injectionName(variable) : null;

        return new _Annotation._private(name, annotation);
    }

    _Annotation._private(this.name, this.type);
}

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
    Registration register(Type type, { final String named = null, final Type annotatedWith: null });

    /// Compatibility with di:package
    /// see [register]
    Registration bind(Type type,  { final String named = null, final Type annotatedWith: null })
        => register(type,named: named, annotatedWith: annotatedWith);

    /// unregister a [type] and [named] (optional), returns [true] if registration has been removed
    bool unregister(Type type, { final String named: null, final Type annotatedWith: null });

    /// Get new instance of [type] with [named] (optional) and all dependencies resolved
    dynamic getInstance(Type type, { final String named: null, final Type annotatedWith: null });

    dynamic getMultiInstance(Type type, { final String named: null, final Type annotatedWith: null });

    /// Compatibility with di:package
    /// see [getInstance]
    dynamic get(Type type, { final String named: null, final Type annotatedWith: null })
        => getInstance(type,named: named, annotatedWith: annotatedWith);

    /// Resolve injections in existing Object (does not create a new instance)
    Object resolveInjections(Object obj);

    /// Get unmodifiable map of registrations
    Map<TypeMirrorWrapper, Registration> get registrations;

    Injector._private();
}

/// Implementation of [Injector].
class InjectorImpl extends Injector {
    final Logger _logger = new Logger('dice.InjectorImpl');

    final Map<TypeMirrorWrapper, Registration> _registrations = new Map<TypeMirrorWrapper, Registration>();

    InjectorImpl([module = null]) : super._private() {
        if (module != null) {
            module.configure();
            _registrations.addAll(module._registrations);
        }
    }

    @override
    Registration register(Type type, { final String named: null, final Type annotatedWith: null }) {
        _validate(annotatedWith == null && named == null ? isInjectable(type) : true,
            _ASSERT_REGISTER_TYPE_NOT_MARKED(type));

        _validate(annotatedWith != null ? isInjectable(annotatedWith) : true,
            _ASSERT_REGISTER_ANNOTATION_NOT_MARKED(type,annotatedWith));

        var registration = new Registration(type);
        var typeMirrorWrapper = new TypeMirrorWrapper.fromType(type, named, annotatedWith);
        _registrations[typeMirrorWrapper] = registration;

        return registration;
    }

    @override
    bool unregister(Type type, { final String named: null, final Type annotatedWith: null }) {
        
        return _removeRegistrationFor(reflectType(type), named, annotatedWith != null
            ? reflectType(type) : null) != null;
    }

    bool _hasRegistrationFor(TypeMirror type, String name, TypeMirror annotation) =>
        _registrations.containsKey(new TypeMirrorWrapper(type, name, annotation));

    Registration _getRegistrationFor(TypeMirror type, String name, TypeMirror annotation) =>
        _registrations[new TypeMirrorWrapper(type, name, annotation)];

    Registration _removeRegistrationFor(TypeMirror type, String name, TypeMirror annotation) {
        final Registration registration = _registrations.remove(new TypeMirrorWrapper(type, name, annotation));

        // Remove reference to our instance if there is one
        registration ?._instance = null;
        return registration;
    }

    @override
    dynamic getInstance(Type type, { final String named: null, final Type annotatedWith: null }) {
        _validate(annotatedWith == null && named == null ? isInjectable(type) : true,
            _ASSERT_GET_TYPE_NOT_MARKED(type));

        _validate(annotatedWith != null ? isInjectable(annotatedWith) : true,
            _ASSERT_GET_ANNOTATION_NOT_MARKED(type,annotatedWith));

        var typeMirror = reflectType(type);
        return _getInstanceFor(typeMirror, named, annotatedWith);
    }

    dynamic getMultiInstance(Type type, { final String named: null, final Type annotatedWith: null }){
        _validate(annotatedWith == null && named == null ? isInjectable(type) : true,
            _ASSERT_GET_TYPE_NOT_MARKED(type));

        _validate(annotatedWith != null ? isInjectable(annotatedWith) : true,
            _ASSERT_GET_ANNOTATION_NOT_MARKED(type,annotatedWith));

        var typeMirror = reflectType(List,[type]);
        return _getInstanceFor(typeMirror, named, annotatedWith);
    }


    @override
    Object resolveInjections(Object obj) {
        var instanceMirror = reflect(obj);
        return _resolveInjections(instanceMirror);
    }

    @override
    Map<TypeMirrorWrapper, Registration> get registrations => new UnmodifiableMapView(_registrations);

    dynamic _getInstanceFor(TypeMirror tm, [ final String named = null, final Type annotatedWith = null ]) {
        final annotationTypeMirror = annotatedWith != null ? reflectType(annotatedWith) : null;
        if (!_hasRegistrationFor(tm, named, annotationTypeMirror)) {
            throw new ArgumentError(
                "no instance registered for type ${symbolAsString(tm.simpleName)}, "
                    "named: $named, "
                    "annotatedWith: $annotatedWith");
        }

        final registration = _getRegistrationFor(tm, named, annotationTypeMirror);

        // Check if we want a singleton
        if (registration._asSingleton && registration._instance != null) {
            // If we have one - return it
            return registration._instance;
        }
        var instance;
        if(registration is RegistrationMulti) {
            RegistrationMulti reg = registration as RegistrationMulti;
            instance = reg._registrations.map((r){
                final obj = r._builder();

                InstanceMirror im = (obj is Type)
                    ? _newInstance(reflectClass(obj))
                    : reflect(obj);
                return _resolveInjections(im);
            }).toList(growable: false);
        } else {
            final obj = registration._builder();

            InstanceMirror im = (obj is Type)
                ? _newInstance(reflectClass(obj))
                : reflect(obj);
            instance = _resolveInjections(im);
        }
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
    InstanceMirror _newInstance(final ClassMirror classMirror) {
        // Look for an injectable constructor
        var constructors = injectableConstructors(classMirror).toList();

        // that has the greatest number of parameters to inject, optional included
        MethodMirror constructor = constructors.fold(null,
                (MethodMirror previous, MethodMirror element) =>
                    previous == null
                        || _injectableParameters(previous).length < _injectableParameters(element).length
                            ? element : previous);

        final positionalArguments = constructor.parameters
            .where((final ParameterMirror param) => !param.hasDefaultValue && !param.isOptional)
                .map((final ParameterMirror param) {
                    final _Annotation _annotation = new _Annotation.fromMirror(this, param);
                    return _getInstanceFor(param.type, _annotation.name, _annotation.type);
        }).toList();

        final namedArguments = new Map<Symbol, dynamic>();
        constructor.parameters
            .where((final ParameterMirror param) => param.hasDefaultValue && !param.isOptional)
                .forEach((final ParameterMirror param)
                    => namedArguments[param.simpleName] = param.defaultValue.reflectee);

        return classMirror.newInstance(constructor.constructorName, positionalArguments, namedArguments);
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
            final _Annotation _annotation = new _Annotation.fromMirror(this, variable);

            final instanceToInject = _getInstanceFor(variable.type, _annotation.name, _annotation.type);

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

    /// Returns parameters (including optional) that can be injected
    Iterable<ParameterMirror> _injectableParameters(final MethodMirror method) {
        return method.parameters.where((final ParameterMirror pm) {
            return _hasRegistrationFor(pm.type, null, null);
        });
    }

}
