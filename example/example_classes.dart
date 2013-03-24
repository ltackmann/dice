// Copyright (c) 2013, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

part of dice_example;

class BillingServiceImpl implements BillingService {
  // fields starting with $ and _$ gets injected
  CreditCardProcessor _$processor;
  
  Receipt chargeOrder(Order order, CreditCard creditCard) {
    if(!(_$processor.validate(creditCard))) {
      throw new ArgumentError("payment method not accepted");
    }
    // :
    print("charge order for ${order.item}");
  }
}

class CreditCardProcessorImpl implements CreditCardProcessor {
  bool validate(CreditCard card) => card.type.toUpperCase() == "VISA";
}

abstract class BillingService {
  Receipt chargeOrder(Order order, CreditCard creditCard);
}

abstract class CreditCardProcessor {
  bool validate(CreditCard creditCard);
}

class CreditCard {
  CreditCard(this.type);
  final String type;
}

class Order { 
  Order(this.item);
  final String item;
}

class Receipt { }

