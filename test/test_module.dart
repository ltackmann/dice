// Copyright (c) 2013 Solvr, Inc. All rights reserved.
//
// This open source software is governed by the license terms 
// specified in the LICENSE file

class RealBillingService implements BillingService {
  @inject
  RealBillingService(this.processor, this.transactionLog);

  @override
  Receipt chargeOrder(Order order, CreditCard creditCard) {
    // ...
  }
  
  final CreditCardProcessor processor;
  final TransactionLog transactionLog;
}

abstract class BillingService {
  Receipt chargeOrder(Order order, CreditCard creditCard);
}

abstract class CreditCard {}
abstract class CreditCardProcessor {}
abstract class Order { }
abstract class Receipt { }
abstract class TransactionLog {}

class TestModule extends Module {
  @override 
  configure() {
    bind(TestFunction).toInstance(_testFunction);
    bind(TestClass).toInstance(new TestClass());
  }
  
  String _testFunction() => "Test Function";
}

class TestClass {
  String get hello => "Test Class";
}

typedef String TestFunction();


