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
  elseif($status == 2) {
    if (!function_exists( "ServerTerminateAccount" )) {
	  require ROOTDIR . "/includes/modulefunctions.php";
    }
    if (!function_exists( "closeClient" )) {
      require ROOTDIR . "/includes/clientfunctions.php";
      require ROOTDIR . "/includes/ccfunctions.php";
    }
    $reason = $_GET['reason'];
    if ($reason == 1 || $reason == 2 || $reason == 3) {
	  $invoice_items = select_query("tblinvoiceitems","relid,userid",array("type" => "Hosting", "invoiceid" => $invoice_id));
	  while ($item = mysql_fetch_array($invoice_items)) {
		  echo var_dump($item);
		if (isset($item["relid"]) && $item["relid"] != 0) {
  	      $result = ServerTerminateAccount($item["relid"]);	
	    }
		$userid = $item["userid"];  
	  }
	  closeClient($userid);
    }
    elseif($reason == 9) {
	  $invoice_items = select_query("tblinvoiceitems","relid,userid",array("type" => "Hosting", "invoiceid" => $invoice_id));
	  while ($item = mysql_fetch_array($invoice_items)) {
		$userid = $item["userid"];  
	    ServerTerminateAccount($item["relid"]);
	  }
	  $transid = get_query_val("tblaccounts","id", array("transid" => $charge_id));
	  $result = refundInvoicePayment( $transid, null, false, false, false, null );
    }
  }
  echo "OK";
  
  	
?>