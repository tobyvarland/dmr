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