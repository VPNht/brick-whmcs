<?php

 function paywall_api_key($vars) {
   if ($vars["clientareaaction"] == "creditcard" || $vars["filename"] == "creditcard") {
	 $error_message =  $_SESSION['paymentwall_errors'];
	 $pending_review = $_SESSION['paywall_pending_review'];
	 unset($_SESSION['paymentwall_errors']);  
	 unset($_SESSION['paywall_pending_review']);
	 if (get_query_val("tblpaymentgateways","value",array("gateway" => "paymentwallbrick","setting" => "test_mode")) == "on") {
       return array("paymentwall_pendingreview" => $pending_review, "paymentwall_errors" =>$error_message , "brick_public_key" => get_query_val("tblpaymentgateways","value",array("gateway" => "paymentwallbrick","setting" => "test_public_key")));
     }
     else {
	   return array("paymentwall_pendingreview" => $pending_review, "paymentwall_errors" => $error_message,"brick_public_key" => get_query_val("tblpaymentgateways","value",array("gateway" => "paymentwallbrick","setting" => "public_key")));
     }
   }
 } 
 
 function paywall_update_stored_cc_details($vars) {
   $card = $_SESSION['paymentwall_card'];
   update_query("tblclients", array("cardtype" => $card->type, "gatewayid" =>$card->token,"cardlastfour" => $card->last4), array("id" => $vars['userid']));
   unset($_SESSION['paymentwall_card']);
 }
 
 
 function paywall_prevent_failure_message($vars){
  if (isset($_SESSION['paywall_pending_review'])) {
	  return array("abortsend" => true);
  }	 
 }
 
 add_hook("EmailPreSend",1,"paywall_prevent_failure_message");
 add_hook("ClientAreaPage",1,"paywall_api_key");
 add_hook("CCUpdate",1,"paywall_update_stored_cc_details");
?>