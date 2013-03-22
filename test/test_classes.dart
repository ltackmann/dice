// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice_test;

class BillingServiceImpl implements BillingService {
  @inject
  BillingServiceImpl(this.processor);

  @override
  Receipt chargeOrder(Order order, CreditCard creditCard) {
    // ...
  }
  
  final CreditCardProcessor processor;
}

abstract class BillingService {
  Receipt chargeOrder(Order order, CreditCard creditCard);
}

abstract class CreditCard {}
abstract class CreditCardProcessor {}
abstract class Order { }
abstract class Receipt { }

