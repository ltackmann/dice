// Copyright (c) 2013-2015, the project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed 
// by a Apache license that can be found in the LICENSE file.

library dice_example;

import "../lib/d17.dart";

part "example_classes.dart";

main() {
  var injector = new Injector(new ExampleModule());
  var billingService = injector.getInstance(BillingService);
  var creditCard = new CreditCard("VISA");
  var order = new Order("Dart: Up and Running");
  billingService.chargeOrder(order, creditCard);
}

class ExampleModule extends Module {
  configure() {
    // bind CreditCardProcessor to a singleton
    register(CreditProcessor).toInstance(new CreditProcessorImpl());
    // bind BillingService to a type
    register(BillingService).toType(BillingServiceImpl);
  }
}

