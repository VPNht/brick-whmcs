<?php

 function paywall_api_key($vars) {
   if ($vars["clientareaaction"] == "creditcard" || $vars["filename"] == "creditcard") {
	 if (get_query_val("tblpaymentgateways","value",array("gateway" => "paymentwallbrick","setting" => "test_mode")) == "on") {
       return array("brick_public_key" => get_query_val("tblpaymentgateways","value",array("gateway" => "paymentwallbrick","setting" => "test_public_key")));
     }
     else {
	   return array("brick_public_key" => get_query_val("tblpaymentgateways","value",array("gateway" => "paymentwallbrick","setting" => "public_key")));
     }
   }
 } 
 function paywall_update_stored_cc_details($vars) {
   $card = $_SESSION['paymentwall_card'];
   update_query("tblclients", array("cardtype" => $card->type, "gatewayid" =>$card->token,"cardlastfour" => $card->last4), array("id" => $vars['userid']));
   unset($_SESSION['paymentwall_card']);
 }
 
 add_hook("ClientAreaPage",1,"paywall_api_key");
 add_hook("CCUpdate",1,"paywall_update_stored_cc_details");
?>