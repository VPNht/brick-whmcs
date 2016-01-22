<script src="https://api.paymentwall.com/brick/brick.1.4.js"> </script>
<script>
  // using jQuery
  
  $(document).ready(function() {
  var $form = $('#brick-creditcard-form');
  var brick = new Brick({
    public_key: '{$brick_public_key}',
    form: { formatter: true }
  }, 'custom');

  $form.submit(function(e) {
	  
	if ($("input[name=ccinfo]:checked").val() == "useexisting") {
	  $('#brick-creditcard-form').append('<input type="hidden" name="cccvv" value="111"/>');
	  return true;
	}
    e.preventDefault();
    $form.find('button').prop('disabled', true);
    
    if ($('#inputCardCvv').val() == "") {
	  $("#payment-errors").html("You must enter a CVV number");
      $("#payment-errors").show();
	  return false;
	}
	    
    brick.tokenizeCard({
      card_number: $('#inputCardNumber').val(),
      card_expiration_month: $('#inputCardExpiry').val(),
      card_expiration_year: $('#inputCardExpiryYear').val(),
      card_cvv: $('#inputCardCvv').val()
    }, function(response) {
      if (response.type == 'Error') {
        // handle errors
        $("#payment-errors").html(response.error);
        $("#payment-errors").show();
      } else {
        $form.append('<input type="hidden" name="ccnumber" value="4242424242424242"/>');
        $form.append('<input type="hidden" name="cccvv" value="111"/>');
        $form.append($('<input type="hidden" name="brick_token"/>').val(response.token));
        $form.append($('<input type="hidden" name="brick_fingerprint"/>').val(Brick.getFingerprint()));
        $form.get(0).submit();
      }
    });

    return false;
  });
  
  });
