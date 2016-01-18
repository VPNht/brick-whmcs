<?php
  require_once __DIR__ . '/../../../init.php';
  require_once __DIR__ . '/../../../includes/gatewayfunctions.php';
  require_once __DIR__ . '/../../../includes/invoicefunctions.php';

  $gatewayParams = getGatewayVariables("paymentwallbrick");
  // Die if module is not active.
  if (!$gatewayParams['type']) {
    die("Module Not Activated");
  }
  
  if (!class_exists("Paymentwall_Config")) {
    require_once(dirname(__FILE__) . "/lib/paymentwall.php");
  }

  if ($gatewayParams["test_mode"] == "on") {
    Paymentwall_Config::getInstance()->set(array(
      'api_type' => Paymentwall_Config::API_GOODS,
      'public_key' => $gatewayParams['test_public_key'],
      'private_key' => $gatewayParams['test_private_key']
    ));	
  }
  else {
    Paymentwall_Config::getInstance()->set(array(
      'api_type' => Paymentwall_Config::API_GOODS,
      'public_key' => $gatewayParams['public_key'],
      'private_key' => $gatewayParams['private_key']
    ));		  
  }
  
  $charge_id = $_GET["ref"];
  $invoice_id = $_GET["goodsid"];
  $status = $_GET['type'];
  $charge = new Paymentwall_Charge($_GET["ref"]);
  logTransaction($gatewayParams["name"],$_GET, "PingBack");
  $charge->get();
  if ($status == 201 && $charge->isCaptured()) {
     $invoiceId = checkCbInvoiceID($invoice_id, $gatewayParams['name']);
     checkCbTransID($charge_id);
     logTransaction($gatewayParams["name"],var_export($charge,true), "Charge Approved via PingBack");
     addInvoicePayment($invoiceId, $charge_id, null, null, "paymentwallbrick");
  }
  elseif($status == 202) {
   $invoiceId = checkCbInvoiceID($invoice_id, $gatewayParams['name']);
   checkCbTransID($charge_id);
   logTransaction($gatewayParams["name"],var_export($charge,true), "Charge Declined via PingBack");
   sendMessage( "Credit Card Payment Failed", $invoiceId);
  }
  echo "OK";
  	
?>