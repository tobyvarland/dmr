// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "jquery"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

import * as bootstrap from 'bootstrap'
import "../stylesheets/application"
import "../stylesheets/varland"
import "@fortawesome/fontawesome-free/js/all"

document.addEventListener("DOMContentLoaded", function(event) {

  var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
  popoverTriggerList.map(function (popoverTriggerEl) {
    return new bootstrap.Popover(popoverTriggerEl)
  });

  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
  tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
  });

  // Handle customer selection on monthly report.
  $(document).on("show.bs.tab", function(event) {

    // Reference button just clicked and button previously clicked.
    var $currentButton = $(event.target);
    var $previousButton = $(event.relatedTarget);

    // If not a customer selection button, exit handler.
    if (!$currentButton.hasClass("customer-selector")) return;

    // Reference DMR list for each button.
    var $currentDMRList = $($currentButton.data("bs-target"));
    var $previousDMRList = $($previousButton.data("bs-target"));

    // Hide all DMRs from previous customer.
    $previousDMRList.find('.nav-link').each(function() {
      $(this).removeClass("active");
      var $target = $($(this).data("bs-target"));
      $target.removeClass("show").removeClass("active");
    });

    // Show first DMR for current customer.
    $currentDMRList.find('.nav-link').first().trigger("click");
    
  });

  // Count applied filters for filter form.
  $(".filter-form").each(function() {
    var $form = $(this);
    var $toggler = $('#' + $form.attr('id') + '-toggler');
    var countApplied = 0;
    $(this).find('.countable-filter').each(function() {
      if ($(this).val()) {
        countApplied += 1;
      }
    });
    if (countApplied > 0) {
      $form.addClass('show');
      $toggler.html('<i class="fas fa-fw fa-chevron-down"></i> Filters');
    }
  });
  $(".filter-form").on("show.bs.collapse", function() {
    var $form = $(this);
    var $toggler = $('#' + $form.attr('id') + '-toggler');
    $toggler.html('<i class="fas fa-fw fa-chevron-down"></i> Filters');
  });
  $(".filter-form").on("hide.bs.collapse", function() {
    var $form = $(this);
    var $toggler = $('#' + $form.attr('id') + '-toggler');
    $toggler.html('<i class="fas fa-fw fa-chevron-right"></i> Filters');
  });
  
})