</script>
{if $paymentwall_pendingreview}
  {if $paymentwall_errors}
      <div class="alert alert-danger">{$paymentwall_errors}</div>
  {/if}
{else}  
    <form method="post" action="creditcard.php" class="form-horizontal" role="form" id="brick-creditcard-form">
        <input type="hidden" name="action" value="submit" />
        <input type="hidden" name="invoiceid" value="{$invoiceid}" />

        <div class="row">
            <div class="col-md-7">

                {if $errormessage}
                    {include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}
                {/if}
                
                {if $paymentwall_errors}
                  <div class="alert alert-danger">{$paymentwall_errors}</div>
                {/if}

                <div id="payment-errors" class="alert alert-danger" style="display:none;"></div>
                <div class="form-group">
                    <div class="col-sm-8 col-sm-offset-4">
                        <div class="radio">
                            <label>
                                <input type="radio" name="ccinfo" value="new" onclick="showNewCardInputFields()"{if $ccinfo eq "new" || !$cardOnFile} checked{/if} /> {$LANG.creditcardenternewcard}</label>
                            </label>
                        </div>
                        <div class="radio">
                            <label>
                                <input type="radio" name="ccinfo" value="useexisting" onclick="hideNewCardInputFields()" {if $cardOnFile && $ccinfo neq "new"}checked{elseif !$cardOnFile}disabled{/if} /> {$LANG.creditcarduseexisting}{if $cardOnFile} ({$existingCardType}-{$existingCardLastFour}){/if}
                            </label>
                        </div>
                    </div>
                </div>
                <div class="form-group{if $userDetailsValidationError} hidden{/if}" id="billingAddressSummary">
                    <label for="cctype" class="col-sm-4 control-label">Billing Address</label>
                    <div class="col-sm-6">
                        {if $clientsdetails.companyname}{$clientsdetails.companyname}{else}{$firstname} {$lastname}{/if} <button type="button" id="btnEditBillingAddress" onclick="editBillingAddress()" class="btn btn-default btn-sm"{if $cardOnFile} disabled="disabled"{/if}><i class="fa fa-edit"></i> Change</button><br />
                        {$clientsdetails.address1}{if $clientsdetails.address2}, {$clientsdetails.address2}{/if}<br />
                        {$clientsdetails.city}, {$clientsdetails.state}, {$clientsdetails.postcode}<br />
                        {$clientsdetails.countryname}
                    </div>
                </div>
                <div class="form-group cc-billing-address{if !$userDetailsValidationError} hidden{/if}">
                    <label for="inputFirstName" class="col-sm-4 control-label">{$LANG.clientareafirstname}</label>
                    <div class="col-sm-6">
                        <input type="text" name="firstname" id="inputFirstName" value="{$firstname}" class="form-control" />
                    </div>
                </div>
                <div class="form-group cc-billing-address{if !$userDetailsValidationError} hidden{/if}">
                    <label for="inputLastName" class="col-sm-4 control-label">{$LANG.clientarealastname}</label>
                    <div class="col-sm-6">
                        <input type="text" name="lastname" id="inputLastName" value="{$lastname}" class="form-control" />
                    </div>
                </div>
                <div class="form-group cc-billing-address{if !$userDetailsValidationError} hidden{/if}">
                    <label for="inputAddress1" class="col-sm-4 control-label">{$LANG.clientareaaddress1}</label>
                    <div class="col-sm-6">
                        <input type="text" name="address1" id="inputAddress1" value="{$address1}" class="form-control" />
                    </div>
                </div>
                <div class="form-group cc-billing-address{if !$userDetailsValidationError} hidden{/if}">
                    <label for="inputAddress2" class="col-sm-4 control-label">{$LANG.clientareaaddress2}</label>
                    <div class="col-sm-6">
                        <input type="text" name="address2" id="inputAddress2" value="{$address2}" class="form-control" />
                    </div>
                </div>
                <div class="form-group cc-billing-address{if !$userDetailsValidationError} hidden{/if}">
                    <label for="inputCity" class="col-sm-4 control-label">{$LANG.clientareacity}</label>
                    <div class="col-sm-6">
                        <input type="text" name="city" id="inputCity" value="{$city}" class="form-control" />
                    </div>
                </div>
                <div class="form-group cc-billing-address{if !$userDetailsValidationError} hidden{/if}">
                    <label for="inputState" class="col-sm-4 control-label">{$LANG.clientareastate}</label>
                    <div class="col-sm-6">
                        <input type="text" name="state" id="inputState" value="{$state}" class="form-control" />
                    </div>
                </div>
                <div class="form-group cc-billing-address{if !$userDetailsValidationError} hidden{/if}">
                    <label for="inputPostcode" class="col-sm-4 control-label">{$LANG.clientareapostcode}</label>
                    <div class="col-sm-6">
                        <input type="text" name="postcode" id="inputPostcode" value="{$postcode}" class="form-control" />
                    </div>
                </div>
                <div class="form-group cc-billing-address{if !$userDetailsValidationError} hidden{/if}">
                    <label for="inputCountry" class="col-sm-4 control-label">{$LANG.clientareacountry}</label>
                    <div class="col-sm-6">
                        {$countriesdropdown}
                    </div>
                </div>
                <div class="form-group cc-billing-address{if !$userDetailsValidationError} hidden{/if}">
                    <label for="inputPhone" class="col-sm-4 control-label">{$LANG.clientareaphonenumber}</label>
                    <div class="col-sm-6">
                        <input type="text" name="phonenumber" id="inputPhone" value="{$phonenumber}" class="form-control" />
                    </div>
                </div>
                <div class="form-group cc-details{if !$addingNewCard} hidden{/if}">
                    <label for="inputCardNumber" class="col-sm-4 control-label">{$LANG.creditcardcardnumber}</label>
                    <div class="col-sm-7">
                        <input type="text" data-brick="card-number" id="inputCardNumber" size="30" autocomplete="off" class="form-control newccinfo" />
                    </div>
                </div>
                <div class="form-group cc-details{if !$addingNewCard} hidden{/if}">
                    <label for="inputCardExpiry" class="col-sm-4 control-label">{$LANG.creditcardcardexpires}</label>
                    <div class="col-sm-8">
                        <select name="ccexpirymonth" data-brick="card-expiration-month" id="inputCardExpiry" class="form-control select-inline">
                            {foreach from=$months item=month}
                                <option{if $ccexpirymonth eq $month} selected{/if}>{$month}</option>
                            {/foreach}
                        </select>
                        <select name="ccexpiryyear" data-brick="card-expiration-year" id="inputCardExpiryYear" class="form-control select-inline">
                            {foreach from=$expiryyears item=year}
                                <option{if $ccexpiryyear eq $year} selected{/if}>{$year}</option>
                            {/foreach}
                        </select>
                    </div>
                </div>
                <div class="form-group cc-details{if !$addingNewCard} hidden{/if}">
                    <label for="cctype" class="col-sm-4 control-label">{$LANG.creditcardcvvnumber}</label>
                    <div class="col-sm-7">
                        <input type="number" id="inputCardCvv" autocomplete="off" class="form-control input-inline input-inline-100" />
                        <button type="button" class="btn btn-link" data-toggle="popover" data-content="<img src='{$BASE_PATH_IMG}/ccv.gif' width='210' />">
                            {$LANG.creditcardcvvwhere}
                        </button>
                    </div>
                </div>

                <div class="form-group">
                    <div class="text-center">
                        <input type="submit" class="btn btn-primary btn-lg" value="{$LANG.submitpayment}" id="btnSubmit" />
                    </div>
                </div>

            </div>
            <div class="col-md-5">

                <div id="invoiceIdSummary" class="invoice-summary">
                    <h2 class="text-center">{$LANG.invoicenumber}{$invoiceid}</h2>
                    <div class="invoice-summary-table">
                    <table class="table table-condensed">
                        <tr>
                            <td class="text-center"><strong>{$LANG.invoicesdescription}</strong></td>
                            <td width="150" class="text-center"><strong>{$LANG.invoicesamount}</strong></td>
                        </tr>
                        {foreach $invoiceitems as $item}
                            <tr>
                                <td>{$item.description}</td>
                                <td class="text-center">{$item.amount}</td>
                            </tr>
                        {/foreach}
                        <tr>
                            <td class="total-row text-right">{$LANG.invoicessubtotal}</td>
                            <td class="total-row text-center">{$invoice.subtotal}</td>
                        </tr>
                        {if $invoice.taxrate}
                            <tr>
                                <td class="total-row text-right">{$invoice.taxrate}% {$invoice.taxname}</td>
                                <td class="total-row text-center">{$invoice.tax}</td>
                            </tr>
                        {/if}
                        {if $invoice.taxrate2}
                            <tr>
                                <td class="total-row text-right">{$invoice.taxrate2}% {$invoice.taxname2}</td>
                                <td class="total-row text-center">{$invoice.tax2}</td>
                            </tr>
                        {/if}
                        <tr>
                            <td class="total-row text-right">{$LANG.invoicescredit}</td>
                            <td class="total-row text-center">{$invoice.credit}</td>
                        </tr>
                        <tr>
                            <td class="total-row text-right">{$LANG.invoicestotaldue}</td>
                            <td class="total-row text-center">{$invoice.total}</td>
                        </tr>
                    </table>
                    </div>
                    <p class="text-center">
                        {$LANG.paymentstodate}: <strong>{$invoice.amountpaid}</strong><br />
                        {$LANG.balancedue}: <strong>{$balance}</strong>
                    </p>
                </div>

            </div>
        </div>

        <div class="alert alert-warning" role="alert">
            <i class="fa fa-lock"></i> &nbsp; {$LANG.creditcardsecuritynotice}
        </div>

    </form>
 {/if}
