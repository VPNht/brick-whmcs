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
    e.preventDefault();
    $form.find('button').prop('disabled', true);
    
    if ($('#inputCardCVV').val() == "") {
	  $("#payment-errors").html("You must enter a CVV number");
      $("#payment-errors").show();
	  return false;
	}
	    
    brick.tokenizeCard({
      card_number: $('#inputCardNumber').val(),
      card_expiration_month: $('#inputCardExpiry').val(),
      card_expiration_year: $('#inputCardExpiryYear').val(),
      card_cvv: $('#inputCardCVV').val()
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
    <div class="credit-card">
        <div class="card-icon pull-right">
            <b class="fa fa-2x
            {if $cardtype eq "American Express"}
                fa-cc-amex logo-amex
            {elseif $cardtype eq "Visa"}
                fa-cc-visa logo-visa
            {elseif $cardtype eq "MasterCard"}
                fa-cc-mastercard logo-mastercard
            {elseif $cardtype eq "Discover"}
                fa-cc-discover logo-discover
            {else}
                fa-credit-card
            {/if}">&nbsp;</b>
        </div>
        <div class="card-type">
            {if $cardtype neq "American Express" && $cardtype neq "Visa" && $cardtype neq "MasterCard" && $cardtype neq "Discover"}
                {$cardtype}
            {/if}
        </div>
        <div class="card-number">
            {if $cardlastfour}xxxx xxxx xxxx {$cardlastfour}{else}{$LANG.creditcardnonestored}{/if}
        </div>
        <div class="card-start">
            {if $cardstart}Start: {$cardstart}{/if}
        </div>
        <div class="card-expiry">
            {if $cardexp}Expires: {$cardexp}{/if}
        </div>
        <div class="end"></div>
    </div>

    {if $allowcustomerdelete && $cardtype}
        <form method="post" action="clientarea.php?action=creditcard">
            <input type="hidden" name="remove" value="1" />
            <p class="text-center">
                <button type="submit" class="btn btn-danger">
                    {$LANG.creditcarddelete}
                </button>
            </p>
        </form>
    {/if}

    <h3>{$LANG.creditcardenternewcard}</h3>

    {if $successful}
        {include file="$template/includes/alert.tpl" type="success" msg=$LANG.changessavedsuccessfully textcenter=true}
    {/if}

    {if $errormessage}
        {include file="$template/includes/alert.tpl" type="error" errorshtml=$errormessage}
    {/if}
    
    <div id="payment-errors" class="alert alert-danger" style="display:none;"></div>

    <form class="form-horizontal" id="brick-creditcard-form" role="form" method="post" action="{$smarty.server.PHP_SELF}?action=creditcard&submit=true">
	    <input type="hidden" name="ccupdate" value="1">
        <div class="form-group">
            <label for="inputCardNumber" class="col-sm-4 control-label">{$LANG.creditcardcardnumber}</label>
            <div class="col-sm-6">
                <input type="text" data-brick="card-number" class="form-control newccinfo" id="inputCardNumber" autocomplete="off" />
            </div>
        </div>
        <div class="form-group">
            <label for="inputCardExpiry" class="col-sm-4 control-label">{$LANG.creditcardcardexpires}</label>
            <div class="col-sm-6">
                <select name="ccexpirymonth" id="inputCardExpiry" data-brick="card-expiration-month" class="form-control select-inline">
                    {foreach from=$months item=month}
                    <option{if $ccstartmonth eq $month} selected{/if}>{$month}</option>
                    {/foreach}
                </select>
                <select name="ccexpiryyear" id="inputCardExpiryYear" data-brick="card-expiration-year" class="form-control select-inline">
                    {foreach from=$expiryyears item=year}
                    <option{if $ccstartyear eq $year} selected{/if}>{$year}</option>
                    {/foreach}
                </select>
            </div>
        </div>
        <div class="form-group">
            <label for="inputCardCVV" class="col-sm-4 col-xs-12 control-label">{$LANG.creditcardcvvnumber}</label>
            <div class="col-sm-7">
                <input type="number" class="form-control input-inline input-inline-100" id="inputCardCVV" autocomplete="off" />
                <button type="button" class="btn btn-link" data-toggle="popover" data-content="<img src='{$BASE_PATH_IMG}/ccv.gif' width='210' />">
                    {$LANG.creditcardcvvwhere}
                </button>
            </div>
        </div>
        <div class="form-group">
            <div class="text-center">
                <input class="btn btn-primary" type="submit" value="{$LANG.clientareasavechanges}" />
                <input class="btn btn-default" type="reset" value="{$LANG.cancel}" />
            </div>
        </div>
    </form>
