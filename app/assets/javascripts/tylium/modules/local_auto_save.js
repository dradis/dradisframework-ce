document.addEventListener("turbolinks:load", function() {
  document.querySelectorAll("[data-behavior~=local-auto-save]").forEach(function(form) {
    var key  = form.dataset.autoSaveKey;
    var data = "";

    if (typeof Storage !== "undefined" && Storage !== null) {
      data = JSON.parse(localStorage.getItem(key))
    } else {
      console.log("The browser doesn't support local storage of settings.")
    }

    if (data !== null) {
      for (let [key, value] of Object.entries(data)) {
        if (key.slice(-2) == "[]") {
          value.forEach(function(checkboxValue) {
            var $input = $(form).find(`[name="${key}"][value="${checkboxValue}"]`)
            $input.prop("checked", true)
          })
        } else {
          var $input = $(form).find(`[name="${key}"]`)
          $input.val(value)
          $input.trigger("load-preview")
        }
      }
    } else {
      console.log("No data in localStorage for " + key);
    }

    // List of available inputs: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input
    // Exclude these inputs so that it does not store unnecessary data in local cache
    var excludedInputTypes = ["button", "file", "image", "password", "reset", "submit"]

    // Don't store authenticity_token and utf8
    var excludedHiddenInputNames = ["utf8", "authenticity_token"]

    // Find all inputs and textareas of form, then exclude base on excluded input types
    var formInputs = Array.from(form.querySelectorAll("input, textarea, select")).filter(function(input) {
      return !excludedInputTypes.includes(input.getAttribute("type")) && !excludedHiddenInputNames.includes(input.name)
    })

    var timer;

    formInputs.forEach(function(input) {
      // we're using a jQuery plugin for :textchange event, so need to use $()

      $(input).on("textchange change", function(event, previousText) {
        timer = setTimeout(function(){
          if (typeof Storage !== "undefined" && Storage !== null) {
            localStorage.setItem(key, JSON.stringify(getData(formInputs)));
          } else {
            console.log("The browser doesn't support local storage of settings.");
          }
        }, 1000);
      })
    })

    function getData(formInputs) {
      var reducer = function(hash, input) {
        // Check if name is an array, i.e. checkboxes
        if (input.name.slice(-2) == "[]") {
          var a = hash[input.name] = Array.from(form.querySelectorAll(`[name="${input.name}"]:checked`)).map(function(input) {
            return input.value
          });
        } else {
          hash[input.name] = input.value;

        }
        return hash
      }

      return formInputs.reduce(reducer, {})
    }

    form.addEventListener("submit", function(event) {
      if (typeof Storage !== "undefined" && Storage !== null) {
        localStorage.removeItem(key);
      }
    });

    document.querySelectorAll("[data-behavior~=clear-local-auto-save]").forEach(function(element) {
      element.addEventListener("click", function(event) {
        if (typeof Storage !== "undefined" && Storage !== null) {
          localStorage.removeItem(key);
        }
      })
    });
  });
});