<?php


function paymentwallbrick_config() {
    $configarray = array(
     "FriendlyName" => array("Type" => "System", "Value"=>"Paymentwall Brick"),
     "private_key" => array("FriendlyName" => "Private Key", "Type" => "text", "Size" => "40", ),
     "public_key" => array("FriendlyName" => "Public Key", "Type" => "text", "Size" => "40", ),
     "test_private_key" => array("FriendlyName" => "Test Private Key", "Type" => "text", "Size" => "40", ),
     "test_public_key" => array("FriendlyName" => "Test Public Key", "Type" => "text", "Size" => "40", ),
     "test_mode" => array("FriendlyName" => "Use Test Keys", "Type" => "yesno", ),
    );
	return $configarray;
}

function paymentwallbrick_nolocalcc() {}
	
	
function paymentwallbrick_capture($params) {
  require_once(dirname(__FILE__) . "/paymentwallbrick/lib/paymentwall.php");
  
  if ($params["test_mode"] == "on") {
    Paymentwall_Config::getInstance()->set(array(
      'api_type' => Paymentwall_Config::API_GOODS,
      'public_key' => $params['test_public_key'],
      'private_key' => $params['test_private_key']
    ));	
  }
  else {
    Paymentwall_Config::getInstance()->set(array(
      'api_type' => Paymentwall_Config::API_GOODS,
      'public_key' => $params['public_key'],
      'private_key' => $params['private_key']
    ));		  
  }
  $email = $params['clientdetails']['email'];
  
  $charge = new Paymentwall_Charge();
  
  
  if (isset($_POST['brick_token'])) {
     $charge->create(array(
      'email' => $email,
      'currency' => $params['currency'],
      'capture' => true,
      'amount' => $params['amount'],
      'fingerprint' => $_POST['brick_fingerprint'],  
      'token' => $_POST['brick_token'],
      'description' => "Payment of Invoice #" . $params['invoiceid']
    ));	  
    update_query("tblclients", array("cardtype" => $charge->card->type, "gatewayid" =>$charge->card->token,"cardlastfour" => $charge->card->last4), array("id" => $params['clientdetails']['id']));
  }
  else {
     $charge->create(array(
      'token' => $params['gatewayid'],
      'email' => $email,
      'currency' => $params['currency'],
      'capture' => true,
      'amount' => $params['amount'],
      'description' => "Payment of Invoice #" . $params['invoiceid']
    ));	  
  }
  

  if ($charge->isSuccessful()) {
	  return array('status'=>'success', 'transid'=> $charge->id);
  }
  else {
   $response = $charge->getPublicData();
   $errors = json_decode($response, true);
   return array('status'=>'error', 'rawdata'=> $errors['error']['message']); 
  }
}

function paymentwallbrick_refund($params) {
  require_once(dirname(__FILE__) . "/paymentwallbrick/lib/paymentwall.php");
  if ($params["test_mode"] == "on") {
    Paymentwall_Config::getInstance()->set(array(
      'api_type' => Paymentwall_Config::API_GOODS,
      'public_key' => $params['test_public_key'],
      'private_key' => $params['test_private_key']
    ));	
  }
  else {
    Paymentwall_Config::getInstance()->set(array(
      'api_type' => Paymentwall_Config::API_GOODS,
      'public_key' => $params['public_key'],
      'private_key' => $params['private_key']
    ));		  
  }
  
  $charge = new Paymentwall_Charge($params['transid']);
  $charge->get();
  if ($charge->amount != $params["amount"]) {
    return array('status'=>'error', 'rawdata'=> "Only full refunds are supported"); 
  }
  $charge->refund();
  if ($charge->isRefunded()) {
    return array('status'=>'success', 'transid'=> $charge->id);
  }
  else {
    $response = $charge->getPublicData();
    $errors = json_decode($response, true);
  	return array('status'=>'error', 'rawdata'=> $errors['error']['message']); 
  }
}

function paymentwallbrick_storeremote($params) {
  $email = $params['clientdetails']['email'];

  global $CONFIG;
  $systemurl = ($CONFIG['SystemSSLURL']) ? $CONFIG['SystemSSLURL'].'/' : $CONFIG['SystemURL'].'/';

  
  require_once(dirname(__FILE__) . "/paymentwallbrick/lib/paymentwall.php");
  
  if ($params["test_mode"] == "on") {
    Paymentwall_Config::getInstance()->set(array(
      'api_type' => Paymentwall_Config::API_GOODS,
      'public_key' => $params['test_public_key'],
      'private_key' => $params['test_private_key']
    ));	
  }
  else {
    Paymentwall_Config::getInstance()->set(array(
      'api_type' => Paymentwall_Config::API_GOODS,
      'public_key' => $params['public_key'],
      'private_key' => $params['private_key']
    ));		  
  }
  
  if ($params["action"] == "delete") {
	  return array('status'=>'success');
  }
  if (isset($_POST['brick_token'])) {
	if (isset($_POST['ccupdate'])) {
	  $charge = new Paymentwall_Charge();
      $charge->create(array(
        'fingerprint' => $_POST['brick_fingerprint'],  
        'token' => $_POST['brick_token'],
        'email' => $email,
        'capture' => false,
        'currency' => $params['currency'],
        'amount' => 1,
        'description' => 'Card Update - This charge will be automatically voided'
      ));
      if ($charge->isSuccessful()) {
        $gatewayid = $charge->card->token;
        $_SESSION['paymentwall_card'] = $charge->card;
        $charge->void();
        return array('status'=>'success', 'gatewayid'=> $gatewayid);
      }
      else {
  	    $response = $charge->getPublicData();
        $errors = json_decode($response, true);
  	    return array('status'=>'error', 'rawdata'=> $errors['error']['message']); 
      }
	}
	else {
      return array('status'=>'success', 'gatewayid'=> "brickjs");
    }
  }
  elseif(isset($params['cardnum'])) {
    $tokenModel = new Paymentwall_OneTimeToken();
    $token =  $tokenModel->create(array(
      'public_key' => Paymentwall_Config::getInstance()->getPublicKey(),
      'card[number]' => $params['cardnum'],
      'card[exp_month]' =>  substr($params['cardexp'], 0, 2),
      'card[exp_year]' =>  substr($params['cardexp'], 2, 2),
      'card[cvv]' => $params['cardcvv']
    ));
    
    $charge = new Paymentwall_Charge();
    $charge->create(array(
      'token' => $token->getToken(),
      'email' => $email,
      'capture' => false,
      'currency' => $params['currency'],
      'amount' => 1,
      'browser_ip' => $_SERVER['REMOTE_ADDR'],
      'browser_domain' => $_SERVER['HTTP_HOST'],
      'description' => 'Card Update - This charge will be automatically voided'
    ));
    if ($charge->isSuccessful()) {
      $gatewayid = $charge->card->token;
      $charge->void();
      return array('status'=>'success', 'gatewayid'=> $gatewayid);
    }
    else {
  	  $response = $charge->getPublicData();
      $errors = json_decode($response, true);
  	  return array('status'=>'error', 'rawdata'=> $errors['error']['message']); 
    }
  }
}

?>