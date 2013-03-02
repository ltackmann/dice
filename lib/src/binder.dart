// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

part of dice;

/**
 * Collects configuration information (primarily bindings) which will be used to create an [Injector].
 */
class Binder {
  // TODO support more bindings as need arrises https://code.google.com/p/google-guice/wiki/Bindings
  toInstance(var instance) {
    _instance = instance;
  }
  
  var _instance;
}

