import Trix from "trix";
require("@rails/actiontext");

Trix.config.textAttributes.sup = { tagName: "sup", inheritable: true };
Trix.config.textAttributes.sub = { tagName: "sub", inheritable: true };


addEventListener("trix-initialize", function(event) {
  let buttonHTML  = '<button type="button" data-trix-attribute="sup" class="trix-button"><sup>SUP</sup></button>';
  buttonHTML += '<button type="button" data-trix-attribute="sub" class="trix-button"><sub>SUB</sub></button>';

  const buttonGroup = event.target.toolbarElement.querySelector(".trix-button-group--text-tools");
  buttonGroup.insertAdjacentHTML("beforeend", buttonHTML)
});
